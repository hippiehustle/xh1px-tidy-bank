; ==========================================
; xh1px's Tidy Bank - Database Module v2.0
; Comprehensive OSRS Item Categorization
; ==========================================

class ItemDatabase {
    static dbPath := A_ScriptDir "\osrsbox-db.json"
    static cachedDB := ""
    static itemsByCategory := Map()
    static itemsByID := Map()
    static itemsByName := Map()
    static categoryKeywords := Map()

    ; ==========================================
    ; CATEGORY KEYWORD MAPPINGS
    ; Maps skill/category names to item identifiers
    ; ==========================================

    static InitializeCategories() {
        ; COMBAT SKILLS
        ItemDatabase.categoryKeywords["Attack"] := [
            "sword", "scimitar", "longsword", "dagger", "axe", "mace", "spear",
            "halberd", "whip", "rapier", "sabre", "blade"
        ]

        ItemDatabase.categoryKeywords["Strength"] := [
            "maul", "greataxe", "warhammer", "two-handed", "2h", "elder maul",
            "granite maul", "dragon warhammer"
        ]

        ItemDatabase.categoryKeywords["Defence"] := [
            "platebody", "platelegs", "plateskirt", "chainbody", "shield", "defender",
            "bulwark", "torso", "body", "helm", "helmet", "coif"
        ]

        ItemDatabase.categoryKeywords["Ranged"] := [
            "bow", "crossbow", "dart", "arrow", "bolt", "javelin", "blowpipe",
            "cannon", "chinchompa", "blessed", "dragon hunter"
        ]

        ItemDatabase.categoryKeywords["Magic"] := [
            "staff", "wand", "orb", "rune", "spell", "tome", "kodai", "sanguinesti",
            "trident", "robes", "mystic", "ancestral"
        ]

        ItemDatabase.categoryKeywords["Prayer"] := [
            "bone", "ashes", "prayer potion", "restore", "sanfew", "super restore",
            "holy", "unholy", "amulet of glory", "symbol", "vestment"
        ]

        ; GATHERING SKILLS
        ItemDatabase.categoryKeywords["Cooking"] := [
            "raw fish", "raw meat", "fish", "meat", "chicken", "beef", "bread",
            "cake", "pie", "pizza", "stew", "potato", "egg", "flour", "milk"
        ]

        ItemDatabase.categoryKeywords["Fishing"] := [
            "fish", "fishing rod", "harpoon", "fishing bait", "feather", "net",
            "lobster pot", "sea turtle", "shark", "manta", "anglerfish", "karambwan",
            "raw", "roe"
        ]

        ItemDatabase.categoryKeywords["Firemaking"] := [
            "logs", "tinderbox", "infernal", "redwood"
        ]

        ItemDatabase.categoryKeywords["Woodcutting"] := [
            "logs", "axe", "redwood", "teak", "mahogany", "maple", "willow",
            "oak", "magic", "yew"
        ]

        ; ARTISAN SKILLS
        ItemDatabase.categoryKeywords["Fletching"] := [
            "arrow", "bow", "dart", "javelin", "bolt", "feather", "string",
            "shaft", "arrowhead", "bolt tip", "headless"
        ]

        ItemDatabase.categoryKeywords["Crafting"] := [
            "leather", "hide", "thread", "needle", "chisel", "gem", "ring",
            "necklace", "amulet", "bracelet", "jewellery", "silver", "gold",
            "cloth", "silk", "dragonhide"
        ]

        ItemDatabase.categoryKeywords["Smithing"] := [
            "ore", "bar", "iron", "steel", "mithril", "adamant", "rune",
            "bronze", "anvil", "hammer", "coal"
        ]

        ItemDatabase.categoryKeywords["Mining"] := [
            "ore", "coal", "gem", "amethyst", "pickaxe", "hammer", "clay",
            "limestone", "iron", "copper", "tin", "gold", "mithril", "adamant",
            "runite", "diamond", "sapphire", "ruby", "emerald"
        ]

        ItemDatabase.categoryKeywords["Herblore"] := [
            "herb", "grimy", "potion", "vial", "leaf", "seed", "secondary",
            "eye of newt", "red spider", "unicorn horn", "dragon scale",
            "limpwurt", "wine", "snape"
        ]

        ; SUPPORT SKILLS
        ItemDatabase.categoryKeywords["Agility"] := [
            "graceful", "stamina", "shortcut", "rope", "marks of grace"
        ]

        ItemDatabase.categoryKeywords["Thieving"] := [
            "lockpick", "blackjack", "rogue", "dodgy", "keys", "lock"
        ]

        ItemDatabase.categoryKeywords["Slayer"] := [
            "slayer helmet", "black mask", "task", "earmuff", "facemask",
            "nose peg", "spiky", "witchwood", "mirror shield", "leaf-bladed",
            "imbued heart", "eternal gem", "craw", "viggora"
        ]

        ItemDatabase.categoryKeywords["Farming"] := [
            "seed", "seedling", "sapling", "herb seed", "tree seed", "hops",
            "compost", "watering can", "spade", "rake", "secateurs", "harvest",
            "kindling", "diseased"
        ]

        ItemDatabase.categoryKeywords["Runecraft"] := [
            "essence", "rune", "talisman", "tiara", "pouch", "binding",
            "daeyalt", "catalyst"
        ]

        ItemDatabase.categoryKeywords["Hunter"] := [
            "trap", "net", "snare", "jar", "salamander", "chinchompa",
            "butterfly", "impling", "teasing stick", "torch"
        ]

        ItemDatabase.categoryKeywords["Construction"] := [
            "plank", "nail", "saw", "hammer", "limestone", "marble", "gold leaf",
            "magic stone", "flatpack", "cloth"
        ]

        ; EQUIPMENT TYPES
        ItemDatabase.categoryKeywords["Helm"] := [
            "helm", "hat", "hood", "crown", "mask", "helmet", "coif",
            "fullhelm", "med helm", "chainmail"
        ]

        ItemDatabase.categoryKeywords["Body"] := [
            "platebody", "body", "chestplate", "chain", "leather", "robes",
            "jacket", "top", "vestment", "torso", "brassard"
        ]

        ItemDatabase.categoryKeywords["Legs"] := [
            "platelegs", "legs", "chaps", "skirt", "tasset", "tassets",
            "bottom", "tights"
        ]

        ItemDatabase.categoryKeywords["Boots"] := [
            "boots", "shoes", "feet", "greaves"
        ]

        ItemDatabase.categoryKeywords["Gloves"] := [
            "gloves", "hands", "vambraces", "bracers", "gauntlets"
        ]

        ItemDatabase.categoryKeywords["Cape"] := [
            "cape", "cloak", "back", "ava", "fire cape", "infernal cape",
            "skill cape", "god cape"
        ]

        ItemDatabase.categoryKeywords["Neck"] := [
            "amulet", "necklace", "pendant", "glory", "fury", "torture",
            "anguish", "occult", "salve"
        ]

        ItemDatabase.categoryKeywords["Ring"] := [
            "ring", "band", "dueling", "wealth", "suffering", "berserker",
            "archer", "seer", "warrior", "treasonous", "tyrannical"
        ]

        ; CONSUMABLES
        ItemDatabase.categoryKeywords["Potion"] := [
            "potion", "flask", "vial", "dose", "super", "divine", "antidote",
            "antifire", "extended", "anti-venom", "stamina", "guthix",
            "saradomin brew", "restore"
        ]

        ItemDatabase.categoryKeywords["Food"] := [
            "fish", "meat", "bread", "cake", "pie", "pizza", "stew",
            "potato", "egg", "chocolate", "seaweed", "soup", "lobster",
            "shark", "swordfish", "shrimp", "herring", "karambwan",
            "manta ray", "anglerfish", "dark crab"
        ]

        ItemDatabase.categoryKeywords["Ammo"] := [
            "arrow", "bolt", "dart", "javelin", "knife", "chinchompa",
            "head", "tip", "blessed", "ammunition"
        ]

        ItemDatabase.categoryKeywords["Rune"] := [
            "rune", " air ", " water ", " earth ", " fire ", " mind ",
            " body ", " cosmic ", " chaos ", " nature ", " law ",
            " death ", " blood ", " soul ", " wrath ", " astral "
        ]

        ; SPECIAL CATEGORIES
        ItemDatabase.categoryKeywords["Currency"] := [
            "coin", "token", "ticket", "tokkul", "trading stick",
            "zeal", "point", "mark of grace", "platinum"
        ]

        ItemDatabase.categoryKeywords["GP"] := [
            "coins"
        ]

        ItemDatabase.categoryKeywords["Quest Item"] := [
            "quest", "key", "scroll", "diary", "letterbox", "casket",
            "silverlight", "excalibur", "anti-dragon", "ghostspeak"
        ]

        ItemDatabase.categoryKeywords["Barrows"] := [
            "ahrim", "dharok", "guthan", "karil", "torag", "verac"
        ]

        ItemDatabase.categoryKeywords["God Wars"] := [
            "bandos", "armadyl", "saradomin", "zamorak", "godsword"
        ]

        ItemDatabase.categoryKeywords["Raids - CoX"] := [
            "twisted", "kodai", "elder maul", "dragon claws", "ancestral",
            "dinh", "hunter crossbow", "dexterous", "arcane"
        ]

        ItemDatabase.categoryKeywords["Raids - ToB"] := [
            "scythe", "ghrazi", "sanguinesti", "avernic", "justiciar",
            "faceguard", "chestguard", "legguard"
        ]

        ItemDatabase.categoryKeywords["Boss Drops"] := [
            "voidwaker", "dragon pickaxe", "treasonous", "tyrannical",
            "primordial", "pegasian", "eternal", "cerberus", "hydra",
            "sire", "kraken", "smoke devil", "abyssal"
        ]

        ItemDatabase.categoryKeywords["Skilling Outfit"] := [
            "graceful", "angler", "lumberjack", "prospector", "farmer",
            "pyromancer", "rogue", "outfit"
        ]

        ItemDatabase.categoryKeywords["Weapon"] := [
            "sword", "axe", "mace", "dagger", "spear", "staff", "bow",
            "wand", "whip", "rapier", "scimitar", "halberd", "maul",
            "greataxe", "warhammer", "crossbow", "blowpipe", "tentacle"
        ]

        ItemDatabase.categoryKeywords["Shield"] := [
            "shield", "defender", "bulwark", "book", "tome"
        ]
    }

