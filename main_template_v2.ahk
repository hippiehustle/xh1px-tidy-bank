#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; xh1px's Tidy Bank - OSRS Bank Sorter Bot v2.0
; With Item Grouping System & Conflict Resolution
; ==========================================

; Include modules
#Include constants.ahk
#Include performance.ahk
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

; ==========================================
; FUNCTION: InitializeBot
; ==========================================
; PURPOSE: Perform complete bot initialization on startup
; CALLED: Once at application startup (line 608)
;
; OPERATIONS:
;   1. Initialize performance monitoring system
;   2. Validate configuration (calls ValidateConfiguration)
;   3. Load OSRS item database from JSON file
;   4. Initialize bank tab resolver with user configuration
;   5. Log initialization metrics and database statistics
;
; ERROR HANDLING:
;   - If config validation fails: Log error and exit
;   - If item database fails to load: Log error, show MsgBox, and exit
;   - Any uncaught error is caught and rethrown after logging
;
; DEPENDENCIES:
;   - PerformanceMonitor (performance.ahk)
;   - ValidateConfiguration() function
;   - ItemGroupingSystem (item_grouping.ahk)
;   - BankTabResolver (must be defined)
;   - FilePathConstants.DATABASE_FILE for item data
;
; RETURN VALUE: None (void)
; SIDE EFFECTS: Modifies global bankCategories, cfg, initializes systems
;
InitializeBot() {
    global bankCategories, cfg

    ; Initialize performance monitoring
    PerformanceMonitor.Initialize()
    initTracker := CreateTrackedOperation("bot_initialization")

    try {
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

        ; Record initialization metrics
        initDuration := initTracker.Complete(true)

        Log("xh1px's Tidy Bank v2.0 initialized successfully (took " . initDuration . "ms)", LogLevelConstants.INFO)
        Log("Item database loaded: " . ItemGroupingSystem.GetDatabaseStats()["totalItems"] . " items", LogLevelConstants.INFO)
        Log("Bank tab resolver initialized with " . bankCategories.Count . " configured tabs", LogLevelConstants.INFO)
    } catch as err {
        initTracker.Complete(false)
        Log("Initialization error: " . err.Message, LogLevelConstants.ERROR)
        throw err
    }
}

; ==========================================
; FUNCTION: ValidateConfiguration
; ==========================================
; PURPOSE: Validate loaded configuration values against constraints
; CALLED: During InitializeBot initialization
;
; VALIDATIONS PERFORMED:
;   1. Check all required keys exist in config
;   2. Validate AntiBan mode is in ANTIBAN_MODES list
;   3. Validate MaxSession is within MIN/MAX range
;   4. Validate StealthMode boolean value
;
; REQUIRED CONFIG KEYS:
;   - AntiBan: Must be one of ["Psychopath", "Extreme", "Stealth", "Off"]
;   - VoiceAlerts: Must be boolean
;   - MaxSession: Must be 30-1440 (minutes)
;   - StealthMode: Must be boolean
;
; DEPENDENCIES:
;   - ValidationConstants (constants.ahk)
;   - cfg global variable
;
; RETURN VALUE:
;   Boolean: true if all validations pass, false if any validation fails
;
; SIDE EFFECTS:
;   - Logs warnings for each validation failure
;   - Returns false on first failure (early exit)
;
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

; ==========================================
; FUNCTION: Speak
; ==========================================
; PURPOSE: Provide voice alerts to user using Text-to-Speech
; PARAMETERS:
;   t (String): Text message to speak aloud
;
; BEHAVIOR:
;   - Only speaks if cfg["VoiceAlerts"] is true
;   - Uses Windows SAPI.SpVoice for text-to-speech
;   - Catches any TTS errors and logs them without stopping bot
;
; DEPENDENCIES:
;   - cfg global variable
;   - Log() function
;   - Windows SAPI COM object
;
; RETURN VALUE: None (void)
; SIDE EFFECTS: Produces audio output if VoiceAlerts enabled
;
Speak(t) {
    if cfg["VoiceAlerts"] {
        try {
            ComObject("SAPI.SpVoice").Speak(t, 0)
        } catch as err {
            Log("Text-to-speech error: " . err.Message)
        }
    }
}

