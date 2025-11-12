#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; xh1px's Tidy Bank - Configuration GUI v3.0
; Modern Card-Based Design with Tab Navigation
; ==========================================

; COLOR SYSTEM (Preserved from original)
ColorSystem := Map(
    "PrimaryBg", "0a0e14",
    "SecondaryBg", "151b24",
    "TertiaryBg", "1a2332",
    "PrimaryAccent", "00d9ff",
    "SecondaryAccent", "0ea5e9",
    "PrimaryText", "e5f4ff",
    "SecondaryText", "7a8fa3",
    "TertiaryText", "4a5a6a",
    "ButtonBorder", "0ea5e9",
    "InputBorder", "2a3f52",
    "Success", "00d9ff",
    "Warning", "fbbf24",
    "Error", "ef4444"
)

; TYPOGRAPHY SYSTEM
TypographySystem := Map(
    "Title", Map("size", 28, "weight", 700),
    "SectionHeader", Map("size", 16, "weight", 600),
    "Subsection", Map("size", 13, "weight", 600),
    "Body", Map("size", 11, "weight", 400),
    "Small", Map("size", 10, "weight", 400)
)

; SPACING SYSTEM
SpacingSystem := Map(
    "CardPadding", 20,
    "SectionGap", 16,
    "ItemGap", 10,
    "BorderRadius", 8
)

; ==========================================
; JSON PARSER (EMBEDDED)
; ==========================================

class JSON {
    static Parse(text) {
        text := Trim(text)
        if (SubStr(text, 1, 1) == "{")
            return JSON._ParseObject(text, &pos := 1)
        else if (SubStr(text, 1, 1) == "[")
            return JSON._ParseArray(text, &pos := 1)
        return ""
    }

    static Stringify(obj) {
        if (obj is Map) {
            items := []
            for key, value in obj
                items.Push('"' . key . '":' . JSON.Stringify(value))
            return "{" . JSON._Join(items, ",") . "}"
        }
        else if (obj is Array) {
            items := []
            for value in obj
                items.Push(JSON.Stringify(value))
            return "[" . JSON._Join(items, ",") . "]"
        }
        else if (obj is String)
            return '"' . obj . '"'
        else if (obj = true)
            return "true"
        else if (obj = false)
            return "false"
        else if (obj = "")
            return "null"
        else
            return String(obj)
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
            throw Error("Expected , or }")
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
        throw Error("Unexpected character: " . ch)
    }

    static _ParseString(text, &pos) {
        if (SubStr(text, pos, 1) != '"')
            throw Error("Expected string")
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
        throw Error("Unterminated string")
    }

