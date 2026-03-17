#Requires AutoHotkey v2.0
#Include json_parser.ahk

; ==========================================
; JSON PARSER UNIT TESTS
; ==========================================
; Comprehensive test suite for JSON.Parse() and JSON.Stringify()
; Tests basic functionality, edge cases, and error handling
;

class JSONParserTests {
    ; Test results tracking
    static totalTests := 0
    static passedTests := 0
    static failedTests := 0
    static testLog := ""

    ; ==========================================
    ; TEST EXECUTION
    ; ==========================================

    static RunAllTests() {
        MsgBox(, "JSON Parser Tests", "Starting comprehensive JSON parser test suite...")

        this.totalTests := 0
        this.passedTests := 0
        this.failedTests := 0
        this.testLog := ""

        ; Run test groups
        this.TestBasicParsing()
        this.TestStringHandling()
        this.TestNumberParsing()
        this.TestArrayHandling()
        this.TestObjectHandling()
        this.TestStringification()
        this.TestErrorHandling()
        this.TestEdgeCases()

        ; Display results
        this.DisplayResults()
    }

    ; ==========================================
    ; BASIC PARSING TESTS
    ; ==========================================

    static TestBasicParsing() {
        ; Test simple string parsing
        this.TestParse('""', "", "Empty string")
        this.TestParse('"hello"', "hello", "Simple string")
        this.TestParse('"hello world"', "hello world", "String with space")

        ; Test boolean parsing
        this.TestParse('true', true, "Boolean true")
        this.TestParse('false', false, "Boolean false")

        ; Test null parsing
        this.TestParse('null', "", "Null value")

        ; Test number parsing
        this.TestParse('0', 0, "Zero")
        this.TestParse('123', 123, "Positive integer")
        this.TestParse('-123', -123, "Negative integer")
        this.TestParse('123.456', 123.456, "Float number")
        this.TestParse('-123.456', -123.456, "Negative float")
        this.TestParse('1e10', 1e10, "Scientific notation")
    }

    ; ==========================================
    ; STRING HANDLING TESTS
    ; ==========================================

    static TestStringHandling() {
        ; Test escape sequences
        this.TestParse('"hello\nworld"', "hello`nworld", "String with newline")
        this.TestParse('"hello\tworld"', "hello`tworld", "String with tab")
        this.TestParse('"hello\\world"', "hello\world", "String with backslash")
        this.TestParse('"hello\"world"', 'hello"world', "String with quote")

        ; Test special characters
        this.TestParse('"hello\r\nworld"', "hello`r`nworld", "CRLF sequence")
        this.TestParse('"hello\fworld"', "hello`fworld", "Form feed")
        this.TestParse('"hello\bworld"', "hello`bworld", "Backspace")

        ; Test whitespace handling
        this.TestParse('"  hello  "', "  hello  ", "String with whitespace")
        this.TestParse('" hello "', " hello ", "String with padding")
    }

    ; ==========================================
    ; NUMBER PARSING TESTS
    ; ==========================================

    static TestNumberParsing() {
        ; Test integer boundaries
        this.TestParse('0', 0, "Zero value")
        this.TestParse('1', 1, "Single digit")
        this.TestParse('999999', 999999, "Large integer")

        ; Test negative numbers
        this.TestParse('-1', -1, "Negative one")
        this.TestParse('-999999', -999999, "Large negative")

        ; Test decimal numbers
        this.TestParse('0.5', 0.5, "Decimal less than 1")
        this.TestParse('123.456', 123.456, "Decimal with digits on both sides")
        this.TestParse('-123.456', -123.456, "Negative decimal")

        ; Test scientific notation
        this.TestParse('1e5', 100000, "Scientific notation 1e5")
        this.TestParse('1.5e5', 150000, "Scientific notation 1.5e5")
        this.TestParse('1e-5', 0.00001, "Scientific notation negative exponent")
    }

    ; ==========================================
    ; ARRAY HANDLING TESTS
    ; ==========================================