; ==========================================
; HOTKEY DEFINITIONS
; ==========================================
; F1 - Toggle bot start/stop
; F2 - Emergency stop (panic abort)
; Esc - Exit application completely
;
F1::ToggleBot()
F2::PanicAbort()
Esc::ExitApp()

; ==========================================
; FUNCTION: ToggleBot
; ==========================================
; PURPOSE: Toggle bot execution between running and paused states
; HOTKEY: F1
;
; BEHAVIOR:
;   - Flips running global variable
;   - Logs state change
;   - Provides voice feedback if enabled
;
; DEPENDENCIES:
;   - running global variable
;   - cfg global variable
;   - Speak() function
;   - Log() function
;
; RETURN VALUE: None (void)
; SIDE EFFECTS: Modifies running state, produces log entry and optional audio
;
ToggleBot() {
    global running, cfg
    running := !running
    if running {
        Speak("xh1px's Tidy Bank activated")
        SetTimer(BankSortLoop, TimeConstants.LOOP_INTERVAL)
        Log("Bot activated", LogLevelConstants.INFO)
    } else {
        Speak("Bot deactivated")
        SetTimer(BankSortLoop, 0)
        Log("Bot deactivated", LogLevelConstants.INFO)
    }
}

; ==========================================
; FUNCTION: PanicAbort
; ==========================================
; PURPOSE: Emergency stop - immediately halt bot and clean up game state
; HOTKEY: F2
;
; OPERATIONS:
;   1. Speak "Emergency shutdown" alert
;   2. Log emergency abort event
;   3. Send Android keyevent 4 (Back button) to close any open dialogs
;   4. Sleep 1 second for dialog to close
;   5. Send Android keyevent 82 (Menu button) to return to main game state
;   6. Sleep 3 seconds for game to stabilize
;   7. Reboot Android device via ADB
;   8. Exit application completely
;
; ERROR HANDLING:
;   - All ADB commands wrapped in try-catch
;   - Continues to ExitApp() even if ADB commands fail
;
; DEPENDENCIES:
;   - adb global variable
;   - Speak() function
;   - Log() function
;
; RETURN VALUE: None (void) - Function always exits application
; SIDE EFFECTS:
;   - Reboots the Android emulator/device
;   - Exits the bot application
;   - Produces warning log entry
;
; IMPORTANT: This function is the safety shutdown mechanism
; Use when: Bot is stuck, performing unwanted actions, or needs immediate stop
;
PanicAbort() {
    global adb
    Speak("Emergency shutdown")
    Log("Emergency abort triggered", LogLevelConstants.WARNING)
    try {
        Run(adb " shell input keyevent 4")
        Sleep(1000)
        Run(adb " shell input keyevent 82")
        Sleep(3000)
        Run("adb reboot", , "Hide")
    } catch as err {
        Log("Error during emergency abort: " . err.Message, LogLevelConstants.ERROR)
    }
    ExitApp()
}

