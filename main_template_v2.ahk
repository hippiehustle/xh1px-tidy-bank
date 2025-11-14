#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; xh1px's Tidy Bank - OSRS Bank Sorter Bot v2.0
; With Item Grouping System & Conflict Resolution
; ==========================================

; Include modules
#Include constants.ahk
#Include item_grouping.ahk
#Include bank_tab_resolver.ahk

; {{BANK_CATEGORIES_JSON}}

; Default bank categories configuration
bankCategories := Map(
    1, ["Weapons", "Equipment"],
    2, ["Food", "Potions"],
    3, ["Seeds", "Farming"],
    4, ["Ores", "Bars", "Smithing"],
    5, ["Logs", "Fletching"],
    6, ["Runes", "Magic"],
    7, ["Quest items", "Teleports"],
    8, ["Miscellaneous"]
)

; Configuration from template variables
cfg := Map(
    "AntiBan", "Stealth",
    "VoiceAlerts", true,
    "WorldHop", false,
    "MaxSession", 120,
    "UseOCR", false,
    "StealthMode", false
)

; ADB configuration
adb := "adb -s 127.0.0.1:5555"
screenshot := A_Temp "\tidybank_screenshot.png"
running := false
sessionStart := A_TickCount

; ==========================================
; INITIALIZATION
; ==========================================

; Load item database and initialize systems
InitializeBot() {
    global bankCategories, cfg

    ; Validate configuration
    if !ValidateConfiguration() {
        Log("Critical: Configuration validation failed", LogLevelConstants.ERROR)
        MsgBox("Configuration validation failed! Check logs for details.", "xh1px's Tidy Bank - Error", 16)
        ExitApp()
    }

    ; Load item grouping database
    if !ItemGroupingSystem.LoadDatabase() {
        Log("Critical: Failed to load item database", LogLevelConstants.ERROR)
        MsgBox("Failed to load item database!`n`nPlease ensure osrs-items-condensed.json is present.", "xh1px's Tidy Bank - Error", 16)
        ExitApp()
    }

    ; Initialize conflict resolver with user's bank tab configuration
    BankTabResolver.Initialize(bankCategories)

    Log("xh1px's Tidy Bank v2.0 initialized successfully", LogLevelConstants.INFO)
    Log("Item database loaded: " . ItemGroupingSystem.GetDatabaseStats()["totalItems"] . " items", LogLevelConstants.INFO)
    Log("Bank tab resolver initialized with " . bankCategories.Count . " configured tabs", LogLevelConstants.INFO)
}

; Validate bot configuration
ValidateConfiguration() {
    global cfg

    try {
        ; Check required keys
        requiredKeys := ["AntiBan", "VoiceAlerts", "MaxSession", "StealthMode"]
        for key in requiredKeys {
            if !cfg.Has(key) {
                Log("Config validation: Missing required key '" . key . "'", LogLevelConstants.WARNING)
                return false
            }
        }

        ; Validate AntiBan mode
        if !ValidationConstants.IsValidAntiBanMode(cfg["AntiBan"]) {
            Log("Config validation: Invalid AntiBan mode '" . cfg["AntiBan"] . "'", LogLevelConstants.WARNING)
            return false
        }

        ; Validate MaxSession
        if !ValidationConstants.IsValidMaxSession(cfg["MaxSession"]) {
            Log("Config validation: MaxSession out of range: " . cfg["MaxSession"], LogLevelConstants.WARNING)
            cfg["MaxSession"] := ValidationConstants.DEFAULT_MAX_SESSION
        }

        return true
    } catch as err {
        Log("Config validation error: " . err.Message, LogLevelConstants.ERROR)
        return false
    }
}

; ==========================================
; CORE FUNCTIONS
; ==========================================

