# AutoHotkey v2 Syntax Reference

Quick reference for AutoHotkey v2 syntax, patterns, and common gotchas.

---

## 🔤 Variable Declarations

### Global Variables
```autohotkey
; Top-level (outside functions) - automatically global
myVar := "value"
myMap := Map()

; Inside functions - must declare as global
MyFunction() {
    global myVar, myMap  ; Declare ALL globals you use
    myVar := "new value"
    myMap["key"] := "value"
}
```

### Local Variables
```autohotkey
MyFunction() {
    local myLocal := "value"  ; Optional 'local' keyword
    anotherLocal := "value"   ; Implicitly local if not declared global
}
```

### Static Variables
```autohotkey
Counter() {
    static count := 0  ; Retains value between calls
    count++
    return count
}
```

---

## 📦 Data Structures

### Arrays
```autohotkey
; Create array
arr := ["item1", "item2", "item3"]

; Access elements (1-based indexing)
first := arr[1]
last := arr[arr.Length]

; Add elements
arr.Push("item4")
arr.InsertAt(2, "inserted")  ; Insert at position 2

; Remove elements
arr.Pop()                ; Remove last
arr.RemoveAt(1)          ; Remove first
arr.Delete(index)        ; Also removes

; Iterate
for index, value in arr {
    MsgBox("Index: " . index . ", Value: " . value)
}

; Properties
length := arr.Length
capacity := arr.Capacity
```

### Maps (Dictionaries)
```autohotkey
; Create map
myMap := Map()
myMap["key1"] := "value1"
myMap["key2"] := "value2"

; Or initialize with pairs
myMap := Map("key1", "value1", "key2", "value2")

; Access elements
value := myMap["key1"]

; Check if key exists
if myMap.Has("key1") {
    value := myMap["key1"]
}

; Remove element
myMap.Delete("key1")

; Iterate
for key, value in myMap {
    MsgBox("Key: " . key . ", Value: " . value)
}

; Clone
newMap := myMap.Clone()

; Properties
count := myMap.Count
```

### Objects
```autohotkey
; Create object
obj := {
    name: "John",
    age: 30,
    address: {
        street: "123 Main St",
        city: "New York"
    }
}

; Access properties
name := obj.name
city := obj.address.city

; Add/modify properties
obj.email := "john@example.com"

; Iterate
for key, value in obj.OwnProps() {
    MsgBox(key . ": " . value)
}
```

---

## 🔄 Control Flow

### If Statements
```autohotkey
; Basic if
if (condition) {
    ; code
}

; If-else
if (condition) {
    ; code
} else {
    ; code
}

; If-else if
if (condition1) {
    ; code
} else if (condition2) {
    ; code
} else {
    ; code
}

; Ternary operator
result := (condition) ? "true value" : "false value"
```

### Loops
```autohotkey
; Basic loop (count-based)
Loop 10 {
    index := A_Index  ; A_Index is 1-based (1, 2, 3, ..., 10)
}

; Loop with variable
count := 5
Loop count {
    ; code
}

; For loop (arrays)
for index, value in myArray {
    ; index is 1-based
}

; For loop (maps)
for key, value in myMap {
    ; key and value
}

; While loop
while (condition) {
    ; code
    if (exitCondition)
        break
}

; Until loop
Loop {
    ; code
    if (exitCondition)
        break
}

; Loop control
break      ; Exit loop
continue   ; Skip to next iteration
```

---

## 📞 Functions

### Function Definition
```autohotkey
; Basic function
MyFunction() {
    return "result"
}

; With parameters
MyFunction(param1, param2) {
    return param1 + param2
}

; With default parameters
MyFunction(param1, param2 := "default") {
    return param1 . param2
}

; Variadic function (unlimited parameters)
MyFunction(params*) {
    for index, value in params {
        ; process each parameter
    }
}
```

### Arrow Functions (Lambdas)
```autohotkey
; Basic arrow function
add := (a, b) => a + b
result := add(5, 3)  ; 8

; With body
process := (x) => {
    result := x * 2
    return result
}

; No parameters
greet := () => MsgBox("Hello")

; Single parameter (parentheses optional)
double := x => x * 2
```

### Function Binding
```autohotkey
; Bind parameters
MyFunction(a, b, c) {
    return a + b + c
}

; Bind first parameter
boundFunc := MyFunction.Bind(10)
result := boundFunc(5, 3)  ; Same as MyFunction(10, 5, 3)

; Useful for event handlers
btn.OnEvent("Click", MyHandler.Bind("param"))
```

---

## 🎨 GUI Controls

### Creating GUI
```autohotkey
; Create GUI
MyGui := Gui("+Resize", "Window Title")

; Add controls
btn := MyGui.Add("Button", "x10 y10 w100 h30", "Click Me")
txt := MyGui.Add("Text", "x10 y50 w200", "Label text")
edt := MyGui.Add("Edit", "x10 y80 w200 h20", "Default text")
lv := MyGui.Add("ListView", "x10 y110 w300 h200", ["Col1", "Col2", "Col3"])

; Show GUI
MyGui.Show("w400 h400")
```

