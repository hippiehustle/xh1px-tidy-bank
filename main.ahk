#Requires AutoHotkey v2.0
#SingleInstance Force
#Include json_parser.ahk
#Include constants.ahk

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
adb := ADBConstants.DEVICE_ID
screenshot := FilePathConstants.SCREENSHOT_FILE
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

        SetTimer(BankSortLoop, TimeConstants.LOOP_INTERVAL)
    } else {
        Speak("Bot deactivated")
        SetTimer(BankSortLoop, 0)
    }
}

PanicAbort() {
    global adb

    Speak("Emergency shutdown")
    try {
        Run(adb " shell input keyevent 4")
        Sleep(TimeConstants.EMERGENCY_KEYPRESS_DELAY)
        Run(adb " shell input keyevent 82")
        Sleep(TimeConstants.EMERGENCY_UNLOCK_DELAY)
        Run("adb reboot", , "Hide")
    }
    ExitApp()
}

BankSortLoop() {
    global cfg, screenshot

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

    dbPath := FilePathConstants.DATABASE_FILE
    if !FileExist(dbPath) {
        MsgBox("Database file not found: " . dbPath, "xh1px's Tidy Bank - Error", 16)
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
        Log("Screenshot error: " . err.Message)
    }
}

ScanBank() {
    global screenshot

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
    Loop BankCoordinates.GRID_ROWS {
        row := A_Index - 1
        rowY := BankCoordinates.GRID_START_Y + (row * BankCoordinates.GRID_CELL_SPACING)

        Loop BankCoordinates.GRID_COLS {
            col := A_Index - 1
            colX := BankCoordinates.GRID_START_X + (col * BankCoordinates.GRID_CELL_SPACING)

            ; PLACEHOLDER: Random item generation for testing
            ; TODO: Replace with actual OCR/image detection
            id := Random(1, 100) > 50 ? Random(1, 1000) : 0

            if (id > 0) {
                items.Push(Map(
                    "id", id,
                    "x", colX + BankCoordinates.GRID_CELL_CENTER_OFFSET,
                    "y", rowY + BankCoordinates.GRID_CELL_CENTER_OFFSET,
                    "slot", row * BankCoordinates.GRID_COLS + col
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
    global db, cfg

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
    col := 0
    row := 0

    for item in items {
        targetX := BankCoordinates.GRID_START_X + (col * BankCoordinates.GRID_CELL_SPACING)
        targetY := BankCoordinates.GRID_START_Y + (row * BankCoordinates.GRID_CELL_SPACING)

        UI_Drag(item["x"], item["y"], targetX, targetY)

        col++
        if (col >= BankCoordinates.GRID_COLS) {
            col := 0
            row++
        }
    }
}

UI_Drag(sx, sy, ex, ey) {
    global adb, cfg

    if (cfg["StealthMode"]) {
        try {
            Run(adb " shell input swipe " Round(sx) " " Round(sy) " " Round(ex) " " Round(ey) " " TimeConstants.DRAG_DURATION, , "Hide")
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
        Run(adb " shell input swipe " Round(sx) " " Round(sy) " " Round(ex) " " Round(ey) " " TimeConstants.DRAG_DURATION, , "Hide")
    }
}

; ==========================================
; ANTI-BAN SYSTEM
; ==========================================

AntiBan() {
    global cfg, sessionStart

    if (cfg["StealthMode"] || cfg["AntiBan"] = "Off") {
        return
    }

    r := Random(1, 100)

    switch cfg["AntiBan"] {
        case "Psychopath":
            if (r < TimeConstants.ANTIBAN_PSYCHOPATH_CHANCE && ElapsedHours() > TimeConstants.ANTIBAN_PSYCHOPATH_HOURS) {
                Sleep(TimeConstants.GetAntiBanDelay("Psychopath"))
            }
        case "Extreme":
            if (r < TimeConstants.ANTIBAN_EXTREME_CHANCE && ElapsedHours() > TimeConstants.ANTIBAN_EXTREME_HOURS) {
                Sleep(TimeConstants.GetAntiBanDelay("Extreme"))
            }
        case "Stealth":
            if (r < TimeConstants.ANTIBAN_STEALTH_CHANCE && ElapsedHours() > TimeConstants.ANTIBAN_STEALTH_HOURS) {
                Sleep(TimeConstants.GetAntiBanDelay("Stealth"))
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
    global adb

    Speak("Opening bank")
    try {
        Run(adb " shell input tap " BankCoordinates.SCREEN_CENTER_X " " BankCoordinates.SCREEN_CENTER_Y, , "Hide")
    }
    Sleep(TimeConstants.BANK_OPEN_DELAY)
}

ElapsedHours() {
    global sessionStart

    return Round((A_TickCount - sessionStart) / 3600000, 1)
}

Log(message) {
    ; Ensure log directory exists
    FilePathConstants.EnsureLogDirectory()

    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")

    try {
        FileAppend(timestamp " | " message "`n", FilePathConstants.LOG_FILE)
    }
}

; Initialize
Log("xh1px's Tidy Bank v1.0 started")
Speak("xh1px's Tidy Bank ready. Press F1 to start, F2 for emergency stop, Escape to exit.")