; ==========================================
; FUNCTION: BankSortLoop
; ==========================================
; PURPOSE: Main loop - executed repeatedly while bot is running (F1 toggle)
; TIMER: Calls SetTimer(BankSortLoop, TimeConstants.LOOP_INTERVAL) when activated
;
; MAIN FLOW:
;   1. Activate BlueStacks window (bring to front)
;   2. Execute anti-ban system (delays, randomization)
;   3. Check if bank is open - if not, open it and return
;   4. Take screenshot of current bank state
;   5. Scan bank grid to detect all items
;   6. Organize items into tabs according to categories
;   7. Move items to their assigned tabs
;   8. Record performance metrics
;
; ERROR HANDLING:
;   - Window activation errors logged and recorded, function returns early
;   - All operations wrapped in try-catch blocks
;   - Errors increment error counter in performance metrics
;
; DEPENDENCIES:
;   - AntiBan() function
;   - IsBankOpen() function
;   - OpenBank() function
;   - ScreenshotBank() function
;   - ScanBank() function
;   - SortIntoTabs() function
;   - MoveItemsToTab() function
;   - PerformanceMonitor
;   - CreateTrackedOperation() function
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Modifies game state (moves items in bank)
;   - Creates screenshot files
;   - Records performance metrics
;   - Produces log entries
;
; IMPORTANT: This is called repeatedly by SetTimer. Keep processing time < LOOP_INTERVAL
;
BankSortLoop() {
    loopTracker := CreateTrackedOperation("bank_sort_loop")

    try {
        WinActivate("BlueStacks")
    } catch as err {
        Log("Window activation error: " . err.Message, LogLevelConstants.WARNING)
        PerformanceMonitor.RecordMetric("errors_encountered")
        return
    }

    AntiBan()

    if !IsBankOpen() {
        OpenBank()
        return
    }

    try {
        screenshotTracker := CreateTrackedOperation("screenshot_capture")
        ScreenshotBank()
        screenshotTracker.Complete()
        PerformanceMonitor.RecordMetric("screenshots_taken")

        items := ScanBank()

        if items.Length > 0 {
            ; Sort items by bank tab using the grouping system
            sortTracker := CreateTrackedOperation("items_sorting")
            SortIntoTabs(items)
            sortTracker.Complete()

            PerformanceMonitor.RecordMetric("items_sorted", items.Length)
            Speak("Sorted " . items.Length . " items")
            Log("Sorted " . items.Length . " items into bank tabs", LogLevelConstants.INFO)
        }

        loopTracker.Complete(true)
    } catch as err {
        Log("Error in BankSortLoop: " . err.Message, LogLevelConstants.ERROR)
        PerformanceMonitor.RecordMetric("errors_encountered")
        loopTracker.Complete(false)
    } finally {
        ; Clean up screenshot even if error occurs
        if FileExist(screenshot) {
            try {
                FileDelete(screenshot)
            } catch as err {
                Log("Screenshot cleanup error: " . err.Message, LogLevelConstants.WARNING)
            }
        }
    }
}

; ==========================================
; SCREENSHOT & SCANNING
; ==========================================

; ==========================================
; FUNCTION: ScreenshotBank
; ==========================================
; PURPOSE: Capture current bank interface via ADB and save to file
; CALLED: From BankSortLoop during each iteration
;
; OPERATIONS:
;   1. Execute ADB screencap command to /sdcard/bank.png on device
;   2. With timeout protection: ADB_TIMEOUT (5000ms)
;   3. Pull screenshot file from device to local temp directory
;   4. With timeout protection: ADB_TIMEOUT (5000ms)
;   5. Verify file exists locally
;   6. Log success or failure
;
; ERROR HANDLING:
;   - Timeout checks after each ADB command
;   - File existence verification
;   - Try-catch for all operations
;   - Logs errors and returns without crashing
;
; DEPENDENCIES:
;   - adb global variable
;   - screenshot global variable (FilePathConstants.SCREENSHOT_FILE)
;   - TimeConstants.ADB_TIMEOUT
;   - Log() function
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Creates/modifies screenshot file in temp directory
;   - Produces log entries
;
; IMPORTANT: Timeouts prevent bot from hanging if ADB disconnects
;
ScreenshotBank() {
    global adb, screenshot

    try {
        ; Verify ADB connection is available
        if !FileExist(screenshot) {
            ; Initial check - file shouldn't exist yet
        }

        ; Screencap with timeout protection
        startTime := A_TickCount
        RunWait(adb " shell screencap -p /sdcard/bank.png", , "Hide")
        if (A_TickCount - startTime) > TimeConstants.ADB_TIMEOUT {
            Log("Screenshot screencap timeout exceeded", LogLevelConstants.WARNING)
            return
        }

        ; Pull screenshot with timeout protection
        startTime := A_TickCount
        RunWait(adb ' pull /sdcard/bank.png "' screenshot '"', , "Hide")
        if (A_TickCount - startTime) > TimeConstants.ADB_TIMEOUT {
            Log("Screenshot pull timeout exceeded", LogLevelConstants.WARNING)
            return
        }

        ; Verify screenshot was actually created
        if !FileExist(screenshot) {
            Log("Warning: Screenshot file not created", LogLevelConstants.WARNING)
            return
        }

        Log("Screenshot captured successfully", LogLevelConstants.DEBUG)
    } catch as err {
        Log("Screenshot error: " . err.Message, LogLevelConstants.ERROR)
    }
}

