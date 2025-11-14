# AutoHotkey v2 Code Review Checklist

## 📋 Use This Before Every Commit

This checklist helps catch common AutoHotkey v2 bugs before they make it into the codebase.

---

## ✅ Variable Scope & Global Declarations

### Global Variables
- [ ] All functions that **read** global Maps/Objects declare them as `global`
- [ ] All functions that **modify** global Maps/Objects declare them as `global`
- [ ] No accidental local variable shadowing (e.g., missing `tabConfigs` in global declaration)

### Common Global Variables in This Project
```autohotkey
// These MUST be in global declaration if used:
global userCfg          // User configuration Map
global tabConfigs       // Bank tab assignments Map
global groupToTab       // Runtime group-to-tab mapping
global cfgFile          // Config file path
global selectedBankTab  // Currently selected tab number
```

### ⚠️ Bug Pattern to Avoid
```autohotkey
// ❌ WRONG - Creates local variable
SaveData() {
    global userCfg, cfgFile  // Missing tabConfigs!
    tabConfigs := Map()      // Creates LOCAL tabConfigs
    userCfg["data"] := tabConfigs  // Saves local, not global!
}

// ✅ CORRECT - Updates global variable
SaveData() {
    global userCfg, cfgFile, tabConfigs  // Declares all globals
    tabConfigs := Map()      // Updates GLOBAL tabConfigs
    userCfg["data"] := tabConfigs  // Saves global correctly
}
```

---

## ✅ Closures & Callback Functions

### Loop Variables in Closures
- [ ] Loop variables captured in closures use **IIFE** or **.Bind()**
- [ ] No direct reference to loop variables like `A_Index`, `tabNum`, `i` in arrow functions
- [ ] Each iteration captures the **value**, not the **reference**

### ⚠️ Bug Pattern to Avoid
```autohotkey
// ❌ WRONG - All buttons call the same function with final value
Loop 8 {
    tabNum := A_Index
    btn.OnEvent("Click", (*) => SelectTab(tabNum))  // Captures reference!
}
// Result: All buttons call SelectTab(8)

// ✅ CORRECT - IIFE Pattern
Loop 8 {
    tabNum := A_Index
    btn.OnEvent("Click", ((num) => ((*) => SelectTab(num)))(tabNum))
}
// Result: Buttons call SelectTab(1), SelectTab(2), etc.

// ✅ ALSO CORRECT - .Bind() Pattern
Loop 8 {
    tabNum := A_Index
    btn.OnEvent("Click", SelectTab.Bind(tabNum))
}
```

### When Closures Are Safe
```autohotkey
// ✅ OK - No loop variable
btn.OnEvent("Click", (*) => ExitApp())

// ✅ OK - Not in a loop
selectedTab := 5
btn.OnEvent("Click", (*) => SelectTab(selectedTab))
```

---

## ✅ ListView Operations

### ListView.Modify() Syntax
- [ ] All `ListView.Modify()` calls use **empty strings ""** for skipped parameters
- [ ] No comma-only syntax for skipped parameters
- [ ] Column updates specify correct column count

### ⚠️ Bug Pattern to Avoid
```autohotkey
// ❌ WRONG - AHK v2 doesn't support comma-skipping
lvGroupsCtrl.Modify(rowNum, , , , "Tab " . assignedTab)

// ✅ CORRECT - Use empty strings
lvGroupsCtrl.Modify(rowNum, "", "", "", "Tab " . assignedTab)
```

### ListView.Modify() Reference
```autohotkey
// Syntax: ListView.Modify(RowNumber, Options, Col1, Col2, Col3, ...)

// Update only column 4 (skip columns 1-3)
lv.Modify(rowNum, "", "", "", "New Value")

// Update column 2 only
lv.Modify(rowNum, "", "New Value")

// Check a row without changing text
lv.Modify(rowNum, "Check")

// Uncheck a row
lv.Modify(rowNum, "-Check")

// Update column 4 AND check the row
lv.Modify(rowNum, "Check", "", "", "", "New Value")
```

