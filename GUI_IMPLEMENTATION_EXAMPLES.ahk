; ==========================================
; xh1px's Tidy Bank - GUI Implementation Examples
; Real-world examples for creating future GUIs
; ==========================================

; ==========================================
; EXAMPLE 1: Configuration GUI (Full Implementation)
; ==========================================

/*
USE CASE: Settings/configuration interface
FEATURES: Header, two-column layout, dropdowns, checkboxes, buttons

HOW TO RUN:
1. Include GUI_TEMPLATE_SYSTEM.ahk
2. Copy this example code
3. Adjust colors and text as needed
4. Event handlers at bottom
*/

class ConfigGUIExample {
    __New() {
        ; Create GUI using ConfigTemplate
        this.gui := ConfigTemplate("Bot Configuration", 1200, 700)

        ; LEFT COLUMN - Basic Settings
        this.antiBanDdl := this.gui.AddSetting("left", "Anti-Ban Mode", "DropDownList", "Psychopath|Extreme|Stealth|Off")
        this.voiceAlertChk := this.gui.AddSetting("left", "Enable Voice Alerts", "CheckBox", "")
        this.worldHopChk := this.gui.AddSetting("left", "World Hop", "CheckBox", "")
        this.ocrChk := this.gui.AddSetting("left", "Enable OCR Detection", "CheckBox", "")
        this.stealthChk := this.gui.AddSetting("left", "STEALTH MODE (PRIMARY)", "CheckBox", "")

        ; RIGHT COLUMN - Advanced Settings
        this.maxSessionSlider := this.gui.AddSetting("right", "Max Session Duration", "Slider", "Range60-480")
        this.themeDD := this.gui.AddSetting("right", "Theme", "DropDownList", "Dark|Light")
        this.logLevelDD := this.gui.AddSetting("right", "Log Level", "DropDownList", "Debug|Info|Warn|Error")

        ; Add buttons
        btnSave := this.gui.CreateButton("Save Settings", 40, 650)
        btnReset := this.gui.CreateButton("Reset to Default", 200, 650)
        btnCancel := this.gui.CreateButton("Cancel", 360, 650)

        btnSave.OnEvent("Click", (*) => this.SaveSettings())
        btnReset.OnEvent("Click", (*) => this.ResetSettings())
        btnCancel.OnEvent("Click", (*) => ExitApp())
    }

    Show() {
        this.gui.Show()
    }

    SaveSettings() {
        MsgBox("Settings saved successfully!", "Success", 64)
    }

    ResetSettings() {
        result := MsgBox("Reset all settings to default?", "Confirm Reset", 4)
        if (result == "Yes") {
            MsgBox("Settings reset!", "Info", 64)
        }
    }
}

; Run the example
; ExampleConfigGUI := ConfigGUIExample()
; ExampleConfigGUI.Show()

; ==========================================
; EXAMPLE 2: Status/Log Monitor GUI
; ==========================================

/*
USE CASE: Display logs, status messages, activity
FEATURES: Log display, real-time updates, clear button

HOW TO RUN:
1. Create instance
2. Call AddLog() with messages
3. Show() displays the GUI
*/

class StatusMonitorExample {
    __New() {
        this.monitor := StatusTemplate("Bot Status Monitor", 1000, 600)
    }

    Show() {
        this.monitor.Show()
    }

    AddLog(message) {
        this.monitor.AddLog(message)
    }

    AddSuccess(message) {
        this.monitor.AddLog("[SUCCESS] " . message)
    }

    AddError(message) {
        this.monitor.AddLog("[ERROR] " . message)
    }

    AddWarning(message) {
        this.monitor.AddLog("[WARNING] " . message)
    }
}

; Run the example
/*
Example := StatusMonitorExample()
Example.AddLog("Bot started")
Example.AddSuccess("Connected to server")
Example.AddWarning("High memory usage detected")
Example.AddError("Connection failed")
Example.Show()
*/

; ==========================================
; EXAMPLE 3: Settings with Sidebar Navigation
; ==========================================

