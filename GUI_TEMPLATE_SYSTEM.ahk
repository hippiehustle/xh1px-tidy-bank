; ==========================================
; xh1px's Tidy Bank - Professional GUI Template System
; Reusable Design System for All Future Projects
; ==========================================
; This is a MASTER TEMPLATE that can be copied and adapted
; for any future GUI project while maintaining design consistency
; ==========================================

; ==========================================
; COLOR SYSTEM (FIXED - DO NOT MODIFY)
; ==========================================

class DesignSystem {
    ; Background Colors
    static PrimaryBg := "0a0e14"        ; Deep dark blue-black
    static SecondaryBg := "151b24"      ; Slightly lighter panel
    static TertiaryBg := "1a2332"       ; Elevated card background

    ; Accent Colors
    static PrimaryAccent := "00d9ff"    ; Electric cyan
    static SecondaryAccent := "0ea5e9"  ; Cyan-blue

    ; Text Colors
    static PrimaryText := "e5f4ff"      ; Near-white with cyan tint
    static SecondaryText := "7a8fa3"    ; Muted blue-gray
    static TertiaryText := "4a5a6a"     ; Dimmer gray-blue

    ; Component Colors
    static ButtonBorder := "0ea5e9"
    static InputBorder := "2a3f52"
    static Success := "00d9ff"
    static Warning := "fbbf24"
    static Error := "ef4444"

    ; ==========================================
    ; TYPOGRAPHY SPECIFICATIONS
    ; ==========================================

    static MainTitle := "32|700"        ; Size|Weight
    static SectionHeader := "24|600"
    static SubsectionHeader := "18|600"
    static BodyText := "14|400"
    static SmallText := "12|400"
    static CodeText := "13|400"

    ; ==========================================
    ; SPACING & LAYOUT
    ; ==========================================

    static SidebarWidth := 80
    static PaddingLarge := 60
    static PaddingMedium := 32
    static PaddingSmall := 16
    static BorderRadius := 12
    static ColumnGap := 32
    static ItemSpacing := 16

    ; ==========================================
    ; HELPER METHODS
    ; ==========================================

    static Color(colorName) {
        ; Get color by name: Color("PrimaryAccent") returns hex value
        return "0x" . this[colorName]
    }

    static Font(typographyLevel) {
        ; Returns "size|weight" for SetFont
        ; Usage: MyGui.SetFont(DesignSystem.Font("MainTitle"))
        return this[typographyLevel]
    }

    static GetHexColor(colorName) {
        return this[colorName]
    }
}

; ==========================================
; TEMPLATE: BASIC GUI STRUCTURE
; ==========================================

class GUITemplate {
    __New(title := "xh1px Application", width := 1200, height := 700) {
        this.gui := Gui("+LastFound", title)
        this.gui.OnEvent("Close", (*) => ExitApp())

        ; Set background color using design system
        this.gui.BackColor := "0x" . DesignSystem.PrimaryBg
        this.gui.SetFont("s11 c0x" . DesignSystem.PrimaryText, "Segoe UI")

        this.width := width
        this.height := height
        this.currentY := 0
    }

    CreateHeader(titleText, subtitleText := "", statusText := "Ready") {
        ; Header with 3 sections: Title (left), Subtitle (left), Status (right)

        ; Header background panel
        headerBg := this.gui.Add("Text", "x0 y0 w" . this.width " h100 c0x" . DesignSystem.SecondaryBg, "")
        headerBg.Opt("-Background")

        ; Main title
        this.gui.SetFont("s32 w700 c0x" . DesignSystem.PrimaryAccent, "Segoe UI")
        this.gui.Add("Text", "x40 y20 w500", titleText)

        ; Subtitle
        this.gui.SetFont("s13 w400 c0x" . DesignSystem.SecondaryText, "Segoe UI")
        this.gui.Add("Text", "x40 y55 w500", subtitleText)

        ; Status area (top right)
        this.gui.SetFont("s12 c0x" . DesignSystem.SecondaryText, "Segoe UI")
        this.gui.Add("Text", (this.width - 180) . " y30 w150 h50 Right", statusText)

        ; Divider
        this.gui.Add("Text", "x0 y100 w" . this.width . " h1 c0x" . DesignSystem.InputBorder, "")

        this.currentY := 120
    }

