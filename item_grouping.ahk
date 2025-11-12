#Requires AutoHotkey v2.0
#Include json_parser.ahk

; ==========================================
; OSRS Item Grouping System
; Hierarchical Classification for Bank Sorting
; ==========================================

class ItemGroupingSystem {
    ; Core group definitions
    static CORE_GROUPS := Map(
        "SKILLS", "Skills",
        "EQUIPMENT", "Equipment",
        "RESOURCES", "Resources",
        "CONSUMABLES", "Consumables",
        "TOOLS", "Tools",
        "QUEST", "Quest Items",
        "CURRENCY", "Currency",
        "CLUE_SCROLLS", "Clue Scrolls",
        "PVP", "PvP Items",
        "MINIGAME", "Minigame Items",
        "COSMETIC", "Cosmetics",
        "PETS", "Pets",
        "TRANSPORTATION", "Transportation",
        "MISCELLANEOUS", "Miscellaneous"
    )

    ; Subgroup definitions
    static SUBGROUPS := Map(
        ; SKILLS Subgroups
        "skill_attack", "Attack",
        "skill_strength", "Strength",
        "skill_defence", "Defence",
        "skill_ranged", "Ranged",
        "skill_prayer", "Prayer",
        "skill_magic", "Magic",
        "skill_hitpoints", "Hitpoints",
        "skill_slayer", "Slayer",
        "skill_mining", "Mining",
        "skill_fishing", "Fishing",
        "skill_woodcutting", "Woodcutting",
        "skill_hunter", "Hunter",
        "skill_farming", "Farming",
        "skill_cooking", "Cooking",
        "skill_smithing", "Smithing",
        "skill_crafting", "Crafting",
        "skill_fletching", "Fletching",
        "skill_herblore", "Herblore",
        "skill_construction", "Construction",
        "skill_firemaking", "Firemaking",
        "skill_runecraft", "Runecraft",
        "skill_agility", "Agility",
        "skill_thieving", "Thieving",

        ; EQUIPMENT Subgroups
        "equip_weapon_main", "Main-Hand Weapons",
        "equip_weapon_2h", "Two-Handed Weapons",
        "equip_weapon_offhand", "Off-Hand Weapons",
        "equip_melee", "Melee Equipment",
        "equip_ranged", "Ranged Equipment",
        "equip_magic", "Magic Equipment",
        "equip_armor_melee", "Melee Armor",
        "equip_armor_ranged", "Ranged Armor",
        "equip_armor_magic", "Magic Armor",
        "equip_head", "Head Slot",
        "equip_body", "Body Slot",
        "equip_legs", "Legs Slot",
        "equip_hands", "Hands Slot",
        "equip_feet", "Feet Slot",
        "equip_cape", "Cape Slot",
        "equip_shield", "Shield Slot",
        "equip_neck", "Neck Slot",
        "equip_ring", "Ring Slot",
        "equip_ammo", "Ammo Slot",

        ; RESOURCES Subgroups
        "resource_ore", "Ores",
        "resource_bar", "Bars",
        "resource_log", "Logs",
        "resource_plank", "Planks",
        "resource_fish_raw", "Raw Fish",
        "resource_fish_cooked", "Cooked Fish",
        "resource_herb_grimy", "Grimy Herbs",
        "resource_herb_clean", "Clean Herbs",
        "resource_seed_allotment", "Allotment Seeds",
        "resource_seed_herb", "Herb Seeds",
        "resource_seed_flower", "Flower Seeds",
        "resource_seed_tree", "Tree Seeds",
        "resource_seed_fruit_tree", "Fruit Tree Seeds",
        "resource_hide", "Hides",
        "resource_leather", "Leather",
        "resource_gem_uncut", "Uncut Gems",
        "resource_gem_cut", "Cut Gems",
        "resource_rune_elemental", "Elemental Runes",
        "resource_rune_catalytic", "Catalytic Runes",
        "resource_rune_combination", "Combination Runes",
        "resource_bone", "Bones",
        "resource_ash", "Ashes",

        ; CONSUMABLES Subgroups
        "consume_food", "Food",
        "consume_potion_combat", "Combat Potions",
        "consume_potion_skill", "Skill Potions",
        "consume_potion_prayer", "Prayer Potions",
        "consume_ammo_arrow", "Arrows",
        "consume_ammo_bolt", "Bolts",
        "consume_ammo_dart", "Darts",
        "consume_teleport_tablet", "Teleport Tablets",

        ; TOOLS Subgroups
        "tool_pickaxe", "Pickaxes",
        "tool_axe", "Axes",
        "tool_fishing_equipment", "Fishing Equipment",
        "tool_hunter_trap", "Hunter Equipment",
        "tool_farming", "Farming Tools",

        ; CLUE SCROLLS Subgroups
        "clue_easy", "Easy Clues",
        "clue_medium", "Medium Clues",
        "clue_hard", "Hard Clues",
        "clue_elite", "Elite Clues",
        "clue_master", "Master Clues",
        "clue_beginner", "Beginner Clues",

        ; PVP Subgroups
        "pvp_weapon", "PvP Weapons",
        "pvp_emblem", "PvP Emblems",

        ; MINIGAME Subgroups
        "minigame_ba", "Barbarian Assault",
        "minigame_pc", "Pest Control",
        "minigame_cw", "Castle Wars",
        "minigame_fight_caves", "Fight Caves",
        "minigame_inferno", "Inferno",
        "minigame_nmz", "Nightmare Zone",
        "minigame_cox", "Chambers of Xeric",
        "minigame_tob", "Theatre of Blood"
    )