    ; Initialize database
    static Load() {
        if (ItemDatabase.cachedDB != "") {
            return true  ; Already loaded
        }

        ItemDatabase.InitializeCategories()

        if !FileExist(ItemDatabase.dbPath) {
            ItemDatabase.GenerateStubDatabase()
        }

        try {
            rawData := FileRead(ItemDatabase.dbPath)
            ItemDatabase.cachedDB := JSON.Parse(rawData)

            ; Build lookup maps
            ItemDatabase.BuildLookupMaps()
            return true
        } catch as err {
            MsgBox("Error loading database: " err.Message, "Database Error", 16)
            return false
        }
    }

    ; Build category and ID lookup maps
    static BuildLookupMaps() {
        ; Initialize category arrays
        for category in ItemDatabase.categoryKeywords {
            ItemDatabase.itemsByCategory[category] := []
        }

        ; Index items by ID and build categories
        for itemId, itemData in ItemDatabase.cachedDB {
            id := Integer(itemId)
            name := itemData.Has("name") ? itemData["name"] : "Unknown"

            ItemDatabase.itemsByID[id] := itemData
            ItemDatabase.itemsByName[name] := itemData

            ; Categorize items based on name matching
            for category, keywords in ItemDatabase.categoryKeywords {
                if ItemDatabase.MatchesCategory(name, keywords) {
                    ItemDatabase.itemsByCategory[category].Push(id)
                }
            }
        }
    }

