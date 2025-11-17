#Requires AutoHotkey v2.0
#SingleInstance Force
#Include json_parser.ahk

; ==========================================
; xh1px's Tidy Bank - OSRS Bank Sorter Bot
; Version: 1.0.0
; ==========================================

; Configuration from template variables
cfg := Map(
    "AntiBan", "Psychopath",
    "VoiceAlerts", false,
    "WorldHop", false,
    "SortMode", "GEValue",
    "MaxSession", 240,
    "UseOCR", false,
    "StealthMode", true
)

; ADB configuration
adb := "adb -s 127.0.0.1:5555"
screenshot := A_Temp "\tidybank_screenshot.png"
running := false
sessionStart := A_TickCount
db := Map()
itemHashes := Map()

; ==========================================
; CORE FUNCTIONS
; ==========================================

; Validate ADB connection and BlueStacks
ValidateEnvironment() {
    global adb

    ; Check if BlueStacks window exists
    if !WinExist("BlueStacks") {
        MsgBox("BlueStacks is not running!`n`nPlease start BlueStacks and try again.", "xh1px's Tidy Bank - Error", 16)
        return false
    }

    ; Test ADB connection
    try {
        RunWait(adb " shell echo test", , "Hide")
        Log("ADB connection validated successfully")
        return true
    } catch as err {
        MsgBox("ADB connection failed!`n`nError: " . err.Message . "`n`nPlease ensure ADB is running at 127.0.0.1:5555", "xh1px's Tidy Bank - Error", 16)
        return false
    }
}

Speak(t) {
    if (cfg["VoiceAlerts"]) {
        try {
            ComObject("SAPI.SpVoice").Speak(t, 0)
        }
    }
}

; Hotkeys
F1::ToggleBot()
F2::PanicAbort()
Esc::ExitApp()

ToggleBot() {
    global running
    running := !running
    if (running) {
        ; Validate environment before starting
        if (!ValidateEnvironment()) {
            running := false
            return
        }

        Speak("xh1px's Tidy Bank activated")

        ; Check if database loaded successfully
        if (!PreloadCache()) {
            running := false
            Speak("Failed to load item database")
            return
        }

        SetTimer(BankSortLoop, 800)
    } else {
        Speak("Bot deactivated")
        SetTimer(BankSortLoop, 0)
    }
}

PanicAbort() { 
    Speak("Emergency shutdown")
    try {
        Run(adb " shell input keyevent 4")
        Sleep(1000)
        Run(adb " shell input keyevent 82")
        Sleep(3000)
        Run("adb reboot", , "Hide")
    }
    ExitApp()
}

BankSortLoop() { 
    try {
        WinActivate("BlueStacks")
    }
    
    AntiBan()
    
    if (!IsBankOpen()) { 
        OpenBank()
        return
    }
    
    ScreenshotBank()
    items := ScanBank()
    
    if (items.Length > 0) {
        sorted := SortItems(items, cfg["SortMode"])
        Rearrange(sorted)
        Speak("Sorted " items.Length " items")
        Log("Sorted " items.Length " items")
    }
    
    if FileExist(screenshot) {
        FileDelete(screenshot)
    }
}

; ==========================================
; DATABASE FUNCTIONS
; ==========================================

PreloadCache() {
    global db, itemHashes

    dbPath := A_ScriptDir "\osrs-items-condensed.json"
    if !FileExist(dbPath) {
        MsgBox("Database file not found: " dbPath, "xh1px's Tidy Bank - Error", 16)
        Log("ERROR: Database file not found: " . dbPath)
        return false
    }

    try {
        raw := FileRead(dbPath)
        data := JSON.Parse(raw)

        if (!data || !data.Count) {
            throw Error("Database is empty or invalid")
        }

        for itemId, item in data {
            db[Integer(itemId)] := Map(
                "name", item["name"],
                "ge", item.Has("current") && item["current"].Has("price") ? item["current"]["price"] : 0
            )
        }

        Log("xh1px's Tidy Bank: Loaded " . db.Count . " items from database")
        return true
    } catch as err {
        MsgBox("Error loading database: " . err.Message, "xh1px's Tidy Bank - Error", 16)
        Log("ERROR: Failed to load database: " . err.Message)
        return false
    }
}

; ==========================================
; SCREENSHOT & SCANNING
; ==========================================

ScreenshotBank() { 
    try {
        RunWait(adb " shell screencap -p /sdcard/bank.png", , "Hide")
        RunWait(adb ' pull /sdcard/bank.png "' screenshot '"', , "Hide")
    } catch as err {
        Log("Screenshot error: " err.Message)
    }
}

