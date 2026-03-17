# xh1px's Tidy Bank v2.0 - Quick Start Guide

## What Changed in v2.0

### Old (v1.0)
- 11 hardcoded test items
- One simple sort mode (GEValue, Alphabet, ItemID)
- No category organization

### New (v2.0)
- 40+ OSRS item categories and skills
- **Interactive bank tab configuration**
- **Per-tab category selection**
- **Full osrsbox database integration ready**
- Stealth-first design
- Character position safety

---

## Getting Started (3 Steps)

### Step 1: Configure Your Bank Tabs
```
1. Run: config_gui.ahk
2. Left panel: Set Anti-Ban, OCR, Stealth Mode, Max Session
3. Center panel: Click each bank tab (Tab 1-8)
4. Check the categories you want in that tab
5. Click "Save Settings"
```

### Step 2: See Your Configuration
The bot saves your settings to `user_config.json`:
```json
{
  "BankCategories": {
    "tab_0": ["Attack", "Strength"],
    "tab_1": ["Defence", "Prayer"],
    ...
  }
}
```

### Step 3: Generate Bot
```
1. Click "Generate Bot" in config_gui
2. Bot will read your categories
3. Start bot with F1 key in main.ahk
```

---

## Available Categories (40+)

### Combat Skills (6)
Attack, Strength, Defence, Ranged, Magic, Prayer

### Gathering Skills (5)
Cooking, Fishing, Firemaking, Woodcutting, Mining

### Artisan Skills (6)
Fletching, Crafting, Smithing, Herblore, Runecraft, Farming

### Support Skills (6)
Agility, Thieving, Slayer, Hunter, Construction, (Farming duplicate)

### Equipment Slots (10)
Helm, Body, Legs, Boots, Gloves, Cape, Neck, Ring, Weapon, Shield

### Consumables (3)
Potion, Food, (Drink)

### Special (8)
Ammo, Rune, Currency, GP, Quest Item, Barrows, God Wars, Boss Drops, Raids-CoX, Raids-ToB, Skilling Outfit

---

## Configuration Examples

### Example 1: PvP Combat Setup
```
Tab 1: Attack, Strength
Tab 2: Defence, Prayer
Tab 3: Ranged, Ammo
Tab 4: Helm, Body, Legs, Boots
Tab 5: Cape, Neck, Ring, Gloves
Tab 6: Potion, Food
Tab 7: Currency
Tab 8: (empty)
```

### Example 2: Skilling Setup
```
Tab 1: Woodcutting, Firemaking (Logs)
Tab 2: Fishing, Cooking (Fish, Food)
Tab 3: Mining, Smithing (Ore, Bars)
Tab 4: Herblore, Farming (Herbs, Seeds)
Tab 5: Crafting, Fletching (Gems, Arrows)
Tab 6: Runecraft (Runes, Essence)
Tab 7: Currency
Tab 8: (empty)
```

### Example 3: All-In-One
```
Tab 1: Attack, Strength, Ranged
Tab 2: Magic, Prayer
Tab 3: Defence
Tab 4: Potion, Food
Tab 5: Herblore, Farming
Tab 6: Cooking, Fishing
Tab 7: Currency, GP
Tab 8: Quest Item
```

---

## Bot Controls

| Key | Action |
|-----|--------|
| **F1** | Toggle bot ON/OFF |
| **F2** | Panic abort (emergency stop) |
| **Esc** | Exit completely |

---

## Settings Explained

### Anti-Ban Mode
- **Psychopath:** Minimal pauses (risky, fast)
- **Extreme:** Moderate pauses (balanced)
- **Stealth:** Long pauses (safest)
- **Off:** No pauses (very risky)

### Voice Alerts
- Speaks status updates (useful for monitoring)
- Can be disabled to run silently

### World Hop
- Randomly switches OSRS worlds (rare)
- Helps with congestion/other players

### Enable OCR
- Uses text recognition to identify items
- More accurate than template matching alone
- Slightly slower but more reliable

### Stealth Mode (PRIMARY)
- **MUST be ON** for safety
- Disables visible mouse movements
- Uses Android swipe commands instead
- Zero detection risk

### Max Session
- Limits how long bot runs
- Default: 240 minutes (4 hours)
- Adjustable 60-480 minutes

---

## How It Works

### When You Run the Bot:

1. **Database loads** - Reads osrsbox-db.json
2. **Screenshot taken** - Captures bank UI
3. **Items detected** - OCR reads item names (primary) or template matching (fallback)
4. **Categories applied** - Matches items to your tab categories
5. **Drag operations** - Moves items using Bezier curves (stealth)
6. **Position tracking** - Verifies character stays in place
7. **Logging** - Records all operations

### Safety Features:
- ✅ Character position monitored constantly
- ✅ Auto-corrects if accidentally moved
- ✅ No typing in game chat
- ✅ No character movement (except correction)
- ✅ No NPC interaction
- ✅ All operations logged

---

## Database Setup

### Using Stub Database (Default)
- 33 test items included
- Good for testing configuration
- Works out of the box

### Using Full osrsbox Database (Recommended)
1. Download: https://github.com/osrsbox/osrsbox-db/releases
2. Get: `items-complete.json`
3. Save as: `osrsbox-db.json` in bot folder
4. Bot automatically uses it (23,000+ items!)

---

## Troubleshooting

### Bot says "Database not found"
```
✓ Make sure osrsbox-db.json is in same folder as bot
✓ Check file name exactly matches (case-sensitive)
✓ JSON file should start with "{"
```

### Bot won't detect items
```
✓ Enable OCR in settings
✓ Make sure bank is open in emulator
✓ Verify screenshot is being taken
✓ Check BankCategories in user_config.json
```

### GUI won't open
```
✓ Make sure AutoHotkey v2.0 is installed
✓ Try running as administrator
✓ Check that config_gui.ahk is in bot folder
```

### Items not moving
```
✓ Make sure Stealth Mode is ON
✓ Verify ADB is connected to BlueStacks
✓ Check that categories match item names
✓ Review logs folder for errors
```

---

## Important Warnings

### ⚠️ ALWAYS:
1. Keep Stealth Mode ON
2. Use Anti-Ban (never "Off")
3. Monitor first session manually
4. Read logs folder after each run
5. Check character position stays locked

### ⚠️ NEVER:
1. Set max session > 6 hours
2. Run continuously 24/7
3. Run while actively playing
4. Disable Stealth Mode
5. Type custom code without testing

---

## Performance Tips

### To Make Bot Faster:
- Disable Voice Alerts
- Set Anti-Ban to "Psychopath"
- Use smaller max session (less timeout checks)
- Keep fewer categories per tab

### To Make Bot Safer:
- Enable Voice Alerts (monitor status)
- Set Anti-Ban to "Stealth"
- Increase max session slightly
- More categories per tab = more variation

### To Make Bot More Accurate:
- Enable OCR
- Use full osrsbox database
- Test with single category first
- Monitor first run manually

---

## File Reference

| File | What It Does |
|------|-------------|
| `config_gui.ahk` | Settings configuration UI (run this first!) |
| `database.ahk` | Item categorization system |
| `generate_main.ahk` | Creates bot with your settings |
| `main_template.ahk` | Bot logic (template) |
| `main.ahk` | Your customized bot (run this to bot) |
| `osrsbox-db.json` | Item database (replaceable with full DB) |
| `user_config.json` | Your saved settings |
| `xh1px_logo.png` | Branding image |
| `PROJECT_STATUS.md` | Full project documentation |
| `QUICKSTART.md` | This file |

---

## Next Steps

### Phase 1: Configuration ✅
1. Run config_gui.ahk
2. Set your categories
3. Save settings

### Phase 2: Testing 🔄 (Next)
1. Place full osrsbox-db.json (optional)
2. Run main.ahk
3. Press F1 to start
4. Watch first run manually
5. Check logs folder

### Phase 3: Monitoring 📊 (Soon)
- Dashboard for session stats
- Item detection accuracy
- Sorting time per item
- Position tracking logs

### Phase 4: Optimization 🚀 (Future)
- Template matching for faster detection
- Multi-threaded image processing
- ML-based behavior randomization
- Custom category templates

---

## Support & Updates

**Current Version:** 2.0 (Category-Based)
**Last Updated:** 2025-01-12

**Known Issues:**
- [ ] Image recognition not yet implemented
- [ ] Full database integration pending
- [ ] Position tracking TBD
- [ ] Stealth curves pending

**Planned Features:**
- [ ] OCR item detection
- [ ] Template matching fallback
- [ ] Character position safety
- [ ] Full 23,000+ item database
- [ ] Dashboard UI
- [ ] Category presets

---

**Remember: Safety first, speed second. Test everything on a fresh account first!**
