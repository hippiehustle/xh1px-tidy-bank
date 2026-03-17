# Quick Start Guide v2.0

## New Features in v2.0

🎯 **Intelligent Bank Sorting** - Items are automatically sorted by category
🔄 **Automatic Conflict Resolution** - Items with multiple tags use lowest tab number
⚙️ **Dynamic Main Script Generation** - Settings automatically update main.ahk
📊 **24,735 Tagged Items** - Complete OSRS item database with classifications

---

## Setup (5 Minutes)

### Step 1: Run the Configuration GUI

```
Double-click: config_gui.ahk
```

### Step 2: Configure Bot Settings Tab

1. **Anti-Ban Mode**: Choose your preference (Psychopath, Extreme, Stealth, Off)
2. **Stealth Mode**: ✓ Recommended for primary safety
3. **Max Session**: Set your play time limit (60-480 minutes)
4. **Feature Toggles**: Enable OCR, Voice Alerts, World Hopping as desired

### Step 3: Configure Bank Tabs

1. Click **"Bank Configuration"** tab
2. Select a bank tab (1-8) to configure
3. Check items/categories you want in that tab using the TreeView
4. Repeat for each tab you want to use

**Example Configuration:**
```
Tab 1: Combat Skills (Ranged, Magic, Prayer)
Tab 2: Gathering Skills (Fishing, Woodcutting, Mining)
Tab 3: Artisan Skills (Cooking, Smithing, Crafting)
Tab 4: Food & Potions (Food, Combat Potions)
Tab 5: Resources (Ores, Logs, Fish)
Tab 6: Equipment (Melee Equipment, Ranged Equipment)
Tab 7: Seeds & Herbs
Tab 8: Miscellaneous
```

### Step 4: Save Settings

Click **"Save Settings"** or **"Save Bank Config"**

The system will:
- ✓ Save your configuration to user_config.json
- ✓ **Automatically generate main.ahk** with your settings
- ✓ Initialize the conflict resolver with your tab mappings

---

## Understanding Conflicts

### What are conflicts?

Items with multiple categories that map to different tabs.

**Example:**
- **Shark** has tags: `consume_food`, `skill_fishing`, `skill_cooking`
- You configured:
  - Tab 1 = Fishing
  - Tab 2 = Food
  - Tab 3 = Cooking

**Where does Shark go?** → **Tab 1** (lowest number)

### The Golden Rule

**When an item matches multiple tabs, it goes to the LOWEST numbered tab.**

### How to Control This

Want Food to have priority over Fishing? Assign Food to Tab 1 and Fishing to Tab 2!

```
Priority Configuration:
  Tab 1: Food (consume_food)          ← Gets priority
  Tab 2: Fishing (skill_fishing)
  Tab 3: Cooking (skill_cooking)

Result: Shark → Tab 1 (Food)
```

---

## Running the Bot

### Step 1: Ensure Requirements

- ✓ BlueStacks Android Emulator running
- ✓ OSRS Mobile open in BlueStacks
- ✓ ADB connection established (127.0.0.1:5555)
- ✓ Character standing near bank

### Step 2: Start the Bot

```
Double-click: main.ahk
```

Or click **"Generate Bot"** in config_gui.ahk

### Step 3: Bot Controls

- **F1** - Start/Stop bot
- **F2** - Emergency shutdown (closes OSRS, reboots device)
- **ESC** - Exit bot

### Step 4: Monitor

The bot will:
1. Activate stealth/anti-ban systems
2. Open bank if not already open
3. Scan items in bank
4. Resolve each item to its destination tab
5. Move items to appropriate tabs
6. Continue until session limit reached

---

## How Items Are Sorted

### 1. Item Detection

Bot scans bank and identifies items using OCR or image recognition.

### 2. Tag Lookup

```autohotkey
item := ItemGroupingSystem.GetItemByName("Shark")
; Returns item with tags: [consume_food, skill_fishing, skill_cooking, ...]
```

### 3. Conflict Resolution

```autohotkey
tabNumber := BankTabResolver.ResolveItemTab(item)
; Checks all tags, returns lowest matching tab
```

### 4. Item Placement

Bot moves item to the resolved tab and arranges it in the grid.

---

## Category Reference

### Core Groups

| Core Group | Description | Examples |
|------------|-------------|----------|
| **SKILLS** | Skill-related items | Training equipment, capes |
| **EQUIPMENT** | Worn items | Weapons, armor, jewelry |
| **RESOURCES** | Gatherable materials | Ores, logs, fish, herbs |
| **CONSUMABLES** | Used/eaten items | Food, potions, ammo |
| **TOOLS** | Utility tools | Pickaxes, axes, rods |
| **QUEST** | Quest items | Quest-specific items |
| **CURRENCY** | Money & tokens | Coins, tokkul |

### Popular Tags