ScanBank() {
    items := []

    if !FileExist(screenshot) {
        return items
    }

    ; ============================================
    ; IMPORTANT: PLACEHOLDER IMPLEMENTATION
    ; ============================================
    ; This function currently generates RANDOM item IDs for testing.
    ;
    ; PRODUCTION IMPLEMENTATION REQUIRES:
    ; 1. OCR text recognition (Tesseract) to read item names
    ; 2. Image template matching to identify items by icon
    ; 3. Hash-based item identification using itemHashes Map
    ; 4. Confidence scoring for detection accuracy
    ;
    ; STEPS TO IMPLEMENT:
    ; A) Install Tesseract OCR
    ; B) Create item icon template database
    ; C) Implement image processing in each grid cell
    ; D) Match detected text/image to item database
    ; E) Return actual item IDs with confidence scores
    ;
    ; CURRENT BEHAVIOR: Returns random items for testing
    ; ============================================

    ; Scan 8x8 grid of bank slots
    Loop 8 {
        row := A_Index - 1
        rowY := row * 60 + 150

        Loop 8 {
            col := A_Index - 1
            colX := col * 60 + 50

            ; PLACEHOLDER: Random item generation for testing
            ; TODO: Replace with actual OCR/image detection
            id := Random(1, 100) > 50 ? Random(1, 1000) : 0

            if (id > 0) {
                items.Push(Map(
                    "id", id,
                    "x", colX + 21,
                    "y", rowY + 21,
                    "slot", row * 8 + col
                ))
            }
        }
    }

    return items
}

; ==========================================
; SORTING & REARRANGING
; ==========================================

SortItems(items, mode) { 
    for item in items {
        if db.Has(item["id"]) {
            switch mode {
                case "GEValue":
                    item["value"] := db[item["id"]]["ge"]
                case "Alphabet":
                    item["value"] := db[item["id"]]["name"]
                case "ItemID":
                    item["value"] := item["id"]
                default:
                    item["value"] := item["id"]
            }
        } else {
            item["value"] := 0
        }
    }
    
    return items
}

Rearrange(items) { 
    startX := 71
    startY := 171
    spacing := 60
    col := 0
    row := 0
    
    for item in items {
        targetX := startX + (col * spacing)
        targetY := startY + (row * spacing)
        
        UI_Drag(item["x"], item["y"], targetX, targetY)
        
        col++
        if (col >= 8) {
            col := 0
            row++
        }
    }
}

UI_Drag(sx, sy, ex, ey) {
    if (cfg["StealthMode"]) {
        try {
            Run(adb " shell input swipe " Round(sx) " " Round(sy) " " Round(ex) " " Round(ey) " 150", , "Hide")
        }
        return
    }
    
    ; Human-like movement simulation
    steps := 15
    Loop steps { 
        progress := A_Index / steps
        x := Round((1 - progress) * sx + progress * ex + Random(-2, 2))
        y := Round((1 - progress) * sy + progress * ey + Random(-2, 2))
        
        try {
            Run(adb " shell input tap " x " " y, , "Hide")
        }
        Sleep(10)
    }
    
    try {
        Run(adb " shell input swipe " Round(sx) " " Round(sy) " " Round(ex) " " Round(ey) " 150", , "Hide")
    }
}

; ==========================================
; ANTI-BAN SYSTEM
; ==========================================

AntiBan() {
    if (cfg["StealthMode"] || cfg["AntiBan"] = "Off") {
        return
    }
    
    r := Random(1, 100)
    
    switch cfg["AntiBan"] {
        case "Psychopath":
            if (r < 2 && ElapsedHours() > 2) {
                Sleep(Random(180000, 360000))
            }
        case "Extreme":
            if (r < 5 && ElapsedHours() > 1.5) {
                Sleep(Random(180000, 360000))
            }
        case "Stealth":
            if (r < 1 && ElapsedHours() > 3) {
                Sleep(Random(300000, 600000))
            }
    }
    
    ; Check session time limit
    if (ElapsedHours() >= cfg["MaxSession"] / 60) {
        Speak("Session time limit reached")
        Log("Session ended: Time limit reached")
        ExitApp()
    }
}

; ==========================================
; UTILITY FUNCTIONS
; ==========================================

IsBankOpen() {
    ; IMPROVED: Basic detection with screenshot validation
    ; TODO: Full implementation should include:
    ; - OCR text detection for "Bank of" title
    ; - Pixel color checking for bank interface elements
    ; - Template matching for bank icon

    global screenshot

    if !FileExist(screenshot) {
        return false
    }

    ; Check if screenshot is recent (created in last 5 seconds)
    ; This is a basic sanity check - full implementation needs actual image analysis
    try {
        fileTime := FileGetTime(screenshot, "M")
        currentTime := A_Now

        ; Calculate time difference in seconds
        timeDiff := DateDiff(currentTime, fileTime, "S")

        ; If screenshot is recent, assume bank might be open
        ; In production, this should be replaced with actual image detection
        return (timeDiff < 5)
    } catch {
        return false
    }
}

OpenBank() {
    Speak("Opening bank")
    try {
        Run(adb " shell input tap 960 540", , "Hide")
    }
    Sleep(2000)
}

ElapsedHours() { 
    return Round((A_TickCount - sessionStart) / 3600000, 1)
}

Log(message) { 
    logDir := A_ScriptDir "\logs"
    if !DirExist(logDir) {
        DirCreate(logDir)
    }
    
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logFile := logDir "\tidybank_log.txt"
    
    try {
        FileAppend(timestamp " | " message "`n", logFile)
    }
}

; Initialize
Log("xh1px's Tidy Bank v1.0 started")
Speak("xh1px's Tidy Bank ready. Press F1 to start, F2 for emergency stop, Escape to exit.")