    ; Database instance
    static itemsDB := Map()
    static dbLoaded := false

    ; Load the item database
    static LoadDatabase() {
        if this.dbLoaded
            return true

        dbFile := A_ScriptDir "\osrs-items-condensed.json"

        if !FileExist(dbFile) {
            MsgBox("Item database not found!`n`nExpected: " . dbFile, "Error", "Icon!")
            return false
        }

        try {
            rawData := FileRead(dbFile)
            this.itemsDB := JSON.Parse(rawData)
            this.dbLoaded := true
            return true
        } catch as err {
            MsgBox("Failed to load item database:`n`n" . err.Message, "Error", "Icon!")
            return false
        }
    }

    ; Get item by ID
    static GetItemById(itemId) {
        if !this.dbLoaded
            this.LoadDatabase()

        return this.itemsDB.Has(String(itemId)) ? this.itemsDB[String(itemId)] : ""
    }

    ; Get item by name (case-insensitive search)
    static GetItemByName(itemName) {
        if !this.dbLoaded
            this.LoadDatabase()

        searchName := StrLower(itemName)

        for itemId, item in this.itemsDB {
            if StrLower(item.name) == searchName
                return item
        }

        return ""
    }

    ; Get all items in a core group
    static GetItemsByCoreGroup(coreGroup) {
        if !this.dbLoaded
            this.LoadDatabase()

        items := []
        coreGroupUpper := StrUpper(coreGroup)

        for itemId, item in this.itemsDB {
            for group in item.core_groups {
                if group == coreGroupUpper {
                    items.Push(item)
                    break
                }
            }
        }

        return items
    }

    ; Get all items with a specific tag
    static GetItemsByTag(tag) {
        if !this.dbLoaded
            this.LoadDatabase()

        items := []
        tagLower := StrLower(tag)

        for itemId, item in this.itemsDB {
            for itemTag in item.tags {
                if StrLower(itemTag) == tagLower {
                    items.Push(item)
                    break
                }
            }
        }

        return items
    }

    ; Get all items matching multiple tags (AND logic)
    static GetItemsByTags(tags*) {
        if !this.dbLoaded
            this.LoadDatabase()

        items := []
        searchTags := []

        ; Convert all tags to lowercase
        for tag in tags
            searchTags.Push(StrLower(tag))

        for itemId, item in this.itemsDB {
            hasAllTags := true

            ; Check if item has all required tags
            for searchTag in searchTags {
                found := false
                for itemTag in item.tags {
                    if StrLower(itemTag) == searchTag {
                        found := true
                        break
                    }
                }
                if !found {
                    hasAllTags := false
                    break
                }
            }

            if hasAllTags
                items.Push(item)
        }

        return items
    }

    ; Filter items by members status
    static FilterByMembers(items, membersOnly) {
        filtered := []
        for item in items {
            if membersOnly {
                if item.members
                    filtered.Push(item)
            } else {
                if !item.members
                    filtered.Push(item)
            }
        }
        return filtered
    }

