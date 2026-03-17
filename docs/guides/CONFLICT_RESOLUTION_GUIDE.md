# Bank Tab Conflict Resolution System

## Overview

The Bank Tab Conflict Resolution System automatically handles situations where an item has multiple tags that map to different bank tabs. This ensures consistent and predictable item placement.

---

## The Problem

Many OSRS items belong to multiple categories. For example:

- **Shark** has tags: `consume_food`, `skill_fishing`, `skill_cooking`
- **Ranarr Seed** has tags: `resource_seed_herb`, `skill_farming`, `skill_herblore`
- **Rune Scimitar** has tags: `equip_melee`, `equip_weapon_main`, `skill_attack`, `skill_strength`

If a user configures their bank tabs like this:
- **Tab 1**: Fishing (skill_fishing)
- **Tab 2**: Food (consume_food)
- **Tab 3**: Cooking (skill_cooking)

Where should **Shark** go? It matches all three tabs!

---

## The Solution: Lowest Tab Wins

**Rule:** When an item matches multiple bank tabs, it goes to the **lowest numbered tab**.

### Why This Rule?

1. **Predictable**: Users always know where items will end up
2. **User Control**: Users can prioritize tabs by assigning lower numbers to more important categories
3. **Simple**: No complex decision logic needed
4. **Consistent**: Same items always go to the same place

---

## How It Works

### Step 1: Tag Mapping

When you configure your bank tabs in the GUI, the system creates a mapping:

```
Tag                    -> Tab Number
-------------------------|------------
"skill_fishing"          -> 1
"consume_food"           -> 2
"skill_cooking"          -> 3
"equip_melee"            -> 4
"resource_seed_herb"     -> 5
```

### Step 2: Item Resolution

When sorting, for each item:

1. **Check all item tags** against the mapping
2. **Find all matching tabs** (e.g., Shark matches tabs 1, 2, and 3)
3. **Select the lowest tab number** (Shark goes to Tab 1)
4. **Cache the result** for future use

### Step 3: Conflict-Free Sorting

- Shark → Tab 1 (Fishing - lowest match)
- Raw Shark → Tab 1 (Fishing)
- Lobster → Tab 2 (Food - only match)
- Ranarr Seed → Tab 5 (Herb Seeds - assuming Tab 5 is lowest match)

---

## Example Scenarios

### Scenario 1: Food vs Fishing

**Configuration:**
- Tab 1: Fishing Items (skill_fishing)
- Tab 2: Food (consume_food)

**Items:**
- **Raw Shark**: Has both tags
  - Matches Tab 1 (skill_fishing) ✓
  - Matches Tab 2 (consume_food) ✓
  - **Result: Goes to Tab 1** (lowest)

- **Cooked Shark**: Has food tag only
  - Matches Tab 2 (consume_food) ✓
  - **Result: Goes to Tab 2**

### Scenario 2: Equipment vs Skills

**Configuration:**
- Tab 1: Melee Equipment (equip_melee)
- Tab 2: Attack Training (skill_attack)
- Tab 3: Strength Training (skill_strength)

**Items:**
- **Rune Scimitar**: Has all three tags
  - Matches Tab 1, 2, and 3
  - **Result: Goes to Tab 1** (lowest)

- **Strength Potion**: Has only skill_strength tag
  - Matches Tab 3 only
  - **Result: Goes to Tab 3**

### Scenario 3: Reversing Priority

If you want **Food** to take priority over **Fishing**, simply reverse the tab order:

**Configuration:**
- Tab 1: Food (consume_food)
- Tab 2: Fishing Items (skill_fishing)

**Items:**
- **Raw Shark**: Now goes to Tab 1 (Food takes priority)
- **Fishing Rod**: Goes to Tab 2 (only matches Fishing)

---

## How to Configure for Best Results

### Tip 1: Most Specific First

Put more specific categories in lower-numbered tabs:

```
✓ GOOD:
  Tab 1: Combat Potions (consume_potion_combat)
  Tab 2: All Potions (consume_potion_*)
  Tab 3: Herblore Items (skill_herblore)

✗ BAD:
  Tab 1: Herblore Items (skill_herblore)
  Tab 2: All Potions (consume_potion_*)
  Tab 3: Combat Potions (consume_potion_combat)
```

In the GOOD example, combat potions go to Tab 1 (most specific).
In the BAD example, combat potions go to Tab 1 (Herblore), losing specificity.