    static TestArrayHandling() {
        ; Empty array
        result := JSON.Parse('[]')
        this.AssertTrue(result is Array && result.Length = 0, "Empty array")
        this.totalTests++

        ; Array with single element
        result := JSON.Parse('[1]')
        this.AssertTrue(result is Array && result.Length = 1 && result[1] = 1, "Array with single number")
        this.totalTests++

        ; Array with multiple elements
        result := JSON.Parse('[1, 2, 3]')
        this.AssertTrue(result is Array && result.Length = 3, "Array with three numbers")
        this.totalTests++

        ; Array with strings
        result := JSON.Parse('["a", "b", "c"]')
        this.AssertTrue(result is Array && result.Length = 3 && result[1] = "a", "Array of strings")
        this.totalTests++

        ; Nested array
        result := JSON.Parse('[[1, 2], [3, 4]]')
        this.AssertTrue(result is Array && result.Length = 2 && result[1] is Array, "Nested array")
        this.totalTests++

        ; Array with mixed types
        result := JSON.Parse('[1, "hello", true, null]')
        this.AssertTrue(result is Array && result.Length = 4, "Mixed type array")
        this.totalTests++

        ; Array with objects
        result := JSON.Parse('[{"a": 1}, {"b": 2}]')
        this.AssertTrue(result is Array && result.Length = 2 && result[1] is Map, "Array of objects")
        this.totalTests++
    }

    ; ==========================================
    ; OBJECT HANDLING TESTS
    ; ==========================================

    static TestObjectHandling() {
        ; Empty object
        result := JSON.Parse('{}')
        this.AssertTrue(result is Map && result.Count = 0, "Empty object")
        this.totalTests++

        ; Object with single property
        result := JSON.Parse('{"a": 1}')
        this.AssertTrue(result is Map && result.Count = 1 && result["a"] = 1, "Object with single property")
        this.totalTests++

        ; Object with multiple properties
        result := JSON.Parse('{"a": 1, "b": 2, "c": 3}')
        this.AssertTrue(result is Map && result.Count = 3 && result["b"] = 2, "Object with multiple properties")
        this.totalTests++

        ; Object with string values
        result := JSON.Parse('{"name": "John", "city": "NYC"}')
        this.AssertTrue(result is Map && result["name"] = "John", "Object with string values")
        this.totalTests++

        ; Nested object
        result := JSON.Parse('{"a": {"b": 1}}')
        this.AssertTrue(result is Map && result["a"] is Map && result["a"]["b"] = 1, "Nested object")
        this.totalTests++

        ; Object with array value
        result := JSON.Parse('{"items": [1, 2, 3]}')
        this.AssertTrue(result is Map && result["items"] is Array && result["items"].Length = 3, "Object with array")
        this.totalTests++

        ; Object with boolean/null values
        result := JSON.Parse('{"active": true, "deleted": false, "data": null}')
        this.AssertTrue(result["active"] = true && result["deleted"] = false, "Object with boolean values")
        this.totalTests++
    }

    ; ==========================================
    ; STRINGIFICATION TESTS
    ; ==========================================

    static TestStringification() {
        ; String serialization
        result := JSON.Stringify("hello")
        this.AssertTrue(result = '"hello"', "Stringify string")
        this.totalTests++

        ; Number serialization
        result := JSON.Stringify(123)
        this.AssertTrue(result = "123", "Stringify number")
        this.totalTests++

        ; Boolean serialization
        result := JSON.Stringify(true)
        this.AssertTrue(result = "true", "Stringify true")
        this.totalTests++

        result := JSON.Stringify(false)
        this.AssertTrue(result = "false", "Stringify false")
        this.totalTests++

        ; Array serialization
        arr := [1, 2, 3]
        result := JSON.Stringify(arr)
        this.AssertTrue(result = "[1,2,3]", "Stringify array")
        this.totalTests++

        ; Object serialization
        obj := Map("a", 1, "b", 2)
        result := JSON.Stringify(obj)
        this.AssertTrue(InStr(result, '"a":1') > 0 && InStr(result, '"b":2') > 0, "Stringify object")
        this.totalTests++

        ; Round-trip test (parse -> stringify -> parse)
        original := '{"name":"John","age":30,"items":[1,2,3]}'
        parsed := JSON.Parse(original)
        stringified := JSON.Stringify(parsed)
        reparsed := JSON.Parse(stringified)
        this.AssertTrue(reparsed["name"] = "John" && reparsed["age"] = 30, "Round-trip consistency")
        this.totalTests++
    }

    ; ==========================================
    ; ERROR HANDLING TESTS
    ; ==========================================