/*
USE CASE: Multi-category settings with navigation
FEATURES: Sidebar buttons, category switching, dynamic content
*/

class SidebarSettingsExample {
    __New() {
        this.settings := SettingsTemplate("Settings", 800, 600)

        ; Add categories to sidebar
        this.btnGeneral := this.settings.AddCategory("General")
        this.btnAdvanced := this.settings.AddCategory("Advanced")
        this.btnAbout := this.settings.AddCategory("About")

        ; Bind events
        this.btnGeneral.OnEvent("Click", (*) => this.ShowGeneral())
        this.btnAdvanced.OnEvent("Click", (*) => this.ShowAdvanced())
        this.btnAbout.OnEvent("Click", (*) => this.ShowAbout())
    }

    Show() {
        this.settings.Show()
    }

    ShowGeneral() {
        MsgBox("General Settings", "Info", 64)
    }

    ShowAdvanced() {
        MsgBox("Advanced Settings", "Info", 64)
    }

    ShowAbout() {
        MsgBox("About xh1px's Tidy Bank v2.1", "About", 64)
    }
}

; Run the example
; ExampleSettings := SidebarSettingsExample()
; ExampleSettings.Show()

; ==========================================
; EXAMPLE 4: Dashboard with Cards
; ==========================================

/*
USE CASE: Display metrics, statistics, status cards
FEATURES: Grid layout, card components, visual metrics
*/

class DashboardExample {
    __New() {
        this.dashboard := DashboardTemplate("Bot Dashboard", 1400, 800)
    }

    Show() {
        this.dashboard.Show()
    }

    AddCard(title, x, y, width := 350, height := 300) {
        ; Create card using DashboardTemplate
        cardInfo := this.dashboard.CreateCard(title, x, y, width, height)
        return cardInfo
    }
}

; Run the example
/*
ExampleDash := DashboardExample()
card1 := ExampleDash.AddCard("Bot Status", 20, 100)
card2 := ExampleDash.AddCard("Session Stats", 390, 100)
card3 := ExampleDash.AddCard("Performance", 760, 100)
ExampleDash.Show()
*/

; ==========================================
; EXAMPLE 5: Modal Dialog
; ==========================================

/*
USE CASE: Confirmation dialogs, alerts, input dialogs
FEATURES: Modal behavior, confirm/cancel buttons
*/

class ConfirmDialogExample {
    __New(title, message) {
        this.modal := ModalTemplate(title, 600, 300)
        this.modal.CreateContent(message)
        this.buttons := this.modal.CreateConfirmButtons()

        this.result := false

        this.buttons.confirm.OnEvent("Click", (*) => (this.result := true, this.modal.gui.Destroy()))
        this.buttons.cancel.OnEvent("Click", (*) => (this.result := false, this.modal.gui.Destroy()))
    }

    Show() {
        this.modal.Show()
        ; Wait for dialog to close
        Sleep(100)
        return this.result
    }
}

; Run the example
/*
confirmDlg := ConfirmDialogExample("Confirm Action", "Are you sure you want to proceed?")
result := confirmDlg.Show()
if (result) {
    MsgBox("Action confirmed!")
} else {
    MsgBox("Action cancelled!")
}
*/

; ==========================================
; EXAMPLE 6: Custom GUI with Multiple Sections
; ==========================================

/*
USE CASE: Complex interface with multiple sections
FEATURES: Multiple sections, grouped controls
*/

class MultiSectionGUIExample {
    __New() {
        ; Create basic GUI
        this.gui := GUITemplate("Multi-Section Application", 1200, 700)

        ; Header
        this.gui.CreateHeader("Application Setup", "Configure your preferences")

        ; Section 1: User Profile
        this.gui.CreateSection("User Profile")
        this.username := this.gui.CreateSetting("Name", "Edit", "")
        this.email := this.gui.CreateSetting("Email", "Edit", "")

        ; Section 2: Preferences
        this.gui.CreateSection("Preferences")
        this.theme := this.gui.CreateSetting("Theme", "DropDownList", "Dark|Light|Auto")
        this.language := this.gui.CreateSetting("Language", "DropDownList", "English|Español|Français")

        ; Buttons
        btnSave := this.gui.CreateButton("Save", 40, 650)
        btnCancel := this.gui.CreateButton("Cancel", 200, 650)

        btnSave.OnEvent("Click", (*) => this.SaveSettings())
        btnCancel.OnEvent("Click", (*) => ExitApp())
    }

