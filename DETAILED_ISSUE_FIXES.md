# DETAILED ISSUE FIXES
## xh1px-tidy-bank Project

This document provides specific code fixes for all identified issues.

---

## HIGH PRIORITY FIXES

### FIX #1: Correct Database File Path (main.ahk, Line 190)

**Current Code**:
```ahk
dbPath := A_ScriptDir "\osrsbox-db.json"
```

**Fixed Code**:
```ahk
dbPath := A_ScriptDir "\osrs-items-condensed.json"
```

**Explanation**: The actual database file is named `osrs-items-condensed.json`, not `osrsbox-db.json`.

---

### FIX #2: Remove Duplicate JSON Class and Use Include

**File**: main.ahk
**Lines to Remove**: 10-93 (entire inline JSON class)

**Add at top of file** (after #SingleInstance Force):
```ahk
#Include json_parser.ahk
```

**Explanation**: Eliminates code duplication and uses the full-featured JSON parser.

---

### FIX #3: Fix Configuration Type Consistency

**File**: main.ahk
**Lines**: 96-104

**Current Code**:
```ahk
cfg := Map(
    "AntiBan", "Psychopath",
    "VoiceAlerts", "false",  // String!
    "WorldHop", "false",     // String!
    "SortMode", "GEValue",
    "MaxSession", "240",     // String!
    "UseOCR", "false",       // String!
    "StealthMode", "true"    // String!
)
```

**Fixed Code**:
```ahk
cfg := Map(
    "AntiBan", "Psychopath",
    "VoiceAlerts", false,     // Boolean
    "WorldHop", false,        // Boolean
    "SortMode", "GEValue",
    "MaxSession", 240,        // Number
    "UseOCR", false,          // Boolean
    "StealthMode", true       // Boolean
)
```

**Explanation**: Use proper boolean/number types instead of strings for consistency.

---

### FIX #4: Fix String Comparisons After Type Fix

**File**: main.ahk

**Line 119**:
```ahk
// OLD
if (cfg["VoiceAlerts"] = "true") {

// NEW
if (cfg["VoiceAlerts"]) {
```

**Line 306**:
```ahk
// OLD
if (cfg["StealthMode"] = "true") {

// NEW
if (cfg["StealthMode"]) {
```

**Line 336**:
```ahk
// OLD
if (cfg["StealthMode"] = "true" || cfg["AntiBan"] = "Off") {

// NEW
if (cfg["StealthMode"] || cfg["AntiBan"] = "Off") {
```

---

### FIX #5: Add ADB Connection Validation

**File**: main.ahk
**Location**: After line 112 (after global variable declarations)

**Add New Function**:
```ahk
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
```

**Modify ToggleBot() function** (Line 131):
```ahk
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
        PreloadCache()
        SetTimer(BankSortLoop, 800)
    } else {
        Speak("Bot deactivated")
        SetTimer(BankSortLoop, 0)
    }
}
```

---

### FIX #6: Improve IsBankOpen Detection

**File**: main.ahk
**Lines**: 369-372

**Current Code** (Placeholder):
```ahk
IsBankOpen() {
    ; Placeholder: In production would analyze screenshot
    return true
}
```

**Improved Code** (Basic pixel detection):
```ahk
IsBankOpen() {
    ; IMPROVEMENT: Basic pixel-based detection
    ; This is a simple implementation - can be enhanced with OCR

    global screenshot

    if !FileExist(screenshot) {
        return false
    }

    ; TODO: Implement actual pixel checking or OCR
    ; For now, check if screenshot is recent (created in last 5 seconds)
    try {
        fileTime := FileGetTime(screenshot)
        currentTime := A_Now

        ; Calculate time difference in seconds
        timeDiff := DateDiff(currentTime, fileTime, "Seconds")

        ; If screenshot is recent, assume bank is open
        return (timeDiff < 5)
    } catch {
        return false
    }
}
```

**Add Helper Function**:
```ahk
; Calculate date difference
DateDiff(date1, date2, units) {
    diff := DateDiff(date1, date2)

    if (units = "Seconds") {
        return diff
    } else if (units = "Minutes") {
        return Floor(diff / 60)
    } else if (units = "Hours") {
        return Floor(diff / 3600)
    }

    return diff
}
```

**NOTE**: This is still a basic implementation. Full implementation would require:
- OCR text detection for "Bank of" title
- Pixel color checking for bank interface elements
- Template matching for bank icon

---

### FIX #7: Document ScanBank Placeholder

**File**: main.ahk
**Lines**: 226-257

**Add Clear Documentation**:
```ahk
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
```

---

## MEDIUM PRIORITY FIXES

### FIX #8: Add Error Handling to File Operations

**File**: main.ahk
**Line**: 178-180

**Current Code**:
```ahk
if FileExist(screenshot) {
    FileDelete(screenshot)
}
```

**Fixed Code**:
```ahk
if FileExist(screenshot) {
    try {
        FileDelete(screenshot)
    } catch as err {
        Log("Warning: Failed to delete screenshot: " . err.Message)
    }
}
```

---

### FIX #9: Add Error Handling to PreloadCache

**File**: main.ahk
**Lines**: 187-211

**Wrap FileRead in try-catch** (already present, but improve):
```ahk
PreloadCache() {
    global db, itemHashes

    dbPath := A_ScriptDir "\osrs-items-condensed.json"  // FIXED PATH
    if !FileExist(dbPath) {
        MsgBox("Database file not found: " dbPath, "xh1px's Tidy Bank - Error", 16)
        Log("ERROR: Database file not found: " . dbPath)
        return false  // Add return value
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
        return true  // Add return value
    } catch as err {
        MsgBox("Error loading database: " . err.Message, "xh1px's Tidy Bank - Error", 16)
        Log("ERROR: Failed to load database: " . err.Message)
        return false  // Add return value
    }
}
```

**Update ToggleBot to check return value**:
```ahk
ToggleBot() {
    global running
    running := !running
    if (running) {
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
```

---

### FIX #10: Remove Unused Variable

**File**: main.ahk
**Line**: 112

**Remove**:
```ahk
itemHashes := Map()  // REMOVE THIS LINE
```

**OR Implement hashing** (if needed for future OCR):
```ahk
itemHashes := Map()  // Keep if planning to implement image hashing
```

**Add comment if keeping**:
```ahk
itemHashes := Map()  // Future: Store perceptual hashes for image matching
```

---

### FIX #11: Use Constants for Coordinates

**File**: main.ahk
**Lines**: 234-253, 286-303

**Current Code**:
```ahk
; Line 234-236
Loop 8 {
    row := A_Index - 1
    rowY := row * 60 + 150
```

**Fixed Code** (add #Include first):
```ahk
#Include constants.ahk
```

**Then replace hardcoded coordinates**:
```ahk
ScanBank() {
    items := []

    if !FileExist(screenshot) {
        return items
    }

    ; Use constants from BankCoordinates class
    gridRows := BankCoordinates.GRID_ROWS
    gridCols := BankCoordinates.GRID_COLS

    Loop gridRows {
        row := A_Index - 1

        Loop gridCols {
            col := A_Index - 1

            ; Get cell position from constants
            pos := BankCoordinates.GetCellPosition(row, col)

            if (pos.Count = 0) {
                continue
            }

            ; Placeholder detection
            id := Random(1, 100) > 50 ? Random(1, 1000) : 0

            if (id > 0) {
                items.Push(Map(
                    "id", id,
                    "x", pos["x"],
                    "y", pos["y"],
                    "slot", row * gridCols + col
                ))
            }
        }
    }

    return items
}
```

**Similarly for Rearrange function** (Line 283):
```ahk
Rearrange(items) {
    ; Use constants
    startX := BankCoordinates.GRID_START_X + BankCoordinates.GRID_CELL_CENTER_OFFSET
    startY := BankCoordinates.GRID_START_Y + BankCoordinates.GRID_CELL_CENTER_OFFSET
    spacing := BankCoordinates.GRID_CELL_SPACING
    maxCols := BankCoordinates.GRID_COLS

    col := 0
    row := 0

    for item in items {
        targetX := startX + (col * spacing)
        targetY := startY + (row * spacing)

        UI_Drag(item["x"], item["y"], targetX, targetY)

        col++
        if (col >= maxCols) {
            col := 0
            row++
        }
    }
}
```

---

### FIX #12: Integrate Performance Monitoring

**File**: main.ahk

**Add Include at top**:
```ahk
#Include performance.ahk
#Include constants.ahk
```

**Initialize in startup** (after line 401):
```ahk
; Initialize performance monitoring
PerformanceMonitor.Initialize()
Log("xh1px's Tidy Bank v1.0 started")
Speak("xh1px's Tidy Bank ready. Press F1 to start, F2 for emergency stop, Escape to exit.")
```

**Track operations in BankSortLoop**:
```ahk
BankSortLoop() {
    ; Start operation tracking
    operation := OperationTracker("BankSort")

    try {
        WinActivate("BlueStacks")
    }

    AntiBan()

    if (!IsBankOpen()) {
        OpenBank()
        operation.Complete(false)
        return
    }

    ScreenshotBank()
    PerformanceMonitor.RecordMetric("screenshots_taken")

    items := ScanBank()

    if (items.Length > 0) {
        sorted := SortItems(items, cfg["SortMode"])
        Rearrange(sorted)

        PerformanceMonitor.RecordMetric("items_sorted", items.Length)
        PerformanceMonitor.RecordMetric("drags_performed", items.Length)

        Speak("Sorted " items.Length " items")
        Log("Sorted " items.Length " items")
    }

    if FileExist(screenshot) {
        try {
            FileDelete(screenshot)
        } catch as err {
            Log("Warning: Failed to delete screenshot: " . err.Message)
        }
    }

    ; Complete operation tracking
    operation.Complete(true)
}
```

**Add performance logging on exit**:
```ahk
; Modify ExitApp calls to log performance first
OnExit(LogPerformanceOnExit)

LogPerformanceOnExit(*) {
    Log(PerformanceMonitor.GetPerformanceSummary())
    PerformanceMonitor.LogMetricsToFile(FilePathConstants.LOG_FILE)
}
```

---

## LOW PRIORITY IMPROVEMENTS

### FIX #13: Add Function Documentation

**Example for main functions**:

```ahk
/**
 * Toggles the bot on/off state
 *
 * Validates environment (ADB, BlueStacks) before starting
 * Loads item database and starts main loop
 *
 * Hotkey: F1
 * Global Variables: running, cfg
 * Side Effects: Sets timer for BankSortLoop
 */
ToggleBot() {
    // ... implementation
}

/**
 * Main bot loop - processes bank sorting operations
 *
 * Workflow:
 * 1. Activate BlueStacks window
 * 2. Execute anti-ban routines
 * 3. Check if bank is open
 * 4. Capture screenshot
 * 5. Scan for items
 * 6. Sort items based on mode
 * 7. Rearrange items in bank
 *
 * Called by: SetTimer (800ms interval)
 * Global Variables: cfg, screenshot
 * Side Effects: Modifies bank contents via ADB
 */
BankSortLoop() {
    // ... implementation
}
```

---

### FIX #14: Replace Magic Numbers with Constants

**File**: main.ahk

**Add to top after includes**:
```ahk
; Timing constants (use TimeConstants where possible)
BANK_LOOP_INTERVAL := 800  ; milliseconds
```

**Replace**:
```ahk
// OLD
SetTimer(BankSortLoop, 800)

// NEW
SetTimer(BankSortLoop, BANK_LOOP_INTERVAL)
```

---

## SUMMARY OF FILES TO MODIFY

1. **main.ahk** - Multiple fixes (database path, includes, types, error handling)
2. **config_gui.ahk** - No critical fixes needed
3. **constants.ahk** - No fixes needed
4. **json_parser.ahk** - No fixes needed
5. **item_grouping.ahk** - No fixes needed
6. **bank_tab_resolver.ahk** - No fixes needed
7. **performance.ahk** - No fixes needed

---

## TESTING CHECKLIST

After applying fixes, test:

- [ ] Bot starts without errors
- [ ] Database loads successfully
- [ ] ADB connection is validated
- [ ] BlueStacks window detection works
- [ ] Configuration types are correct
- [ ] Error messages are clear
- [ ] Performance monitoring logs metrics
- [ ] Logging works correctly
- [ ] All includes resolve
- [ ] No runtime errors in AHK v2.0

---

## DEPLOYMENT STEPS

1. Apply all HIGH priority fixes
2. Test thoroughly
3. Apply MEDIUM priority fixes
4. Test again
5. Apply LOW priority improvements
6. Final testing
7. Update documentation
8. Create release

---

**Document Version**: 1.0
**Last Updated**: 2025-11-16
