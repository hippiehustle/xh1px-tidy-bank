#Requires AutoHotkey v2.0

; ==========================================
; xh1px's Tidy Bank - Bot Generator
; Version: 1.0.0
; ==========================================

class JSON {
    static Parse(text) {
        text := Trim(text)
        if (SubStr(text, 1, 1) == "{")
            return JSON._ParseObject(text, &pos := 1)
        return ""
    }
    static _ParseObject(text, &pos) {
        obj := Map()
        pos++
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        if (SubStr(text, pos, 1) == "}")
            return obj
        loop {
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            if (SubStr(text, pos, 1) != '"')
                throw Error("Expected string key")
            key := JSON._ParseString(text, &pos)
            while (pos <= StrLen(text) && InStr(" `t`r`n:", SubStr(text, pos, 1)))
                pos++
            value := JSON._ParseValue(text, &pos)
            obj[key] := value
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            ch := SubStr(text, pos, 1)
            if (ch == "}")
                return obj
            if (ch == ",") {
                pos++
                continue
            }
        }
        return obj
    }
    static _ParseArray(text, &pos) {
        arr := []
        pos++
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        if (SubStr(text, pos, 1) == "]")
            return arr
        loop {
            value := JSON._ParseValue(text, &pos)
            arr.Push(value)
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            ch := SubStr(text, pos, 1)
            if (ch == "]")
                return arr
            if (ch == ",") {
                pos++
                continue
            }
            throw Error("Expected , or ]")
        }
        return arr
    }
    static _ParseValue(text, &pos) {
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        ch := SubStr(text, pos, 1)
        if (ch == '"')
            return JSON._ParseString(text, &pos)
        else if (ch == "{")
            return JSON._ParseObject(text, &pos)
        else if (ch == "[")
            return JSON._ParseArray(text, &pos)
        else if (ch == "t") {
            pos += 4
            return true
        }
        else if (ch == "f") {
            pos += 5
            return false
        }
        else if (ch == "n") {
            pos += 4
            return ""
        }
        else if (InStr("0123456789-", ch))
            return JSON._ParseNumber(text, &pos)
        return ""
    }
    static _ParseString(text, &pos) {
        pos++
        start := pos
        while (pos <= StrLen(text)) {
            ch := SubStr(text, pos, 1)
            if (ch == '"') {
                result := SubStr(text, start, pos - start)
                pos++
                return result
            }
            if (ch == "\")
                pos++
            pos++
        }
        return ""
    }
    static _ParseNumber(text, &pos) {
        start := pos
        while (pos <= StrLen(text)) {
            ch := SubStr(text, pos, 1)
            if (!InStr("0123456789.-+", ch))
                break
            pos++
        }
        return Number(SubStr(text, start, pos - start))
    }
}

try {
    cfg := JSON.Parse(FileRead("user_config.json"))
} catch as err {
    MsgBox("Error loading config: " err.Message "`n`nPlease run config_gui.ahk first!", "xh1px's Tidy Bank - Error", 16)
    ExitApp()
}

template := A_ScriptDir "\main_template.ahk"
output := A_ScriptDir "\main.ahk"

if !FileExist(template) {
    MsgBox("Template file not found: " template, "xh1px's Tidy Bank - Error", 16)
    ExitApp()
}

content := FileRead(template)
content := StrReplace(content, "{{ANTIBAN}}", cfg["AntiBan"])
content := StrReplace(content, "{{VOICE}}", cfg["VoiceAlerts"] ? "true" : "false")
content := StrReplace(content, "{{WORLDHOP}}", cfg["WorldHop"] ? "true" : "false")
content := StrReplace(content, "{{SORTMODE}}", cfg["SortMode"])
content := StrReplace(content, "{{MAXSESSION}}", cfg["MaxSession"])
content := StrReplace(content, "{{USEOCR}}", cfg["UseOCR"] ? "true" : "false")
content := StrReplace(content, "{{STEALTH}}", cfg["StealthMode"] ? "true" : "false")

if FileExist(output)
    FileDelete(output)
FileAppend(content, output)

stealthStatus := cfg["StealthMode"] ? "ENABLED" : "DISABLED"
MsgBox("main.ahk successfully generated!`n`nxh1px's Tidy Bank v1.0`n`nStealth Mode: " stealthStatus "`nAnti-Ban: " cfg["AntiBan"] "`nMax Session: " cfg["MaxSession"] " minutes", "Success", 64)

if FileExist(output) {
    try {
        Run('"' A_AhkPath '" "' output '"')
    }
}

ExitApp()
