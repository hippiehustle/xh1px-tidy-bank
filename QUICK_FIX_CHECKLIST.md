# QUICK FIX CHECKLIST
## Immediate Actions for xh1px-tidy-bank

**Priority**: HIGH
**Estimated Time**: 1 hour
**Difficulty**: Easy

---

## ✅ CHECKLIST (Complete in Order)

### FIX #1: Database File Path (1 minute)
**File**: `main.ahk`
**Line**: 190

- [ ] Open main.ahk in editor
- [ ] Find line 190: `dbPath := A_ScriptDir "\osrsbox-db.json"`
- [ ] Change to: `dbPath := A_ScriptDir "\osrs-items-condensed.json"`
- [ ] Save file

---

### FIX #2: Remove Duplicate JSON Class (5 minutes)
**File**: `main.ahk`
**Lines**: 10-93

- [ ] Delete lines 10-93 (entire JSON class definition)
- [ ] Add after line 2 (after #SingleInstance Force):
  ```ahk
  #Include json_parser.ahk
  ```
- [ ] Save file

---

### FIX #3: Fix Configuration Types (10 minutes)
**File**: `main.ahk`
**Lines**: 96-104

Replace entire cfg Map with:
```ahk
cfg := Map(
    "AntiBan", "Psychopath",
    "VoiceAlerts", false,
    "WorldHop", false,
    "SortMode", "GEValue",
    "MaxSession", 240,
    "UseOCR", false,
    "StealthMode", true
)
```

Then fix comparisons:

- [ ] Line 119: Change `cfg["VoiceAlerts"] = "true"` to `cfg["VoiceAlerts"]`
- [ ] Line 306: Change `cfg["StealthMode"] = "true"` to `cfg["StealthMode"]`
- [ ] Line 336: Change first part to `cfg["StealthMode"]`
- [ ] Save file

---

### FIX #4: Add Dependency Validation (30 minutes)

**File**: `main.ahk`

**Step 1**: Add after line 112 (after global declarations):

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

**Step 2**: Modify ToggleBot() function (around line 131):

Replace the entire function with:

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

- [ ] Add ValidateEnvironment function
- [ ] Update ToggleBot function
- [ ] Save file

---

## ✅ VERIFICATION

After applying all fixes:

- [ ] Open AutoHotkey v2.0
- [ ] Run main.ahk
- [ ] Verify no syntax errors
- [ ] Press F1 to start bot
- [ ] Verify database loads successfully
- [ ] Verify BlueStacks detection works
- [ ] Verify ADB connection check works
- [ ] Check logs for any errors

---

## 📝 NOTES

- All changes are backwards compatible
- No user data will be lost
- Changes are non-breaking
- Can be reverted easily if needed

---

## 🚨 IF ERRORS OCCUR

If you encounter errors after applying fixes:

1. Check syntax - ensure all braces match
2. Verify #Include path is correct
3. Check AHK version is v2.0+
4. Review error message carefully
5. Revert changes and try again

---

## ✨ EXPECTED RESULTS

After completing this checklist:

- ✅ Bot will load item database correctly
- ✅ No duplicate JSON class
- ✅ Configuration uses correct types
- ✅ ADB connection validated on startup
- ✅ Clear error messages if dependencies missing
- ✅ Ready for detection function implementation

---

## 📚 NEXT STEPS

After completing these immediate fixes:

1. Implement IsBankOpen() detection (see DETAILED_ISSUE_FIXES.md)
2. Implement ScanBank() detection (see DETAILED_ISSUE_FIXES.md)
3. Integrate performance monitoring
4. Add comprehensive error handling

---

**Estimated Total Time**: 45 minutes
**Complexity**: Low
**Risk**: Minimal

✅ = Task completed
⚠️ = Issue encountered
❌ = Failed, needs review

---

_Quick Fix Checklist v1.0_
_Generated: 2025-11-16_