; ==========================================
; FUNCTION: ScanBank
; ==========================================
; PURPOSE: Scan the bank grid and detect all items in their slots
; CALLED: From BankSortLoop
;
; ALGORITHM:
;   - Iterate through 8x8 grid (64 bank slots total)
;   - For each slot, calculate screen coordinates using BankCoordinates constants
;   - Call DetectItemAtPosition to identify item at that location
;   - Create item object with data, coordinates, and slot number
;   - Return array of detected items
;
; GRID STRUCTURE:
;   - 8 rows x 8 columns = 64 slots (standard bank layout)
;   - Slot numbering: row * 8 + col (0-63)
;   - Coordinates calculated from constants:
;     GRID_START_X, GRID_START_Y, GRID_CELL_SPACING, GRID_CELL_CENTER_OFFSET
;
; ERROR HANDLING:
;   - Returns empty array if screenshot file doesn't exist
;   - Returns partial results if DetectItemAtPosition fails for some slots
;   - No try-catch needed - relies on called functions
;
; DEPENDENCIES:
;   - screenshot global variable
;   - BankCoordinates constants (constants.ahk)
;   - DetectItemAtPosition() function
;
; RETURN VALUE:
;   Array of Map objects with keys:
;     - itemData: Item object from ItemGroupingSystem
;     - x: X coordinate for clicking
;     - y: Y coordinate for clicking
;     - slot: Slot number (0-63)
;
; SIDE EFFECTS:
;   - Calls DetectItemAtPosition which may return random test items
;   - No file modifications or logging
;
; IMPORTANT: Currently uses placeholder DetectItemAtPosition (returns random items)
; Performance: Scans all 64 slots regardless of actual item count
;
ScanBank() {
    global screenshot

    items := []

    if !FileExist(screenshot) {
        return items
    }

    ; Scan 8x8 grid of bank slots using coordinate constants
    Loop 8 {
        row := A_Index - 1
        rowY := BankCoordinates.GRID_START_Y + (row * BankCoordinates.GRID_CELL_SPACING)

        Loop 8 {
            col := A_Index - 1
            colX := BankCoordinates.GRID_START_X + (col * BankCoordinates.GRID_CELL_SPACING)

            ; In production, this would use OCR/image recognition
            ; For now, simulate with database lookup
            itemData := DetectItemAtPosition(colX, rowY)

            if itemData {
                items.Push(Map(
                    "itemData", itemData,
                    "x", colX + BankCoordinates.GRID_CELL_CENTER_OFFSET,
                    "y", rowY + BankCoordinates.GRID_CELL_CENTER_OFFSET,
                    "slot", row * 8 + col
                ))
            }
        }
    }

    return items
}