    CreateSection(sectionTitle) {
        ; Create a section header
        this.gui.SetFont("s18 w600 c0x" . DesignSystem.PrimaryAccent, "Segoe UI")
        this.gui.Add("Text", "x40 y" . this.currentY, sectionTitle)
        this.currentY += 40
    }

    CreateSetting(label, controlType, options := "") {
        ; Create labeled setting (flexible control type)
        this.gui.SetFont("s13 w500 c0x" . DesignSystem.SecondaryText, "Segoe UI")
        this.gui.Add("Text", "x40 y" . this.currentY . " c0x" . DesignSystem.SecondaryText, label)
        this.currentY += 22

        this.gui.SetFont("s12 c0x" . DesignSystem.PrimaryText, "Segoe UI")
        ctrl := this.gui.Add(controlType, "x40 y" . this.currentY . " w560 " . options)
        this.currentY += 45

        return ctrl
    }

    CreateTwoColumnLayout() {
        ; Setup variables for two-column layout
        return {
            leftX: 40,
            rightX: 40 + 560 + 32,
            columnWidth: 560,
            currentLeftY: 120,
            currentRightY: 120
        }
    }

    CreateButton(text, x, y, width := 150, height := 35) {
        this.gui.SetFont("s12 w600 c0x" . DesignSystem.PrimaryAccent, "Segoe UI")
        btn := this.gui.Add("Button", "x" . x . " y" . y . " w" . width . " h" . height, text)
        return btn
    }

    CreateCheckbox(label, x, y) {
        this.gui.SetFont("s11 c0x" . DesignSystem.PrimaryText, "Segoe UI")
        chk := this.gui.Add("CheckBox", "x" . x . " y" . y . " c0x" . DesignSystem.PrimaryText, label)
        return chk
    }

    Show() {
        this.gui.Show("w" . this.width . " h" . this.height)
    }
}

; ==========================================
; TEMPLATE: DIALOG/MODAL GUI
; ==========================================

class ModalTemplate {
    __New(title := "Dialog", width := 600, height := 400) {
        this.gui := Gui("+LastFound +AlwaysOnTop", title)
        this.gui.OnEvent("Close", (*) => this.gui.Destroy())

        this.gui.BackColor := "0x" . DesignSystem.PrimaryBg
        this.gui.SetFont("s11 c0x" . DesignSystem.PrimaryText, "Segoe UI")

        this.width := width
        this.height := height
    }

    CreateContent(contentText) {
        this.gui.SetFont("s14 w400 c0x" . DesignSystem.PrimaryText, "Segoe UI")
        this.gui.Add("Text", "x20 y20 w" . (this.width - 40), contentText)
    }

    CreateConfirmButtons() {
        this.gui.SetFont("s12 w600 c0x" . DesignSystem.PrimaryAccent, "Segoe UI")
        btnConfirm := this.gui.Add("Button", "x" . ((this.width - 320) / 2) . " y" . (this.height - 60) . " w140 h35", "Confirm")
        btnCancel := this.gui.Add("Button", "x" . ((this.width - 320) / 2 + 150) . " y" . (this.height - 60) . " w140 h35", "Cancel")
        return {confirm: btnConfirm, cancel: btnCancel}
    }

    Show() {
        this.gui.Show("w" . this.width . " h" . this.height)
    }
}

; ==========================================
; TEMPLATE: SETTINGS/PREFERENCES GUI
; ==========================================

class SettingsTemplate {
    __New(title := "Settings", width := 800, height := 600) {
        this.gui := Gui("+LastFound", title)
        this.gui.OnEvent("Close", (*) => ExitApp())

        this.gui.BackColor := "0x" . DesignSystem.PrimaryBg
        this.gui.SetFont("s11 c0x" . DesignSystem.PrimaryText, "Segoe UI")

        this.width := width
        this.height := height

        ; Create sidebar for category navigation
        this.CreateSidebar()
    }

    CreateSidebar() {
        ; Left sidebar with category buttons
        sidebarBg := this.gui.Add("Text", "x0 y0 w100 h" . this.height . " c0x" . DesignSystem.SecondaryBg, "")
        sidebarBg.Opt("-Background")

        this.gui.SetFont("s10 w500 c0x" . DesignSystem.SecondaryText, "Segoe UI")
        this.sidebarButtons := Map()
    }