| Tag | Category | Items |
|-----|----------|-------|
| `skill_herblore` | Herblore | Herbs, potions, secondaries |
| `skill_fishing` | Fishing | Fish, fishing equipment |
| `consume_food` | Food | All edible items |
| `equip_melee` | Melee Equipment | Melee weapons & armor |
| `resource_ore` | Mining | All ores |
| `resource_log` | Woodcutting | All logs |
| `consume_potion_combat` | Combat Potions | Attack, strength, defense potions |

Full list: See ITEM_GROUPING_SYSTEM.md

---

## Tips & Best Practices

### ⭐ Tip 1: Specific Categories First

Put more specific categories in lower tabs:

```
✓ GOOD:
  Tab 1: Combat Potions
  Tab 2: All Potions
  Tab 3: Herblore Items
```

### ⭐ Tip 2: Separate Instead of Combine

```
✓ BETTER:
  Tab 1: Raw Fish
  Tab 2: Cooked Fish
  Tab 3: Fishing Equipment
```

### ⭐ Tip 3: Group by Activity

```
PvP Setup:
  Tab 1: PvP Gear
  Tab 2: PvP Potions/Food
  Tab 3: General Combat

Skilling Setup:
  Tab 1: Current Skill (what you're training)
  Tab 2: Resources
  Tab 3: Tools
```

### ⭐ Tip 4: Use Unassigned Tab

Leave Tab 8 empty to catch unassigned items.

---

## Troubleshooting

### Items Not Sorting

**Check:**
1. Item has tags matching your configuration
2. Bank tabs properly configured in GUI
3. main.ahk was regenerated (automatic on save)

**Test:**
```autohotkey
item := ItemGroupingSystem.GetItemByName("Your Item Name")
MsgBox(JSON.Stringify(item.tags))  ; See all tags
```

### Items Going to Wrong Tab

**Remember:** Lowest tab always wins!

**Check:**
1. Item tags (see above)
2. Your tab configuration order
3. Reorder tabs if needed for different priority

### Bot Not Running

**Check:**
1. BlueStacks is running
2. OSRS Mobile is open
3. ADB connection: `adb devices` in command prompt
4. main.ahk exists (regenerate from GUI if needed)

---

## File Structure

```
xh1px-tidy-bank/
├── config_gui.ahk                  # Configuration interface ⭐
├── main.ahk                        # Generated bot script (auto-created)
├── main_template_v2.ahk            # Template for generation
├── item_grouping.ahk               # Item database module
├── bank_tab_resolver.ahk           # Conflict resolution
├── osrs-items-condensed.json       # Item database (24,735 items)
├── user_config.json                # Your settings (auto-created)
├── ITEM_GROUPING_SYSTEM.md         # Full tag reference
├── CONFLICT_RESOLUTION_GUIDE.md    # Detailed conflict guide
└── QUICK_START_V2.md               # This file
```

---

## Support

### Documentation Files

1. **QUICK_START_V2.md** (This file) - Getting started
2. **ITEM_GROUPING_SYSTEM.md** - Complete tag hierarchy
3. **ITEM_GROUPING_USAGE.md** - API reference
4. **CONFLICT_RESOLUTION_GUIDE.md** - Conflict resolution details

### Common Questions

**Q: How do I change which tab an item goes to?**
A: Reconfigure your tabs in the GUI. Remember: lowest tab wins.

**Q: Can I have the same category in multiple tabs?**
A: Yes, but items will only go to the lowest numbered tab.

**Q: What if an item isn't assigned to any tab?**
A: It goes to Tab 8 by default (configurable in main_template_v2.ahk).

**Q: How do I update the bot after changing settings?**
A: Just save in the GUI - main.ahk is automatically regenerated!

**Q: Where are the logs?**
A: `logs/tidybank_log.txt`

---

## What's New in v2.0

### Added
✓ Item grouping system with 24,735 tagged items
✓ Conflict resolution (lowest tab wins)
✓ Automatic main.ahk generation on save
✓ TreeView category selection in GUI
✓ Real-time item tag lookup
✓ Intelligent bank tab sorting

### Improved
✓ GUI redesigned with modern UX
✓ Better visual hierarchy and feedback
✓ Cleaner codebase (90% documentation reduction)
✓ Performance optimized (4.9MB vs 49MB database)

### Changed
✓ Sorting now uses categories instead of simple GE value/alphabet
✓ Settings automatically generate main.ahk (no separate step)
✓ Bank tabs now support any tag/category from the database

---

## Quick Commands Reference

```autohotkey
; Get item information
item := ItemGroupingSystem.GetItemByName("Shark")

; See all tags
MsgBox(JSON.Stringify(item.tags))

; Resolve destination tab
tabNum := BankTabResolver.ResolveItemTab(item)

; Get conflict statistics
stats := BankTabResolver.GetConflictStats(allItems)
```

---

**Ready to sort your bank like a pro!** 🎯

**Last Updated:** 2025-11-12
**Version:** 2.0