Speak(t) {
    if cfg["VoiceAlerts"] {
        try {
            ComObject("SAPI.SpVoice").Speak(t, 0)
        } catch as err {
            Log("Text-to-speech error: " . err.Message)
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
    if running {
        Speak("xh1px's Tidy Bank activated")
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
    } catch as err {
        Log("Window activation error: " . err.Message)
        return
    }

    AntiBan()

    if !IsBankOpen() {
        OpenBank()
        return
    }

    try {
        ScreenshotBank()
        items := ScanBank()

        if items.Length > 0 {
            ; Sort items by bank tab using the grouping system
            SortIntoTabs(items)
            Speak("Sorted " . items.Length . " items")
            Log("Sorted " . items.Length . " items into bank tabs")
        }
    } finally {
        ; Clean up screenshot even if error occurs
        if FileExist(screenshot) {
            try {
                FileDelete(screenshot)
            } catch as err {
                Log("Screenshot cleanup error: " . err.Message)
            }
        }
    }
}

; ==========================================
; SCREENSHOT & SCANNING
; ==========================================

ScreenshotBank() {
    try {
        ; Verify ADB connection is available
        if !FileExist(screenshot) {
            ; Initial check - file shouldn't exist yet
        }

        RunWait(adb " shell screencap -p /sdcard/bank.png", , "Hide")
        RunWait(adb ' pull /sdcard/bank.png "' screenshot '"', , "Hide")

        ; Verify screenshot was actually created
        if !FileExist(screenshot) {
            Log("Warning: Screenshot file not created")
        }
    } catch as err {
        Log("Screenshot error: " . err.Message)
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

            ; In production, this would use OCR/image recognition
            ; For now, simulate with database lookup
            itemData := DetectItemAtPosition(colX, rowY)

            if itemData {
                items.Push(Map(
                    "itemData", itemData,
                    "x", colX + 21,
                    "y", rowY + 21,
                    "slot", row * 8 + col
                ))
            }
        }
    }

    return items
}

DetectItemAtPosition(x, y) {
    ; Placeholder for actual OCR/image recognition
    ; In production, this would analyze the screenshot at (x, y)
    ; and identify the item using ItemGroupingSystem

    ; For testing, return random items
    if Random(1, 100) > 50 {
        testItems := ["Shark", "Raw shark", "Abyssal whip", "Rune scimitar", "Ranarr seed", "Lobster", "Coins"]
        randomItem := testItems[Random(1, testItems.Length)]
        return ItemGroupingSystem.GetItemByName(randomItem)
    }

    return ""
}

; ==========================================
; BANK TAB SORTING WITH CONFLICT RESOLUTION
; ==========================================

SortIntoTabs(items) {
    ; Group items by their resolved bank tab
    tabGroups := Map()

    ; Initialize tab groups (1-8)
    Loop 8 {
        tabGroups[A_Index] := []
    }

    ; Resolve each item to its destination tab
    for item in items {
        itemData := item["itemData"]
        resolvedTab := BankTabResolver.ResolveItemTab(itemData)

        if resolvedTab > 0 && resolvedTab <= 8 {
            item["destinationTab"] := resolvedTab
            tabGroups[resolvedTab].Push(item)
        } else {
            ; Unassigned items go to last tab by default
            item["destinationTab"] := 8
            tabGroups[8].Push(item)
        }
    }

    ; Move items to their destination tabs
    for tabNum, tabItems in tabGroups {
        if tabItems.Length > 0 {
            MoveItemsToTab(tabItems, tabNum)
        }
    }
}

MoveItemsToTab(items, tabNum) {
    ; First, switch to the destination tab
    SwitchBankTab(tabNum)
    SafeSleep(TimeConstants.TAB_SWITCH_DELAY)

    ; Get grid starting position from constants
    startX := BankCoordinates.GRID_START_X
    startY := BankCoordinates.GRID_START_Y
    spacing := BankCoordinates.GRID_CELL_SPACING
    maxCols := BankCoordinates.GRID_COLS
    maxRows := BankCoordinates.GRID_ROWS

    ; Move each item to its position in the tab
    col := 0
    row := 0

    for item in items {
        targetX := startX + (col * spacing) + BankCoordinates.GRID_CELL_CENTER_OFFSET
        targetY := startY + (row * spacing) + BankCoordinates.GRID_CELL_CENTER_OFFSET

        ; Drag item from current position to target position
        UI_Drag(item["x"], item["y"], targetX, targetY)

        col++
        if col >= maxCols {
            col := 0
            row++
        }

        ; Safety check: don't overfill tab
        if row >= maxRows {
            Log("Warning: Tab " . tabNum . " full, cannot add more items")
            break
        }
    }
}

SwitchBankTab(tabNum) {
    ; Validate tab number
    if !ValidationConstants.IsValidTabNumber(tabNum) {
        Log("Error: Invalid tab number " . tabNum . " (valid: 1-8)")
        return false
    }

    try {
        tabCoords := BankCoordinates.GetTabCoordinates(tabNum)
        tabX := tabCoords["x"]
        tabY := tabCoords["y"]

        Run(adb " shell input tap " . tabX . " " . tabY, , "Hide")
        return true
    } catch as err {
        Log("Error switching to tab " . tabNum . ": " . err.Message)
        return false
    }
}

UI_Drag(sx, sy, ex, ey) {
    if cfg["StealthMode"] {
        try {
            Run(adb " shell input swipe " . Round(sx) . " " . Round(sy) . " " . Round(ex) . " " . Round(ey) . " 150", , "Hide")
        } catch as err {
            Log("Stealth drag error: " . err.Message)
        }
        return
    }

    ; Human-like movement simulation
    steps := 15
    try {
        Loop steps {
            progress := A_Index / steps
            x := Round((1 - progress) * sx + progress * ex + Random(-2, 2))
            y := Round((1 - progress) * sy + progress * ey + Random(-2, 2))

            try {
                Run(adb " shell input tap " . x . " " . y, , "Hide")
            } catch as err {
                Log("Tap error at step " . A_Index . ": " . err.Message)
            }
            Sleep(10)
        }

        ; Final swipe
        Run(adb " shell input swipe " . Round(sx) . " " . Round(sy) . " " . Round(ex) . " " . Round(ey) . " 150", , "Hide")
    } catch as err {
        Log("UI_Drag error: " . err.Message)
    }
}

; ==========================================
; ANTI-BAN SYSTEM
; ==========================================

AntiBan() {
    if cfg["StealthMode"] || cfg["AntiBan"] == "Off" {
        return
    }

    r := Random(1, 100)

    switch cfg["AntiBan"] {
        case "Psychopath":
            if r < 2 && ElapsedHours() > 2 {
                Sleep(Random(180000, 360000))
            }
        case "Extreme":
            if r < 5 && ElapsedHours() > 1.5 {
                Sleep(Random(180000, 360000))
            }
        case "Stealth":
            if r < 1 && ElapsedHours() > 3 {
                Sleep(Random(300000, 600000))
            }
    }

    ; Check session time limit
    if ElapsedHours() >= cfg["MaxSession"] / 60 {
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

Log(message, level := LogLevelConstants.INFO) {
    ; Ensure log directory exists
    if !SafeDirCreate(FilePathConstants.LOG_DIR) {
        ; If we can't create the log directory, at least try to output to console
        OutputDebug(GetTimestamp() . " [" . level . "] " . message)
        return
    }

    timestamp := GetTimestamp()
    logFile := FilePathConstants.LOG_FILE

    try {
        ; Format: YYYY-MM-DD HH:MM:SS [LEVEL] Message
        logEntry := timestamp . " [" . level . "] " . message . "`n"
        FileAppend(logEntry, logFile)
    } catch as err {
        ; Fallback if file append fails
        OutputDebug(logEntry . " (Error: " . err.Message . ")")
    }
}

; ==========================================
; START BOT
; ==========================================

; Initialize systems
InitializeBot()

Log("xh1px's Tidy Bank v2.0 started")
Speak("xh1px's Tidy Bank ready. Press F1 to start, F2 for emergency stop, Escape to exit.")