    AddCategory(categoryName) {
        ; Add category to sidebar
        y := 20 + (this.sidebarButtons.Count() * 50)
        btn := this.gui.Add("Button", "x10 y" . y . " w80 h40 c0x" . DesignSystem.PrimaryAccent, categoryName)
        this.sidebarButtons[categoryName] := {button: btn, y: y}
        return btn
    }

    CreateContentArea() {
        ; Main content area (right of sidebar)
        return {
            startX: 120,
            startY: 20,
            width: this.width - 140,
            height: this.height - 40
        }
    }

    Show() {
        this.gui.Show("w" . this.width . " h" . this.height)
    }
}

; ==========================================
; TEMPLATE: STATUS/LOG GUI
; ==========================================

class StatusTemplate {
    __New(title := "Status Monitor", width := 1000, height := 600) {
        this.gui := Gui("+LastFound", title)
        this.gui.OnEvent("Close", (*) => ExitApp())

        this.gui.BackColor := "0x" . DesignSystem.PrimaryBg
        this.gui.SetFont("s10 c0x" . DesignSystem.SecondaryText, "Segoe UI")

        this.width := width
        this.height := height

        ; Create header
        this.CreateHeader()

        ; Create log area
        this.log := this.gui.Add("ListBox", "x20 y100 w" . (width - 40) . " h" . (height - 140) . " c0x" . DesignSystem.PrimaryText, "")
    }

    CreateHeader() {
        this.gui.SetFont("s24 w600 c0x" . DesignSystem.PrimaryAccent, "Segoe UI")
        this.gui.Add("Text", "x20 y20", "Status Monitor")

        ; Divider
        this.gui.Add("Text", "x0 y60 w" . this.width . " h1 c0x" . DesignSystem.InputBorder, "")
    }

    AddLog(message) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        this.log.Add([timestamp . " - " . message])
    }

    ClearLog() {
        this.log.Delete()
    }

    Show() {
        this.gui.Show("w" . this.width . " h" . this.height)
    }
}

; ==========================================
; TEMPLATE: DASHBOARD GUI
; ==========================================

class DashboardTemplate {
    __New(title := "Dashboard", width := 1400, height := 800) {
        this.gui := Gui("+LastFound", title)
        this.gui.OnEvent("Close", (*) => ExitApp())

        this.gui.BackColor := "0x" . DesignSystem.PrimaryBg
        this.gui.SetFont("s11 c0x" . DesignSystem.PrimaryText, "Segoe UI")

        this.width := width
        this.height := height
    }

    CreateCard(title, x, y, width := 300, height := 200) {
        ; Create a card/panel component
        cardBg := this.gui.Add("Text", "x" . x . " y" . y . " w" . width . " h" . height . " c0x" . DesignSystem.TertiaryBg, "")
        cardBg.Opt("-Background")

        this.gui.SetFont("s14 w600 c0x" . DesignSystem.PrimaryAccent, "Segoe UI")
        this.gui.Add("Text", "x" . (x + 20) . " y" . (y + 15), title)

        return {
            x: x + 20,
            y: y + 40,
            width: width - 40,
            height: height - 60
        }
    }

    CreateGrid(rows, cols) {
        ; Helper to create grid layout
        return {
            rows: rows,
            cols: cols,
            cellWidth: (this.width - 40) / cols,
            cellHeight: (this.height - 120) / rows,
            startX: 20,
            startY: 100
        }
    }

    Show() {
        this.gui.Show("w" . this.width . " h" . this.height)
    }
}

; ==========================================
; TEMPLATE: CONFIG/PREFERENCES GUI
; ==========================================

class ConfigTemplate {
    __New(title := "Configuration", width := 1200, height := 700) {
        this.gui := Gui("+LastFound", title)
        this.gui.OnEvent("Close", (*) => ExitApp())

        this.gui.BackColor := "0x" . DesignSystem.PrimaryBg
        this.gui.SetFont("s11 c0x" . DesignSystem.PrimaryText, "Segoe UI")

        this.width := width
        this.height := height

        ; Create standard header
        this.CreateHeader("Configuration", "Manage application settings")

        ; Create two-column layout
        this.layout := {
            leftX: 40,
            rightX: 40 + 560 + 32,
            columnWidth: 560,
            currentY: 120
        }
    }

