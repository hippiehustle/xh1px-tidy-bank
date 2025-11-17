; ==========================================
; JSON Parser Class (Shared)
; ==========================================

class JSON {
    static Parse(text) {
        text := Trim(text)
        if (SubStr(text, 1, 1) == "{") {
            pos := 1
            return JSON._ParseObject(text, &pos)
        }
        else if (SubStr(text, 1, 1) == "[") {
            pos := 1
            return JSON._ParseArray(text, &pos)
        }
        return ""
    }

    static Stringify(obj) {
        if (obj is Map) {
            items := []
            for key, value in obj
                items.Push(JSON._EscapeString(key) . ':' . JSON.Stringify(value))
            return "{" . JSON._Join(items, ",") . "}"
        }
        else if (obj is Array) {
            items := []
            for value in obj
                items.Push(JSON.Stringify(value))
            return "[" . JSON._Join(items, ",") . "]"
        }
        else if (obj is String)
            return JSON._EscapeString(obj)
        else if (obj = true)
            return "true"
        else if (obj = false)
            return "false"
        else if (obj = "")
            return "null"
        else
            return String(obj)
    }

    static _EscapeString(str) {
        ; Escape special characters in strings
        str := StrReplace(str, "\", "\\")  ; Backslash must be first
        str := StrReplace(str, '"', '\"')  ; Quote
        str := StrReplace(str, "`n", "\n")  ; Newline
        str := StrReplace(str, "`r", "\r")  ; Carriage return
        str := StrReplace(str, "`t", "\t")  ; Tab
        str := StrReplace(str, "`b", "\b")  ; Backspace
        str := StrReplace(str, "`f", "\f")  ; Form feed
        return '"' . str . '"'
    }

    static _ParseObject(text, &pos) {
        textLen := StrLen(text)
        obj := Map()
        pos++
        JSON._SkipWhitespace(text, &pos)

        if (pos > textLen) {
            throw Error("Unexpected end of object at pos " . pos)
        }

        if (SubStr(text, pos, 1) == "}")
            return obj

        loop {
            JSON._SkipWhitespace(text, &pos)
            if (pos > textLen) {
                throw Error("Unexpected end of object while parsing key at pos " . pos)
            }
            if (SubStr(text, pos, 1) != '"')
                throw Error("Expected string key at pos " . pos . ", got '" . SubStr(text, pos, 1) . "'")
            key := JSON._ParseString(text, &pos)
            JSON._SkipWhitespace(text, &pos)
            if (pos > textLen) {
                throw Error("Unexpected end of object after key at pos " . pos)
            }
            if (SubStr(text, pos, 1) != ":")
                throw Error("Expected : after key at pos " . pos . ", got '" . SubStr(text, pos, 1) . "'")
            pos++
            value := JSON._ParseValue(text, &pos)
            obj[key] := value
            JSON._SkipWhitespace(text, &pos)
            if (pos > textLen) {
                throw Error("Unexpected end of object after value at pos " . pos)
            }
            ch := SubStr(text, pos, 1)
            if (ch == "}")
                return obj
            if (ch == ",") {
                pos++
                continue
            }
            throw Error("Expected , or } but got '" . ch . "' at pos " . pos)
        }
        return obj
    }

    static _SkipWhitespace(text, &pos) {
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
    }

    static _ParseArray(text, &pos) {
        textLen := StrLen(text)
        arr := []
        pos++
        JSON._SkipWhitespace(text, &pos)

        if (pos > textLen) {
            throw Error("Unexpected end of array at pos " . pos)
        }

        if (SubStr(text, pos, 1) == "]")
            return arr

        loop {
            value := JSON._ParseValue(text, &pos)
            arr.Push(value)
            JSON._SkipWhitespace(text, &pos)
            if (pos > textLen) {
                throw Error("Unexpected end of array after value at pos " . pos)
            }
            ch := SubStr(text, pos, 1)
            if (ch == "]")
                return arr
            if (ch == ",") {
                pos++
                continue
            }
            throw Error("Expected , or ] but got '" . ch . "' at pos " . pos)
        }
        return arr
    }

    static _ParseValue(text, &pos) {
        textLen := StrLen(text)
        JSON._SkipWhitespace(text, &pos)

        if (pos > textLen) {
            throw Error("Unexpected end of input at pos " . pos)
        }

        ch := SubStr(text, pos, 1)
        if (ch == '"')
            return JSON._ParseString(text, &pos)
        else if (ch == "{")
            return JSON._ParseObject(text, &pos)
        else if (ch == "[")
            return JSON._ParseArray(text, &pos)
        else if (ch == "t") {
            if (pos + 3 <= textLen) {
                pos += 4
                return true
            }
            throw Error("Invalid boolean at pos " . pos)
        }
        else if (ch == "f") {
            if (pos + 4 <= textLen) {
                pos += 5
                return false
            }
            throw Error("Invalid boolean at pos " . pos)
        }
        else if (ch == "n") {
            if (pos + 3 <= textLen) {
                pos += 4
                return ""
            }
            throw Error("Invalid null at pos " . pos)
        }
        else if (InStr("0123456789-", ch))
            return JSON._ParseNumber(text, &pos)
        throw Error("Unexpected character '" . ch . "' at pos " . pos)
    }

    static _ParseString(text, &pos) {
        textLen := StrLen(text)
        if (pos > textLen || SubStr(text, pos, 1) != '"')
            throw Error("Expected string at pos " . pos)
        pos++
        start := pos
        while (pos <= textLen) {
            ch := SubStr(text, pos, 1)
            if (ch == '"') {
                result := SubStr(text, start, pos - start)
                pos++
                return result
            }
            if (ch == "\") {
                pos++  ; Skip the backslash
                if (pos <= textLen) {
                    nextChar := SubStr(text, pos, 1)
                    ; Valid escape sequences: \", \\, \/, \b, \f, \n, \r, \t, \uXXXX
                    if (nextChar == "u") {
                        ; Unicode escape: \uXXXX - at 'u', need to skip u (1) + 4 hex digits (4) = 5 total
                        if (pos + 4 <= textLen) {
                            pos += 5  ; Skip u and 4 hex digits
                        } else {
                            pos++  ; Just skip u, rest will be caught as unterminated
                        }
                    } else {
                        ; Single character escape
                        pos++
                    }
                }
            } else {
                pos++
            }
        }
        throw Error("Unterminated string at pos " . start)
    }

    static _ParseNumber(text, &pos) {
        start := pos
        textLen := StrLen(text)

        while (pos <= textLen) {
            ch := SubStr(text, pos, 1)
            ; Valid number characters: digits, minus, plus, dot, e/E
            if (!InStr("0123456789.-+eE", ch))
                break
            pos++
        }

        numStr := SubStr(text, start, pos - start)
        result := Number(numStr)

        if (result == "" || !IsNumber(result)) {
            throw Error("Invalid number '" . numStr . "' at pos " . start)
        }

        return result
    }

    static IsNumber(val) {
        ; Check if value is a valid number
        return (val != "") && !IsNaN(val)
    }

    static _Join(items, sep) {
        result := ""
        for item in items {
            if (result != "")
                result .= sep
            result .= item
        }
        return result
    }
}
