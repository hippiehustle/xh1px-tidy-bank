# Quick Fix Checklist

## Critical Fixes Required

### main.ahk - String Concatenation Errors

- [ ] **Line 141** - Add concatenation operator:
  ```ahk
  - MsgBox("Database file not found: " dbPath, ...
  + MsgBox("Database file not found: " . dbPath, ...
  ```

- [ ] **Line 179** - Add concatenation operator:
  ```ahk
  - Log("Screenshot error: " err.Message)
  + Log("Screenshot error: " . err.Message)
  ```

---

## High Priority Fixes - Add Missing Global Declarations to main.ahk

- [ ] **Line 93** - `PanicAbort()`:
  ```ahk
  PanicAbort() {
      global adb
      ...
  ```

- [ ] **Line 105** - `BankSortLoop()`:
  ```ahk
  BankSortLoop() {
      global cfg, screenshot
      ...
  ```

- [ ] **Line 183** - `ScanBank()`:
  ```ahk
  ScanBank() {
      global screenshot
      ...
  ```

- [ ] **Line 242** - `SortItems()`:
  ```ahk
  SortItems(items, mode) {
      global db, cfg
      ...
  ```

- [ ] **Line 284** - `UI_Drag()`:
  ```ahk
  UI_Drag(sx, sy, ex, ey) {
      global adb, cfg
      ...
  ```

- [ ] **Line 314** - `AntiBan()`:
  ```ahk
  AntiBan() {
      global cfg, sessionStart
      ...
  ```

- [ ] **Line 378** - `OpenBank()`:
  ```ahk
  OpenBank() {
      global adb
      ...
  ```

- [ ] **Line 386** - `ElapsedHours()`:
  ```ahk
  ElapsedHours() {
      global sessionStart
      ...
  ```

---

## Medium Priority Fixes

- [ ] **main_template_v2.ahk:1257** - Fix time calculation:
  ```ahk
  - timeDiff := (A_TickCount - FileGetTime(screenshot, "M")) / 1000
  + timeDiff := A_Now - FileGetTime(screenshot)
  ```

- [ ] **performance.ahk:1** - Add missing include:
  ```ahk
  #Requires AutoHotkey v2.0
  #Include constants.ahk  ; <-- Add this line
  ```

---

## Verification Checklist

After applying all fixes:

- [ ] All string concatenation operators are present (2 changes)
- [ ] All global declarations added (8 functions in main.ahk)
- [ ] Time calculation fixed (main_template_v2.ahk)
- [ ] Include added to performance.ahk
- [ ] Script syntax check passes
- [ ] Error functions produce readable error messages
- [ ] Time-based detection works correctly

---

## Summary

- **Total Issues:** 12
- **Critical Issues:** 2 (string concatenation)
- **High Priority:** 8 (missing globals)
- **Medium Priority:** 2 (logic bug, dependency)

**Estimated Fix Time:** 15-20 minutes
**Lines to Change:** 12 functions across 3 files
