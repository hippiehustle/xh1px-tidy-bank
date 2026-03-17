#Requires AutoHotkey v2.0
#SingleInstance Force
#Include json_parser.ahk
#Include item_grouping.ahk

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
        "tab_0", ["Skills"],
        "tab_1", ["Equipment"],
        "tab_2", ["Consumables"],
        "tab_3", ["Resources"],
        "tab_4", ["Tools"],
        "tab_5", ["Currency"],
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
    rawCfg := FileRead(cfgFile)
    if rawCfg = "" {
        throw Error("Config file is empty")
    }
    userCfg := JSON.Parse(rawCfg)
    if !userCfg.Has("BankCategories") {
        userCfg["BankCategories"] := defaultCfg["BankCategories"]
    }
} catch as err {
    OutputDebug("Config load error: " . err.Message . " - using defaults")
    userCfg := defaultCfg
    try {
        FileDelete(cfgFile)
    } catch {
        ; Failed to delete, will overwrite
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
Global lvGroupsCtrl
Global groupRows := Map()
Global groupToTab := Map()
Global coreGroupChildren := Map()
Global txtSelectedTabInfoExclusive
Global lbxCurrentTabGroups

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
; TAB 2: BANK CONFIGURATION - REDESIGNED
; Exclusive Group Assignment System
; ==========================================

MainTabs.UseTab(2)

currentY := 140

; === Bank Tab Selector ===
CreateCard(30, currentY, 940, 150, "Select Bank Tab to Configure")
cardY := currentY + 50

MyGui.SetFont("s11 c0x" . ColorSystem["SecondaryText"], "Segoe UI")
MyGui.Add("Text", "x50 y" . cardY, "Choose a bank tab (1-8) to assign core groups and subgroups:")
cardY += 30

; Create bank tab buttons in a grid
buttonStartX := 50
buttonStartY := cardY
buttonWidth := 100
buttonHeight := 40
buttonGapX := 110

Loop 8 {
    tabNum := A_Index
    btnX := buttonStartX + ((tabNum - 1) * buttonGapX)

    MyGui.SetFont("s11 w600", "Segoe UI")
    btn := MyGui.Add("Button", "x" . btnX " y" . buttonStartY " w" . buttonWidth " h" . buttonHeight, "Tab " . tabNum)
    ; Use IIFE to properly capture tabNum value for each button
    btn.OnEvent("Click", ((num) => ((*) => SelectBankTabExclusive(num)))(tabNum))
    bankTabButtons.Push(btn)
}

; === Available Core Groups & Subgroups ===
currentY += 170
CreateCard(30, currentY, 620, 480, "Available Core Groups & Subgroups")
cardY := currentY + 50

MyGui.SetFont("s10 c0x" . ColorSystem["TertiaryText"], "Segoe UI")
MyGui.Add("Text", "x50 y" . cardY " w580", "Check a core group to auto-select all its subgroups. Once assigned, groups are locked to that tab.")
cardY += 25

; Create scrollable list view for core groups and subgroups
MyGui.SetFont("s10 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
lvGroups := MyGui.Add("ListView", "x50 y" . cardY " w570 h390 Checked Grid Background" . ColorSystem["SecondaryBg"], ["Group Name", "Type", "Assigned To"])
lvGroups.OnEvent("ItemCheck", OnGroupCheckChanged)
lvGroups.OnEvent("Click", OnGroupClick)

; Populate with all core groups and subgroups from ItemGroupingSystem
lvGroupsCtrl := lvGroups
groupRows := Map()
groupToTab := Map()
coreGroupChildren := Map()

rowNum := 0

; Add CORE GROUPS first
for coreGroupKey, coreGroupName in ItemGroupingSystem.CORE_GROUPS {
    rowNum++
    lvGroups.Add("", coreGroupName, "CORE", "")

    groupRows[rowNum] := Map(
        "name", coreGroupName,
        "key", coreGroupKey,
        "type", "CORE",
        "parentRow", 0
    )

    coreGroupChildren[coreGroupName] := []
}

; Add SUBGROUPS under their respective core groups
for subgroupKey, subgroupName in ItemGroupingSystem.SUBGROUPS {
    rowNum++

    ; Determine parent core group from tag prefix
    parentCore := ""
    if InStr(subgroupKey, "skill_") == 1 {
        parentCore := "Skills"
    } else if InStr(subgroupKey, "equip_") == 1 {
        parentCore := "Equipment"
    } else if InStr(subgroupKey, "resource_") == 1 {
        parentCore := "Resources"
    } else if InStr(subgroupKey, "consume_") == 1 {
        parentCore := "Consumables"
    } else if InStr(subgroupKey, "tool_") == 1 {
        parentCore := "Tools"
    } else if InStr(subgroupKey, "quest_") == 1 {
        parentCore := "Quest Items"
    } else if InStr(subgroupKey, "currency_") == 1 {
        parentCore := "Currency"
    } else if InStr(subgroupKey, "clue_") == 1 {
        parentCore := "Clue Scrolls"
    } else if InStr(subgroupKey, "pvp_") == 1 {
        parentCore := "PvP Items"
    } else if InStr(subgroupKey, "minigame_") == 1 {
        parentCore := "Minigame Items"
    } else if InStr(subgroupKey, "cosmetic_") == 1 {
        parentCore := "Cosmetics"
    } else if InStr(subgroupKey, "pet_") == 1 {
        parentCore := "Pets"
    } else if InStr(subgroupKey, "transport_") == 1 {
        parentCore := "Transportation"
    } else {
        parentCore := "Miscellaneous"
    }

    lvGroups.Add("", "  → " . subgroupName, "Subgroup", "")

    groupRows[rowNum] := Map(
        "name", subgroupName,
        "key", subgroupKey,
        "type", "SUBGROUP",
        "parentCore", parentCore
    )

    ; Add to parent's children list
    if coreGroupChildren.Has(parentCore) {
        coreGroupChildren[parentCore].Push(rowNum)
    }
}

; Auto-size columns
lvGroups.ModifyCol(1, 300)
lvGroups.ModifyCol(2, 100)
lvGroups.ModifyCol(3, 150)

; === Current Tab Assignment ===
CreateCard(670, currentY, 300, 480, "Current Tab Assignment")
cardY := currentY + 50

MyGui.SetFont("s13 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")
txtSelectedTabInfoExclusive := MyGui.Add("Text", "x690 y" . cardY " w260 Center", "Tab 1: 0 groups")
cardY += 35

MyGui.SetFont("s10 c0x" . ColorSystem["PrimaryText"], "Segoe UI")
lbxCurrentTabGroups := MyGui.Add("ListBox", "x690 y" . cardY " w260 h390 Background" . ColorSystem["SecondaryBg"])
lbxCurrentTabGroups.OnEvent("DoubleClick", RemoveGroupFromTab)

MyGui.SetFont("s9 c0x" . ColorSystem["TertiaryText"], "Segoe UI")
MyGui.Add("Text", "x690 y" . (cardY + 395) " w260 Center", "Double-click to remove")

; === Action Buttons ===
currentY += 500
MyGui.SetFont("s12 w600 c0x" . ColorSystem["PrimaryAccent"], "Segoe UI")

btnSaveBank := MyGui.Add("Button", "x30 y" . currentY " w200 h40", "Save Bank Config")
btnSaveBank.OnEvent("Click", SaveAllSettingsExclusive)

btnClearTab := MyGui.Add("Button", "x240 y" . currentY " w150 h40", "Clear This Tab")
btnClearTab.OnEvent("Click", (*) => ClearCurrentBankTabExclusive())

btnResetAll := MyGui.Add("Button", "x400 y" . currentY " w150 h40", "Reset All Tabs")
btnResetAll.OnEvent("Click", (*) => ResetToDefaultsExclusive())

MainTabs.UseTab()  ; End tab definition

; ==========================================
; SHOW GUI
; ==========================================

MyGui.Show("w1000 h800")

; Initialize
LoadExistingAssignments()  ; Load saved config into groupToTab
SelectBankTabExclusive(1)

; ==========================================
; HELPER FUNCTIONS
; ==========================================

LoadExistingAssignments() {
    ; Convert tabConfigs to groupToTab format when loading existing config
    global tabConfigs, groupToTab, groupRows

    ; Clear existing assignments
    groupToTab := Map()

    ; Build a set of valid group names from groupRows for validation
    validGroupNames := Map()
    for rowNum, rowInfo in groupRows {
        groupName := rowInfo["name"]
        validGroupNames[groupName] := true
    }

    ; Load assignments from tabConfigs
    for tabKey, categories in tabConfigs {
        tabNum := Integer(SubStr(tabKey, 5)) + 1  ; "tab_0" -> 1, "tab_1" -> 2, etc.

        for category in categories {
            ; Only add if the category name exists in groupRows
            if validGroupNames.Has(category) {
                groupToTab[category] := tabNum
            } else {
                ; Log warning for unknown categories (legacy names that don't match)
                ; In future, could add mapping logic here
            }
        }
    }
}

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
; EXCLUSIVE ASSIGNMENT EVENT HANDLERS
; ==========================================

SelectBankTabExclusive(tabNum) {
    global selectedBankTab, bankTabButtons, ColorSystem, txtSelectedTabInfoExclusive
    global lbxCurrentTabGroups, groupToTab, lvGroupsCtrl

    selectedBankTab := tabNum

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

    ; Update current tab's group list
    UpdateCurrentTabDisplay()

    ; Update ListView to show which groups are available/assigned
    UpdateListViewAvailability()
}

UpdateCurrentTabDisplay() {
    global selectedBankTab, groupToTab, lbxCurrentTabGroups, txtSelectedTabInfoExclusive, groupRows

    ; Clear listbox
    lbxCurrentTabGroups.Delete()

    ; Count and display groups assigned to this tab
    groupCount := 0
    for groupName, assignedTab in groupToTab {
        if assignedTab == selectedBankTab {
            groupCount++
            lbxCurrentTabGroups.Add([groupName])
        }
    }

    txtSelectedTabInfoExclusive.Value := "Tab " . selectedBankTab . ": " . groupCount . " groups"
}

UpdateListViewAvailability() {
    global selectedBankTab, groupToTab, lvGroupsCtrl, groupRows, coreGroupChildren

    ; Update each row's checkbox state and "Assigned To" column
    Loop lvGroupsCtrl.GetCount() {
        rowNum := A_Index
        rowInfo := groupRows[rowNum]
        groupName := rowInfo["name"]

        ; Check if this group is assigned to any tab
        if groupToTab.Has(groupName) {
            assignedTab := groupToTab[groupName]

            ; Update "Assigned To" column (Column 3)
            lvGroupsCtrl.Modify(rowNum, "", "", "", "Tab " . assignedTab)

            ; Check/uncheck based on current tab
            if assignedTab == selectedBankTab {
                lvGroupsCtrl.Modify(rowNum, "Check")
            } else {
                lvGroupsCtrl.Modify(rowNum, "-Check")
                ; Grey out row (disable it visually)
                ; Note: ListView doesn't have direct "disabled" state, but we handle it in click event
            }
        } else {
            ; Not assigned to any tab
            lvGroupsCtrl.Modify(rowNum, "", "", "", "")
            lvGroupsCtrl.Modify(rowNum, "-Check")
        }
    }
}

OnGroupCheckChanged(GuiCtrlObj, Item, IsChecked) {
    global selectedBankTab, groupRows, groupToTab, coreGroupChildren, lvGroupsCtrl

    rowInfo := groupRows[Item]
    groupName := rowInfo["name"]
    groupType := rowInfo["type"]

    ; Check if group is already assigned to a different tab
    if groupToTab.Has(groupName) && groupToTab[groupName] != selectedBankTab {
        ; Prevent checking - already assigned to another tab
        lvGroupsCtrl.Modify(Item, "-Check")
        MsgBox(groupName . " is already assigned to Tab " . groupToTab[groupName] . "!`n`nRemove it from that tab first.", "Already Assigned", "Icon!")
        return
    }

    if IsChecked {
        ; If this is a CORE group, check if any subgroups are already assigned to a different tab
        if groupType == "CORE" && coreGroupChildren.Has(groupName) {
            conflictingSubgroups := []
            for subgroupRow in coreGroupChildren[groupName] {
                subgroupInfo := groupRows[subgroupRow]
                subgroupName := subgroupInfo["name"]

                ; Check if subgroup is assigned to a different tab
                if groupToTab.Has(subgroupName) && groupToTab[subgroupName] != selectedBankTab {
                    conflictingSubgroups.Push(subgroupName . " (Tab " . groupToTab[subgroupName] . ")")
                }
            }

            ; If there are conflicts, prevent assignment and show message
            if conflictingSubgroups.Length > 0 {
                lvGroupsCtrl.Modify(Item, "-Check")
                conflictList := ""
                for conflict in conflictingSubgroups {
                    conflictList .= "`n  - " . conflict
                }
                MsgBox("Cannot assign " . groupName . " to Tab " . selectedBankTab . " because some subgroups are already assigned to other tabs:" . conflictList . "`n`nPlease remove those subgroups from their current tabs first.", "Conflicting Assignments", "Icon!")
                return
            }
        }

        ; Assign to current tab
        groupToTab[groupName] := selectedBankTab

        ; If this is a CORE group, automatically check all its subgroups
        if groupType == "CORE" && coreGroupChildren.Has(groupName) {
            for subgroupRow in coreGroupChildren[groupName] {
                subgroupInfo := groupRows[subgroupRow]
                subgroupName := subgroupInfo["name"]

                ; Assign subgroup to same tab
                groupToTab[subgroupName] := selectedBankTab
                lvGroupsCtrl.Modify(subgroupRow, "Check")
                lvGroupsCtrl.Modify(subgroupRow, "", "", "", "Tab " . selectedBankTab)
            }
        }

        ; Update display
        lvGroupsCtrl.Modify(Item, "", "", "", "Tab " . selectedBankTab)
    } else {
        ; Unassign from current tab
        if groupToTab.Has(groupName) {
            groupToTab.Delete(groupName)
        }

        ; If this is a CORE group, automatically uncheck all its subgroups
        if groupType == "CORE" && coreGroupChildren.Has(groupName) {
            for subgroupRow in coreGroupChildren[groupName] {
                subgroupInfo := groupRows[subgroupRow]
                subgroupName := subgroupInfo["name"]

                ; Unassign subgroup
                if groupToTab.Has(subgroupName) {
                    groupToTab.Delete(subgroupName)
                }
                lvGroupsCtrl.Modify(subgroupRow, "-Check")
                lvGroupsCtrl.Modify(subgroupRow, "", "", "", "")
            }
        }

        ; Update display
        lvGroupsCtrl.Modify(Item, "", "", "", "")
    }

    ; Update current tab display
    UpdateCurrentTabDisplay()
}

OnGroupClick(GuiCtrlObj, Item) {
    ; Handle click on row - prevent interaction if assigned to different tab
    global selectedBankTab, groupRows, groupToTab

    if Item > 0 {
        rowInfo := groupRows[Item]
        groupName := rowInfo["name"]

        if groupToTab.Has(groupName) && groupToTab[groupName] != selectedBankTab {
            MsgBox(groupName . " is assigned to Tab " . groupToTab[groupName] . ".`n`nSwitch to that tab or remove it to reassign.", "Info", "Iconi")
        }
    }
}

RemoveGroupFromTab(GuiCtrlObj, Item) {
    global selectedBankTab, groupToTab, lbxCurrentTabGroups, lvGroupsCtrl, groupRows, coreGroupChildren

    selectedIndex := lbxCurrentTabGroups.Value
    if selectedIndex == 0 {
        return
    }

    groupToRemove := lbxCurrentTabGroups.GetText(selectedIndex)
    if groupToRemove == "" {
        return
    }

    ; Remove from assignment
    if groupToTab.Has(groupToRemove) {
        groupToTab.Delete(groupToRemove)
    }

    ; Find and update the ListView row
    Loop lvGroupsCtrl.GetCount() {
        rowInfo := groupRows[A_Index]
        if rowInfo["name"] == groupToRemove {
            lvGroupsCtrl.Modify(A_Index, "-Check")
            lvGroupsCtrl.Modify(A_Index, "", "", "", "")

            ; If CORE group, also remove all subgroups
            if rowInfo["type"] == "CORE" && coreGroupChildren.Has(groupToRemove) {
                for subgroupRow in coreGroupChildren[groupToRemove] {
                    subgroupInfo := groupRows[subgroupRow]
                    subgroupName := subgroupInfo["name"]

                    if groupToTab.Has(subgroupName) {
                        groupToTab.Delete(subgroupName)
                    }
                    lvGroupsCtrl.Modify(subgroupRow, "-Check")
                    lvGroupsCtrl.Modify(subgroupRow, "", "", "", "")
                }
            }
            break
        }
    }

    ; Update display
    UpdateCurrentTabDisplay()
}

ClearCurrentBankTabExclusive() {
    global selectedBankTab, groupToTab, lvGroupsCtrl, groupRows

    result := MsgBox("Clear all groups from Tab " . selectedBankTab . "?", "Confirm Clear", "YN Icon?")
    if result != "Yes" {
        return
    }

    ; Remove all assignments for this tab
    groupsToRemove := []
    for groupName, assignedTab in groupToTab {
        if assignedTab == selectedBankTab {
            groupsToRemove.Push(groupName)
        }
    }

    for groupName in groupsToRemove {
        groupToTab.Delete(groupName)
    }

    ; Update ListView
    UpdateListViewAvailability()
    UpdateCurrentTabDisplay()
}

ResetToDefaultsExclusive() {
    global groupToTab

    result := MsgBox("Reset all tab assignments to defaults?", "Confirm Reset", "YN Icon!")
    if result != "Yes" {
        return
    }

    ; Clear all assignments
    groupToTab := Map()

    ; Update display
    UpdateListViewAvailability()
    UpdateCurrentTabDisplay()

    MsgBox("All tab assignments cleared!", "Success", "Iconi")
}

SaveAllSettingsExclusive(*) {
    global userCfg, cfgFile, groupToTab, groupRows, tabConfigs

    ; Convert groupToTab to tabConfigs format
    ; tabConfigs should be Map("tab_0" -> [groups], "tab_1" -> [groups], ...)
    newTabConfigs := Map()

    ; Initialize all tabs with empty arrays
    Loop 8 {
        newTabConfigs["tab_" . (A_Index - 1)] := []
    }

    ; Populate tabs with assigned groups
    for groupName, tabNum in groupToTab {
        tabKey := "tab_" . (tabNum - 1)
        newTabConfigs[tabKey].Push(groupName)
    }

    ; Update global tabConfigs
    tabConfigs := newTabConfigs

    ; Save config
    SaveConfig()
    userCfg["BankCategories"] := tabConfigs

    try {
        ; Save configuration file
        if FileExist(cfgFile) {
            FileDelete(cfgFile)
        }
        FileAppend(JSON.Stringify(userCfg), cfgFile)

        ; Automatically generate main.ahk with new settings
        success := GenerateMainScript()

        if success {
            MsgBox("Settings saved successfully!`n`nmain.ahk has been updated with your exclusive group assignments.", "Success", "Iconi")
        } else {
            MsgBox("Settings saved, but main.ahk generation failed.`n`nCheck error log for details.", "Warning", "Icon!")
        }
    } catch as err {
        MsgBox("Error saving settings: " . err.Message, "Error", "Icon!")
    }
}

ResetToDefaults() {
    global tabConfigs, defaultCfg, selectedBankTab, groupToTab

    result := MsgBox("Reset all settings to defaults?", "Confirm Reset", "YN Icon!")
    if (result != "Yes")
        return

    ; Reset tab configs
    for key, value in defaultCfg["BankCategories"] {
        tabConfigs[key] := value.Clone()
    }

    ; Reset groupToTab from default config
    groupToTab := Map()
    for tabKey, categories in defaultCfg["BankCategories"] {
        tabNum := Integer(SubStr(tabKey, 5)) + 1  ; "tab_0" -> 1, "tab_1" -> 2, etc.
        for category in categories {
            groupToTab[category] := tabNum
        }
    }

    ; Reset other settings
    ddlAntiBan.Text := defaultCfg["AntiBan"]
    chkVoiceAlerts.Value := defaultCfg["VoiceAlerts"]
    chkWorldHop.Value := defaultCfg["WorldHop"]
    sldMaxSession.Value := defaultCfg["MaxSession"]
    chkUseOCR.Value := defaultCfg["UseOCR"]
    chkStealthMode.Value := defaultCfg["StealthMode"]

    UpdateSliderDisplay()
    SelectBankTabExclusive(selectedBankTab)

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
    ; This function is called by the "Save Settings" button in Bot Settings tab
    ; It should save bot settings AND sync with the exclusive assignment system
    global userCfg, cfgFile, tabConfigs, groupToTab

    SaveConfig()  ; Save bot settings (AntiBan, VoiceAlerts, etc.)

    ; Convert groupToTab to tabConfigs format for consistency
    newTabConfigs := Map()
    Loop 8 {
        newTabConfigs["tab_" . (A_Index - 1)] := []
    }

    for groupName, tabNum in groupToTab {
        tabKey := "tab_" . (tabNum - 1)
        newTabConfigs[tabKey].Push(groupName)
    }

    tabConfigs := newTabConfigs
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
            MsgBox("Template file not found: " . templateFile . "`n`nPlease ensure main_template_v2.ahk is present in the script directory.", "Error", "Icon!")
            return false
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
            ; Escape quotes and backslashes in category names
            escapedCategory := StrReplace(StrReplace(category, "\", "\\"), '"', '\"')
            code .= '"' . escapedCategory . '"'
        }

        code .= "]"
    }

    code .= "`n)`n"
    return code
}
