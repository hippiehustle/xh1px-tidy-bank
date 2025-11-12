#Requires AutoHotkey v2.0

; ==========================================
; Bank Tab Conflict Resolution System
; Handles items with multiple tags mapped to different tabs
; ==========================================

class BankTabResolver {
    ; Tab assignments from config (Map of tag -> tab number)
    static tagToTab := Map()

    ; Core group to tab assignments
    static coreGroupToTab := Map()

    ; Cache for resolved items (itemName -> tabNumber)
    static resolvedCache := Map()

    ; Initialize the resolver with user configuration
    static Initialize(bankCategories) {
        this.tagToTab := Map()
        this.coreGroupToTab := Map()
        this.resolvedCache := Map()

        ; Build mapping from categories/tags to tab numbers
        ; bankCategories structure: Map("tab_0" -> ["Ranged", "Magic"], "tab_1" -> [...])
        for tabKey, categories in bankCategories {
            tabNum := Integer(SubStr(tabKey, 5)) + 1  ; "tab_0" -> 1, "tab_1" -> 2, etc.

            for category in categories {
                categoryLower := StrLower(category)

                ; Map category to tab number
                ; If already exists, keep the lower tab number (conflict resolution)
                if this.tagToTab.Has(categoryLower) {
                    existingTab := this.tagToTab[categoryLower]
                    if tabNum < existingTab {
                        this.tagToTab[categoryLower] := tabNum
                    }
                } else {
                    this.tagToTab[categoryLower] := tabNum
                }
            }
        }
    }

    ; Resolve which tab an item should go to based on its tags
    ; Returns tab number (1-8) or 0 if no matching tab
    static ResolveItemTab(item) {
        if !item {
            return 0
        }

        itemName := item.Has("name") ? item["name"] : ""

        ; Check cache first for performance
        if this.resolvedCache.Has(itemName) {
            return this.resolvedCache[itemName]
        }

        lowestTab := 9999  ; Start with impossibly high number
        matchFound := false

        ; Check all tags the item has
        if item.Has("tags") && item["tags"].Length > 0 {
            for tag in item["tags"] {
                tagLower := StrLower(tag)

                ; Skip CORE: prefixed tags - we want the specific subtags
                if InStr(tagLower, "core:") == 1 {
                    continue
                }

                ; Check if this tag is mapped to a tab
                if this.tagToTab.Has(tagLower) {
                    matchFound := true
                    tabNum := this.tagToTab[tagLower]

                    ; Keep the lowest tab number (conflict resolution rule)
                    if tabNum < lowestTab {
                        lowestTab := tabNum
                    }
                }
            }
        }

        ; If no specific tag matched, try core groups
        if !matchFound && item.Has("core_groups") && item["core_groups"].Length > 0 {
            for coreGroup in item["core_groups"] {
                groupLower := StrLower(coreGroup)

                if this.tagToTab.Has(groupLower) {
                    matchFound := true
                    tabNum := this.tagToTab[groupLower]

                    if tabNum < lowestTab {
                        lowestTab := tabNum
                    }
                }
            }
        }

        resultTab := matchFound ? lowestTab : 0

        ; Cache the result
        if itemName != "" {
            this.resolvedCache[itemName] := resultTab
        }

        return resultTab
    }

    ; Batch resolve multiple items
    ; Returns Map of itemName -> tabNumber
    static ResolveMultipleItems(items) {
        results := Map()

        for item in items {
            itemName := item.Has("name") ? item["name"] : ""
            if itemName != "" {
                tabNum := this.ResolveItemTab(item)
                results[itemName] := tabNum
            }
        }

        return results
    }

    ; Get all items assigned to a specific tab
    static GetItemsForTab(items, tabNumber) {
        tabItems := []

        for item in items {
            resolvedTab := this.ResolveItemTab(item)
            if resolvedTab == tabNumber {
                tabItems.Push(item)
            }
        }

        return tabItems
    }

