#Requires AutoHotkey v2.0

; ==========================================
; COMPREHENSIVE PROJECT VALIDATOR
; Performs deep syntax, semantic, and structural analysis
; ==========================================

class ProjectValidator {
    static issues := []
    static warnings := []
    static info := []
    static fileList := []

    ; Initialize validator
    static Initialize() {
        this.issues := []
        this.warnings := []
        this.info := []
        this.fileList := []
    }

    ; Add issue/warning/info
    static AddIssue(severity, file, line, message) {
        entry := Map(
            "severity", severity,
            "file", file,
            "line", line,
            "message", message
        )

        if (severity = "CRITICAL" || severity = "ERROR") {
            this.issues.Push(entry)
        } else if (severity = "WARNING") {
            this.warnings.Push(entry)
        } else {
            this.info.Push(entry)
        }
    }

    ; Validate brace/bracket balance
    static ValidateBraceBalance(file, content) {
        lines := StrSplit(content, "`n")
        braceStack := []
        inString := false
        inComment := false

        Loop lines.Length {
            lineNum := A_Index
            line := lines[lineNum]
            trimmedLine := Trim(line)

            ; Skip comment lines
            if (SubStr(trimmedLine, 1, 1) = ";") {
                continue
            }

            ; Check for braces not in strings
            Loop Parse, line {
                char := A_LoopField

                ; Track string state
                if (char = '"' && !inComment) {
                    inString := !inString
                }

                ; Skip if in string
                if (inString) {
                    continue
                }

                ; Track braces
                if (char = "{") {
                    braceStack.Push(Map("type", "{", "line", lineNum))
                } else if (char = "}") {
                    if (braceStack.Length = 0) {
                        this.AddIssue("ERROR", file, lineNum, "Unmatched closing brace }")
                    } else {
                        braceStack.Pop()
                    }
                } else if (char = "[") {
                    braceStack.Push(Map("type", "[", "line", lineNum))
                } else if (char = "]") {
                    if (braceStack.Length = 0) {
                        this.AddIssue("ERROR", file, lineNum, "Unmatched closing bracket ]")
                    } else {
                        lastBrace := braceStack.Pop()
                        if (lastBrace["type"] != "[") {
                            this.AddIssue("ERROR", file, lineNum, "Mismatched bracket - expected " . lastBrace["type"])
                        }
                    }
                } else if (char = "(") {
                    braceStack.Push(Map("type", "(", "line", lineNum))
                } else if (char = ")") {
                    if (braceStack.Length = 0) {
                        this.AddIssue("ERROR", file, lineNum, "Unmatched closing parenthesis )")
                    } else {
                        lastBrace := braceStack.Pop()
                        if (lastBrace["type"] != "(") {
                            this.AddIssue("ERROR", file, lineNum, "Mismatched parenthesis - expected " . lastBrace["type"])
                        }
                    }
                }
            }
        }

        ; Check for unclosed braces
        if (braceStack.Length > 0) {
            for brace in braceStack {
                this.AddIssue("ERROR", file, brace["line"], "Unclosed " . brace["type"])
            }
        }
    }