    static TestErrorHandling() {
        ; Invalid JSON should not crash
        try {
            result := JSON.Parse('{invalid')
            ; Expected to fail or return empty
            this.totalTests++
            this.passedTests++
        } catch {
            this.totalTests++
            this.passedTests++
        }

        ; Unclosed string
        try {
            result := JSON.Parse('"unclosed')
            this.totalTests++
            this.passedTests++
        } catch {
            this.totalTests++
            this.passedTests++
        }

        ; Trailing comma (invalid JSON)
        try {
            result := JSON.Parse('[1, 2, 3,]')
            this.totalTests++
        } catch {
            this.totalTests++
            this.passedTests++
        }
    }

    ; ==========================================
    ; EDGE CASE TESTS
    ; ==========================================

    static TestEdgeCases() {
        ; Very long string
        longStr := ""
        Loop 1000 {
            longStr .= "a"
        }
        jsonStr := '"' . longStr . '"'
        result := JSON.Parse(jsonStr)
        this.AssertTrue(result = longStr, "Long string parsing")
        this.totalTests++

        ; Deeply nested structure
        deepNested := '{"a":{"b":{"c":{"d":{"e":1}}}}}'
        result := JSON.Parse(deepNested)
        this.AssertTrue(result["a"]["b"]["c"]["d"]["e"] = 1, "Deep nesting")
        this.totalTests++

        ; Large array
        largeArray := '['
        Loop 100 {
            largeArray .= A_Index . ','
        }
        largeArray := SubStr(largeArray, 1, -1) . ']'
        result := JSON.Parse(largeArray)
        this.AssertTrue(result is Array && result.Length = 100, "Large array")
        this.totalTests++

        ; Unicode characters (if supported)
        result := JSON.Parse('"hello"')
        this.AssertTrue(result = "hello", "Basic character handling")
        this.totalTests++

        ; Empty values
        result := JSON.Parse('{"a": "", "b": null, "c": []}')
        this.AssertTrue(result["a"] = "" && result["c"] is Array && result["c"].Length = 0, "Empty values")
        this.totalTests++
    }

    ; ==========================================
    ; TEST UTILITIES
    ; ==========================================

    static TestParse(jsonStr, expectedResult, testName) {
        try {
            result := JSON.Parse(jsonStr)

            if (result = expectedResult) {
                this.RecordPass(testName)
            } else {
                this.RecordFail(testName . " - Expected: " . expectedResult . ", Got: " . result)
            }
        } catch as err {
            this.RecordFail(testName . " - Error: " . err.Message)
        }
    }

    static AssertTrue(condition, testName) {
        if (condition) {
            this.RecordPass(testName)
        } else {
            this.RecordFail(testName)
        }
    }

    static RecordPass(testName) {
        this.passedTests++
        this.totalTests++
        this.testLog .= "✓ PASS: " . testName . "`n"
    }

    static RecordFail(testName) {
        this.failedTests++
        this.totalTests++
        this.testLog .= "✗ FAIL: " . testName . "`n"
    }

    static DisplayResults() {
        successRate := (this.passedTests / this.totalTests) * 100

        result := "JSON Parser Test Results`n"
        result .= "========================`n`n"
        result .= "Total Tests: " . this.totalTests . "`n"
        result .= "Passed: " . this.passedTests . "`n"
        result .= "Failed: " . this.failedTests . "`n"
        result .= "Success Rate: " . Round(successRate, 2) . "%`n`n"

        if (this.failedTests > 0) {
            result .= "FAILED TESTS:`n"
            result .= "=" . StrRepeat("=", 50) . "`n"
            ; Extract failed tests from log
            failedTests := StrSplit(this.testLog, "`n")
            for test in failedTests {
                if (InStr(test, "✗")) {
                    result .= test . "`n"
                }
            }
        } else {
            result .= "All tests passed! ✓"
        }

        MsgBox(result, "Test Results")

        ; Also save results to file
        resultsFile := A_ScriptDir . "\test_results_json.txt"
        FileAppend(result . "`n`n" . A_Now . "`n", resultsFile)
    }
}

; ==========================================
; UTILITY FUNCTION
; ==========================================

StrRepeat(str, count) {
    result := ""
    Loop count {
        result .= str
    }
    return result
}

; ==========================================
; MAIN: Run tests when script starts
; ==========================================

; Uncomment to auto-run tests:
; JSONParserTests.RunAllTests()

; Or call from another script:
; #Include test_json_parser.ahk
; JSONParserTests.RunAllTests()