; ==========================================
; PLACEHOLDER FUNCTION: DetectItemAtPosition
; ==========================================
; CURRENT STATUS: Testing implementation (returns random items)
; PRODUCTION READY: NO - This function WILL NOT work correctly in production
;
; PARAMETERS:
;   x (Integer): X-coordinate of item position on screen
;   y (Integer): Y-coordinate of item position on screen
;
; RETURN VALUE:
;   Map: Item object from ItemGroupingSystem database OR empty string if unidentified
;        Returns random test items 50% of the time for testing purposes
;
; DESCRIPTION:
; This is a placeholder for actual item detection. Currently returns:
;   - Random test items from hardcoded list (50% chance)
;   - Empty string (50% chance)
;
; This will cause the bot to:
;   - Fail to correctly identify items in the bank
;   - Misidentify items (returns random items instead of actual items at position)
;   - Create incorrect bank organization patterns
;
; REQUIRED IMPLEMENTATION OPTIONS:
; Option 1: OCR (Optical Character Recognition)
;   - Extract item name text from screenshot at (x, y)
;   - Use Tesseract or similar OCR engine
;   - Pros: Works with any item, no database needed
;   - Cons: Requires OCR library, slower processing
;
; Option 2: Pixel-Pattern Detection
;   - Extract item icon bitmap from screenshot
;   - Compare pixels to known item icon templates
;   - Pros: Fast, offline, no OCR needed
;   - Cons: Requires item icon database, breaks on UI updates
;
; Option 3: Template Matching
;   - Use computer vision (OpenCV-style) to match item icons
;   - Match against database of known OSRS item icons
;   - Pros: Robust, handles slight variations
;   - Cons: Complex implementation, requires image library
;
; TODO: Implement production-ready detection using one of the above methods
; TODO: Add error handling for unidentified items
; TODO: Add timeout protection for detection operations
; TODO: Cache detection results for performance
; TODO: Add logging for debugging detection failures
;
DetectItemAtPosition(x, y) {
    ; DEVELOPMENT: For testing, return random items
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

; ==========================================
; FUNCTION: SortIntoTabs
; ==========================================
; PURPOSE: Group scanned items by their destination bank tabs
; CALLED: From BankSortLoop after ScanBank
;
; ALGORITHM:
;   1. Create map with 8 empty arrays (one per tab)
;   2. For each scanned item:
;      - Resolve destination tab using BankTabResolver
;      - Validate tab is in range (1-8)
;      - Add item to appropriate tab group
;      - Store destination tab in item object
;   3. If item has no assigned tab, default to tab 8
;   4. Call MoveItemsToTab for each tab group
;
; ERROR HANDLING:
;   - Invalid tab numbers default to tab 8
;   - Empty tab groups are processed normally (no-op)
;   - No try-catch - relies on BankTabResolver correctness
;
; DEPENDENCIES:
;   - BankTabResolver class and ResolveItemTab method
;   - MoveItemsToTab() function
;
; PARAMETERS:
;   items (Array): Array of item objects from ScanBank
;     Each item contains: itemData, x, y, slot, destinationTab (added)
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Modifies each item to add destinationTab property
;   - Calls MoveItemsToTab (which modifies game state)
;   - Produces log entries and voice alerts
;
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

; ==========================================
; FUNCTION: MoveItemsToTab
; ==========================================
; PURPOSE: Move a group of items to specified bank tab in organized grid
; CALLED: From SortIntoTabs for each tab with items
;
; ALGORITHM:
;   1. Switch to destination tab (SwitchBankTab)
;   2. For each item in order:
;      - Calculate target grid position (left-to-right, top-to-bottom)
;      - Drag item from current location to target location
;      - Increment row/col counter for next item placement
;
; GRID PLACEMENT:
;   - Fills grid left-to-right (columns 0-7)
;   - Then moves to next row (row 0-7)
;   - Starts at GRID_START_X, GRID_START_Y
;   - Uses GRID_CELL_SPACING and GRID_CELL_CENTER_OFFSET
;
; ERROR HANDLING:
;   - Assumes SwitchBankTab succeeds (no validation)
;   - Assumes UI_Drag succeeds (no error handling in loop)
;   - No try-catch blocks
;
; DEPENDENCIES:
;   - SwitchBankTab() function
;   - UI_Drag() function
;   - BankCoordinates constants
;   - TimeConstants.TAB_SWITCH_DELAY
;   - SafeSleep() function
;
; PARAMETERS:
;   items (Array): Items to move (from SortIntoTabs)
;   tabNum (Integer): Destination tab number (1-8)
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Switches active bank tab
;   - Moves items in game (drag operations)
;   - Produces log entries (from UI_Drag)
;   - Records performance metrics (from UI_Drag)
;
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
            Log("Warning: Tab " . tabNum . " full, cannot add more items", LogLevelConstants.WARNING)
            break
        }
    }
}