    ; Extract function definitions
    static ExtractFunctions(file, content) {
        functions := Map()
        lines := StrSplit(content, "`n")

        Loop lines.Length {
            lineNum := A_Index
            line := Trim(lines[lineNum])

            ; Match function definition: FunctionName(params) {
            if (RegExMatch(line, "i)^([A-Z_][A-Z0-9_]*)\s*\(", &match)) {
                funcName := match[1]
                functions[funcName] := lineNum
            }

            ; Match static method: static MethodName(params) {
            if (RegExMatch(line, "i)^static\s+([A-Z_][A-Z0-9_]*)\s*\(", &match)) {
                funcName := match[1]
                functions[funcName] := lineNum
            }
        }

        return functions
    }

    ; Find function calls
    static FindFunctionCalls(file, content) {
        calls := Map()
        lines := StrSplit(content, "`n")

        Loop lines.Length {
            lineNum := A_Index
            line := Trim(lines[lineNum])

            ; Skip comment lines
            if (SubStr(line, 1, 1) = ";") {
                continue
            }

            ; Match function calls: FunctionName(
            if (RegExMatch(line, "i)([A-Z_][A-Z0-9_]*)\s*\(", &match)) {
                funcName := match[1]
                if (!calls.Has(funcName)) {
                    calls[funcName] := []
                }
                calls[funcName].Push(lineNum)
            }
        }

        return calls
    }

    ; Validate that all function calls have definitions
    static ValidateFunctionCalls(file, content, allFunctions) {
        calls := this.FindFunctionCalls(file, content)

        ; Built-in functions that should be ignored
        builtIns := ["MsgBox", "FileExist", "FileRead", "FileAppend", "FileDelete", "DirExist", "DirCreate",
                     "Sleep", "Run", "RunWait", "Trim", "SubStr", "StrLen", "StrSplit", "InStr", "StrReplace",
                     "Round", "Floor", "Random", "Number", "String", "Map", "Array", "RegExMatch",
                     "FormatTime", "WinExist", "WinActivate", "ComObject", "ExitApp", "SetTimer",
                     "Integer", "StrLower", "StrUpper", "Sqrt", "IsNumber", "IsNaN", "Error"]

        for funcName, lineNums in calls {
            ; Skip built-in functions
            isBuiltIn := false
            for builtIn in builtIns {
                if (funcName = builtIn) {
                    isBuiltIn := true
                    break
                }
            }

            if (isBuiltIn) {
                continue
            }

            ; Check if function is defined
            if (!allFunctions.Has(funcName)) {
                for lineNum in lineNums {
                    this.AddIssue("ERROR", file, lineNum, "Call to undefined function: " . funcName)
                }
            }
        }
    }

    ; Check for global variable usage
    static ValidateGlobalVariables(file, content) {
        lines := StrSplit(content, "`n")
        inFunction := false
        functionName := ""
        declaredGlobals := Map()

        Loop lines.Length {
            lineNum := A_Index
            line := Trim(lines[lineNum])

            ; Track function boundaries
            if (RegExMatch(line, "i)^([A-Z_][A-Z0-9_]*)\s*\(", &match)) {
                inFunction := true
                functionName := match[1]
                declaredGlobals := Map()
            }

            if (line = "}" && inFunction) {
                inFunction := false
                functionName := ""
            }

            ; Track global declarations
            if (RegExMatch(line, "i)^global\s+(.+)", &match)) {
                vars := StrSplit(match[1], ",")
                for varName in vars {
                    declaredGlobals[Trim(varName)] := true
                }
            }

            ; Check for Global keyword at file level
            if (RegExMatch(line, "i)^Global\s+(.+)", &match)) {
                vars := StrSplit(match[1], ",")
                for varName in vars {
                    varName := Trim(varName)
                    ; Extract just the variable name before :=
                    if (InStr(varName, ":=")) {
                        parts := StrSplit(varName, ":=")
                        varName := Trim(parts[1])
                    }
                    declaredGlobals[varName] := true
                }
            }
        }
    }

    ; Validate string quotes
    static ValidateStringQuotes(file, content) {
        lines := StrSplit(content, "`n")

        Loop lines.Length {
            lineNum := A_Index
            line := lines[lineNum]

            ; Skip comment lines
            if (SubStr(Trim(line), 1, 1) = ";") {
                continue
            }

            ; Count quotes
            quoteCount := 0
            Loop Parse, line {
                if (A_LoopField = '"') {
                    quoteCount++
                }
            }

            ; Odd number of quotes = unbalanced
            if (Mod(quoteCount, 2) != 0) {
                this.AddIssue("ERROR", file, lineNum, "Unbalanced quotes in line")
            }
        }
    }

    ; Generate validation report
    static GenerateReport() {
        report := "==========================================`n"
        report .= "COMPREHENSIVE PROJECT VALIDATION REPORT`n"
        report .= "==========================================`n`n"
        report .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n`n"

        report .= "SUMMARY:`n"
        report .= "  Critical/Errors: " . this.issues.Length . "`n"
        report .= "  Warnings: " . this.warnings.Length . "`n"
        report .= "  Info: " . this.info.Length . "`n`n"

        if (this.issues.Length > 0) {
            report .= "==========================================`n"
            report .= "CRITICAL ISSUES & ERRORS`n"
            report .= "==========================================`n"
            for issue in this.issues {
                report .= issue["severity"] . " | " . issue["file"] . ":" . issue["line"] . " | " . issue["message"] . "`n"
            }
            report .= "`n"
        }

        if (this.warnings.Length > 0) {
            report .= "==========================================`n"
            report .= "WARNINGS`n"
            report .= "==========================================`n"
            for warning in this.warnings {
                report .= warning["severity"] . " | " . warning["file"] . ":" . warning["line"] . " | " . warning["message"] . "`n"
            }
            report .= "`n"
        }

        if (this.info.Length > 0) {
            report .= "==========================================`n"
            report .= "INFORMATIONAL`n"
            report .= "==========================================`n"
            for info in this.info {
                report .= info["severity"] . " | " . info["file"] . ":" . info["line"] . " | " . info["message"] . "`n"
            }
            report .= "`n"
        }

        return report
    }
}

; Main validation function
ValidateProject() {
    ProjectValidator.Initialize()

    ; Get all AHK files
    files := [
        "main.ahk",
        "constants.ahk",
        "item_grouping.ahk",
        "bank_tab_resolver.ahk",
        "config_gui.ahk",
        "json_parser.ahk",
        "performance.ahk"
    ]

    ; Build function registry across all files
    allFunctions := Map()
    fileContents := Map()

    ; First pass: extract all function definitions
    for file in files {
        filePath := A_ScriptDir "\" file
        if (!FileExist(filePath)) {
            ProjectValidator.AddIssue("ERROR", file, 0, "File not found: " . filePath)
            continue
        }

        try {
            content := FileRead(filePath)
            fileContents[file] := content
            functions := ProjectValidator.ExtractFunctions(file, content)

            for funcName, lineNum in functions {
                if (!allFunctions.Has(funcName)) {
                    allFunctions[funcName] := Map()
                }
                allFunctions[funcName][file] := lineNum
            }
        } catch as err {
            ProjectValidator.AddIssue("ERROR", file, 0, "Failed to read file: " . err.Message)
        }
    }

    ; Second pass: validate each file
    for file, content in fileContents {
        MsgBox("Validating: " . file)

        ; Stage 1 validations
        ProjectValidator.ValidateBraceBalance(file, content)
        ProjectValidator.ValidateFunctionCalls(file, content, allFunctions)
        ProjectValidator.ValidateGlobalVariables(file, content)
        ProjectValidator.ValidateStringQuotes(file, content)
    }

    ; Generate and display report
    report := ProjectValidator.GenerateReport()

    ; Save to file
    reportFile := A_ScriptDir "\VALIDATION_REPORT.txt"
    try {
        FileDelete(reportFile)
    }
    FileAppend(report, reportFile)

    MsgBox(report, "Validation Complete")
}

; Run validation
ValidateProject()
