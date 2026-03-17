# OSRS Item Grouping System
# Hierarchical Classification System for Bank Sorting

## Overview
This document defines the complete hierarchical grouping system for OSRS items.
Structure: CORE GROUPS → SUBGROUPS → TAGS → ITEMS

---

## CORE GROUP 1: SKILLS
**Purpose:** Items used to train or related to specific skills
**Tag Prefix:** skill_

### Subgroups:
- **Combat Skills**
  - Attack (skill_attack)
  - Strength (skill_strength)
  - Defence (skill_defence)
  - Ranged (skill_ranged)
  - Prayer (skill_prayer)
  - Magic (skill_magic)
  - Hitpoints (skill_hitpoints)
  - Slayer (skill_slayer)

- **Gathering Skills**
  - Mining (skill_mining)
  - Fishing (skill_fishing)
  - Woodcutting (skill_woodcutting)
  - Hunter (skill_hunter)
  - Farming (skill_farming)

- **Artisan Skills**
  - Cooking (skill_cooking)
  - Smithing (skill_smithing)
  - Crafting (skill_crafting)
  - Fletching (skill_fletching)
  - Herblore (skill_herblore)
  - Construction (skill_construction)
  - Firemaking (skill_firemaking)
  - Runecraft (skill_runecraft)

- **Support Skills**
  - Agility (skill_agility)
  - Thieving (skill_thieving)

---

## CORE GROUP 2: EQUIPMENT
**Purpose:** Items that can be equipped/worn by the player
**Tag Prefix:** equip_

### Subgroups:
- **Weapons**
  - Main-Hand (equip_weapon_main)
  - Two-Handed (equip_weapon_2h)
  - Off-Hand (equip_weapon_offhand)

- **Weapon Types**
  - Melee Weapons (equip_melee)
    - Swords (equip_sword)
    - Scimitars (equip_scimitar)
    - Daggers (equip_dagger)
    - Axes (equip_axe)
    - Maces (equip_mace)
    - Spears (equip_spear)
    - Staves (equip_staff_melee)
  - Ranged Weapons (equip_ranged)
    - Bows (equip_bow)
    - Crossbows (equip_crossbow)
    - Thrown (equip_thrown)
    - Chinchompas (equip_chinchompa)
  - Magic Weapons (equip_magic)
    - Staves (equip_staff_magic)
    - Wands (equip_wand)

- **Armor**
  - Head (equip_head)
  - Body (equip_body)
  - Legs (equip_legs)
  - Hands (equip_hands)
  - Feet (equip_feet)
  - Cape (equip_cape)
  - Shield (equip_shield)
  - Neck (equip_neck)
  - Ring (equip_ring)
  - Ammo (equip_ammo)

- **Armor Styles**
  - Melee Armor (equip_armor_melee)
  - Ranged Armor (equip_armor_ranged)
  - Magic Armor (equip_armor_magic)
  - Hybrid Armor (equip_armor_hybrid)

---

## CORE GROUP 3: RESOURCES
**Purpose:** Gatherable and processable materials
**Tag Prefix:** resource_

### Subgroups:
- **Ores & Bars**
  - Ores (resource_ore)
  - Bars (resource_bar)

- **Logs & Planks**
  - Logs (resource_log)
  - Planks (resource_plank)

- **Fish**
  - Raw Fish (resource_fish_raw)
  - Cooked Fish (resource_fish_cooked)

- **Herbs & Secondaries**
  - Grimy Herbs (resource_herb_grimy)
  - Clean Herbs (resource_herb_clean)
  - Herb Secondaries (resource_herb_secondary)

- **Seeds**
  - Allotment Seeds (resource_seed_allotment)
  - Herb Seeds (resource_seed_herb)
  - Flower Seeds (resource_seed_flower)
  - Tree Seeds (resource_seed_tree)
  - Fruit Tree Seeds (resource_seed_fruit_tree)
  - Special Seeds (resource_seed_special)

- **Hides & Leather**
  - Hides (resource_hide)
  - Leather (resource_leather)

- **Gems**
  - Uncut Gems (resource_gem_uncut)
  - Cut Gems (resource_gem_cut)

- **Runes**
  - Elemental Runes (resource_rune_elemental)
  - Catalytic Runes (resource_rune_catalytic)
  - Combination Runes (resource_rune_combination)