; ==========================================
; FUNCTION: SwitchBankTab
; ==========================================
; PURPOSE: Switch to specified bank tab via ADB tap command
; CALLED: From MoveItemsToTab before moving items
;
; OPERATIONS:
;   1. Validate tab number is in range 1-8
;   2. Get tab coordinates from BankCoordinates
;   3. Send ADB tap command to tab location
;   4. Record metric and return success
;
; VALIDATION:
;   - Uses ValidationConstants.IsValidTabNumber
;   - Returns false if invalid tab
;   - Logs error on validation failure
;
; ERROR HANDLING:
;   - Wrapped in try-catch
;   - Logs errors with operation type
;   - Records error metric
;   - Returns false on any error
;
; DEPENDENCIES:
;   - adb global variable
;   - BankCoordinates.GetTabCoordinates(tabNum)
;   - ValidationConstants.IsValidTabNumber
;   - PerformanceMonitor.RecordMetric
;   - Log() function
;
; PARAMETERS:
;   tabNum (Integer): Bank tab to switch to (1-8)
;
; RETURN VALUE:
;   Boolean: true if tab switch succeeded, false otherwise
;
; SIDE EFFECTS:
;   - Changes active bank tab in game
;   - Records tab switch metric
;   - Produces log entry on error
;
SwitchBankTab(tabNum) {
    global adb

    ; Validate tab number
    if !ValidationConstants.IsValidTabNumber(tabNum) {
        Log("Error: Invalid tab number " . tabNum . " (valid: 1-8)", LogLevelConstants.ERROR)
        return false
    }

    try {
        tabCoords := BankCoordinates.GetTabCoordinates(tabNum)
        tabX := tabCoords["x"]
        tabY := tabCoords["y"]

        Run(adb " shell input tap " . tabX . " " . tabY, , "Hide")
        PerformanceMonitor.RecordMetric("tabs_switched")
        return true
    } catch as err {
        Log("Error switching to tab " . tabNum . ": " . err.Message, LogLevelConstants.ERROR)
        PerformanceMonitor.RecordMetric("errors_encountered")
        return false
    }
}

; ==========================================
; FUNCTION: UI_Drag
; ==========================================
; PURPOSE: Drag item from source to destination with human-like motion
; CALLED: From MoveItemsToTab for each item placement
;
; BEHAVIOR:
;   If StealthMode enabled:
;     - Use ADB swipe command with 150ms duration
;     - Direct linear motion without intermediate steps
;     - Fastest but less human-like
;   If StealthMode disabled:
;     - Simulate human hand movement with 15 intermediate steps
;     - Randomized movement path (hand jitter)
;     - Add anti-ban delays between steps
;     - More realistic but slower
;
; ALGORITHM (Normal Mode):
;   1. Calculate movement vector (endX - startX, endY - startY)
;   2. Divide into 15 intermediate steps
;   3. For each step:
;      - Calculate current position
;      - Execute ADB tap at that position
;      - Add random delay (anti-ban)
;
; ERROR HANDLING:
;   - Wrapped in try-catch
;   - Logs errors as warnings (non-fatal)
;   - Records error metrics
;   - Completes operation tracker with success/failure
;
; DEPENDENCIES:
;   - adb global variable
;   - cfg["StealthMode"] setting
;   - PerformanceMonitor
;   - CreateTrackedOperation() function
;   - TimeConstants.GetShortPause() for delays
;   - SafeSleep() for delays
;
; PARAMETERS:
;   sx (Float): Source X coordinate
;   sy (Float): Source Y coordinate
;   ex (Float): Destination X coordinate
;   ey (Float): Destination Y coordinate
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Records drag metric
;   - Executes ADB commands (moves item in game)
;   - Produces log entries on error
;   - Records operation timing
;
UI_Drag(sx, sy, ex, ey) {
    global adb, cfg

    dragTracker := CreateTrackedOperation("ui_drag")

    if cfg["StealthMode"] {
        try {
            Run(adb " shell input swipe " . Round(sx) . " " . Round(sy) . " " . Round(ex) . " " . Round(ey) . " 150", , "Hide")
            PerformanceMonitor.RecordMetric("drags_performed")
            dragTracker.Complete(true)
        } catch as err {
            Log("Stealth drag error: " . err.Message, LogLevelConstants.WARNING)
            PerformanceMonitor.RecordMetric("errors_encountered")
            dragTracker.Complete(false)
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
                Log("Tap error at step " . A_Index . ": " . err.Message, LogLevelConstants.DEBUG)
            }
            Sleep(10)
        }

        ; Final swipe
        Run(adb " shell input swipe " . Round(sx) . " " . Round(sy) . " " . Round(ex) . " " . Round(ey) . " 150", , "Hide")
        PerformanceMonitor.RecordMetric("drags_performed")
        dragTracker.Complete(true)
    } catch as err {
        Log("UI_Drag error: " . err.Message, LogLevelConstants.ERROR)
        PerformanceMonitor.RecordMetric("errors_encountered")
        dragTracker.Complete(false)
    }
}