    ; Check if item has a specific tag
    static ItemHasTag(item, tag) {
        if !item || !item.tags
            return false

        tagLower := StrLower(tag)
        for itemTag in item.tags {
            if StrLower(itemTag) == tagLower
                return true
        }
        return false
    }

    ; Check if item belongs to core group
    static ItemInCoreGroup(item, coreGroup) {
        if !item || !item.core_groups
            return false

        coreGroupUpper := StrUpper(coreGroup)
        for group in item.core_groups {
            if group == coreGroupUpper
                return true
        }
        return false
    }

    ; Get all available core groups
    static GetAllCoreGroups() {
        groups := []
        for groupKey, groupName in this.CORE_GROUPS
            groups.Push(Map("key", groupKey, "name", groupName))
        return groups
    }

    ; Get all available subgroups
    static GetAllSubgroups() {
        subgroups := []
        for tagKey, tagName in this.SUBGROUPS
            subgroups.Push(Map("key", tagKey, "name", tagName))
        return subgroups
    }

    ; Get subgroups for a specific core group
    static GetSubgroupsForCoreGroup(coreGroup) {
        subgroups := []
        prefix := StrLower(coreGroup) "_"

        for tagKey, tagName in this.SUBGROUPS {
            if InStr(tagKey, prefix) == 1
                subgroups.Push(Map("key", tagKey, "name", tagName))
        }

        return subgroups
    }

    ; Search items by partial name match
    static SearchItemsByName(searchTerm) {
        if !this.dbLoaded
            this.LoadDatabase()

        results := []
        searchLower := StrLower(searchTerm)

        for itemId, item in this.itemsDB {
            if InStr(StrLower(item.name), searchLower)
                results.Push(item)
        }

        return results
    }

    ; Get statistics about the database
    static GetDatabaseStats() {
        if !this.dbLoaded
            this.LoadDatabase()

        stats := Map(
            "totalItems", 0,
            "membersItems", 0,
            "f2pItems", 0,
            "stackableItems", 0,
            "coreGroupCounts", Map()
        )

        for itemId, item in this.itemsDB {
            stats["totalItems"]++

            if item.members
                stats["membersItems"]++
            else
                stats["f2pItems"]++

            if item.stackable
                stats["stackableItems"]++

            ; Count core groups
            for group in item.core_groups {
                if !stats["coreGroupCounts"].Has(group)
                    stats["coreGroupCounts"][group] := 0
                stats["coreGroupCounts"][group]++
            }
        }

        return stats
    }
}

; Example usage function (for testing)
TestItemGrouping() {
    ; Load database
    if !ItemGroupingSystem.LoadDatabase() {
        MsgBox("Failed to load database!", "Error", "Icon!")
        return
    }

    ; Test 1: Get item by name
    whip := ItemGroupingSystem.GetItemByName("Abyssal whip")
    if whip {
        msg := "Abyssal Whip:`n"
        msg .= "ID: " . whip.id . "`n"
        msg .= "Core Groups: " . JSON.Stringify(whip.core_groups) . "`n"
        msg .= "Tags: " . whip.tags.Length . " total`n"
        MsgBox(msg, "Test 1: Get Item by Name", "Iconi")
    }

    ; Test 2: Get all items in EQUIPMENT core group
    equipment := ItemGroupingSystem.GetItemsByCoreGroup("EQUIPMENT")
    MsgBox("Found " . equipment.Length . " equipment items", "Test 2: Core Group", "Iconi")

    ; Test 3: Get all items with skill_herblore tag
    herbloreItems := ItemGroupingSystem.GetItemsByTag("skill_herblore")
    MsgBox("Found " . herbloreItems.Length . " Herblore items", "Test 3: Tag Search", "Iconi")

    ; Test 4: Database statistics
    stats := ItemGroupingSystem.GetDatabaseStats()
    msg := "Database Statistics:`n`n"
    msg .= "Total Items: " . stats["totalItems"] . "`n"
    msg .= "Members Items: " . stats["membersItems"] . "`n"
    msg .= "F2P Items: " . stats["f2pItems"] . "`n"
    msg .= "Stackable Items: " . stats["stackableItems"] . "`n`n"
    msg .= "Core Group Distribution:`n"

    for group, count in stats["coreGroupCounts"]
        msg .= "  " . group . ": " . count . "`n"

    MsgBox(msg, "Test 4: Statistics", "Iconi")
}