    Show() {
        this.gui.Show()
    }

    SaveSettings() {
        MsgBox("Settings saved!", "Success", 64)
    }
}

; Run the example
; ExampleMulti := MultiSectionGUIExample()
; ExampleMulti.Show()

; ==========================================
; EXAMPLE 7: Bank Tab Configuration (Tidy Bank Specific)
; ==========================================

/*
USE CASE: Configure which items go in each bank tab
FEATURES: Tab selection, category checkboxes, dynamic preview
*/

class BankTabConfigExample {
    __New() {
        this.gui := GUITemplate("Bank Tab Configuration", 1200, 700)
        this.gui.CreateHeader("Bank Organization", "Configure items for each bank tab")

        this.tabNum := 1
        this.tabCategories := Map()

        ; Initialize tabs
        Loop 8 {
            this.tabCategories["tab_" (A_Index - 1)] := []
        }

        this.CreateTabSection()
        this.CreateCategorySection()
    }

    CreateTabSection() {
        this.gui.CreateSection("Bank Tabs")

        ; Create tab buttons
        this.tabButtons := Map()
        Loop 8 {
            tabNum := A_Index
            btn := this.gui.CreateButton("Tab " . tabNum, 40 + ((tabNum - 1) * 135), this.gui.currentY - 40)
            btn.OnEvent("Click", (*) => this.SelectTab(tabNum))
            this.tabButtons["tab_" (tabNum - 1)] := btn
        }

        this.gui.currentY += 20
    }

    CreateCategorySection() {
        this.gui.CreateSection("Category Selection")

        categories := ["Attack", "Strength", "Defence", "Ranged", "Magic", "Prayer",
                     "Food", "Potion", "Ammo", "Rune", "Currency", "Quest Item"]

        for category in categories {
            chk := this.gui.gui.Add("CheckBox", "x40 y" . this.gui.currentY . " c0xe5f4ff", category)
            chk.OnEvent("Click", (*) => this.UpdateCategories())
            this.gui.currentY += 22
        }
    }

    SelectTab(tabNum) {
        this.tabNum := tabNum
        MsgBox("Selected Tab " . tabNum, "Info", 64)
    }

    UpdateCategories() {
        MsgBox("Categories updated for Tab " . this.tabNum, "Info", 64)
    }

    Show() {
        this.gui.Show()
    }
}

; Run the example
; ExampleBankTab := BankTabConfigExample()
; ExampleBankTab.Show()

; ==========================================
; HELPER: Using DesignSystem Directly
; ==========================================

class DesignSystemExample {
    static Run() {
        ; Create GUI using default colors
        myGui := Gui("+LastFound", "Design System Example")
        myGui.BackColor := "0x" . DesignSystem.GetHexColor("PrimaryBg")

        ; Set font with system typography
        myGui.SetFont("s32 w700 c0x" . DesignSystem.GetHexColor("PrimaryAccent"), "Segoe UI")
        myGui.Add("Text", "x40 y20 w500", "Title with Cyan Accent")

        myGui.SetFont("s14 w400 c0x" . DesignSystem.GetHexColor("PrimaryText"), "Segoe UI")
        myGui.Add("Text", "x40 y100 w500", "Body text with proper color hierarchy")

        myGui.SetFont("s12 w400 c0x" . DesignSystem.GetHexColor("SecondaryText"), "Segoe UI")
        myGui.Add("Text", "x40 y150 w500", "Secondary text for descriptions")

        myGui.Show("w600 h300")
    }
}

; Run the example
; DesignSystemExample.Run()

; ==========================================
; QUICK REFERENCE: Creating Custom GUIs
; ==========================================

