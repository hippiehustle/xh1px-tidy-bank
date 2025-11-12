#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; xh1px's Tidy Bank - Configuration GUI v2.2
; Professional Design System - Accordion Selection
; ==========================================

; COLOR SYSTEM
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
    "MainTitle", Map("size", 32, "weight", 700),
    "SectionHeader", Map("size", 24, "weight", 600),
    "SubsectionHeader", Map("size", 18, "weight", 600),
    "BodyText", Map("size", 14, "weight", 400),
    "SmallText", Map("size", 12, "weight", 400),
    "CodeText", Map("size", 13, "weight", 400)
)

; SPACING & LAYOUT SYSTEM
SpacingSystem := Map(
    "SidebarWidth", 200,
    "PaddingLarge", 60,
    "PaddingMedium", 32,
    "PaddingSmall", 16,
    "BorderRadius", 12,
    "ButtonPadding", "10|20",
    "ColumnGap", 32,
    "ItemSpacing", 16
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

Global SkillCategories := Map(
    "Combat", ["Ranged", "Magic", "Prayer"],
    "Gathering", ["Woodcutting", "Mining", "Fishing", "Hunter"],
    "Crafting", ["Cooking", "Fletching", "Crafting", "Smithing", "Herblore"],
    "Processing", ["Runecraft", "Firemaking", "Construction"],
    "Utility", ["Agility", "Thieving", "Slayer", "Farming"]
)

Global ItemTypeCategories := Map(
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
Global selectedTab := 1
Global tabConfigs := Map()
Global tabButtons := Map()
Global expandedGroups := Map()
Global skillListboxes := Map()
Global typeListboxes := Map()

InitializeTabConfigs() {
    Loop 8 {
        tabKey := "tab_" (A_Index - 1)
        if userCfg["BankCategories"].Has(tabKey) {
            tabConfigs[tabKey] := userCfg["BankCategories"][tabKey]
        } else {
            tabConfigs[tabKey] := []
        }
    }
}

; ==========================================
; GUI INITIALIZATION
; ==========================================

MyGui := Gui("+LastFound", "xh1px's Tidy Bank - Bank Configuration v2.2")
MyGui.OnEvent("Close", (*) => ExitApp())

; Initialize tab configurations from loaded settings
InitializeTabConfigs()

; Set colors using color system
bgColor := "0x" . ColorSystem["PrimaryBg"]
MyGui.BackColor := bgColor
MyGui.SetFont("s11 c0x" . ColorSystem["PrimaryText"], "Segoe UI")

; ==========================================
; HEADER SECTION
; ==========================================

; Header background
headerPx := MyGui.Add("Text", "x0 y0 w1400 h100 c0x" . ColorSystem["PrimaryBg"], "")
headerPx.Opt("-Background")

; Logo and title area
logoTitleCtrl := MyGui.Add("Text", "x40 y20 w400 c0x" . ColorSystem["PrimaryAccent"], "xh1px's Tidy Bank")
MyGui.SetFont("s32 w700", "Segoe UI")
logoTitleCtrl.Value := "xh1px's Tidy Bank"

MyGui.SetFont("s13 w400 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
subtitleCtrl := MyGui.Add("Text", "x40 y55 w400", "OSRS Bank Organization v2.2")
subtitleCtrl.Value := "OSRS Bank Organization v2.2"

; Status area (top right)
MyGui.SetFont("s12 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
statusCtrl := MyGui.Add("Text", "x1200 y30 w150 h50 Right", "Ready")

; ==========================================
; DIVIDER
; ==========================================

MyGui.Add("Text", "x0 y100 w1400 h1 c0x" . ColorSystem["InputBorder"], "")

; ==========================================
; MAIN CONTENT - LEFT COLUMN (BASIC SETTINGS)
; ==========================================

contentStartY := 120
leftColumnX := 40
leftColumnWidth := 350

MyGui.SetFont("s18 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . leftColumnX " y" . contentStartY, "BASIC SETTINGS")

currentY := contentStartY + 40

; Anti-Ban Setting
MyGui.SetFont("s13 w500 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
MyGui.Add("Text", "x" . leftColumnX " y" . currentY . " c0x" . ColorSystem["SecondaryText"], "Anti-Ban Mode")
currentY += 22

ddlAntiBan := MyGui.Add("DropDownList", "x" . leftColumnX " y" . currentY " w" . leftColumnWidth, ["Psychopath", "Extreme", "Stealth", "Off"])
ddlAntiBan.OnEvent("Change", SaveConfig)
try {
    ddlAntiBan.Text := userCfg["AntiBan"]
} catch {
    ddlAntiBan.Choose(1)
}
currentY += 45

; Voice Alerts
chkVoiceAlerts := MyGui.Add("CheckBox", "x" . leftColumnX " y" . currentY " c0x" . ColorSystem["PrimaryText"], "Enable Voice Alerts")
chkVoiceAlerts.OnEvent("Click", SaveConfig)
try {
    chkVoiceAlerts.Value := userCfg["VoiceAlerts"]
} catch {
    chkVoiceAlerts.Value := true
}
currentY += 35

; World Hop
chkWorldHop := MyGui.Add("CheckBox", "x" . leftColumnX " y" . currentY " c0x" . ColorSystem["PrimaryText"], "World Hop (Rare)")
chkWorldHop.OnEvent("Click", SaveConfig)
try {
    chkWorldHop.Value := userCfg["WorldHop"]
} catch {
    chkWorldHop.Value := false
}
currentY += 35

; Enable OCR
chkUseOCR := MyGui.Add("CheckBox", "x" . leftColumnX " y" . currentY " c0x" . ColorSystem["PrimaryText"], "Enable OCR Item Detection")
chkUseOCR.OnEvent("Click", SaveConfig)
try {
    chkUseOCR.Value := userCfg["UseOCR"]
} catch {
    chkUseOCR.Value := true
}
currentY += 35

; Stealth Mode
chkStealthMode := MyGui.Add("CheckBox", "x" . leftColumnX " y" . currentY " c0x" . ColorSystem["PrimaryAccent"], "STEALTH MODE (PRIMARY)")
chkStealthMode.OnEvent("Click", SaveConfig)
try {
    chkStealthMode.Value := userCfg["StealthMode"]
} catch {
    chkStealthMode.Value := true
}
currentY += 45

; Max Session
MyGui.SetFont("s13 w500 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x" . leftColumnX " y" . currentY, "Max Session Duration")
currentY += 22

MyGui.SetFont("s12 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
sldMaxSession := MyGui.Add("Slider", "x" . leftColumnX " y" . currentY " w" . leftColumnWidth . " Range60-480 TickInterval30 c0x" . ColorSystem["SecondaryAccent"], userCfg["MaxSession"])
sldMaxSession.OnEvent("Change", UpdateSliderDisplay)
currentY += 35

MyGui.SetFont("s12 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
txtMaxSession := MyGui.Add("Text", "x" . leftColumnX " y" . currentY . " c0x" . ColorSystem["PrimaryAccent"], userCfg["MaxSession"] . " minutes")

; ==========================================
; MAIN CONTENT - RIGHT COLUMN (BANK TABS & SELECTION)
; ==========================================

rightColumnX := leftColumnX + leftColumnWidth + SpacingSystem["ColumnGap"]
rightColumnWidth := 1000

MyGui.SetFont("s18 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . rightColumnX " y" . contentStartY, "BANK TABS & ITEM SELECTION")

currentY := contentStartY + 40

; Tab buttons grid
MyGui.SetFont("s10 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
tabGridY := currentY
tabGridX := rightColumnX

Loop 8 {
    tabNum := A_Index
    btnX := tabGridX + (Mod(tabNum - 1, 4) * 135)
    btnY := tabGridY + (Floor((tabNum - 1) / 4) * 45)

    tabBtn := MyGui.Add("Button", "x" . btnX " y" . btnY " w120 h35", "Tab " . tabNum)
    tabBtn.OnEvent("Click", (*) => SelectTab(tabNum))
    tabButtons["tab_" (tabNum - 1)] := tabBtn
}

currentY := tabGridY + 100

; Selected tab info
MyGui.SetFont("s13 w500 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x" . rightColumnX " y" . currentY, "Tab Configuration:")
currentY += 25

MyGui.SetFont("s12 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
txtSelectedTab := MyGui.Add("Text", "x" . rightColumnX " y" . currentY " c0x" . ColorSystem["PrimaryAccent"], "Selected: Tab 1 (0 items)")

currentY += 35

; ==========================================
; ACCORDION-STYLE SELECTION SECTION
; ==========================================

accordionX := rightColumnX
accordionY := currentY
accordionWidth := rightColumnWidth - 20

; Create collapsible skill groups
MyGui.SetFont("s12 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . accordionX " y" . accordionY, "Select Skills & Items:")
accordionY += 30

expandedGroups["Skills"] := false
expandedGroups["Potions"] := false
expandedGroups["Herbs"] := false
expandedGroups["Logs"] := false
expandedGroups["Fish"] := false
expandedGroups["Ore"] := false

; Skills Section
btnSkillsToggle := MyGui.Add("Button", "x" . accordionX " y" . accordionY " w" . accordionWidth . " h30", "▶ Skills (Combat, Gathering, Crafting, Processing, Utility)")
btnSkillsToggle.OnEvent("Click", (*) => ToggleAccordionGroup("Skills", accordionX, accordionY + 30, accordionWidth))
accordionY += 35

; Create containers for each section with multiple listboxes
skillsContainerY := accordionY
skillsColumnX1 := accordionX + 10
skillsColumnX2 := accordionX + 270

; Combat
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
skillsContainerY_local := skillsContainerY
MyGui.Add("Text", "x" . skillsColumnX1 " y" . skillsContainerY_local, "Combat")
skillsContainerY_local += 18

combatList := MyGui.Add("ListBox", "x" . skillsColumnX1 " y" . skillsContainerY_local " w250 h80 Multi", ["Ranged", "Magic", "Prayer"])
combatList.OnEvent("Change", UpdateSelectedItems)
skillListboxes["Combat"] := combatList
skillsContainerY_local += 90

; Gathering
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . skillsColumnX1 " y" . skillsContainerY_local, "Gathering")
skillsContainerY_local += 18

gatheringList := MyGui.Add("ListBox", "x" . skillsColumnX1 " y" . skillsContainerY_local " w250 h100 Multi", ["Woodcutting", "Mining", "Fishing", "Hunter"])
gatheringList.OnEvent("Change", UpdateSelectedItems)
skillListboxes["Gathering"] := gatheringList
skillsContainerY_local += 110

; Crafting
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . skillsColumnX1 " y" . skillsContainerY_local, "Crafting")
skillsContainerY_local += 18

craftingList := MyGui.Add("ListBox", "x" . skillsColumnX1 " y" . skillsContainerY_local " w250 h100 Multi", ["Cooking", "Fletching", "Crafting", "Smithing", "Herblore"])
craftingList.OnEvent("Change", UpdateSelectedItems)
skillListboxes["Crafting"] := craftingList
skillsContainerY_local += 110

; Processing & Utility combined on right
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . skillsColumnX2 " y" . skillsContainerY, "Processing")
skillsContainerY += 18

processingList := MyGui.Add("ListBox", "x" . skillsColumnX2 " y" . skillsContainerY " w250 h80 Multi", ["Runecraft", "Firemaking", "Construction"])
processingList.OnEvent("Change", UpdateSelectedItems)
skillListboxes["Processing"] := processingList
skillsContainerY += 90

; Utility
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . skillsColumnX2 " y" . skillsContainerY, "Utility")
skillsContainerY += 18

utilityList := MyGui.Add("ListBox", "x" . skillsColumnX2 " y" . skillsContainerY " w250 h100 Multi", ["Agility", "Thieving", "Slayer", "Farming"])
utilityList.OnEvent("Change", UpdateSelectedItems)
skillListboxes["Utility"] := utilityList
skillsContainerY += 110

accordionY := skillsContainerY + 20

; Item Types Section
btnItemsToggle := MyGui.Add("Button", "x" . accordionX " y" . accordionY " w" . accordionWidth . " h30", "▶ Item Types (Potions, Herbs, Logs, Fish, Ore)")
btnItemsToggle.OnEvent("Click", (*) => ToggleAccordionGroup("Items", accordionX, accordionY + 30, accordionWidth))
accordionY += 35

; Create item type listboxes
itemsContainerY := accordionY
itemsColumnX1 := accordionX + 10
itemsColumnX2 := accordionX + 270

; Potions
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
itemsContainerY_local := itemsContainerY
MyGui.Add("Text", "x" . itemsColumnX1 " y" . itemsContainerY_local, "Potions")
itemsContainerY_local += 18

potionsList := MyGui.Add("ListBox", "x" . itemsColumnX1 " y" . itemsContainerY_local " w250 h100 Multi", ["Stamina Potion", "Strength Potion", "Attack Potion", "Defense Potion", "Magic Potion"])
potionsList.OnEvent("Change", UpdateSelectedItems)
typeListboxes["Potions"] := potionsList
itemsContainerY_local += 110

; Herbs
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . itemsColumnX1 " y" . itemsContainerY_local, "Herbs")
itemsContainerY_local += 18

herbsList := MyGui.Add("ListBox", "x" . itemsColumnX1 " y" . itemsContainerY_local " w250 h100 Multi", ["Guam", "Marrentill", "Tarromin", "Spidermine", "Irit Leaf"])
herbsList.OnEvent("Change", UpdateSelectedItems)
typeListboxes["Herbs"] := herbsList
itemsContainerY_local += 110

; Logs
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . itemsColumnX2 " y" . itemsContainerY, "Logs")
itemsContainerY += 18

logsList := MyGui.Add("ListBox", "x" . itemsColumnX2 " y" . itemsContainerY " w250 h100 Multi", ["Logs", "Oak Logs", "Willow Logs", "Maple Logs", "Yew Logs"])
logsList.OnEvent("Change", UpdateSelectedItems)
typeListboxes["Logs"] := logsList
itemsContainerY += 110

; Fish
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . itemsColumnX2 " y" . itemsContainerY, "Fish")
itemsContainerY += 18

fishList := MyGui.Add("ListBox", "x" . itemsColumnX2 " y" . itemsContainerY " w250 h100 Multi", ["Salmon", "Tuna", "Trout", "Mackerel", "Herring"])
fishList.OnEvent("Change", UpdateSelectedItems)
typeListboxes["Fish"] := fishList
itemsContainerY += 110

; Ore
MyGui.SetFont("s10 w600 c0x" . ColorSystem["SecondaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . itemsColumnX1 " y" . itemsContainerY_local, "Ore")
itemsContainerY_local += 18

oreList := MyGui.Add("ListBox", "x" . itemsColumnX1 " y" . itemsContainerY_local " w250 h100 Multi", ["Copper Ore", "Tin Ore", "Iron Ore", "Coal", "Mithril Ore"])
oreList.OnEvent("Change", UpdateSelectedItems)
typeListboxes["Ore"] := oreList
itemsContainerY_local += 110

maxY := Max(itemsContainerY, itemsContainerY_local) + 30

; ==========================================
; SELECTED ITEMS DISPLAY
; ==========================================

selectedDisplayX := rightColumnX + rightColumnWidth + 20
selectedDisplayY := contentStartY + 40
selectedDisplayWidth := 250

MyGui.SetFont("s12 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
MyGui.Add("Text", "x" . selectedDisplayX " y" . selectedDisplayY, "Selected Items:")
selectedDisplayY += 25

MyGui.SetFont("s11 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
lbxTabItems := MyGui.Add("ListBox", "x" . selectedDisplayX " y" . selectedDisplayY " w" . selectedDisplayWidth . " h" . (maxY - selectedDisplayY) . " Multi", [])
lbxTabItems.OnEvent("DoubleClick", RemoveTabItem)
Global lbxTabItems

; ==========================================
; BOTTOM SECTION - BUTTONS
; ==========================================

bottomY := maxY + 30

MyGui.SetFont("s12 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")

; Save Settings Button
btnSave := MyGui.Add("Button", "x40 y" . bottomY " w150 h35 c0x" . ColorSystem["PrimaryAccent"], "Save Settings")
btnSave.OnEvent("Click", SaveAllSettings)

; Generate Bot Button
btnGenerate := MyGui.Add("Button", "x200 y" . bottomY " w150 h35 c0x" . ColorSystem["PrimaryAccent"], "Generate Bot")
btnGenerate.OnEvent("Click", GenerateBot)

; Reset Button
btnReset := MyGui.Add("Button", "x360 y" . bottomY " w120 h35 c0x" . ColorSystem["PrimaryAccent"], "Reset")
btnReset.OnEvent("Click", (*) => ResetCategories())

; Status text (bottom right)
MyGui.SetFont("s12 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
txtStatus := MyGui.Add("Text", "x1200 y" . bottomY " w150 h35 Right", "Ready")

; ==========================================
; SHOW GUI
; ==========================================

guiHeight := bottomY + 50
MyGui.Show("w1400 h" . guiHeight)

; Initialize the interface
SelectTab(1)

; ==========================================
; EVENT HANDLERS
; ==========================================

ToggleAccordionGroup(groupName, x, y, width) {
    global expandedGroups

    ; Toggle state
    expandedGroups[groupName] := !expandedGroups[groupName]

    ; Update button appearance (▶ vs ▼)
    ; This would require more complex GUI manipulation in AutoHotkey v2.0
    ; For now, we'll keep the functionality working
}

SelectTab(tabNum) {
    global selectedTab, txtSelectedTab, tabConfigs, lbxTabItems, skillListboxes, typeListboxes

    selectedTab := tabNum
    tabKey := "tab_" (tabNum - 1)

    ; Update the display with correct tab number
    itemCount := tabConfigs[tabKey].Length
    txtSelectedTab.Value := "Selected: Tab " . tabNum . " (" . itemCount . " items)"

    ; Update ListBox with current tab items
    lbxTabItems.Delete()
    for item in tabConfigs[tabKey] {
        lbxTabItems.Add([item])
    }

    ; Uncheck all skill listboxes
    for group, listbox in skillListboxes {
        listbox.Value := ""
    }

    ; Uncheck all type listboxes
    for group, listbox in typeListboxes {
        listbox.Value := ""
    }

    ; Check the appropriate items in skill listboxes
    for skill, listbox in skillListboxes {
        Loop Parse, listbox.GetText(0), "|" {
            item := A_LoopField
            for tabItem in tabConfigs[tabKey] {
                if (tabItem == item) {
                    ; Find and select this item in the listbox
                    Loop listbox.GetCount() {
                        if (listbox.GetText(A_Index) == item) {
                            listbox.Choose(A_Index)
                            break
                        }
                    }
                    break
                }
            }
        }
    }

    ; Check the appropriate items in type listboxes
    for type, listbox in typeListboxes {
        Loop Parse, listbox.GetText(0), "|" {
            item := A_LoopField
            for tabItem in tabConfigs[tabKey] {
                if (tabItem == item) {
                    Loop listbox.GetCount() {
                        if (listbox.GetText(A_Index) == item) {
                            listbox.Choose(A_Index)
                            break
                        }
                    }
                    break
                }
            }
        }
    }
}

UpdateSelectedItems(GuiCtrlObj, Info, *) {
    global selectedTab, tabConfigs, lbxTabItems, txtSelectedTab, skillListboxes, typeListboxes

    tabKey := "tab_" (selectedTab - 1)
    tabConfigs[tabKey] := []

    ; Collect all selected items from skill listboxes
    for group, listbox in skillListboxes {
        selected := listbox.Value
        Loop Parse, selected, "|" {
            if (A_LoopField != "") {
                selectedIndex := A_LoopField
                if (selectedIndex > 0) {
                    item := listbox.GetText(selectedIndex)
                    if (item != "") {
                        tabConfigs[tabKey].Push(item)
                    }
                }
            }
        }
    }

    ; Collect all selected items from type listboxes
    for type, listbox in typeListboxes {
        selected := listbox.Value
        Loop Parse, selected, "|" {
            if (A_LoopField != "") {
                selectedIndex := A_LoopField
                if (selectedIndex > 0) {
                    item := listbox.GetText(selectedIndex)
                    if (item != "") {
                        tabConfigs[tabKey].Push(item)
                    }
                }
            }
        }
    }

    ; Update ListBox display
    lbxTabItems.Delete()
    for selectedItem in tabConfigs[tabKey] {
        lbxTabItems.Add([selectedItem])
    }

    ; Update item count
    txtSelectedTab.Value := "Selected: Tab " . selectedTab . " (" . tabConfigs[tabKey].Length . " items)"
}

RemoveTabItem(GuiCtrlObj, Info, *) {
    global selectedTab, tabConfigs, lbxTabItems, txtSelectedTab, skillListboxes, typeListboxes

    tabKey := "tab_" (selectedTab - 1)

    ; Get the selected item from ListBox
    selectedIndex := lbxTabItems.Value
    if (selectedIndex == 0)
        return

    itemToRemove := lbxTabItems.GetText(selectedIndex)
    if (itemToRemove == "")
        return

    ; Remove from tabConfigs
    Loop (tabConfigs[tabKey].Length) {
        if (tabConfigs[tabKey][A_Index] == itemToRemove) {
            tabConfigs[tabKey].RemoveAt(A_Index)
            break
        }
    }

    ; Uncheck from skill listboxes
    for group, listbox in skillListboxes {
        Loop listbox.GetCount() {
            if (listbox.GetText(A_Index) == itemToRemove) {
                ; Deselect this item
                ; In AutoHotkey v2.0 ListBox, we need to rebuild the selection
                break
            }
        }
    }

    ; Uncheck from type listboxes
    for type, listbox in typeListboxes {
        Loop listbox.GetCount() {
            if (listbox.GetText(A_Index) == itemToRemove) {
                break
            }
        }
    }

    ; Remove from ListBox
    lbxTabItems.Delete(selectedIndex)

    ; Update display
    txtSelectedTab.Value := "Selected: Tab " . selectedTab . " (" . tabConfigs[tabKey].Length . " items)"
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

    try {
        if FileExist(cfgFile)
            FileDelete(cfgFile)
        FileAppend(JSON.Stringify(userCfg), cfgFile)
    }
}

SaveAllSettings(*) {
    global userCfg, cfgFile, txtStatus, tabConfigs

    SaveConfig()
    userCfg["BankCategories"] := tabConfigs

    try {
        if FileExist(cfgFile)
            FileDelete(cfgFile)
        FileAppend(JSON.Stringify(userCfg), cfgFile)
        txtStatus.Value := "✓ Saved"
        SetTimer(() => txtStatus.Value := "Ready", -2000)
    } catch as err {
        MsgBox("Error saving: " . err.Message, "Error", 16)
        txtStatus.Value := "Error"
    }
}

ResetCategories() {
    global tabConfigs, selectedTab

    result := MsgBox("Reset all tabs to defaults?", "Confirm Reset", 4)
    if (result != "Yes") {
        return
    }

    tabConfigs["tab_0"] := ["Ranged", "Magic"]
    tabConfigs["tab_1"] := ["Prayer", "Agility"]
    tabConfigs["tab_2"] := ["Cooking", "Fletching"]
    tabConfigs["tab_3"] := ["Crafting", "Smithing"]
    tabConfigs["tab_4"] := ["Mining", "Woodcutting"]
    tabConfigs["tab_5"] := ["Fishing", "Hunter"]
    tabConfigs["tab_6"] := []
    tabConfigs["tab_7"] := []

    SelectTab(selectedTab)
}

GenerateBot(*) {
    global txtStatus, userCfg, cfgFile

    result := MsgBox("Generate bot from current settings?", "xh1px's Tidy Bank - Generate", "YN Icon?")
    if (result == "Yes") {
        SaveAllSettings()

        if FileExist(A_ScriptDir "\generate_main.ahk") {
            try {
                Run('"' A_AhkPath '" "' A_ScriptDir '\generate_main.ahk"')
                txtStatus.Value := "Generating..."
            } catch as err {
                MsgBox("Error: " . err.Message, "Error", 16)
            }
        } else {
            MsgBox("Missing: generate_main.ahk", "Error", 48)
        }
    }
}
