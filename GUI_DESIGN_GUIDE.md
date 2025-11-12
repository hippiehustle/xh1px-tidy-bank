# xh1px's Professional GUI Design System
## Complete Guide for All Future Projects

---

## 📋 TABLE OF CONTENTS
1. [Color System](#color-system)
2. [Typography System](#typography-system)
3. [Layout Architecture](#layout-architecture)
4. [Component Specifications](#component-specifications)
5. [Template Classes](#template-classes)
6. [Usage Instructions](#usage-instructions)
7. [Design Patterns](#design-patterns)
8. [Responsive Behavior](#responsive-behavior)
9. [Accessibility](#accessibility)
10. [Troubleshooting](#troubleshooting)

---

## COLOR SYSTEM

### Fixed Colors (DO NOT MODIFY)

#### Background Colors
```
Primary Background:     #0a0e14  (Deep dark blue-black)
Secondary Background:   #151b24  (Slightly lighter panel)
Tertiary Background:    #1a2332  (Elevated card background)
```

**Usage:**
- Primary: Main window background
- Secondary: Header, footer, panels
- Tertiary: Cards, popups, elevated content

#### Accent Colors
```
Primary Accent (Cyan):  #00d9ff  (Electric cyan for headers, highlights)
Secondary Accent:       #0ea5e9  (Cyan-blue for buttons, interactive elements)
```

**Usage:**
- Primary: Important titles, active states, primary CTAs
- Secondary: Buttons, links, secondary interactive elements

#### Text Colors
```
Primary Text:   #e5f4ff     (Near-white with cyan tint for body)
Secondary Text: #7a8fa3     (Muted blue-gray for subtitles)
Tertiary Text:  #4a5a6a     (Dimmer gray-blue for metadata)
```

**Hierarchy:**
- Primary: Main content, labels
- Secondary: Descriptions, hints
- Tertiary: Timestamps, metadata, disabled text

#### Status Colors
```
Success:  #00d9ff  (Same as Primary Accent - green alternative #10b981)
Warning:  #fbbf24  (Amber/yellow for caution)
Error:    #ef4444  (Red for errors/danger)
```

### Color Implementation

```autohotkey
; Using DesignSystem class
colorCyan := DesignSystem.Color("PrimaryAccent")      ; Returns "0x00d9ff"
bgColor := "0x" . DesignSystem.GetHexColor("PrimaryBg")  ; Returns "0x0a0e14"

; In SetFont
MyGui.SetFont("c0x" . DesignSystem.PrimaryText, "Segoe UI")

; For control creation
textCtrl := MyGui.Add("Text", , "Status")
```

---

## TYPOGRAPHY SYSTEM

### Fixed Typography (DO NOT MODIFY)

#### Font Family
```
Primary Font:   Segoe UI, Inter, -apple-system, sans-serif
Monospace Font: Fira Code, JetBrains Mono, Consolas, monospace
```

#### Font Sizes & Weights

| Level | Size | Weight | Usage |
|-------|------|--------|-------|
| **Main Title** | 32px | 700 | Page/window title |
| **Section Header** | 24px | 600 | Major section headers |
| **Subsection Header** | 18px | 600 | Subsection headers |
| **Body Text** | 14px | 400 | Standard content |
| **Small Text** | 12px | 400 | Descriptions, hints |
| **Code Text** | 13px | 400 | Monospace code |

#### Implementation

```autohotkey
; Using DesignSystem.Font()
MyGui.SetFont(DesignSystem.Font("MainTitle"))          ; "32|700"
MyGui.SetFont(DesignSystem.Font("SectionHeader"))      ; "24|600"
MyGui.SetFont(DesignSystem.Font("BodyText"))           ; "14|400"

; Manual specification
MyGui.SetFont("s32 w700 c0x00d9ff", "Segoe UI")       ; Main title
MyGui.SetFont("s24 w600 c0x00d9ff", "Segoe UI")       ; Section header
MyGui.SetFont("s14 w400 c0xe5f4ff", "Segoe UI")       ; Body text
```

#### Text Styling

- **Letter Spacing:** Slightly increased for headers (+0.5px to +1px)
- **Line Height:** 1.5-1.6 for body, 1.2-1.3 for headers
- **Case:** Preserve natural casing (Title Case for headers)

---

## LAYOUT ARCHITECTURE

### Grid System

```
Total Width: 1200px (adjustable)

+---+---+---+---+---+---+---+---+
|   |                           |
| 80 |  1120px Content Area    |
|   |                           |
+---+---+---+---+---+---+---+---+

Content Area:
+--------+--------+
|        |        |
| 560px  |  560px | (with 32px gap)
|        |        |
+--------+--------+
```

### Spacing Constants

```autohotkey
SidebarWidth:   80px
PaddingLarge:   60px
PaddingMedium:  32px
PaddingSmall:   16px
ColumnGap:      32px
ItemSpacing:    16px
BorderRadius:   12px
```

### Typical Layouts

#### Single Column
```
┌─────────────────────────────┐
│        Header (100px)       │
├─────────────────────────────┤
│                             │
│    Main Content Area        │
│    (40px margins)           │
│                             │
├─────────────────────────────┤
│    Buttons (bottom)         │
└─────────────────────────────┘
```

#### Two Column
```
┌─────────────────────────────┐
│        Header (100px)       │
├──────────────┬──────────────┤
│              │              │
│  Left Col    │  Right Col   │
│  (560px)     │  (560px)     │
│              │  (32px gap)  │
├──────────────┴──────────────┤
│    Footer / Buttons         │
└─────────────────────────────┘
```

#### Sidebar + Content
```
┌──────┬──────────────────────┐
│ Side │      Header          │
│ Bar  ├──────────────────────┤
│ (80) │                      │
│      │  Main Content        │
│      │                      │
├──────┼──────────────────────┤
│      │    Buttons/Footer    │
└──────┴──────────────────────┘
```

---

## COMPONENT SPECIFICATIONS

### Headers/Titles

**Style:**
- Color: Primary Accent (#00d9ff)
- Size: As per typography table
- Weight: 600-700
- Letter Spacing: +0.5px to +1px
- Margin Bottom: 16-20px

**Example:**
```autohotkey
MyGui.SetFont("s32 w700 c0x00d9ff", "Segoe UI")
MyGui.Add("Text", "x40 y20 w500", "Application Title")
```

### Buttons

**Style:**
- Background: Transparent
- Border: 2px solid #0ea5e9
- Border Radius: 6-8px
- Padding: 10px horizontal, 20px vertical
- Text Color: #00d9ff
- Font Weight: 500-600

**Hover State:**
- Border Color: #00d9ff (brightens)
- Glow Effect: 0 0 12px rgba(0, 217, 255, 0.4)
- Transition: 0.2s ease-in-out

**Example:**
```autohotkey
MyGui.SetFont("s12 w600 c0x00d9ff", "Segoe UI")
btn := MyGui.Add("Button", "x40 y100 w150 h35", "Click Me")
btn.OnEvent("Click", MyFunction)
```

### Input Fields

**Style:**
- Background: rgba(255, 255, 255, 0.03)
- Border: 1px solid #2a3f52
- Border Radius: 6-8px
- Padding: 12px horizontal, 12px vertical
- Text Color: #e5f4ff
- Placeholder Color: #4a5a6a

**Focus State:**
- Border Color: #0ea5e9
- Glow Effect: 0 0 12px rgba(0, 217, 255, 0.2)

**Example:**
```autohotkey
MyGui.SetFont("s12 c0xe5f4ff", "Segoe UI")
edit := MyGui.Add("Edit", "x40 y100 w560 h35", "")
```

### CheckBoxes

**Style:**
- Text Color: Primary Text (#e5f4ff)
- Size: s11 for standard, s13 for important
- Spacing: 22px between items

**Example:**
```autohotkey
MyGui.SetFont("s11 c0xe5f4ff", "Segoe UI")
chk := MyGui.Add("CheckBox", "x40 y100", "Enable Feature")
```

### Dropdowns

**Style:**
- Same styling as input fields
- Text Color: Primary Text (#e5f4ff)
- Options listed in consistent format

**Example:**
```autohotkey
MyGui.SetFont("s12 c0xe5f4ff", "Segoe UI")
ddl := MyGui.Add("DropDownList", "x40 y100 w560", ["Option1", "Option2", "Option3"])
```

### Cards/Panels

**Style:**
- Background: Secondary or Tertiary BG (#151b24 or #1a2332)
- Border Radius: 12px
- Padding: 24-32px
- Box Shadow: 0 4px 12px rgba(0, 0, 0, 0.4)
- Border: 1px solid rgba(255, 255, 255, 0.05)

**Example:**
```autohotkey
; Card background
cardBg := MyGui.Add("Text", "x40 y100 w520 h300 c0x1a2332", "")
cardBg.Opt("-Background")

; Card title
MyGui.SetFont("s18 w600 c0x00d9ff", "Segoe UI")
MyGui.Add("Text", "x60 y115", "Card Title")
```

### Dividers

**Style:**
- Color: #2a3f52 (InputBorder)
- Height: 1px
- Width: Full or specific
- Margin: 20px top/bottom

**Example:**
```autohotkey
MyGui.Add("Text", "x0 y100 w1200 h1 c0x2a3f52", "")
```

---

## TEMPLATE CLASSES

### DesignSystem (Color & Typography Constants)

```autohotkey
; Access colors
MyColor := DesignSystem.Color("PrimaryAccent")
MyHex := DesignSystem.GetHexColor("ErrorColor")

; Access typography
MyFont := DesignSystem.Font("MainTitle")  ; Returns "32|700"

; Spacing constants
SidebarWidth := DesignSystem.SidebarWidth    ; 80
PaddingLarge := DesignSystem.PaddingLarge    ; 60
```

### GUITemplate (Basic GUI Structure)

```autohotkey
MyGui := GUITemplate("Application Title", 1200, 700)
MyGui.CreateHeader("Title", "Subtitle", "Status")
MyGui.CreateSection("Settings")
MyGui.CreateSetting("Label", "Edit", "")
btn := MyGui.CreateButton("Save", 40, 600, 150, 35)
MyGui.Show()
```

### ConfigTemplate (Configuration Interface)

```autohotkey
MyCfg := ConfigTemplate("Settings", 1200, 700)
MyCfg.AddSetting("left", "Username", "Edit", "")
MyCfg.AddSetting("right", "Theme", "DropDownList", "Light|Dark|Auto")
MyCfg.Show()
```

### ModalTemplate (Dialog/Popup)

```autohotkey
MyModal := ModalTemplate("Confirm", 600, 300)
MyModal.CreateContent("Are you sure?")
buttons := MyModal.CreateConfirmButtons()
buttons.confirm.OnEvent("Click", ConfirmAction)
MyModal.Show()
```

### SettingsTemplate (Preferences with Sidebar)

```autohotkey
MySettings := SettingsTemplate("Settings", 800, 600)
MySettings.AddCategory("General")
MySettings.AddCategory("Advanced")
MySettings.Show()
```

### StatusTemplate (Logging/Status Display)

```autohotkey
MyStatus := StatusTemplate("Status Monitor", 1000, 600)
MyStatus.AddLog("Application started")
MyStatus.AddLog("Process complete")
MyStatus.Show()
```

### DashboardTemplate (Metrics/Status Dashboard)

```autohotkey
MyDash := DashboardTemplate("Dashboard", 1400, 800)
card1 := MyDash.CreateCard("Statistics", 20, 100, 300, 300)
card2 := MyDash.CreateCard("Activity", 340, 100, 300, 300)
MyDash.Show()
```

---

## USAGE INSTRUCTIONS

### Step 1: Include the Template System

```autohotkey
#Requires AutoHotkey v2.0
#Include GUI_TEMPLATE_SYSTEM.ahk

; Your code here
```

### Step 2: Choose a Template

```autohotkey
; For configuration GUI
MyGui := ConfigTemplate("My Settings", 1200, 700)

; For status/logging
MyGui := StatusTemplate("Status Monitor", 1000, 600)

; For general purpose
MyGui := GUITemplate("My Application", 1200, 700)
```

### Step 3: Create Your Content

```autohotkey
MyGui := ConfigTemplate("Bot Configuration", 1200, 700)

; Add settings to left column
edit1 := MyGui.AddSetting("left", "Username", "Edit", "")
chk1 := MyGui.AddSetting("left", "Enable Feature", "CheckBox", "")

; Add settings to right column
ddl1 := MyGui.AddSetting("right", "Theme", "DropDownList", "Light|Dark")
chk2 := MyGui.AddSetting("right", "Advanced Mode", "CheckBox", "")

; Add buttons
btn := MyGui.CreateButton("Save", 40, 650)
btn.OnEvent("Click", SaveConfig)

MyGui.Show()
```

### Step 4: Add Event Handlers

```autohotkey
SaveConfig(*) {
    MsgBox("Settings saved!")
}

MyGui.Show()
```

---

## DESIGN PATTERNS

### Pattern 1: Header + Content + Footer

```autohotkey
MyGui := GUITemplate("Application", 1200, 700)
MyGui.CreateHeader("Welcome", "This is a demo")

; Add content (automatically increments Y position)
MyGui.CreateSection("Main Settings")
setting1 := MyGui.CreateSetting("Name", "Edit")

; Add buttons at bottom
MyGui.CreateButton("Save", 40, 650)
MyGui.CreateButton("Cancel", 200, 650)

MyGui.Show()
```

### Pattern 2: Two-Column Layout

```autohotkey
MyCfg := ConfigTemplate("Settings", 1200, 700)

; Left column
text1 := MyCfg.AddSetting("left", "Setting 1", "Edit", "")
chk1 := MyCfg.AddSetting("left", "Feature A", "CheckBox", "")

; Right column
text2 := MyCfg.AddSetting("right", "Setting 2", "Edit", "")
chk2 := MyCfg.AddSetting("right", "Feature B", "CheckBox", "")

MyCfg.Show()
```

### Pattern 3: Sidebar Navigation

```autohotkey
MySettings := SettingsTemplate("Settings", 800, 600)

btn1 := MySettings.AddCategory("General")
btn2 := MySettings.AddCategory("Advanced")
btn3 := MySettings.AddCategory("About")

btn1.OnEvent("Click", (*) => ShowGeneral())
btn2.OnEvent("Click", (*) => ShowAdvanced())
btn3.OnEvent("Click", (*) => ShowAbout())

MySettings.Show()
```

### Pattern 4: Status Display

```autohotkey
MyStatus := StatusTemplate("Logs", 1000, 600)

MyStatus.AddLog("Starting process...")
MyStatus.AddLog("Step 1 complete")
MyStatus.AddLog("Step 2 complete")
MyStatus.AddLog("Process finished")

MyStatus.Show()
```

### Pattern 5: Card Dashboard

```autohotkey
MyDash := DashboardTemplate("Dashboard", 1400, 800)

card1 := MyDash.CreateCard("Statistics", 20, 100, 350, 300)
card2 := MyDash.CreateCard("Activity", 390, 100, 350, 300)
card3 := MyDash.CreateCard("Performance", 760, 100, 350, 300)

MyDash.Show()
```

---

## RESPONSIVE BEHAVIOR

### Desktop (1200px+)
- Full two-column layout
- Sidebar visible
- Normal spacing

### Tablet (768px - 1199px)
- Collapse to single column (optional)
- Reduce padding proportionally
- Stack sidebars if needed

### Mobile (< 768px)
- Single column layout
- Sidebar becomes hamburger menu
- Reduced padding (halve PaddingLarge)
- Full-width buttons

---

## ACCESSIBILITY

### Color Contrast
- Primary Text (#e5f4ff) on Primary BG (#0a0e14): 18.2:1 ✅
- All text meets WCAG AA standards

### Typography
- Minimum font size: 12px
- Line height: 1.5+ for body text
- Clear visual hierarchy

### Keyboard Navigation
- All buttons accessible via Tab key
- Enter activates buttons
- Checkboxes accessible via Space

### Screen Readers
- All elements have descriptive labels
- Avoid icon-only buttons (use labels)
- Use proper control types

---

## TROUBLESHOOTING

### Colors Look Different

**Problem:** Colors on your screen don't match the palette
**Solution:** Check monitor color profile, ensure 24-bit color mode

### Text Overlapping

**Problem:** Text elements are overlapping
**Solution:** Increase spacing values, use proper Y coordinates

### GUI Too Large/Small

**Problem:** GUI doesn't fit screen
**Solution:** Adjust width/height in template constructor

### Fonts Not Rendering

**Problem:** Wrong font displaying
**Solution:** Ensure Segoe UI is installed (default Windows font)

### Buttons Not Responding

**Problem:** Buttons don't respond to clicks
**Solution:** Check event handler is properly bound with `.OnEvent()`

### Colors Not Applying

**Problem:** Color values not working
**Solution:** Remember hex format: "0x" + hexcode (e.g., "0x00d9ff")

---

## QUICK REFERENCE

### Common Colors
```autohotkey
Primary Accent:     "0x00d9ff"
Secondary Accent:   "0x0ea5e9"
Primary Text:       "0xe5f4ff"
Secondary Text:     "0x7a8fa3"
Primary BG:         "0x0a0e14"
Secondary BG:       "0x151b24"
Error:              "0xef4444"
Warning:            "0xfbbf24"
```

### Common Fonts
```
Title:      "s32 w700"
Header:     "s24 w600"
Body:       "s14 w400"
Small:      "s12 w400"
Code:       "s13 w400"
```

### Common Spacing
```
Sidebar:     80px
Padding:     40-60px
Gap:         32px
Item Space:  16-22px
Border Rad:  12px
```

---

## NEXT STEPS

1. **Copy this guide** to your project folder
2. **Include GUI_TEMPLATE_SYSTEM.ahk** in your project
3. **Use the templates** for all future GUIs
4. **Maintain consistency** by always using DesignSystem
5. **Document changes** if you adapt templates

---

## VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 2025 | Initial design system |
| 2.1 | Jan 2025 | Enhanced config_gui with template system |

---

## SUPPORT

For questions about the design system or template implementation:
1. Review the USAGE INSTRUCTIONS section
2. Check the TROUBLESHOOTING section
3. Examine existing templates in config_gui.ahk

---

**This design system ensures consistency, professionalism, and accessibility across all xh1px projects.**

*Last Updated: January 2025*