    static _ParseNumber(text, &pos) {
        start := pos
        while (pos <= StrLen(text)) {
            ch := SubStr(text, pos, 1)
            if (!InStr("0123456789.-+eE", ch))
                break
            pos++
        }
        return Number(SubStr(text, start, pos - start))
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

; ==========================================
; CATEGORY DEFINITIONS
; ==========================================

Global AllSkills := ["Ranged", "Magic", "Prayer", "Woodcutting", "Mining", "Fishing",
                     "Hunter", "Cooking", "Fletching", "Crafting", "Smithing", "Herblore",
                     "Runecraft", "Firemaking", "Construction", "Agility", "Thieving",
                     "Slayer", "Farming"]

Global AllItemTypes := ["Stamina Potion", "Strength Potion", "Attack Potion", "Defense Potion",
                        "Magic Potion", "Guam", "Marrentill", "Tarromin", "Spidermine", "Irit Leaf",
                        "Logs", "Oak Logs", "Willow Logs", "Maple Logs", "Yew Logs",
                        "Salmon", "Tuna", "Trout", "Mackerel", "Herring",
                        "Copper Ore", "Tin Ore", "Iron Ore", "Coal", "Mithril Ore"]

Global CategoryGroups := Map(
    "Combat Skills", ["Ranged", "Magic", "Prayer"],
    "Gathering Skills", ["Woodcutting", "Mining", "Fishing", "Hunter"],
    "Artisan Skills", ["Cooking", "Fletching", "Crafting", "Smithing", "Herblore"],
    "Support Skills", ["Runecraft", "Firemaking", "Construction", "Agility", "Thieving", "Slayer", "Farming"],
    "Potions", ["Stamina Potion", "Strength Potion", "Attack Potion", "Defense Potion", "Magic Potion"],
    "Herbs", ["Guam", "Marrentill", "Tarromin", "Spidermine", "Irit Leaf"],
    "Logs", ["Logs", "Oak Logs", "Willow Logs", "Maple Logs", "Yew Logs"],
    "Fish", ["Salmon", "Tuna", "Trout", "Mackerel", "Herring"],
    "Ore", ["Copper Ore", "Tin Ore", "Iron Ore", "Coal", "Mithril Ore"]
)

; ==========================================
; DEFAULT CONFIGURATION
; ==========================================

Global defaultCfg := Map(
    "AntiBan", "Psychopath",
    "VoiceAlerts", true,
    "WorldHop", false,
    "SortMode", "Category",
    "MaxSession", 240,
    "UseOCR", true,
    "StealthMode", true,
    "BankCategories", Map(
        "tab_0", ["Ranged", "Magic"],
        "tab_1", ["Prayer", "Agility"],
        "tab_2", ["Cooking", "Fletching"],
        "tab_3", ["Crafting", "Smithing"],
        "tab_4", ["Mining", "Woodcutting"],
        "tab_5", ["Fishing", "Hunter"],
        "tab_6", [],
        "tab_7", []
    )
)

cfgFile := "user_config.json"

; Load or create config
if !FileExist(cfgFile) {
    FileAppend(JSON.Stringify(defaultCfg), cfgFile)
}

try {
    userCfg := JSON.Parse(FileRead(cfgFile))
    if !userCfg.Has("BankCategories") {
        userCfg["BankCategories"] := defaultCfg["BankCategories"]
    }
} catch {
    userCfg := defaultCfg
    try {
        FileDelete(cfgFile)
    }
    FileAppend(JSON.Stringify(defaultCfg), cfgFile)
}

; ==========================================
; GLOBAL STATE
; ==========================================

Global MyGui
Global MainTabs
Global selectedBankTab := 1
Global tabConfigs := Map()
Global bankTabButtons := []
Global categoryCheckboxes := Map()
Global itemCheckboxes := Map()
Global txtSelectedTabInfo
Global lbxCurrentTabItems

; Initialize tab configurations
Loop 8 {
    tabKey := "tab_" (A_Index - 1)
    if userCfg["BankCategories"].Has(tabKey) {
        tabConfigs[tabKey] := userCfg["BankCategories"][tabKey]
    } else {
        tabConfigs[tabKey] := []
    }
}

; ==========================================
; GUI INITIALIZATION
; ==========================================

MyGui := Gui("+LastFound", "xh1px's Tidy Bank - Configuration v3.0")
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.BackColor := "0x" . ColorSystem["PrimaryBg"]
MyGui.SetFont("s11 c0x" . ColorSystem["PrimaryText"], "Segoe UI")

; ==========================================
; HEADER
; ==========================================

MyGui.SetFont("s28 w700 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
MyGui.Add("Text", "x30 y20 w900", "xh1px's Tidy Bank")

MyGui.SetFont("s12 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x30 y58 w900", "OSRS Bank Organization Tool - Configure your bot settings")

; Divider
MyGui.Add("Text", "x0 y95 w1000 h2 0x10 Background" . ColorSystem["InputBorder"], "")

; ==========================================
; TAB NAVIGATION
; ==========================================

MyGui.SetFont("s11 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
MainTabs := MyGui.Add("Tab3", "x0 y100 w1000 h700", ["Bot Settings", "Bank Configuration"])

; ==========================================
; TAB 1: BOT SETTINGS
; ==========================================

MainTabs.UseTab(1)

; Create settings cards
currentY := 140

; === CARD: Anti-Ban Settings ===
CreateCard(30, currentY, 450, 260, "Anti-Ban & Safety")
cardY := currentY + 50

MyGui.SetFont("s11 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x50 y" . cardY, "Anti-Ban Mode")
cardY += 25

ddlAntiBan := MyGui.Add("DropDownList", "x50 y" . cardY " w410", ["Psychopath", "Extreme", "Stealth", "Off"])
ddlAntiBan.OnEvent("Change", SaveConfig)
try {
    ddlAntiBan.Text := userCfg["AntiBan"]
} catch {
    ddlAntiBan.Choose(1)
}
cardY += 50

chkStealthMode := MyGui.Add("CheckBox", "x50 y" . cardY " c0x" . ColorSystem["PrimaryAccent"], "STEALTH MODE (Primary Safety)")
chkStealthMode.OnEvent("Click", SaveConfig)
try {
    chkStealthMode.Value := userCfg["StealthMode"]
} catch {
    chkStealthMode.Value := true
}
cardY += 40

MyGui.SetFont("s10 c0x" . ColorSystem["TertiaryText"], "Segoe UI")
MyGui.Add("Text", "x50 y" . cardY " w410", "Stealth mode adds randomized delays and natural mouse movements to avoid detection.")

; === CARD: Session Settings ===
currentY += 280
CreateCard(30, currentY, 450, 180, "Session Configuration")
cardY := currentY + 50

MyGui.SetFont("s11 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x50 y" . cardY, "Maximum Session Duration")
cardY += 25

sldMaxSession := MyGui.Add("Slider", "x50 y" . cardY " w410 Range60-480 TickInterval30", userCfg["MaxSession"])
sldMaxSession.OnEvent("Change", UpdateSliderDisplay)
cardY += 40

MyGui.SetFont("s12 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
txtMaxSession := MyGui.Add("Text", "x50 y" . cardY " w410 Center", userCfg["MaxSession"] . " minutes")

; === CARD: Features ===
currentY := 140
CreateCard(510, currentY, 450, 360, "Feature Toggles")
cardY := currentY + 50

MyGui.SetFont("s11 c0x" . ColorSystem["PrimaryText"], "Segoe UI")

chkUseOCR := MyGui.Add("CheckBox", "x530 y" . cardY, "Enable OCR Item Detection")
chkUseOCR.OnEvent("Click", SaveConfig)
try {
    chkUseOCR.Value := userCfg["UseOCR"]
} catch {
    chkUseOCR.Value := true
}
cardY += 30

MyGui.SetFont("s10 c0x" . ColorSystem["TertiaryText"], "Segoe UI")
MyGui.Add("Text", "x550 y" . cardY " w390", "Uses Tesseract OCR to identify items by name")
cardY += 40

MyGui.SetFont("s11 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
chkVoiceAlerts := MyGui.Add("CheckBox", "x530 y" . cardY, "Enable Voice Alerts")
chkVoiceAlerts.OnEvent("Click", SaveConfig)
try {
    chkVoiceAlerts.Value := userCfg["VoiceAlerts"]
} catch {
    chkVoiceAlerts.Value := true
}
cardY += 30

MyGui.SetFont("s10 c0x" . ColorSystem["TertiaryText"], "Segoe UI")
MyGui.Add("Text", "x550 y" . cardY " w390", "Provides audio notifications for important events")
cardY += 40

MyGui.SetFont("s11 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
chkWorldHop := MyGui.Add("CheckBox", "x530 y" . cardY, "Enable World Hopping (Rare)")
chkWorldHop.OnEvent("Click", SaveConfig)
try {
    chkWorldHop.Value := userCfg["WorldHop"]
} catch {
    chkWorldHop.Value := false
}
cardY += 30

MyGui.SetFont("s10 c0x" . ColorSystem["TertiaryText"], "Segoe UI")
MyGui.Add("Text", "x550 y" . cardY " w390", "Occasionally switches worlds to mimic human behavior")

; === Action Buttons ===
MyGui.SetFont("s12 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
btnSaveSettings := MyGui.Add("Button", "x30 y720 w200 h40", "Save Settings")
btnSaveSettings.OnEvent("Click", SaveAllSettings)

btnGenerateBot := MyGui.Add("Button", "x240 y720 w200 h40", "Generate Bot")
btnGenerateBot.OnEvent("Click", GenerateBot)

btnReset := MyGui.Add("Button", "x450 y720 w150 h40", "Reset to Defaults")
btnReset.OnEvent("Click", (*) => ResetToDefaults())

; ==========================================
; TAB 2: BANK CONFIGURATION
; ==========================================

MainTabs.UseTab(2)

currentY := 140

; === Bank Tab Selector ===
CreateCard(30, currentY, 940, 200, "Select Bank Tab to Configure")
cardY := currentY + 50

MyGui.SetFont("s11 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x50 y" . cardY, "Choose a bank tab (1-8) to assign skills and items:")
cardY += 35

; Create bank tab buttons in a grid
buttonStartX := 50
buttonStartY := cardY
buttonWidth := 100
buttonHeight := 40
buttonGapX := 110
buttonGapY := 50

Loop 8 {
    tabNum := A_Index
    col := Mod(tabNum - 1, 4)
    row := Floor((tabNum - 1) / 4)

    btnX := buttonStartX + (col * buttonGapX)
    btnY := buttonStartY + (row * buttonGapY)

    MyGui.SetFont("s11 w600", "Segoe UI")
    btn := MyGui.Add("Button", "x" . btnX " y" . btnY " w" . buttonWidth " h" . buttonHeight, "Tab " . tabNum)
    btn.OnEvent("Click", (*) => SelectBankTab(tabNum))
    bankTabButtons.Push(btn)
}

; === Items Assignment Section ===
currentY += 220
CreateCard(30, currentY, 620, 420, "Available Skills & Items")
cardY := currentY + 50

MyGui.SetFont("s11 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x50 y" . cardY, "Select items to assign to this tab:")
cardY += 30

; Create TreeView for organized selection
MyGui.SetFont("s10 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
tvCategories := MyGui.Add("TreeView", "x50 y" . cardY " w570 h340 Checked Background" . ColorSystem["SecondaryBg"])
tvCategories.OnEvent("Click", UpdateBankTabFromTree)

; Populate TreeView with categories
Global tvNodes := Map()
for categoryName, items in CategoryGroups {
    parentNode := tvCategories.Add(categoryName, 0, "Expand")
    tvNodes[categoryName] := Map("parent", parentNode, "children", Map())

    for item in items {
        childNode := tvCategories.Add(item, parentNode)
        tvNodes[categoryName]["children"][item] := childNode
    }
}

; === Current Tab Items ===
CreateCard(670, currentY, 300, 420, "Current Tab Items")
cardY := currentY + 50

MyGui.SetFont("s13 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
txtSelectedTabInfo := MyGui.Add("Text", "x690 y" . cardY " w260 Center", "Tab 1: 0 items")
cardY += 35

MyGui.SetFont("s10 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
lbxCurrentTabItems := MyGui.Add("ListBox", "x690 y" . cardY " w260 h340 Background" . ColorSystem["SecondaryBg"])
lbxCurrentTabItems.OnEvent("DoubleClick", RemoveItemFromTab)

MyGui.SetFont("s9 c0x" . ColorSystem["TertiaryText"], "Segoe UI")
MyGui.Add("Text", "x690 y" . (cardY + 345) " w260 Center", "Double-click to remove")

; === Action Buttons ===
currentY += 440
MyGui.SetFont("s12 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")

btnSaveBank := MyGui.Add("Button", "x30 y" . currentY " w200 h40", "Save Bank Config")
btnSaveBank.OnEvent("Click", SaveAllSettings)

btnClearTab := MyGui.Add("Button", "x240 y" . currentY " w150 h40", "Clear This Tab")
btnClearTab.OnEvent("Click", (*) => ClearCurrentBankTab())

btnResetAll := MyGui.Add("Button", "x400 y" . currentY " w150 h40", "Reset All Tabs")
btnResetAll.OnEvent("Click", (*) => ResetToDefaults())

MainTabs.UseTab()  ; End tab definition

; ==========================================
; SHOW GUI
; ==========================================

MyGui.Show("w1000 h800")

; Initialize
SelectBankTab(1)

; ==========================================
; HELPER FUNCTIONS
; ==========================================

CreateCard(x, y, width, height, title) {
    global MyGui, ColorSystem

    ; Card background
    MyGui.Add("Text", "x" . x " y" . y " w" . width " h" . height " Background" . ColorSystem["SecondaryBg"], "")

    ; Card title bar
    MyGui.Add("Text", "x" . x " y" . y " w" . width " h35 Background" . ColorSystem["TertiaryBg"], "")

    ; Card title text
    MyGui.SetFont("s13 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
    MyGui.Add("Text", "x" . (x + 15) " y" . (y + 8) " Background" . ColorSystem["TertiaryBg"], title)
}

; ==========================================
; EVENT HANDLERS
; ==========================================

SelectBankTab(tabNum) {
    global selectedBankTab, bankTabButtons, tabConfigs, txtSelectedTabInfo, lbxCurrentTabItems, tvCategories, tvNodes, ColorSystem

    selectedBankTab := tabNum
    tabKey := "tab_" (tabNum - 1)

    ; Update button visual states
    Loop 8 {
        if (A_Index == tabNum) {
            bankTabButtons[A_Index].Opt("+Background" . ColorSystem["PrimaryAccent"])
            MyGui.SetFont("s11 w700 c0x" . ColorSystem["PrimaryBg"], "Segoe UI")
            bankTabButtons[A_Index].SetFont()
        } else {
            bankTabButtons[A_Index].Opt("+BackgroundDefault")
            MyGui.SetFont("s11 w600 c0xFFFFFF", "Segoe UI")
            bankTabButtons[A_Index].SetFont()
        }
    }

    ; Update info text
    itemCount := tabConfigs[tabKey].Length
    txtSelectedTabInfo.Value := "Tab " . tabNum . ": " . itemCount . " items"

    ; Update current items listbox
    lbxCurrentTabItems.Delete()
    for item in tabConfigs[tabKey] {
        lbxCurrentTabItems.Add([item])
    }

    ; Update TreeView checkboxes
    for categoryName, categoryData in tvNodes {
        for item, nodeID in categoryData["children"] {
            isChecked := false
            for tabItem in tabConfigs[tabKey] {
                if (tabItem == item) {
                    isChecked := true
                    break
                }
            }
            tvCategories.Modify(nodeID, isChecked ? "Check" : "-Check")
        }
    }
}

UpdateBankTabFromTree(*) {
    global selectedBankTab, tabConfigs, tvCategories, tvNodes, lbxCurrentTabItems, txtSelectedTabInfo

    tabKey := "tab_" (selectedBankTab - 1)
    tabConfigs[tabKey] := []

    ; Collect all checked items from TreeView
    for categoryName, categoryData in tvNodes {
        for item, nodeID in categoryData["children"] {
            if (tvCategories.GetNext(nodeID, "Checked") == nodeID || tvCategories.GetNext(0, "Checked " nodeID)) {
                ; Check if this node is checked
                itemText := tvCategories.GetText(nodeID)

                ; Verify it's actually checked
                currentItem := tvCategories.GetNext(0, "Checked")
                loop {
                    if (!currentItem)
                        break
                    if (currentItem == nodeID) {
                        tabConfigs[tabKey].Push(item)
                        break
                    }
                    currentItem := tvCategories.GetNext(currentItem, "Checked")
                }
            }
        }
    }

    ; Update display
    lbxCurrentTabItems.Delete()
    for item in tabConfigs[tabKey] {
        lbxCurrentTabItems.Add([item])
    }

    txtSelectedTabInfo.Value := "Tab " . selectedBankTab . ": " . tabConfigs[tabKey].Length . " items"
}

RemoveItemFromTab(*) {
    global selectedBankTab, tabConfigs, lbxCurrentTabItems, txtSelectedTabInfo, tvCategories, tvNodes

    selectedIndex := lbxCurrentTabItems.Value
    if (selectedIndex == 0)
        return

    itemToRemove := lbxCurrentTabItems.GetText(selectedIndex)
    if (itemToRemove == "")
        return

    tabKey := "tab_" (selectedBankTab - 1)

    ; Remove from config
    Loop (tabConfigs[tabKey].Length) {
        if (tabConfigs[tabKey][A_Index] == itemToRemove) {
            tabConfigs[tabKey].RemoveAt(A_Index)
            break
        }
    }

    ; Uncheck in TreeView
    for categoryName, categoryData in tvNodes {
        if (categoryData["children"].Has(itemToRemove)) {
            nodeID := categoryData["children"][itemToRemove]
            tvCategories.Modify(nodeID, "-Check")
            break
        }
    }

    ; Update display
    lbxCurrentTabItems.Delete(selectedIndex)
    txtSelectedTabInfo.Value := "Tab " . selectedBankTab . ": " . tabConfigs[tabKey].Length . " items"
}

ClearCurrentBankTab() {
    global selectedBankTab, tabConfigs, tvCategories, tvNodes

    result := MsgBox("Clear all items from Tab " . selectedBankTab . "?", "Confirm Clear", "YN Icon?")
    if (result != "Yes")
        return

    tabKey := "tab_" (selectedBankTab - 1)
    tabConfigs[tabKey] := []

    ; Uncheck all items in TreeView
    for categoryName, categoryData in tvNodes {
        for item, nodeID in categoryData["children"] {
            tvCategories.Modify(nodeID, "-Check")
        }
    }

    SelectBankTab(selectedBankTab)
}

ResetToDefaults() {
    global tabConfigs, defaultCfg, selectedBankTab

    result := MsgBox("Reset all settings to defaults?", "Confirm Reset", "YN Icon!")
    if (result != "Yes")
        return

    ; Reset tab configs
    for key, value in defaultCfg["BankCategories"] {
        tabConfigs[key] := value.Clone()
    }

    ; Reset other settings
    ddlAntiBan.Text := defaultCfg["AntiBan"]
    chkVoiceAlerts.Value := defaultCfg["VoiceAlerts"]
    chkWorldHop.Value := defaultCfg["WorldHop"]
    sldMaxSession.Value := defaultCfg["MaxSession"]
    chkUseOCR.Value := defaultCfg["UseOCR"]
    chkStealthMode.Value := defaultCfg["StealthMode"]

    UpdateSliderDisplay()
    SelectBankTab(selectedBankTab)

    MsgBox("Settings reset to defaults!", "Success", "Iconi")
}

UpdateSliderDisplay(*) {
    global sldMaxSession, txtMaxSession
    txtMaxSession.Value := sldMaxSession.Value . " minutes"
}

SaveConfig(*) {
    global userCfg, cfgFile, ddlAntiBan, chkVoiceAlerts, chkWorldHop, sldMaxSession, chkUseOCR, chkStealthMode

    userCfg["AntiBan"] := ddlAntiBan.Text
    userCfg["VoiceAlerts"] := chkVoiceAlerts.Value
    userCfg["WorldHop"] := chkWorldHop.Value
    userCfg["MaxSession"] := sldMaxSession.Value
    userCfg["UseOCR"] := chkUseOCR.Value
    userCfg["StealthMode"] := chkStealthMode.Value
    userCfg["SortMode"] := "Category"
}

SaveAllSettings(*) {
    global userCfg, cfgFile, tabConfigs

    SaveConfig()
    userCfg["BankCategories"] := tabConfigs

    try {
        ; Save configuration file
        if FileExist(cfgFile)
            FileDelete(cfgFile)
        FileAppend(JSON.Stringify(userCfg), cfgFile)

        ; Automatically generate main.ahk with new settings
        success := GenerateMainScript()

        if success {
            MsgBox("Settings saved successfully!`n`nmain.ahk has been updated with your configuration.", "Success", "Iconi")
        } else {
            MsgBox("Settings saved, but main.ahk generation failed.`n`nCheck error log for details.", "Warning", "Icon!")
        }
    } catch as err {
        MsgBox("Error saving settings: " . err.Message, "Error", "Icon!")
    }
}

GenerateBot(*) {
    global userCfg, cfgFile

    result := MsgBox("Generate bot from current settings?`n`nThis will create main.ahk with your configuration.", "Generate Bot", "YN Icon?")
    if (result != "Yes")
        return

    SaveAllSettings()
}

GenerateMainScript() {
    global userCfg, tabConfigs

    try {
        ; Read the template
        templateFile := A_ScriptDir "\main_template_v2.ahk"
        if !FileExist(templateFile) {
            MsgBox("Template file not found: " . templateFile . "`n`nUsing fallback template.", "Warning", "Icon!")
            templateFile := A_ScriptDir "\main_template.ahk"
            if !FileExist(templateFile) {
                return false
            }
        }

        content := FileRead(templateFile)

        ; Generate bank categories as AHK code
        bankCategoriesCode := GenerateBankCategoriesCode(tabConfigs)

        ; Replace template variables
        content := StrReplace(content, "{{BANK_CATEGORIES_JSON}}", bankCategoriesCode)
        content := StrReplace(content, "{{ANTIBAN}}", userCfg["AntiBan"])
        content := StrReplace(content, "{{VOICE}}", userCfg["VoiceAlerts"] ? "true" : "false")
        content := StrReplace(content, "{{WORLDHOP}}", userCfg["WorldHop"] ? "true" : "false")
        content := StrReplace(content, "{{MAXSESSION}}", userCfg["MaxSession"])
        content := StrReplace(content, "{{USEOCR}}", userCfg["UseOCR"] ? "true" : "false")
        content := StrReplace(content, "{{STEALTH}}", userCfg["StealthMode"] ? "true" : "false")

        ; Write to main.ahk
        outputFile := A_ScriptDir "\main.ahk"
        if FileExist(outputFile) {
            FileDelete(outputFile)
        }
        FileAppend(content, outputFile)

        return true
    } catch as err {
        MsgBox("Error generating main script: " . err.Message, "Error", "Icon!")
        return false
    }
}

GenerateBankCategoriesCode(tabConfigs) {
    ; Generate AutoHotkey code for bank categories Map
    code := "; Bank tab configuration (generated from GUI)`n"
    code .= "bankCategories := Map(`n"

    first := true
    for tabKey, categories in tabConfigs {
        if !first {
            code .= ",`n"
        }
        first := false

        ; Build array of categories
        code .= '    "' . tabKey . '", ['

        catFirst := true
        for category in categories {
            if !catFirst {
                code .= ", "
            }
            catFirst := false
            code .= '"' . category . '"'
        }

        code .= "]"
    }

    code .= "`n)`n"
    return code
}