    ; Check if item matches category keywords
    static MatchesCategory(itemName, keywords) {
        itemNameLower := StrLower(itemName)
        for keyword in keywords {
            keywordLower := StrLower(keyword)
            if InStr(itemNameLower, keywordLower) {
                return true
            }
        }
        return false
    }

    ; Get items for specific category
    static GetItemsByCategory(category) {
        if ItemDatabase.itemsByCategory.Has(category) {
            return ItemDatabase.itemsByCategory[category]
        }
        return []
    }

    ; Get all items for tab categories (multiple categories per tab)
    static GetItemsForTab(tabCategories) {
        tabItems := []
        seenItems := Map()  ; Prevent duplicates

        for category in tabCategories {
            items := ItemDatabase.GetItemsByCategory(category)
            for itemId in items {
                if !seenItems.Has(itemId) {
                    tabItems.Push(itemId)
                    seenItems[itemId] := true
                }
            }
        }
        return tabItems
    }

    ; Look up item by ID
    static GetItemByID(id) {
        if ItemDatabase.itemsByID.Has(id) {
            return ItemDatabase.itemsByID[id]
        }
        return ""
    }

    ; Look up item by name
    static GetItemByName(name) {
        if ItemDatabase.itemsByName.Has(name) {
            return ItemDatabase.itemsByName[name]
        }
        return ""
    }

