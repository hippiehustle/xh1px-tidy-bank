# AutoHotkey Semantic Structure Analysis Report

## Summary

**Analysis Date:** 2025-11-17
**Total Functions Found:** 64
**Issues Identified:** 12
**Severity Breakdown:** 2 Critical, 8 High, 2 Medium

---

## Issue Breakdown by File

### File: main.ahk - CRITICAL ISSUES

#### Issue 1: String Concatenation Error (Line 141) - CRITICAL
**Location:** `main.ahk:141`
**Function:** `PreloadCache()`
**Severity:** CRITICAL

**Code:**
```autohotkey
MsgBox("Database file not found: " dbPath, "xh1px's Tidy Bank - Error", 16)
```

**Problem:** Missing concatenation operator. String and variable are not concatenated.
**Expected Behavior:** Should concatenate the file path into the error message
**Fix:**
```autohotkey
MsgBox("Database file not found: " . dbPath, "xh1px's Tidy Bank - Error", 16)
```

---

#### Issue 2: String Concatenation Error (Line 179) - CRITICAL
**Location:** `main.ahk:179`
**Function:** `ScreenshotBank()`
**Severity:** CRITICAL

**Code:**
```autohotkey
Log("Screenshot error: " err.Message)
```

**Problem:** Missing concatenation operator. String and error message are not concatenated.
**Expected Behavior:** Should concatenate error details into log message
**Fix:**
```autohotkey
Log("Screenshot error: " . err.Message)
```

---

#### Issue 3: Missing Global Declaration (Line 93) - HIGH
**Location:** `main.ahk:93-103`
**Function:** `PanicAbort()`
**Severity:** HIGH

**Variables Used:** `adb` (lines 96, 98)
**Problem:** Function accesses global variable `adb` without declaring it global
**Impact:** Variable will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
PanicAbort() {
    global adb
    ...
}
```

---

#### Issue 4: Missing Global Declaration (Line 105) - HIGH
**Location:** `main.ahk:105-130`
**Function:** `BankSortLoop()`
**Severity:** HIGH

**Variables Used:** `cfg` (line 121), `screenshot` (implicitly in called functions)
**Problem:** Function accesses global variable `cfg` without declaring it global
**Impact:** Variable will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
BankSortLoop() {
    global cfg, screenshot
    ...
}
```

---

#### Issue 5: Missing Global Declaration (Line 183) - HIGH
**Location:** `main.ahk:183-236`
**Function:** `ScanBank()`
**Severity:** HIGH

**Variables Used:** `screenshot` (line 186)
**Problem:** Function accesses global variable `screenshot` without declaring it global
**Impact:** Variable will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
ScanBank() {
    global screenshot
    ...
}
```

---

#### Issue 6: Missing Global Declaration (Line 242) - HIGH
**Location:** `main.ahk:242-261`
**Function:** `SortItems()`
**Severity:** HIGH

**Variables Used:** `db` (line 244), `cfg` (line 121 indirectly referenced)
**Problem:** Function accesses global variable `db` without declaring it global
**Impact:** Variable will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
SortItems(items, mode) {
    global db, cfg
    ...
}
```

---

#### Issue 7: Missing Global Declaration (Line 284) - HIGH
**Location:** `main.ahk:284-308`
**Function:** `UI_Drag()`
**Severity:** HIGH

**Variables Used:** `cfg` (line 285), `adb` (lines 287, 300, 306)
**Problem:** Function accesses global variables `cfg` and `adb` without declaring them global
**Impact:** Variables will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
UI_Drag(sx, sy, ex, ey) {
    global adb, cfg
    ...
}
```

---

#### Issue 8: Missing Global Declaration (Line 314) - HIGH
**Location:** `main.ahk:314-342`
**Function:** `AntiBan()`
**Severity:** HIGH

**Variables Used:** `cfg` (lines 315, 321, 337)
**Problem:** Function accesses global variable `cfg` without declaring it global
**Impact:** Variable will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
AntiBan() {
    global cfg, sessionStart
    ...
}
```

---

#### Issue 9: Missing Global Declaration (Line 378) - HIGH
**Location:** `main.ahk:378-384`
**Function:** `OpenBank()`
**Severity:** HIGH

