# OSRS Item Grouping System - Usage Guide

## Overview

This project now includes a comprehensive item grouping and classification system for all 24,735 OSRS items. The system allows for intelligent, automated bank sorting based on hierarchical categories.

---

## Quick Start

### 1. Include the Module

```autohotkey
#Include item_grouping.ahk

; Load the database (do this once at startup)
ItemGroupingSystem.LoadDatabase()
```

### 2. Basic Usage Examples

```autohotkey
; Get item by name
shark := ItemGroupingSystem.GetItemByName("Shark")
if shark {
    MsgBox("Found: " . shark.name)
    MsgBox("Core Groups: " . JSON.Stringify(shark.core_groups))
}

; Get all equipment items
equipment := ItemGroupingSystem.GetItemsByCoreGroup("EQUIPMENT")
MsgBox("Found " . equipment.Length . " equipment items")

; Get all Herblore-related items
herbloreItems := ItemGroupingSystem.GetItemsByTag("skill_herblore")
MsgBox("Found " . herbloreItems.Length . " Herblore items")

; Check if item has specific tag
if ItemGroupingSystem.ItemHasTag(shark, "consume_food") {
    MsgBox("Shark is food!")
}
```

---

## Database Structure

### Item Object Properties

Each item in the database has the following properties:

```json
{
  "id": 385,
  "name": "Shark",
  "members": true,
  "stackable": false,
  "tags": [
    "CORE:CONSUMABLES",
    "CORE:SKILLS",
    "consume_food",
    "skill_cooking",
    "skill_fishing",
    "special_members",
    "special_tradeable"
  ],
  "core_groups": [
    "CONSUMABLES",
    "SKILLS"
  ]
}
```

- **id**: Item ID number
- **name**: Item name
- **members**: Whether item is members-only
- **stackable**: Whether item can stack
- **tags**: Array of all tags (including CORE: prefixed ones)
- **core_groups**: Array of core groups (without CORE: prefix)

---

## Core Groups

The system uses 14 primary core groups:

| Core Group | Description | Example Items |
|------------|-------------|---------------|
| **SKILLS** | Skill-related items | Training equipment, skill capes |
| **EQUIPMENT** | Worn items | Weapons, armor, jewelry |
| **RESOURCES** | Gatherable materials | Ores, logs, fish, herbs |
| **CONSUMABLES** | Used/eaten items | Food, potions, ammunition |
| **TOOLS** | Utility tools | Pickaxes, axes, fishing rods |
| **QUEST** | Quest items | Quest-specific items |
| **CURRENCY** | Money & tokens | Coins, tokkul, tokens |
| **CLUE_SCROLLS** | Treasure trails | Clue scrolls & rewards |
| **PVP** | PvP items | Emblems, PvP gear |
| **MINIGAME** | Minigame items | BA gear, PC void |
| **COSMETIC** | Cosmetic items | Holiday items, cosmetics |
| **PETS** | Pet items | Boss pets, skilling pets |
| **TRANSPORTATION** | Travel items | Teleports, scrolls |
| **MISCELLANEOUS** | Other items | Items not fitting elsewhere |

---

## Common Tags Reference

### Skill Tags
- `skill_attack`, `skill_strength`, `skill_defence`
- `skill_ranged`, `skill_prayer`, `skill_magic`
- `skill_mining`, `skill_fishing`, `skill_woodcutting`
- `skill_cooking`, `skill_smithing`, `skill_crafting`
- `skill_fletching`, `skill_herblore`, `skill_farming`
- ... and more

### Equipment Tags
- `equip_weapon_main` - Main-hand weapons
- `equip_weapon_2h` - Two-handed weapons
- `equip_melee`, `equip_ranged`, `equip_magic` - Combat styles
- `equip_head`, `equip_body`, `equip_legs` - Armor slots
- `equip_sword`, `equip_bow`, `equip_staff_magic` - Weapon types

### Resource Tags
- `resource_ore`, `resource_bar` - Mining/Smithing
- `resource_log`, `resource_plank` - Woodcutting/Construction
- `resource_fish_raw`, `resource_fish_cooked` - Fishing/Cooking
- `resource_herb_grimy`, `resource_herb_clean` - Herblore
- `resource_seed_herb`, `resource_seed_tree` - Farming
- `resource_gem_uncut`, `resource_gem_cut` - Crafting