### Event Handlers
```autohotkey
; Button click
btn.OnEvent("Click", OnButtonClick)
OnButtonClick(GuiCtrlObj, Info) {
    MsgBox("Button clicked!")
}

; Or with arrow function
btn.OnEvent("Click", (*) => MsgBox("Clicked"))

; ListView events
lv.OnEvent("Click", OnListViewClick)
lv.OnEvent("ItemCheck", OnItemCheck)

OnItemCheck(GuiCtrlObj, Item, IsChecked) {
    if IsChecked {
        MsgBox("Item " . Item . " checked")
    }
}
```

### ListView Operations
```autohotkey
; Add row
lv.Add("", "Col1 Value", "Col2 Value", "Col3 Value")

; Add row with options (checked)
lv.Add("Check", "Col1", "Col2", "Col3")

; Modify row
lv.Modify(rowNum, "", "New Col1", "New Col2", "New Col3")

; Modify specific column (skip others with empty strings)
lv.Modify(rowNum, "", "", "", "New Col3")  ; Update only column 3

; Modify row options
lv.Modify(rowNum, "Check")    ; Check row
lv.Modify(rowNum, "-Check")   ; Uncheck row
lv.Modify(rowNum, "Select")   ; Select row
lv.Modify(rowNum, "Focus")    ; Focus row

; Get row count
count := lv.GetCount()

; Get selected row
selectedRow := lv.GetNext(0, "Checked")  ; Get first checked row

; Get row text
text := lv.GetText(rowNum, columnNum)

; Delete row
lv.Delete(rowNum)

; Delete all rows
lv.Delete()
```

---

## 🔗 Closures and Scope

### Problem: Loop Variable Capture
```autohotkey
; ❌ WRONG - All buttons will call same value
Loop 8 {
    i := A_Index
    btn := MyGui.Add("Button", "x10 y" . (i*40), "Button " . i)
    btn.OnEvent("Click", (*) => MsgBox("Clicked " . i))
    ; ALL buttons will show "Clicked 8" because i is captured by reference
}
```

### Solution 1: IIFE (Immediately Invoked Function Expression)
```autohotkey
; ✅ CORRECT - Each button captures its own value
Loop 8 {
    i := A_Index
    btn := MyGui.Add("Button", "x10 y" . (i*40), "Button " . i)
    ; IIFE creates new scope for each iteration
    btn.OnEvent("Click", ((num) => ((*) => MsgBox("Clicked " . num)))(i))
    ; Each button shows correct number: "Clicked 1", "Clicked 2", etc.
}
```

### Solution 2: Function Binding
```autohotkey
; ✅ CORRECT - Bind parameter to function
HandleClick(num, *) {
    MsgBox("Clicked " . num)
}

Loop 8 {
    i := A_Index
    btn := MyGui.Add("Button", "x10 y" . (i*40), "Button " . i)
    btn.OnEvent("Click", HandleClick.Bind(i))
}
```

### When Closures Work Fine
```autohotkey
; ✅ OK - Variable not in loop
selectedTab := 5
btn.OnEvent("Click", (*) => SelectTab(selectedTab))

; ✅ OK - No variable capture
btn.OnEvent("Click", (*) => ExitApp())

; ✅ OK - Direct value
btn.OnEvent("Click", (*) => SelectTab(3))
```

---

## 📝 String Operations

### Concatenation
```autohotkey
; Using dot operator
result := "Hello " . "World"
path := A_ScriptDir "\files\config.json"

; With variables
name := "John"
msg := "Hello, " . name . "!"
```

### Escaping
```autohotkey
; Escape quotes with backtick
str := "He said `"hello`""

; Or double quotes in expression
str := "He said ""hello"""

; Escape backtick
str := "This is a backtick: ``"