    ; Get item GE price
    static GetGEPrice(id) {
        item := ItemDatabase.GetItemByID(id)
        if (item && item.Has("current") && item["current"].Has("price")) {
            return item["current"]["price"]
        }
        return 0
    }

    ; Generate stub database for testing
    static GenerateStubDatabase() {
        stubDB := Map()

        ; Comprehensive test items covering all categories
        testItems := [
            [995, "Coins", 1],
            [1042, "Pot", 15],
            [1511, "Logs", 89],
            [1513, "Magic logs", 987],
            [2, "Cannonball", 215],
            [554, "Fire rune", 5],
            [555, "Water rune", 4],
            [556, "Air rune", 4],
            [557, "Earth rune", 4],
            [561, "Nature rune", 178],
            [21880, "Dragon claws", 43500000],
            [11694, "Abyssal whip", 4200000],
            [1187, "Abyssal dagger", 450000],
            [11726, "Amulet of fury", 450000],
            [1704, "Amulet of glory", 4500],
            [6737, "Graceful hood", 25000],
            [6738, "Graceful top", 35000],
            [6739, "Graceful legs", 35000],
            [6740, "Graceful gloves", 20000],
            [6741, "Graceful boots", 25000],
            [6742, "Graceful cape", 35000],
            [6571, "Barrows gloves", 3500000],
            [12002, "Bandos chestplate", 2500000],
            [12004, "Bandos tassets", 2000000],
            [12006, "Bandos boots", 150000],
            [11802, "Ghrazi rapier", 28000000],
            [13899, "Scythe of vitur", 50000000],
            [12924, "Dragon hunter crossbow", 9000000],
            [13035, "Sanguinesti staff", 22000000],
            [19553, "Dragon boots", 150000],
            [11840, "Abyssal tentacle", 1500000],
            [6522, "Fury ornament kit", 1200000]
        ]

        for item in testItems {
            id := item[1]
            name := item[2]
            price := item[3]
            stubDB[String(id)] := Map(
                "id", id,
                "name", name,
                "current", Map("price", price)
            )
        }

        ; Save stub
        try {
            FileAppend(JSON.Stringify(stubDB), ItemDatabase.dbPath)
        }
    }

    ; Get database statistics
    static GetStats() {
        stats := Map(
            "total_items", ItemDatabase.itemsByID.Count(),
            "categories", ItemDatabase.itemsByCategory.Count()
        )
        return stats
    }