    ; Get statistics about conflicts
    ; Returns Map with conflict information
    static GetConflictStats(items) {
        stats := Map(
            "totalItems", items.Length,
            "itemsWithConflicts", 0,
            "itemsResolved", 0,
            "itemsUnassigned", 0,
            "conflictDetails", []
        )

        for item in items {
            itemName := item.Has("name") ? item["name"] : "Unknown"
            matchingTabs := []

            ; Find all tabs this item could go to
            if item.Has("tags") {
                for tag in item["tags"] {
                    tagLower := StrLower(tag)
                    if InStr(tagLower, "core:") == 1 {
                        continue
                    }

                    if this.tagToTab.Has(tagLower) {
                        tabNum := this.tagToTab[tagLower]
                        if !HasValue(matchingTabs, tabNum) {
                            matchingTabs.Push(tabNum)
                        }
                    }
                }
            }

            ; Classify the item
            if matchingTabs.Length == 0 {
                stats["itemsUnassigned"]++
            } else if matchingTabs.Length > 1 {
                stats["itemsWithConflicts"]++
                stats["itemsResolved"]++

                ; Sort tabs to find lowest
                SortArray(&matchingTabs)

                stats["conflictDetails"].Push(Map(
                    "item", itemName,
                    "conflictingTabs", matchingTabs,
                    "resolvedTab", matchingTabs[1]
                ))
            } else {
                stats["itemsResolved"]++
            }
        }

        return stats
    }

    ; Clear the resolution cache
    static ClearCache() {
        this.resolvedCache := Map()
    }

    ; Get debug information about tag-to-tab mappings
    static GetTagMappings() {
        return this.tagToTab
    }

    ; Check if a specific tag is mapped to any tab
    static IsTagMapped(tag) {
        return this.tagToTab.Has(StrLower(tag))
    }

    ; Get the tab number for a specific tag (or 0 if not mapped)
    static GetTabForTag(tag) {
        tagLower := StrLower(tag)
        return this.tagToTab.Has(tagLower) ? this.tagToTab[tagLower] : 0
    }
}

; Helper function to check if array contains value
HasValue(arr, value) {
    for v in arr {
        if v == value {
            return true
        }
    }
    return false
}

; Helper function to sort array
SortArray(&arr) {
    if arr.Length <= 1 {
        return
    }

    ; Simple bubble sort
    Loop arr.Length - 1 {
        i := A_Index
        Loop arr.Length - i {
            j := A_Index
            if arr[j] > arr[j + 1] {
                temp := arr[j]
                arr[j] := arr[j + 1]
                arr[j + 1] := temp
            }
        }
    }
}

; Example usage and testing
TestConflictResolution() {
    ; Load item grouping system
    #Include item_grouping.ahk

    if !ItemGroupingSystem.LoadDatabase() {
        MsgBox("Failed to load item database!", "Error", "Icon!")
        return
    }

    ; Simulate user configuration
    ; User wants: Tab 1 = Fishing, Tab 2 = Food/Consumables
    testConfig := Map(
        "tab_0", ["Fishing", "skill_fishing"],
        "tab_1", ["Food", "consume_food", "Consumables"],
        "tab_2", ["Combat", "equip_melee"],
        "tab_3", []
    )

    ; Initialize resolver
    BankTabResolver.Initialize(testConfig)

    ; Test with Shark (has both fishing and food tags)
    shark := ItemGroupingSystem.GetItemByName("Shark")
    if shark {
        sharkTab := BankTabResolver.ResolveItemTab(shark)
        MsgBox("Shark Conflict Resolution:`n`nShark has tags:`n  - skill_fishing (Tab 1)`n  - consume_food (Tab 2)`n`nResolved to: Tab " . sharkTab . " (lowest tab wins)", "Conflict Test", "Iconi")
    }

    ; Test with multiple items
    testItems := []
    testItemNames := ["Shark", "Raw shark", "Abyssal whip", "Rune scimitar", "Ranarr seed"]

    for itemName in testItemNames {
        item := ItemGroupingSystem.GetItemByName(itemName)
        if item {
            testItems.Push(item)
        }
    }

    ; Get conflict statistics
    stats := BankTabResolver.GetConflictStats(testItems)

    msg := "Conflict Resolution Statistics:`n`n"
    msg .= "Total Items: " . stats["totalItems"] . "`n"
    msg .= "Items with Conflicts: " . stats["itemsWithConflicts"] . "`n"
    msg .= "Items Resolved: " . stats["itemsResolved"] . "`n"
    msg .= "Unassigned Items: " . stats["itemsUnassigned"] . "`n`n"

    if stats["conflictDetails"].Length > 0 {
        msg .= "Conflict Details:`n"
        for conflict in stats["conflictDetails"] {
            msg .= "  " . conflict["item"] . " -> Tab " . conflict["resolvedTab"] . "`n"
            msg .= "    (Conflicted between tabs: "
            for tab in conflict["conflictingTabs"] {
                msg .= tab . " "
            }
            msg .= ")`n"
        }
    }

    MsgBox(msg, "Test Results", "Iconi")
}