### Tip 2: Group by Priority

Assign tabs based on what matters most to you:

**PvP Focus:**
```
Tab 1: PvP Gear
Tab 2: PvP Potions
Tab 3: Food
Tab 4: General Combat Gear
```

**Skilling Focus:**
```
Tab 1: Active Training Skills (what you're training now)
Tab 2: Resources
Tab 3: Tools
Tab 4: Equipment
```

### Tip 3: Use Separate Tabs for Similar Items

Instead of combining, separate them:

```
✓ BETTER:
  Tab 1: Raw Fish
  Tab 2: Cooked Fish
  Tab 3: Fishing Equipment

Rather than:
  Tab 1: All Fishing-Related Items
```

This gives you more control and reduces conflicts.

---

## Advanced: Conflict Statistics

The system can show you conflict statistics:

```autohotkey
stats := BankTabResolver.GetConflictStats(items)

; Stats includes:
; - totalItems: Number of items analyzed
; - itemsWithConflicts: Items matching multiple tabs
; - itemsResolved: Items successfully assigned
; - itemsUnassigned: Items with no matching tab
; - conflictDetails: Detailed list of conflicts
```

---

## API Reference

### Initialize the Resolver

```autohotkey
; Load user's bank configuration
bankCategories := Map(
    "tab_0", ["Fishing", "skill_fishing"],
    "tab_1", ["Food", "consume_food"]
)

; Initialize
BankTabResolver.Initialize(bankCategories)
```

### Resolve a Single Item

```autohotkey
; Get item from grouping system
shark := ItemGroupingSystem.GetItemByName("Shark")

; Resolve which tab it should go to
tabNumber := BankTabResolver.ResolveItemTab(shark)
; Returns 1 (Fishing tab) because it's lower than 2 (Food tab)
```

### Resolve Multiple Items

```autohotkey
; Get all items
items := [shark, lobster, swordfish, ...]

; Batch resolve
results := BankTabResolver.ResolveMultipleItems(items)
; Returns Map("Shark" -> 1, "Lobster" -> 2, ...)
```

### Get Items for Specific Tab

```autohotkey
; Get all items assigned to Tab 1
tab1Items := BankTabResolver.GetItemsForTab(allItems, 1)
```

### Check Tag Mappings

```autohotkey
; Check if a tag is mapped
isMapped := BankTabResolver.IsTagMapped("skill_fishing")  ; true

; Get tab number for a tag
tabNum := BankTabResolver.GetTabForTag("consume_food")  ; 2
```

---

## Integration with Main Bot

The conflict resolution system is automatically integrated into `main.ahk`:

1. **User saves settings** in config_gui.ahk
2. **config_gui generates** main.ahk with bank tab configuration
3. **main.ahk initializes** BankTabResolver with user's settings
4. **Bot sorts items** using resolved tab assignments

No manual intervention required!

---

## Troubleshooting

### Problem: Items going to wrong tab

**Check:**
1. Your tab assignments in the GUI
2. The item's tags (use ItemGroupingSystem.GetItemByName() to inspect)
3. Remember: lowest tab always wins

### Problem: Items not being sorted

**Check:**
1. Item has at least one tag that matches your configuration
2. Use GetConflictStats() to see unassigned items

### Problem: Too many conflicts

**Solution:**
1. Make categories more specific
2. Use separate tabs instead of overlapping categories
3. Reorder tabs to put priority categories first

---

## Performance Notes

- **Resolution is cached**: Each item is resolved once, then cached
- **Memory efficient**: Only stores item name → tab number
- **Fast lookups**: Uses Map data structure (O(1) access)
- **Batch processing**: Can resolve thousands of items quickly

---

## Future Enhancements

Potential improvements:

1. **Priority Weights**: Assign weights to tags for more control
2. **Custom Rules**: User-defined resolution logic
3. **Smart Suggestions**: Recommend optimal tab configurations
4. **Conflict Preview**: Show conflicts before saving
5. **Multi-Level Resolution**: Primary/secondary/tertiary tab preferences

---

## Summary

The conflict resolution system ensures that:

✓ **Every item** has a predictable home
✓ **Conflicts are resolved** automatically
✓ **Users have control** through tab ordering
✓ **Performance is optimized** through caching
✓ **Integration is seamless** with the bot

The golden rule: **Lowest Tab Wins!**

---

**Last Updated:** 2025-11-12
**Version:** 1.0