; Backslashes (usually don't need escaping)
path := "C:\Users\John\file.txt"

; But escape if needed
regex := "\\d+"
```

### String Functions
```autohotkey
; SubStr (1-based indexing)
substr := SubStr("Hello World", 7, 5)  ; "World"
substr := SubStr("Hello World", 7)      ; "World" (to end)

; StrReplace
result := StrReplace("Hello World", "World", "There")  ; "Hello There"

; StrLen
length := StrLen("Hello")  ; 5

; InStr (find position)
pos := InStr("Hello World", "World")  ; 7
pos := InStr("Hello World", "xyz")     ; 0 (not found)

; StrSplit
parts := StrSplit("a,b,c", ",")  ; ["a", "b", "c"]

; Trim
trimmed := Trim("  Hello  ")  ; "Hello"
trimmed := LTrim("  Hello")   ; "Hello"
trimmed := RTrim("Hello  ")   ; "Hello"

; Case conversion
upper := StrUpper("hello")  ; "HELLO"
lower := StrLower("HELLO")  ; "hello"
title := StrTitle("hello world")  ; "Hello World"
```

---

## 📄 File Operations

### Reading Files
```autohotkey
; Read entire file
content := FileRead("path\to\file.txt")

; Check if file exists first
if FileExist("path\to\file.txt") {
    content := FileRead("path\to\file.txt")
}
```

### Writing Files
```autohotkey
; Write file (creates or overwrites)
FileAppend("content", "path\to\file.txt")

; Delete then write (recommended to avoid appending)
if FileExist("path\to\file.txt")
    FileDelete("path\to\file.txt")
FileAppend("content", "path\to\file.txt")
```

### File Paths
```autohotkey
; Script directory
scriptDir := A_ScriptDir

; Full path to file
filePath := A_ScriptDir "\config\settings.json"

; Working directory
workingDir := A_WorkingDir
```

---

## 🔢 JSON Operations

### Stringify (Object/Map to JSON)
```autohotkey
; Map to JSON
myMap := Map("name", "John", "age", 30)
jsonString := JSON.Stringify(myMap)
; Result: {"name":"John","age":30}

; Array to JSON
myArray := ["item1", "item2", "item3"]
jsonString := JSON.Stringify(myArray)
; Result: ["item1","item2","item3"]
```

### Parse (JSON to Object/Map)
```autohotkey
; JSON string to Map/Object
jsonString := '{"name":"John","age":30}'
obj := JSON.Parse(jsonString)
name := obj["name"]  ; "John"

; With error handling
try {
    obj := JSON.Parse(jsonString)
} catch as err {
    MsgBox("Invalid JSON: " . err.Message)
}
```

---

## 🎯 Classes

### Basic Class
```autohotkey
class Person {
    ; Properties
    name := ""
    age := 0

    ; Constructor
    __New(name, age) {
        this.name := name
        this.age := age
    }

    ; Method
    Greet() {
        return "Hello, I'm " . this.name
    }

    ; Static method
    static Create(name, age) {
        return Person(name, age)
    }
}

; Usage
person := Person("John", 30)
msg := person.Greet()
```

### Static Methods
```autohotkey
class ItemGroupingSystem {
    static GetItemsByCoreGroup(coreGroup) {
        ; Static method - no instance needed
        return ["item1", "item2"]
    }
}

; Usage
items := ItemGroupingSystem.GetItemsByCoreGroup("Skills")
```

---

## ⚠️ Common Gotchas

### 1. Global Variable Assignment
```autohotkey
; ❌ Creates local variable
MyFunction() {
    global cfgFile
    tabConfigs := Map()  ; LOCAL variable (not declared global)
}

; ✅ Updates global variable
MyFunction() {
    global cfgFile, tabConfigs
    tabConfigs := Map()  ; GLOBAL variable
}
```

### 2. Loop Variable in Closure
```autohotkey
; ❌ All closures share same variable
Loop 5 {
    i := A_Index
    func := () => MsgBox(i)  ; All will show 5
}

; ✅ Use IIFE
Loop 5 {
    i := A_Index
    func := ((n) => () => MsgBox(n))(i)  ; Each shows correct number
}
```

### 3. ListView.Modify Parameter Skipping
```autohotkey
; ❌ WRONG in v2
lv.Modify(row, , , , "Col4")  ; Commas don't skip parameters

; ✅ CORRECT in v2
lv.Modify(row, "", "", "", "Col4")  ; Use empty strings
```

### 4. Array Indexing
```autohotkey
; Arrays are 1-based
arr := ["a", "b", "c"]
first := arr[1]  ; "a" (NOT arr[0])
last := arr[arr.Length]  ; "c"
```

### 5. String Comparison
```autohotkey
; Use == for comparison, not =
if (str == "value") {  ; ✅ Correct
}

if (str = "value") {   ; ❌ Wrong (assignment, not comparison)
}
```

### 6. Map.Has() Before Access
```autohotkey
; ❌ May throw error if key doesn't exist
value := myMap["key"]

; ✅ Check first
if myMap.Has("key") {
    value := myMap["key"]
}
```

---

## 📚 AutoHotkey v2 Changes from v1

### Major Differences
1. **Expressions everywhere** - No more legacy syntax
2. **All strings in quotes** - No auto-quoting
3. **Functions always need parentheses** - `MyFunc()` not `MyFunc`
4. **True/false are lowercase** - `true`, `false` (not `True`, `False`)
5. **Array/Map methods** - `.Push()`, `.Has()`, etc.
6. **ListView.Modify syntax** - Use empty strings, not commas
7. **No auto-concatenation** - Must use `.` operator
8. **ByRef is different** - Use `&` prefix: `MyFunc(&var)`

---

**Quick Reference Version**: 1.0.0
**Last Updated**: 2025-11-14
**AutoHotkey Version**: v2.0+
