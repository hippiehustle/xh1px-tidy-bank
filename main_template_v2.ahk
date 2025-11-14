#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; xh1px's Tidy Bank - OSRS Bank Sorter Bot v2.0
; With Item Grouping System & Conflict Resolution
; ==========================================

; Include modules
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
    global bankCategories

    ; Load item grouping database
    if !ItemGroupingSystem.LoadDatabase() {
        MsgBox("Failed to load item database!`n`nPlease ensure osrs-items-condensed.json is present.", "xh1px's Tidy Bank - Error", 16)
        ExitApp()
    }

    ; Initialize conflict resolver with user's bank tab configuration
    BankTabResolver.Initialize(bankCategories)

    Log("xh1px's Tidy Bank v2.0 initialized successfully")
    Log("Item database loaded: " . ItemGroupingSystem.GetDatabaseStats()["totalItems"] . " items")
    Log("Bank tab resolver initialized with " . bankCategories.Count . " configured tabs")
}

; ==========================================
; CORE FUNCTIONS
; ==========================================

Speak(t) {
    if cfg["VoiceAlerts"] {
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
    }

    AntiBan()

    if !IsBankOpen() {
        OpenBank()
        return
    }

    ScreenshotBank()
    items := ScanBank()

    if items.Length > 0 {
        ; Sort items by bank tab using the grouping system
        SortIntoTabs(items)
        Speak("Sorted " . items.Length . " items")
        Log("Sorted " . items.Length . " items into bank tabs")
    }

    if FileExist(screenshot) {
        FileDelete(screenshot)
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
    Sleep(300)

    ; Calculate starting position for this tab
    startX := 71
    startY := 171
    spacing := 60

    ; Move each item to its position in the tab
    col := 0
    row := 0

    for item in items {
        targetX := startX + (col * spacing)
        targetY := startY + (row * spacing)

        ; Drag item from current position to target position
        UI_Drag(item["x"], item["y"], targetX, targetY)

        col++
        if col >= 8 {
            col := 0
            row++
        }

        ; Safety check: don't overfill tab
        if row >= 8 {
            Log("Warning: Tab " . tabNum . " full, cannot add more items")
            break
        }
    }
}

SwitchBankTab(tabNum) {
    ; Bank tabs are at the top of the bank interface
    ; Tab positions (approximate): Tab 1 = 150px, Tab 2 = 210px, etc.
    tabBaseX := 150
    tabSpacing := 60
    tabY := 80

    tabX := tabBaseX + ((tabNum - 1) * tabSpacing)

    try {
        Run(adb " shell input tap " . tabX . " " . tabY, , "Hide")
    } catch as err {
        Log("Error switching to tab " . tabNum . ": " . err.Message)
    }
}

UI_Drag(sx, sy, ex, ey) {
    if cfg["StealthMode"] {
        try {
            Run(adb " shell input swipe " . Round(sx) . " " . Round(sy) . " " . Round(ex) . " " . Round(ey) . " 150", , "Hide")
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
            Run(adb " shell input tap " . x . " " . y, , "Hide")
        }
        Sleep(10)
    }

    try {
        Run(adb " shell input swipe " . Round(sx) . " " . Round(sy) . " " . Round(ex) . " " . Round(ey) . " 150", , "Hide")
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

Log(message) {
    logDir := A_ScriptDir "\logs"
    if !DirExist(logDir) {
        DirCreate(logDir)
    }

    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logFile := logDir "\tidybank_log.txt"

    try {
        FileAppend(timestamp " | " . message . "`n", logFile)
    }
}

; ==========================================
; START BOT
; ==========================================

; Initialize systems
InitializeBot()

Log("xh1px's Tidy Bank v2.0 started")
Speak("xh1px's Tidy Bank ready. Press F1 to start, F2 for emergency stop, Escape to exit.")