- **Bones**
  - Bones (resource_bone)
  - Ashes (resource_ash)

- **Farming Resources**
  - Produce (resource_produce)
  - Compost (resource_compost)

- **Crafting Materials**
  - Cloth (resource_cloth)
  - Thread (resource_thread)
  - Leather (resource_leather)
  - Glass (resource_glass)
  - Jewelry Components (resource_jewelry)

---

## CORE GROUP 4: CONSUMABLES
**Purpose:** Items consumed during use
**Tag Prefix:** consume_

### Subgroups:
- **Food & Drink**
  - Food (consume_food)
  - Drink (consume_drink)
  - Cooking Ingredients (consume_ingredient_cooking)

- **Potions**
  - Combat Potions (consume_potion_combat)
  - Skill Potions (consume_potion_skill)
  - Prayer Potions (consume_potion_prayer)
  - Anti-Poison (consume_potion_antipoison)
  - Anti-Fire (consume_potion_antifire)
  - Unfinished Potions (consume_potion_unf)

- **Ammunition**
  - Arrows (consume_ammo_arrow)
  - Bolts (consume_ammo_bolt)
  - Darts (consume_ammo_dart)
  - Javelins (consume_ammo_javelin)
  - Knives (consume_ammo_knife)
  - Throwing Axes (consume_ammo_throwing_axe)
  - Cannonballs (consume_ammo_cannonball)

- **Runes** (Duplicate from Resources for consumption context)
  - Combat Runes (consume_rune)

- **Teleportation**
  - Teleport Tablets (consume_teleport_tablet)
  - Teleport Scrolls (consume_teleport_scroll)
  - Teleport Jewelry (consume_teleport_jewelry)

---

## CORE GROUP 5: TOOLS
**Purpose:** Items used as tools for various activities
**Tag Prefix:** tool_

### Subgroups:
- **Gathering Tools**
  - Pickaxes (tool_pickaxe)
  - Axes (tool_axe)
  - Fishing Rods (tool_fishing_rod)
  - Fishing Equipment (tool_fishing_equipment)
  - Butterfly Nets (tool_butterfly_net)
  - Hunter Traps (tool_hunter_trap)
  - Secateurs (tool_secateurs)
  - Rakes (tool_rake)
  - Spades (tool_spade)

- **Processing Tools**
  - Hammers (tool_hammer)
  - Needles (tool_needle)
  - Chisels (tool_chisel)
  - Saws (tool_saw)
  - Knives (tool_knife)
  - Pestle and Mortar (tool_pestle_mortar)
  - Vials (tool_vial)

- **Utility Tools**
  - Tinderboxes (tool_tinderbox)
  - Ropes (tool_rope)
  - Buckets (tool_bucket)
  - Watering Cans (tool_watering_can)

---

## CORE GROUP 6: QUEST
**Purpose:** Quest-specific items
**Tag Prefix:** quest_

### Subgroups:
- **Quest Items** (quest_item)
- **Quest Keys** (quest_key)
- **Quest Tools** (quest_tool)

---

## CORE GROUP 7: CURRENCY
**Purpose:** Monetary items and tradeable currency
**Tag Prefix:** currency_

### Subgroups:
- **Coins** (currency_coin)
- **Tokens** (currency_token)
- **Tokkul** (currency_tokkul)
- **Platinum Tokens** (currency_platinum)
- **Trading Sticks** (currency_trading_stick)

---

## CORE GROUP 8: CLUE_SCROLLS
**Purpose:** Treasure trail items
**Tag Prefix:** clue_

### Subgroups:
- **Clue Scrolls**
  - Easy Clues (clue_easy)
  - Medium Clues (clue_medium)
  - Hard Clues (clue_hard)
  - Elite Clues (clue_elite)
  - Master Clues (clue_master)
  - Beginner Clues (clue_beginner)

- **Clue Rewards**
  - Cosmetics (clue_reward_cosmetic)
  - Treasure Trail Uniques (clue_reward_unique)

---

## CORE GROUP 9: PVP
**Purpose:** Items primarily used in PvP/Wilderness
**Tag Prefix:** pvp_

### Subgroups:
- **PvP Weapons** (pvp_weapon)
- **PvP Food** (pvp_food)
- **PvP Potions** (pvp_potion)
- **Emblems** (pvp_emblem)