---

## ✅ Function & Method Names

### Naming Rules
- [ ] No spaces in function names
- [ ] No spaces in method names
- [ ] PascalCase for public functions/methods
- [ ] camelCase for parameters

### ⚠️ Bug Pattern to Avoid
```autohotkey
// ❌ WRONG - Space in name
static GetItemsByCore Group(coreGroup) {
}

// ✅ CORRECT - No spaces
static GetItemsByCoreGroup(coreGroup) {
}
```

---

## ✅ String Handling

### Escaping
- [ ] Backslashes in strings are doubled: `"C:\\path\\file.txt"`
- [ ] Quotes in strings are escaped: `"He said \"hello\""`
- [ ] JSON strings are properly escaped via `StrReplace()`

### String Concatenation
```autohotkey
// ✅ Correct concatenation
msg := "Hello " . name . "!"
path := A_ScriptDir "\files\config.json"
```

---

## ✅ Map Operations

### Map Methods
- [ ] Use `Map.Has(key)` before `Map[key]` to avoid errors
- [ ] Use `Map.Delete(key)` not `Map.Remove(key)` (v2 change)
- [ ] Clone Maps when needed: `newMap := oldMap.Clone()`

### Map Iteration
```autohotkey
// ✅ Correct iteration
for key, value in myMap {
    ; Process key and value
}

// ✅ Check before accessing
if myMap.Has(key) {
    value := myMap[key]
}
```

---

## ✅ Control Flow

### Conditional Statements
- [ ] Proper parentheses: `if (condition)` not `if condition`
- [ ] Use `==` for equality, not `=` (assignment)
- [ ] Return values are checked: `if (result != "Yes")`

### Loop Patterns
```autohotkey
// ✅ Numeric loop
Loop 8 {
    index := A_Index  // 1, 2, 3, ..., 8
}

// ✅ Collection loop
for key, value in collection {
}

// ✅ Counted loop
Loop myArray.Length {
}
```

---

## ✅ Error Handling

### Try-Catch Blocks
- [ ] File operations wrapped in try-catch
- [ ] Error messages are descriptive
- [ ] Resources are cleaned up (files closed, etc.)

### Pattern
```autohotkey
try {
    if FileExist(filePath)
        FileDelete(filePath)
    FileAppend(content, filePath)
} catch as err {
    MsgBox("Error: " . err.Message, "Error", "Icon!")
}
```

---

## ✅ GUI Controls

### Event Handlers
- [ ] Event names are correct: `"Click"`, `"Change"`, `"ItemCheck"`, etc.
- [ ] Handler signatures match: `OnClick(GuiCtrlObj, Info)` or `(*) => ...`
- [ ] Global GUI controls are declared global in handlers

### Common Events
```autohotkey
Button.OnEvent("Click", OnButtonClick)
CheckBox.OnEvent("Click", OnCheckBoxClick)
ListView.OnEvent("ItemCheck", OnItemCheck)
ListView.OnEvent("Click", OnListViewClick)
DropDownList.OnEvent("Change", OnDropDownChange)
```

---

## ✅ File Operations

### File Paths
- [ ] Use `A_ScriptDir` for script-relative paths
- [ ] Use backslashes `\` for Windows paths
- [ ] Check `FileExist()` before reading
- [ ] Delete before writing to avoid append issues

### Pattern
```autohotkey
// ✅ Correct file handling
configFile := A_ScriptDir "\user_config.json"

if FileExist(configFile) {
    content := FileRead(configFile)
}

if FileExist(configFile)
    FileDelete(configFile)