**Variables Used:** `adb` (line 381)
**Problem:** Function accesses global variable `adb` without declaring it global
**Impact:** Variable will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
OpenBank() {
    global adb
    ...
}
```

---

#### Issue 10: Missing Global Declaration (Line 386) - HIGH
**Location:** `main.ahk:386-388`
**Function:** `ElapsedHours()`
**Severity:** HIGH

**Variables Used:** `sessionStart` (line 387)
**Problem:** Function accesses global variable `sessionStart` without declaring it global
**Impact:** Variable will be treated as local, causing undefined variable errors
**Fix:** Add at top of function:
```autohotkey
ElapsedHours() {
    global sessionStart
    ...
}
```

---

### File: main_template_v2.ahk - TIME CALCULATION BUG

#### Issue 11: Type Mismatch in Time Calculation (Line 1257) - MEDIUM
**Location:** `main_template_v2.ahk:1257`
**Function:** `IsBankOpen()`
**Severity:** MEDIUM

**Code:**
```autohotkey
timeDiff := (A_TickCount - FileGetTime(screenshot, "M")) / 1000
```

**Problem:** Incompatible time sources being subtracted:
- `A_TickCount`: Milliseconds since system startup (very large number, e.g., 1234567890000)
- `FileGetTime(screenshot, "M")`: File modification time in format YYYYMMDDHHmmss (string, e.g., 20251117154530)

Subtracting a timestamp string from milliseconds produces meaningless results.

**Expected Behavior:** Calculate time difference between current time and file modification time
**Fix Option 1:** Use consistent time units:
```autohotkey
elapsedMs := (A_TickCount - FileGetTime(screenshot, "M")) / 1000
```
Should use:
```autohotkey
timeDiff := (A_Now - FileGetTime(screenshot)) / 1000  ; Both in same format
```

**Fix Option 2:** Use elapsed time from file creation:
```autohotkey
currentTickCount := A_TickCount
fileTickCount := FileGetTime(screenshot, "M")  ; Get as numeric timestamp
timeDiff := (currentTickCount - fileTickCount) / 1000
```

---

### File: performance.ahk - DEPENDENCY ISSUE

#### Issue 12: Unincluded Dependency (Line 218) - MEDIUM
**Location:** `performance.ahk:218`
**Function:** `LogPerformanceMetrics()`
**Severity:** MEDIUM

**Code:**
```autohotkey
LogPerformanceMetrics(logFile := FilePathConstants.LOG_FILE) {
    PerformanceMonitor.LogMetricsToFile(logFile)
}
```

**Problem:** Function parameter references `FilePathConstants` class which is defined in `constants.ahk` but not included in `performance.ahk`

**Impact:**
- If `performance.ahk` is used without proper include order, will fail with undefined class error
- Requires `constants.ahk` to be included before `performance.ahk`
- Currently works because `main_template_v2.ahk` includes both in correct order

**Risk:**
- Code fragility: Breaks if performance.ahk is moved or included separately
- Undocumented dependency

**Fix Option 1:** Add include to top of performance.ahk:
```autohotkey
#Include constants.ahk
```

**Fix Option 2:** Remove dependency:
```autohotkey
LogPerformanceMetrics(logFile := "") {
    if (logFile == "") {
        logFile := A_ScriptDir . "\logs\tidybank_log.txt"
    }
    PerformanceMonitor.LogMetricsToFile(logFile)
}
```

---

## Summary Table

| Issue # | File | Line | Function | Severity | Type | Status |
|---------|------|------|----------|----------|------|--------|
| 1 | main.ahk | 141 | PreloadCache | CRITICAL | String Concat | Unfixed |
| 2 | main.ahk | 179 | ScreenshotBank | CRITICAL | String Concat | Unfixed |
| 3 | main.ahk | 93 | PanicAbort | HIGH | Missing Global | Unfixed |
| 4 | main.ahk | 105 | BankSortLoop | HIGH | Missing Global | Unfixed |
| 5 | main.ahk | 183 | ScanBank | HIGH | Missing Global | Unfixed |
| 6 | main.ahk | 242 | SortItems | HIGH | Missing Global | Unfixed |
| 7 | main.ahk | 284 | UI_Drag | HIGH | Missing Global | Unfixed |
| 8 | main.ahk | 314 | AntiBan | HIGH | Missing Global | Unfixed |
| 9 | main.ahk | 378 | OpenBank | HIGH | Missing Global | Unfixed |
| 10 | main.ahk | 386 | ElapsedHours | HIGH | Missing Global | Unfixed |
| 11 | main_template_v2.ahk | 1257 | IsBankOpen | MEDIUM | Type Mismatch | Unfixed |
| 12 | performance.ahk | 218 | LogPerformanceMetrics | MEDIUM | Dependency | Unfixed |

---

## Files Without Issues

✅ **bank_tab_resolver.ahk** - No semantic issues found
✅ **config_gui.ahk** - No semantic issues found
✅ **constants.ahk** - No semantic issues found
✅ **item_grouping.ahk** - No semantic issues found
✅ **json_parser.ahk** - No semantic issues found

---

## Analysis Details

### Total Functions Found: 64
- Class methods (static): 52
- Global functions: 12
- Parameter verification: All parameter counts match between definitions and calls
- Dead code analysis: No unreachable code blocks found
- Variable scope: 10 missing global declarations identified

### Additional Notes

1. **Missing Concatenation Operators (2 instances):** Both occur in error logging contexts, making error reporting unreliable
2. **Missing Global Declarations (8 instances):** All in main.ahk, causing variables to be treated as local and creating undefined variable errors
3. **Time Calculation Bug:** High risk - produces incorrect time calculations for bank state detection
4. **Dependency Management:** performance.ahk requires constants.ahk but doesn't explicitly include it
5. **Code Quality:** The template file (main_template_v2.ahk) has proper global declarations throughout, suggesting main.ahk was not updated correctly

---

## Recommended Priority

### Immediate (Critical)
- Fix issues #1 and #2 (string concatenation errors)

### High Priority
- Fix issues #3-#10 (missing global declarations in main.ahk)
- These will cause runtime errors when functions are called

### Medium Priority
- Fix issue #11 (time calculation bug in main_template_v2.ahk)
- Fix issue #12 (add include in performance.ahk)

---

## Testing Recommendations

After fixes:
1. Test each function that was missing global declarations
2. Verify error messages display correctly
3. Test time-based detection logic with various time scenarios
4. Ensure performance.ahk can be included independently