; ==========================================
; ANTI-BAN SYSTEM
; ==========================================

; ==========================================
; FUNCTION: AntiBan
; ==========================================
; PURPOSE: Apply anti-ban delays/behavior to reduce detection risk
; CALLED: From BankSortLoop at start of each loop iteration
;
; BEHAVIOR:
;   If StealthMode enabled: Return immediately (no delays)
;   If AntiBan mode is "Off": Return immediately (no delays)
;   Otherwise: Apply delays based on selected AntiBan mode and session time
;
; ANTI-BAN MODES:
;   1. "Psychopath": Least cautious
;      - 2% chance per iteration of 3-6 min pause after 2+ hours
;   2. "Extreme": More cautious
;      - 5% chance per iteration of 3-6 min pause after 1.5+ hours
;   3. "Stealth": Most cautious
;      - 10% chance per iteration of 3-6 min pause after 1 hour
;      - Plus additional short random pauses (1-5 sec) every other loop
;   4. "Off": Disabled
;      - No anti-ban delays
;
; MATH:
;   - Random(1, 100) generates probability check
;   - ElapsedHours() calculates session duration from sessionStart
;   - Sleep values in milliseconds (180000ms = 3 min, 360000ms = 6 min)
;
; ERROR HANDLING:
;   - No try-catch (sleep is always safe)
;   - No error conditions
;
; DEPENDENCIES:
;   - cfg["StealthMode"] setting
;   - cfg["AntiBan"] mode selection
;   - sessionStart global variable
;   - ElapsedHours() function
;   - TimeConstants for pause timing
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Causes Sleep() delays (blocks bot execution)
;   - No logging or metrics recorded
;
; IMPORTANT: These delays are part of bot's human-like behavior
;
AntiBan() {
    global cfg, sessionStart

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
        Log("Session ended: Time limit reached", LogLevelConstants.WARNING)
        ExitApp()
    }
}

; ==========================================
; UTILITY FUNCTIONS
; ==========================================

IsBankOpen() {
    ; PLACEHOLDER FUNCTION - Needs Implementation
    ; Current behavior: Returns hardcoded true (will malfunction in production)
    ;
    ; REQUIRED IMPLEMENTATION:
    ; - Analyze the screenshot captured by ScreenshotBank()
    ; - Use OCR or image recognition to detect if bank interface is open
    ; - Return true if bank UI is visible, false otherwise
    ;
    ; CURRENT STATUS: Disabled - Always returns true, bot assumes bank is open
    ; This will cause the bot to attempt item manipulation even if bank is closed
    ;
    ; TODO: Implement actual bank detection using:
    ; Option 1: OCR (via Tesseract or Windows MODI API)
    ; Option 2: Pixel color detection on known bank UI elements
    ; Option 3: Template matching on characteristic bank window pixels

    return true
}