FileAppend(newContent, configFile)
```

---

## ✅ JSON Handling

### JSON Operations
- [ ] Use `JSON.Stringify()` for Maps/Objects to JSON
- [ ] Use `JSON.Parse()` for JSON to Maps/Objects
- [ ] Handle parse errors with try-catch

### Pattern
```autohotkey
// ✅ Serialize Map to JSON
jsonString := JSON.Stringify(myMap)

// ✅ Parse JSON to Map
try {
    myMap := JSON.Parse(jsonString)
} catch as err {
    MsgBox("Invalid JSON: " . err.Message)
}
```

---

## ✅ Common Pitfalls in This Project

### Bank Tab System
- [ ] `groupToTab` and `tabConfigs` are kept in sync
- [ ] Tab numbers are 1-based (1-8) for UI, 0-based for storage (tab_0 to tab_7)
- [ ] Conversion formula: `tabKey := "tab_" . (tabNum - 1)`
- [ ] Reverse formula: `tabNum := Integer(SubStr(tabKey, 5)) + 1`

### Exclusive Assignment
- [ ] Check if group is already assigned before reassignment
- [ ] Parent core groups check all subgroups for conflicts
- [ ] Update both `groupToTab` AND `tabConfigs` on save

---

## 📊 Pre-Commit Checklist

Before committing code changes:

1. [ ] Run validation script: `.claude/scripts/validate_ahk.sh`
2. [ ] Review all modified .ahk files against this checklist
3. [ ] Test the GUI manually on Windows machine
4. [ ] Verify no syntax errors when script loads
5. [ ] Check git diff for any obvious issues:
   ```bash
   git diff config_gui.ahk
   git diff item_grouping.ahk
   ```
6. [ ] Run full functionality test if SaveAllSettings modified
7. [ ] Update CHANGELOG.md if adding features or fixing bugs

---

## 🔍 Quick Issue Detection Commands

```bash
# Find potential spaces in function names
grep -n "^[[:space:]]*\(static\s\+\)\?[A-Za-z_][A-Za-z0-9_]* [A-Za-z].*(" *.ahk

# Find ListView.Modify with commas
grep -n "\.Modify([^)]*,\s*,\s*," *.ahk

# Find closures with loop variables
grep -n "=>\s*.*A_Index\|=>\s*.*tabNum" *.ahk

# Find Map assignments (check for global declaration)
grep -n "^\s*[A-Za-z_][A-Za-z0-9_]*\s*:=\s*Map()" *.ahk

# Count braces
echo "Open braces:  $(grep -o '{' config_gui.ahk | wc -l)"
echo "Close braces: $(grep -o '}' config_gui.ahk | wc -l)"
```

---

## 💡 Tips for Error-Free Code

1. **Always declare globals explicitly** - Don't rely on implicit behavior
2. **Use IIFE for loop closures** - It's verbose but prevents bugs
3. **Test on target platform** - Run .ahk files on Windows to catch runtime errors
4. **Check parameters** - Verify function calls match signatures
5. **Read error messages carefully** - AHK v2 errors are usually very specific
6. **Use comments** - Explain complex closure patterns or conversions
7. **Keep functions small** - Easier to verify global declarations
8. **Test edge cases** - Empty arrays, null values, missing keys

---

## 🐛 Bugs We've Fixed (Learning Reference)

### Bug #1: Closure Capture (Commit 7f76aa9)
**Pattern**: Loop variable in arrow function closure
**Fix**: Use IIFE pattern to capture value

### Bug #2: Missing Global Declaration (Commit 353c00d)
**Pattern**: Assigning to global variable without declaration
**Fix**: Add variable to global declaration

### Bug #3: ListView.Modify Syntax (Commit 421f8f1)
**Pattern**: Using commas to skip parameters
**Fix**: Use empty strings ""

### Bug #4: Space in Method Name (Commit 4d61312)
**Pattern**: `GetItemsByCore Group` with space
**Fix**: Remove space: `GetItemsByCoreGroup`

---

**Last Updated**: 2025-11-14
**Version**: 1.0.0
