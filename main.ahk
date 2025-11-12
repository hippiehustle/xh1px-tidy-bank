#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; xh1px's Tidy Bank - OSRS Bank Sorter Bot
; Version: 1.0.0
; ==========================================

; Inline JSON Library
class JSON {
    static Parse(text) {
        text := Trim(text)
        if (SubStr(text, 1, 1) == "{")
            return JSON._ParseObject(text, &pos := 1)
        return ""
    }
    static _ParseObject(text, &pos) {
        obj := Map()
        pos++
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        if (SubStr(text, pos, 1) == "}")
            return obj
        loop {
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            if (SubStr(text, pos, 1) != '"')
                break
            key := JSON._ParseString(text, &pos)
            while (pos <= StrLen(text) && InStr(" `t`r`n:", SubStr(text, pos, 1)))
                pos++
            value := JSON._ParseValue(text, &pos)
            obj[key] := value
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            ch := SubStr(text, pos, 1)
            if (ch == "}")
                return obj
            if (ch == ",") {
                pos++
                continue
            }
            break
        }
        return obj
    }
    static _ParseValue(text, &pos) {
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        ch := SubStr(text, pos, 1)
        if (ch == '"')
            return JSON._ParseString(text, &pos)
        else if (ch == "{")
            return JSON._ParseObject(text, &pos)
        else if (ch == "t") {
            pos += 4
            return true
        }
        else if (ch == "f") {
            pos += 5
            return false
        }
        else if (InStr("0123456789-", ch))
            return JSON._ParseNumber(text, &pos)
        return ""
    }
    static _ParseString(text, &pos) {
        pos++
        start := pos
        while (pos <= StrLen(text)) {
            ch := SubStr(text, pos, 1)
            if (ch == '"') {
                result := SubStr(text, start, pos - start)
                pos++
                return result
            }
            if (ch == "\")
                pos++
            pos++
        }
        return ""
    }
    static _ParseNumber(text, &pos) {
        start := pos
        while (pos <= StrLen(text)) {
            ch := SubStr(text, pos, 1)
            if (!InStr("0123456789.-+", ch))
                break
            pos++
        }
        return Number(SubStr(text, start, pos - start))
    }
}

; Configuration from template variables
cfg := Map(
    "AntiBan", "Psychopath", 
    "VoiceAlerts", "false", 
    "WorldHop", "false", 
    "SortMode", "GEValue", 
    "MaxSession", "240", 
    "UseOCR", "false", 
    "StealthMode", "true"
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

Speak(t) { 
    if (cfg["VoiceAlerts"] = "true") {
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
        Speak("xh1px's Tidy Bank activated")
        PreloadCache()
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
    
    dbPath := A_ScriptDir "\osrsbox-db.json"
    if !FileExist(dbPath) {
        MsgBox("Database file not found: " dbPath, "xh1px's Tidy Bank - Error", 16)
        return
    }
    
    try {
        raw := FileRead(dbPath)
        data := JSON.Parse(raw)
        
        for itemId, item in data {
            db[Integer(itemId)] := Map(
                "name", item["name"],
                "ge", item.Has("current") && item["current"].Has("price") ? item["current"]["price"] : 0
            )
        }
        
        Log("xh1px's Tidy Bank: Loaded " db.Count " items from database")
    } catch as err {
        MsgBox("Error loading database: " err.Message, "xh1px's Tidy Bank - Error", 16)
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
    
    ; Scan 8x8 grid of bank slots
    Loop 8 { 
        row := A_Index - 1
        rowY := row * 60 + 150
        
        Loop 8 { 
            col := A_Index - 1
            colX := col * 60 + 50
            
            ; Placeholder: In production, this would analyze the screenshot
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
    if (cfg["StealthMode"] = "true") {
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
    if (cfg["StealthMode"] = "true" || cfg["AntiBan"] = "Off") {
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
    ; Placeholder: In production would analyze screenshot
    return true
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