### Consumable Tags
- `consume_food` - Edible food
- `consume_potion_combat` - Combat potions
- `consume_potion_prayer` - Prayer potions
- `consume_ammo_arrow`, `consume_ammo_bolt` - Ammunition
- `consume_teleport_tablet` - Teleport tablets

### Special Tags
- `special_members` - Members-only item
- `special_f2p` - Free-to-play item
- `special_stackable` - Stackable item
- `special_tradeable` - Tradeable item
- `special_high_value` - High value (>100k)

---

## API Reference

### Loading & Setup

#### `ItemGroupingSystem.LoadDatabase()`
Loads the item database from `osrs-items-condensed.json`. Call this once at startup.

**Returns:** `true` on success, `false` on failure

---

### Item Retrieval

#### `ItemGroupingSystem.GetItemById(itemId)`
Get a specific item by its ID.

**Parameters:**
- `itemId` - Item ID number (string or integer)

**Returns:** Item object or empty string if not found

**Example:**
```autohotkey
whip := ItemGroupingSystem.GetItemById(4151)
```

---

#### `ItemGroupingSystem.GetItemByName(itemName)`
Get an item by exact name match (case-insensitive).

**Parameters:**
- `itemName` - Exact item name

**Returns:** Item object or empty string if not found

**Example:**
```autohotkey
scimitar := ItemGroupingSystem.GetItemByName("Rune scimitar")
```

---

#### `ItemGroupingSystem.SearchItemsByName(searchTerm)`
Search for items by partial name match.

**Parameters:**
- `searchTerm` - Partial name to search for

**Returns:** Array of matching items

**Example:**
```autohotkey
potions := ItemGroupingSystem.SearchItemsByName("potion")
; Returns all items with "potion" in the name
```

---

### Filtering by Category

#### `ItemGroupingSystem.GetItemsByCoreGroup(coreGroup)`
Get all items in a specific core group.

**Parameters:**
- `coreGroup` - Core group name (e.g., "EQUIPMENT", "SKILLS")

**Returns:** Array of items

**Example:**
```autohotkey
equipment := ItemGroupingSystem.GetItemsByCoreGroup("EQUIPMENT")
```

---

#### `ItemGroupingSystem.GetItemsByTag(tag)`
Get all items with a specific tag.

**Parameters:**
- `tag` - Tag to search for (e.g., "skill_herblore")

**Returns:** Array of items

**Example:**
```autohotkey
herbloreItems := ItemGroupingSystem.GetItemsByTag("skill_herblore")
```

---

#### `ItemGroupingSystem.GetItemsByTags(tags*)`
Get items matching ALL specified tags (AND logic).

**Parameters:**
- `tags*` - Variable number of tags

**Returns:** Array of items

**Example:**
```autohotkey
; Get all members-only food
membersFood := ItemGroupingSystem.GetItemsByTags("consume_food", "special_members")
```

---

### Checking Item Properties

#### `ItemGroupingSystem.ItemHasTag(item, tag)`
Check if an item has a specific tag.

**Parameters:**
- `item` - Item object
- `tag` - Tag to check for

**Returns:** `true` or `false`

**Example:**
```autohotkey
if ItemGroupingSystem.ItemHasTag(myItem, "consume_food") {
    ; Item is food
}
```

---

#### `ItemGroupingSystem.ItemInCoreGroup(item, coreGroup)`
Check if an item belongs to a core group.

**Parameters:**
- `item` - Item object
- `coreGroup` - Core group name

**Returns:** `true` or `false`

**Example:**
```autohotkey
if ItemGroupingSystem.ItemInCoreGroup(myItem, "EQUIPMENT") {
    ; Item is equipment
}
```

---

### Utility Functions

#### `ItemGroupingSystem.FilterByMembers(items, membersOnly)`
Filter an array of items by members status.

**Parameters:**
- `items` - Array of items
- `membersOnly` - `true` for members items, `false` for F2P items

**Returns:** Filtered array of items

**Example:**
```autohotkey
allFood := ItemGroupingSystem.GetItemsByTag("consume_food")
f2pFood := ItemGroupingSystem.FilterByMembers(allFood, false)
```

---

#### `ItemGroupingSystem.GetDatabaseStats()`
Get statistics about the database.

**Returns:** Map with statistics