; ==========================================
; FUNCTION: OpenBank
; ==========================================
; PURPOSE: Attempt to open the bank interface by tapping center of screen
; CALLED: From BankSortLoop if IsBankOpen() returns false
;
; OPERATIONS:
;   1. Provide voice feedback
;   2. Log opening attempt
;   3. Send ADB tap command to screen center
;   4. Wait 2 seconds for bank to open
;   5. Log any errors (non-fatal)
;
; BEHAVIOR:
;   - Assumes bank booth/NPC is at center of screen
;   - Generic screen center tap (doesn't validate position)
;   - Waits 2 seconds regardless of success/failure
;
; ERROR HANDLING:
;   - Wrapped in try-catch
;   - Logs errors but continues (non-fatal)
;   - Returns normally even on ADB failure
;
; DEPENDENCIES:
;   - adb global variable
;   - BankCoordinates.SCREEN_CENTER_X and SCREEN_CENTER_Y
;   - Speak() function
;   - Log() function
;   - SafeSleep() via Sleep()
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Executes ADB tap command
;   - Produces voice alert
;   - Produces log entry
;   - Blocks for 2 seconds
;
; LIMITATIONS:
;   - Generic tap location (may miss bank if not centered)
;   - No validation that bank actually opened
;   - Next loop iteration will check with IsBankOpen()
;
OpenBank() {
    global adb

    Speak("Opening bank")
    Log("Opening bank...", LogLevelConstants.INFO)
    try {
        Run(adb " shell input tap " . BankCoordinates.SCREEN_CENTER_X . " " . BankCoordinates.SCREEN_CENTER_Y, , "Hide")
    } catch as err {
        Log("Error opening bank: " . err.Message, LogLevelConstants.ERROR)
    }
    Sleep(2000)
}

; ==========================================
; FUNCTION: ElapsedHours
; ==========================================
; PURPOSE: Calculate session duration in hours since bot started
; CALLED: From AntiBan function to determine wait durations
;
; CALCULATION:
;   - Gets milliseconds elapsed since sessionStart
;   - Divides by 3,600,000 (ms/hour)
;   - Rounds to 1 decimal place (0.1 hour precision)
;
; DEPENDENCIES:
;   - sessionStart global variable (initialized at script start)
;   - A_TickCount built-in variable
;
; RETURN VALUE:
;   Float: Session duration in hours (e.g., 2.5, 1.3, 0.1)
;
; SIDE EFFECTS: None
;
ElapsedHours() {
    global sessionStart

    return Round((A_TickCount - sessionStart) / 3600000, 1)
}

; ==========================================
; FUNCTION: Log
; ==========================================
; PURPOSE: Write timestamped log entry to file with log level
; CALLED: From multiple functions throughout bot for debugging/tracking
;
; LOG LEVELS:
;   - INFO: Normal operation messages
;   - WARNING: Non-critical issues
;   - ERROR: Critical issues that may halt operation
;   - DEBUG: Detailed diagnostic information
;
; OPERATIONS:
;   1. Ensure log directory exists (FilePathConstants.LOG_DIR)
;   2. Format log entry: YYYY-MM-DD HH:MM:SS [LEVEL] Message
;   3. Append to log file (FilePathConstants.LOG_FILE)
;   4. If file write fails, fallback to OutputDebug (console)
;   5. If directory creation fails, skip to OutputDebug only
;
; ERROR HANDLING:
;   - Wrapped in try-catch for file operations
;   - Fallback to OutputDebug if file write fails
;   - Fallback to OutputDebug if directory creation fails
;   - Never throws exceptions (always succeeds)
;
; DEPENDENCIES:
;   - FilePathConstants.LOG_DIR (log directory path)
;   - FilePathConstants.LOG_FILE (log file path)
;   - GetTimestamp() function
;   - SafeDirCreate() function
;   - LogLevelConstants for level names
;
; PARAMETERS:
;   message (String): Log message text
;   level (String): Log level ["INFO", "WARNING", "ERROR", "DEBUG"]
;     Defaults to LogLevelConstants.INFO
;
; RETURN VALUE: None (void)
; SIDE EFFECTS:
;   - Creates/modifies log file
;   - Creates log directory if needed
;   - Outputs to console if file write fails
;
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

Log("xh1px's Tidy Bank v2.0 started", LogLevelConstants.INFO)
Speak("xh1px's Tidy Bank ready. Press F1 to start, F2 for emergency stop, Escape to exit.")