    CreateHeader(title, subtitle) {
        ; Header background
        headerBg := this.gui.Add("Text", "x0 y0 w" . this.width . " h100 c0x" . DesignSystem.SecondaryBg, "")
        headerBg.Opt("-Background")

        this.gui.SetFont("s32 w700 c0x" . DesignSystem.PrimaryAccent, "Segoe UI")
        this.gui.Add("Text", "x40 y20 w500", title)

        this.gui.SetFont("s13 w400 c0x" . DesignSystem.SecondaryText, "Segoe UI")
        this.gui.Add("Text", "x40 y55 w500", subtitle)

        ; Divider
        this.gui.Add("Text", "x0 y100 w" . this.width . " h1 c0x" . DesignSystem.InputBorder, "")
    }

    AddSetting(column, label, controlType, options := "") {
        ; Add setting to left or right column
        ; column: "left" or "right"

        x := (column == "left") ? this.layout.leftX : this.layout.rightX
        y := this.layout.currentY

        this.gui.SetFont("s13 w500 c0x" . DesignSystem.SecondaryText, "Segoe UI")
        this.gui.Add("Text", "x" . x . " y" . y, label)
        y += 22

        this.gui.SetFont("s12 c0x" . DesignSystem.PrimaryText, "Segoe UI")
        ctrl := this.gui.Add(controlType, "x" . x . " y" . y . " w" . this.layout.columnWidth . " " . options)

        this.layout.currentY += 45

        return ctrl
    }

    Show() {
        this.gui.Show("w" . this.width . " h" . this.height)
    }
}

; ==========================================
; USAGE EXAMPLE
; ==========================================

/*
Example 1: Basic GUI using template

MyGui := GUITemplate("My Application", 1200, 700)
MyGui.CreateHeader("Welcome", "This is a demo application")
MyGui.CreateSection("Settings")
MyGui.CreateSetting("Name", "Edit")
MyGui.CreateSetting("Options", "DropDownList", "Choose1|Choose2")
MyGui.Show()

Example 2: Using design system directly

myColor := DesignSystem.Color("PrimaryAccent")     ; Returns "0x00d9ff"
myFont := DesignSystem.Font("MainTitle")           ; Returns "32|700"
hexColor := DesignSystem.GetHexColor("ErrorColor") ; Returns "ef4444"

Example 3: Settings GUI with sidebar

MySettings := SettingsTemplate("My Settings", 800, 600)
MySettings.AddCategory("General")
MySettings.AddCategory("Advanced")
MySettings.AddCategory("About")
MySettings.Show()

Example 4: Dashboard with cards

MyDash := DashboardTemplate("System Dashboard", 1400, 800)
card1 := MyDash.CreateCard("Statistics", 20, 100, 300, 300)
card2 := MyDash.CreateCard("Activity", 340, 100, 300, 300)
MyDash.Show()

*/

; ==========================================
; INSTALLATION & USAGE INSTRUCTIONS
; ==========================================

/*

HOW TO USE THIS TEMPLATE SYSTEM:

1. COPY THIS FILE
   - Save as: [YourProject]_gui_templates.ahk
   - Include at top of your GUI file: #Include [YourProject]_gui_templates.ahk

2. CHOOSE A TEMPLATE
   - GUITemplate (for general purpose)
   - ModalTemplate (for dialogs)
   - SettingsTemplate (for preferences)
   - StatusTemplate (for logs/monitoring)
   - DashboardTemplate (for status/metrics)
   - ConfigTemplate (for configuration)

3. CREATE YOUR GUI
   Example:

   #Requires AutoHotkey v2.0
   #Include config_gui_templates.ahk

   MyGui := ConfigTemplate("My App Configuration", 1200, 700)

   ; Add your custom content
   btn := MyGui.CreateButton("Save", 40, 650)
   btn.OnEvent("Click", SaveSettings)

   MyGui.Show()

   SaveSettings(*) {
       MsgBox "Settings saved!"
   }

4. CUSTOMIZE
   - All colors come from DesignSystem (change one place = all change)
   - All spacing/sizing from DesignSystem (consistent across app)
   - Only modify content/text/logic - never colors or styling

5. MAINTAIN CONSISTENCY
   ✅ ALWAYS use DesignSystem colors
   ✅ ALWAYS use DesignSystem fonts
   ✅ ALWAYS use DesignSystem spacing
   ❌ NEVER hardcode colors
   ❌ NEVER use different color schemes
   ❌ NEVER modify design constants

BENEFITS:
- Consistent design across all projects
- Easy to update design globally
- Professional, polished appearance
- Quick GUI development
- Accessible color scheme
- Proven layout patterns

*/