    ; Get list of all available categories
    static GetAllCategories() {
        categories := []
        for category in ItemDatabase.categoryKeywords {
            categories.Push(category)
        }
        return categories
    }

    ; Validate items exist for category
    static ValidateCategory(category) {
        items := ItemDatabase.GetItemsByCategory(category)
        return items.Length > 0
    }
}

; ==========================================
; JSON UTILITY CLASS
; ==========================================

class JSON {
    static Parse(text) {
        text := Trim(text)
        if (SubStr(text, 1, 1) == "{")
            return JSON._ParseObject(text, &pos := 1)
        else if (SubStr(text, 1, 1) == "[")
            return JSON._ParseArray(text, &pos := 1)
        return ""
    }

    static Stringify(obj) {
        if (obj is Map) {
            items := []
            for key, value in obj
                items.Push('"' . key . '":' . JSON.Stringify(value))
            return "{" . JSON._Join(items, ",") . "}"
        }
        else if (obj is Array) {
            items := []
            for value in obj
                items.Push(JSON.Stringify(value))
            return "[" . JSON._Join(items, ",") . "]"
        }
        else if (obj is String)
            return '"' . obj . '"'
        else if (obj = true)
            return "true"
        else if (obj = false)
            return "false"
        else if (obj = "")
            return "null"
        else
            return String(obj)
    }

    static _ParseObject(text, &pos) {
        obj := Map()
        pos++
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        if (SubStr(text, pos, 1) == "}")
            return obj
        loop {
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            if (SubStr(text, pos, 1) != '"')
                throw Error("Expected string key")
            key := JSON._ParseString(text, &pos)
            while (pos <= StrLen(text) && InStr(" `t`r`n:", SubStr(text, pos, 1)))
                pos++
            value := JSON._ParseValue(text, &pos)
            obj[key] := value
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            ch := SubStr(text, pos, 1)
            if (ch == "}")
                return obj
            if (ch == ",") {
                pos++
                continue
            }
            throw Error("Expected , or }")
        }
        return obj
    }

    static _ParseArray(text, &pos) {
        arr := []
        pos++
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        if (SubStr(text, pos, 1) == "]")
            return arr
        loop {
            value := JSON._ParseValue(text, &pos)
            arr.Push(value)
            while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
                pos++
            ch := SubStr(text, pos, 1)
            if (ch == "]")
                return arr
            if (ch == ",") {
                pos++
                continue
            }
            throw Error("Expected , or ]")
        }
        return arr
    }

    static _ParseValue(text, &pos) {
        while (pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1)))
            pos++
        ch := SubStr(text, pos, 1)
        if (ch == '"')
            return JSON._ParseString(text, &pos)
        else if (ch == "{")
            return JSON._ParseObject(text, &pos)
        else if (ch == "[")
            return JSON._ParseArray(text, &pos)
        else if (ch == "t") {
            pos += 4
            return true
        }
        else if (ch == "f") {
            pos += 5
            return false
        }
        else if (ch == "n") {
            pos += 4
            return ""
        }
        else if (InStr("0123456789-", ch))
            return JSON._ParseNumber(text, &pos)
        throw Error("Unexpected character: " . ch)
    }

    static _ParseString(text, &pos) {
        if (SubStr(text, pos, 1) != '"')
            throw Error("Expected string")
        pos++
        start := pos
        while (pos <= StrLen(text)) {
            ch := SubStr(text, pos, 1)
            if (ch == '"') {
                result := SubStr(text, start, pos - start)
                pos++
                return result
            }
            if (ch == "\")
                pos++
            pos++
        }
        throw Error("Unterminated string")
    }

    static _ParseNumber(text, &pos) {
        start := pos
        while (pos <= StrLen(text)) {
            ch := SubStr(text, pos, 1)
            if (!InStr("0123456789.-+eE", ch))
                break
            pos++
        }
        return Number(SubStr(text, start, pos - start))
    }

    static _Join(items, sep) {
        result := ""
        for item in items {
            if (result != "")
                result .= sep
            result .= item
        }
        return result
    }
}