**Example:**
```autohotkey
stats := ItemGroupingSystem.GetDatabaseStats()
MsgBox("Total items: " . stats["totalItems"])
```

---

## Practical Examples

### Example 1: Sort Bank Tab by Core Group

```autohotkey
; Get all items in user's bank (pseudo-code)
bankItems := GetBankItems()

; Separate items by core group
equipmentItems := []
consumableItems := []
resourceItems := []

for item in bankItems {
    itemData := ItemGroupingSystem.GetItemByName(item.name)

    if !itemData
        continue

    if ItemGroupingSystem.ItemInCoreGroup(itemData, "EQUIPMENT")
        equipmentItems.Push(item)
    else if ItemGroupingSystem.ItemInCoreGroup(itemData, "CONSUMABLES")
        consumableItems.Push(item)
    else if ItemGroupingSystem.ItemInCoreGroup(itemData, "RESOURCES")
        resourceItems.Push(item)
}

; Now sort each group into separate bank tabs
```

---

### Example 2: Auto-Detect Item Type

```autohotkey
DetectItemType(itemName) {
    item := ItemGroupingSystem.GetItemByName(itemName)

    if !item
        return "Unknown"

    ; Check core groups
    for group in item.core_groups {
        switch group {
            case "EQUIPMENT":
                return "Equipment"
            case "CONSUMABLES":
                if ItemGroupingSystem.ItemHasTag(item, "consume_food")
                    return "Food"
                else if ItemGroupingSystem.ItemHasTag(item, "consume_potion_combat")
                    return "Combat Potion"
                else
                    return "Consumable"
            case "RESOURCES":
                return "Resource"
            case "TOOLS":
                return "Tool"
            default:
                return group
        }
    }

    return "Miscellaneous"
}
```

---

### Example 3: Create Custom Filters

```autohotkey
; Get all high-value tradeable items for GE tracking
highValueTradeables := ItemGroupingSystem.GetItemsByTags("special_high_value", "special_tradeable")

; Get all F2P combat equipment
f2pCombat := ItemGroupingSystem.GetItemsByTags("equip_melee", "special_f2p")

; Get all stackable resources
stackableResources := []
resources := ItemGroupingSystem.GetItemsByCoreGroup("RESOURCES")
for item in resources {
    if item.stackable
        stackableResources.Push(item)
}
```

---

## Database Statistics

**Total Items:** 24,735

**Core Group Distribution:**
- SKILLS: 9,966 items
- MISCELLANEOUS: 8,436 items
- EQUIPMENT: 3,885 items
- QUEST: 3,590 items
- RESOURCES: 2,077 items
- CONSUMABLES: 1,644 items
- CLUE_SCROLLS: 1,385 items
- MINIGAME: 668 items
- TOOLS: 588 items
- COSMETIC: 106 items
- PVP: 89 items
- CURRENCY: 49 items

---

## File Structure

```
xh1px-tidy-bank/
├── item_grouping.ahk              # Main grouping module
├── osrs-items-condensed.json      # Condensed database (4.9 MB)
├── ITEM_GROUPING_SYSTEM.md        # System architecture
├── ITEM_GROUPING_USAGE.md         # This file
└── tag_items.py                   # Tagging script (for reference)
```

---

## Performance Notes

- **Database Size:** 4.9 MB (condensed from 49.5 MB)
- **Load Time:** ~1-2 seconds
- **Memory Usage:** ~10-15 MB
- **Search Performance:** Fast lookups with Map data structure

---

## Future Enhancements

Potential improvements for future versions:

1. **Caching** - Cache frequently accessed items
2. **Index Creation** - Pre-build indexes for faster tag searches
3. **Custom Groups** - Allow users to define custom grouping rules
4. **GE Price Integration** - Add Grand Exchange price data
5. **Item Stats** - Include combat stats for equipment
6. **Icon Support** - Add item icon data for GUI display

---

## Credits

- **Item Data:** OSRSBox Database (https://www.osrsbox.com/)
- **Tagging System:** Custom hierarchical classification
- **Total Tags:** 150+ unique tags across 14 core groups

---

## Support

For issues or questions:
1. Check the ITEM_GROUPING_SYSTEM.md for tag definitions
2. Review example code in item_grouping.ahk
3. Run TestItemGrouping() function to verify setup

---

**Last Updated:** 2025-11-12
**Database Version:** 1.0
**Items:** 24,735