/*
STEP 1: Choose Template
--------
ConfigTemplate      → For settings/preferences
StatusTemplate      → For logs/status
SettingsTemplate    → For sidebar navigation
DashboardTemplate   → For metrics/cards
ModalTemplate       → For dialogs/popups
GUITemplate         → For general purpose

STEP 2: Create Instance
--------
MyGui := ConfigTemplate("Title", 1200, 700)

STEP 3: Add Content
--------
// Using AddSetting()
setting := MyGui.AddSetting("left", "Label", "Edit", "")

// Or using gui directly
MyGui.gui.SetFont("s14 c0xe5f4ff", "Segoe UI")
control := MyGui.gui.Add("Text", "x40 y100", "Content")

STEP 4: Add Events
--------
btn.OnEvent("Click", (*) => MyFunction())

STEP 5: Show
--------
MyGui.Show()

COLORS TO REMEMBER
--------
Titles:         "0x00d9ff" (Cyan)
Text:           "0xe5f4ff" (Near-white)
Secondary:      "0x7a8fa3" (Muted blue)
Background:     "0x0a0e14" (Dark)
Buttons:        "0x0ea5e9" (Button border)
Error:          "0xef4444" (Red)

SPACING TO REMEMBER
--------
Sidebar:        80px
Padding:        40-60px
Column Gap:     32px
Item Space:     16-22px
Border Radius:  12px
*/

; ==========================================
; COMMON PATTERNS
; ==========================================

/*
PATTERN 1: Simple Settings Page
--------
MyGui := ConfigTemplate("Settings", 1200, 700)
setting1 := MyGui.AddSetting("left", "Name", "Edit")
setting2 := MyGui.AddSetting("left", "Theme", "DropDownList", "Dark|Light")
MyGui.Show()

PATTERN 2: Confirmation Dialog
--------
result := ConfirmDialogExample("Delete Item", "Are you sure?").Show()
if (result) {
    ; Perform deletion
}

PATTERN 3: Status Monitor
--------
statusMonitor := StatusMonitorExample()
statusMonitor.AddLog("Process started")
statusMonitor.AddSuccess("Step 1 complete")
statusMonitor.Show()

PATTERN 4: Dashboard Display
--------
dashboard := DashboardExample()
card1 := dashboard.AddCard("Statistics", 20, 100)
card2 := dashboard.AddCard("Activity", 390, 100)
dashboard.Show()

PATTERN 5: Multi-Category Settings
--------
settings := SidebarSettingsExample()
settings.Show()
*/

; ==========================================
; NOTES FOR FUTURE DEVELOPMENT
; ==========================================

/*
When creating new GUIs:

1. ALWAYS use DesignSystem colors
   ✓ "0x" . DesignSystem.GetHexColor("PrimaryAccent")
   ✗ "0x00d9ff" (hardcoded)

2. ALWAYS use consistent spacing
   ✓ Use DesignSystem.PaddingLarge (60)
   ✗ Arbitrary padding values

3. ALWAYS maintain typography hierarchy
   ✓ Titles: s32 w700
   ✓ Headers: s24 w600
   ✓ Body: s14 w400
   ✗ Random font sizes

4. NEVER create custom color schemes
   ✓ Use provided colors
   ✗ Create new accent colors

5. ALWAYS document your custom GUIs
   ✓ Add comments explaining purpose
   ✓ Note required includes
   ✗ Leave code undocumented

6. CONSIDER template reusability
   ✓ Create templates for common patterns
   ✓ Share templates across projects
   ✗ Duplicate code in each project

7. TEST on multiple resolutions
   ✓ Test 1200px (desktop)
   ✓ Test 800px (tablet)
   ✓ Test 400px (mobile)
   ✗ Only test on one screen

*/

; ==========================================
; END OF EXAMPLES
; ==========================================

/*
These examples demonstrate how to use the GUI template system
for creating professional, consistent interfaces.

Each example is self-contained and can be uncommented to run.

For more information, see:
- GUI_TEMPLATE_SYSTEM.ahk (Template classes)
- GUI_DESIGN_GUIDE.md (Design documentation)
- config_gui.ahk (Full implementation example)
*/