---

## CORE GROUP 10: MINIGAME
**Purpose:** Items specific to minigames
**Tag Prefix:** minigame_

### Subgroups:
- **Barbarian Assault** (minigame_ba)
- **Pest Control** (minigame_pc)
- **Castle Wars** (minigame_cw)
- **Fight Caves** (minigame_fight_caves)
- **Inferno** (minigame_inferno)
- **Nightmare Zone** (minigame_nmz)
- **Chambers of Xeric** (minigame_cox)
- **Theatre of Blood** (minigame_tob)
- **Other Minigames** (minigame_other)

---

## CORE GROUP 11: COSMETIC
**Purpose:** Items that are purely cosmetic
**Tag Prefix:** cosmetic_

### Subgroups:
- **Fashionscape** (cosmetic_fashion)
- **Holiday Items** (cosmetic_holiday)
- **Achievement Cosmetics** (cosmetic_achievement)

---

## CORE GROUP 12: PETS
**Purpose:** Pet items
**Tag Prefix:** pet_

### Subgroups:
- **Boss Pets** (pet_boss)
- **Skilling Pets** (pet_skilling)
- **Other Pets** (pet_other)

---

## CORE GROUP 13: TRANSPORTATION
**Purpose:** Movement and transportation items
**Tag Prefix:** transport_

### Subgroups:
- **Teleports** (transport_teleport)
- **Spirit Trees** (transport_spirit_tree)
- **Fairy Rings** (transport_fairy_ring)
- **Boats** (transport_boat)

---

## CORE GROUP 14: MISCELLANEOUS
**Purpose:** Items that don't fit other categories
**Tag Prefix:** misc_

### Subgroups:
- **Books** (misc_book)
- **Maps** (misc_map)
- **Certificates** (misc_certificate)
- **Junk** (misc_junk)
- **Untradeable** (misc_untradeable)
- **Other** (misc_other)

---

## SPECIAL TAGS
**Purpose:** Cross-category attributes
**Tag Prefix:** special_

- **Members Only** (special_members)
- **Free to Play** (special_f2p)
- **Stackable** (special_stackable)
- **Tradeable** (special_tradeable)
- **Noted** (special_noted)
- **Placeholder** (special_placeholder)
- **High Value** (special_high_value)
- **Rare** (special_rare)
- **Discontinued** (special_discontinued)

---

## USAGE NOTES

### Tagging Rules:
1. Each item can have multiple tags from different core groups
2. Items should have at least one primary core group tag
3. Equipment items should have both equipment type and combat style tags
4. Resources should include both raw/processed state tags when applicable
5. Quest items should always include the quest_item tag
6. All items should include applicable special tags

### Examples:
- **Abyssal Whip**: equip_weapon_main, equip_melee, skill_attack, skill_strength, skill_defence, special_members, special_tradeable
- **Rune Scimitar**: equip_weapon_main, equip_scimitar, equip_melee, skill_attack, skill_strength, special_f2p, special_tradeable
- **Raw Shark**: resource_fish_raw, consume_food, skill_fishing, skill_cooking, special_members, special_tradeable
- **Ranarr Seed**: resource_seed_herb, skill_farming, skill_herblore, special_members, special_tradeable, special_stackable
- **Super Combat Potion**: consume_potion_combat, skill_herblore, pvp_potion, special_members, special_tradeable

---

## TAG HIERARCHY SUMMARY

```
CORE GROUPS (14)
├── SKILLS (23 subgroups)
├── EQUIPMENT (30+ subgroups)
├── RESOURCES (20+ subgroups)
├── CONSUMABLES (15+ subgroups)
├── TOOLS (15+ subgroups)
├── QUEST (3 subgroups)
├── CURRENCY (5 subgroups)
├── CLUE_SCROLLS (8 subgroups)
├── PVP (4 subgroups)
├── MINIGAME (8+ subgroups)
├── COSMETIC (3 subgroups)
├── PETS (3 subgroups)
├── TRANSPORTATION (4 subgroups)
└── MISCELLANEOUS (6 subgroups)

SPECIAL TAGS (10)

TOTAL: ~150+ distinct tags
```

This system allows for flexible, multi-dimensional classification of all OSRS items
for efficient bank organization and automated sorting.
