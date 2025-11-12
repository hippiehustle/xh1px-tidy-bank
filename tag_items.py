#!/usr/bin/env python3
"""
OSRS Item Tagging System
Automatically tags all items in the OSRSBox database according to the hierarchical grouping system
"""

import json
import re
from typing import Dict, List, Set

class ItemTagger:
    def __init__(self):
        self.skill_keywords = {
            'skill_attack': ['attack', 'slash', 'crush', 'stab'],
            'skill_strength': ['strength'],
            'skill_defence': ['defence', 'defense', 'armor', 'armour'],
            'skill_ranged': ['ranged', 'range', 'bow', 'crossbow', 'arrow', 'bolt'],
            'skill_prayer': ['prayer', 'bone', 'ash', 'bury'],
            'skill_magic': ['magic', 'mage', 'spell', 'rune', 'staff', 'wand'],
            'skill_mining': ['mining', 'pickaxe', 'ore'],
            'skill_fishing': ['fishing', 'fish', 'net', 'rod', 'harpoon', 'lobster', 'shark', 'tuna'],
            'skill_woodcutting': ['woodcutting', 'axe', 'log', 'tree'],
            'skill_hunter': ['hunter', 'trap', 'chinchompa', 'implings'],
            'skill_farming': ['farming', 'seed', 'herb', 'allotment', 'compost'],
            'skill_cooking': ['cooking', 'cooked', 'raw', 'burnt'],
            'skill_smithing': ['smithing', 'bar', 'anvil', 'smelt'],
            'skill_crafting': ['crafting', 'leather', 'hide', 'gem', 'jewelry', 'jewellery'],
            'skill_fletching': ['fletching', 'bow', 'arrow', 'dart'],
            'skill_herblore': ['herblore', 'potion', 'herb', 'vial'],
            'skill_construction': ['construction', 'plank', 'nail', 'saw'],
            'skill_firemaking': ['firemaking', 'tinderbox', 'fire'],
            'skill_runecraft': ['runecraft', 'talisman', 'tiara', 'altar'],
            'skill_agility': ['agility', 'graceful', 'mark of grace'],
            'skill_thieving': ['thieving', 'lockpick', 'steal'],
            'skill_slayer': ['slayer', 'task', 'monster'],
        }

        # Equipment slot mappings
        self.equipment_slots = {
            'head': 'equip_head',
            'body': 'equip_body',
            'legs': 'equip_legs',
            'hands': 'equip_hands',
            'feet': 'equip_feet',
            'cape': 'equip_cape',
            'neck': 'equip_neck',
            'ring': 'equip_ring',
            'shield': 'equip_shield',
            'weapon': 'equip_weapon_main',
            '2h': 'equip_weapon_2h',
            'ammo': 'equip_ammo'
        }

        # Weapon type mappings
        self.weapon_types = {
            'slash_sword': ['equip_sword', 'equip_melee'],
            'stab_sword': ['equip_sword', 'equip_melee'],
            'scimitar': ['equip_scimitar', 'equip_melee'],
            'dagger': ['equip_dagger', 'equip_melee'],
            'axe': ['equip_axe', 'equip_melee'],
            'mace': ['equip_mace', 'equip_melee'],
            'spear': ['equip_spear', 'equip_melee'],
            'staff': ['equip_staff_melee', 'equip_melee'],
            'bow': ['equip_bow', 'equip_ranged'],
            'crossbow': ['equip_crossbow', 'equip_ranged'],
            'thrown': ['equip_thrown', 'equip_ranged'],
            'chinchompa': ['equip_chinchompa', 'equip_ranged'],
            'magic_staff': ['equip_staff_magic', 'equip_magic'],
            'wand': ['equip_wand', 'equip_magic'],
        }

    def tag_item(self, item: Dict) -> Set[str]:
        """Generate all appropriate tags for an item"""
        tags = set()
        name = (item.get('name') or '').lower()
        examine = (item.get('examine') or '').lower()

        # Add special tags
        tags.update(self._get_special_tags(item))

        # Add quest tags
        if item.get('quest_item'):
            tags.add('quest_item')
            tags.add('CORE:QUEST')

        # Add equipment tags
        if item.get('equipable'):
            equip_tags = self._get_equipment_tags(item, name)
            tags.update(equip_tags)
            if equip_tags:
                tags.add('CORE:EQUIPMENT')

        # Add resource tags
        resource_tags = self._get_resource_tags(item, name, examine)
        tags.update(resource_tags)
        if resource_tags:
            tags.add('CORE:RESOURCES')

        # Add consumable tags
        consumable_tags = self._get_consumable_tags(item, name, examine)
        tags.update(consumable_tags)
        if consumable_tags:
            tags.add('CORE:CONSUMABLES')

        # Add tool tags
        tool_tags = self._get_tool_tags(item, name, examine)
        tags.update(tool_tags)
        if tool_tags:
            tags.add('CORE:TOOLS')

        # Add currency tags
        currency_tags = self._get_currency_tags(item, name)
        tags.update(currency_tags)
        if currency_tags:
            tags.add('CORE:CURRENCY')

        # Add clue tags
        clue_tags = self._get_clue_tags(item, name)
        tags.update(clue_tags)
        if clue_tags:
            tags.add('CORE:CLUE_SCROLLS')

        # Add skill tags
        skill_tags = self._get_skill_tags(item, name, examine)
        tags.update(skill_tags)
        if skill_tags:
            tags.add('CORE:SKILLS')

        # Add cosmetic tags
        if self._is_cosmetic(item, name, examine):
            tags.add('cosmetic_fashion')
            tags.add('CORE:COSMETIC')

        # Add minigame tags
        minigame_tags = self._get_minigame_tags(item, name, examine)
        tags.update(minigame_tags)
        if minigame_tags:
            tags.add('CORE:MINIGAME')

        # Add PvP tags
        pvp_tags = self._get_pvp_tags(item, name, examine)
        tags.update(pvp_tags)
        if pvp_tags:
            tags.add('CORE:PVP')

        # Default to MISC if no core group assigned
        if not any(tag.startswith('CORE:') for tag in tags):
            tags.add('CORE:MISCELLANEOUS')
            tags.add('misc_other')

        return tags

    def _get_special_tags(self, item: Dict) -> Set[str]:
        """Get special attribute tags"""
        tags = set()

        if item.get('members'):
            tags.add('special_members')
        else:
            tags.add('special_f2p')

        if item.get('stackable'):
            tags.add('special_stackable')

        if item.get('tradeable'):
            tags.add('special_tradeable')

        if item.get('noted'):
            tags.add('special_noted')

        if item.get('placeholder'):
            tags.add('special_placeholder')

        # High value (>100k gp)
        if item.get('cost', 0) > 100000:
            tags.add('special_high_value')

        return tags

    def _get_equipment_tags(self, item: Dict, name: str) -> Set[str]:
        """Get equipment-related tags"""
        tags = set()

        if not item.get('equipable'):
            return tags

        equipment = item.get('equipment', {})
        if not equipment:
            return tags

        # Equipment slot
        slot = equipment.get('slot', '').lower()
        if slot in self.equipment_slots:
            tags.add(self.equipment_slots[slot])

        # Weapon handling
        if item.get('equipable_weapon'):
            weapon = item.get('weapon', {})
            weapon_type = weapon.get('weapon_type', '').lower()

            # Add weapon type tags
            for wtype, wtags in self.weapon_types.items():
                if wtype in weapon_type or wtype in name:
                    tags.update(wtags)

            # Two-handed check
            if slot == '2h' or '2h' in name or 'two-handed' in name:
                tags.add('equip_weapon_2h')
            else:
                tags.add('equip_weapon_main')

        # Armor style detection
        if slot in ['head', 'body', 'legs', 'hands', 'feet', 'shield']:
            # Check equipment stats to determine armor style
            attack_stab = equipment.get('attack_stab', 0)
            attack_slash = equipment.get('attack_slash', 0)
            attack_crush = equipment.get('attack_crush', 0)
            attack_ranged = equipment.get('attack_ranged', 0)
            attack_magic = equipment.get('attack_magic', 0)

            if attack_ranged > 0 or 'range' in name or 'leather' in name or 'dragonhide' in name:
                tags.add('equip_armor_ranged')
            elif attack_magic > 0 or 'robe' in name or 'mystic' in name or 'wizard' in name:
                tags.add('equip_armor_magic')
            elif any(x > 0 for x in [attack_stab, attack_slash, attack_crush]):
                tags.add('equip_armor_melee')

        return tags

    def _get_resource_tags(self, item: Dict, name: str, examine: str) -> Set[str]:
        """Get resource-related tags"""
        tags = set()

        # Ores
        if ' ore' in name and name.endswith(' ore'):
            tags.add('resource_ore')
            tags.add('skill_mining')
            tags.add('skill_smithing')

        # Bars
        if ' bar' in name:
            tags.add('resource_bar')
            tags.add('skill_smithing')

        # Logs
        if 'log' in name and ('logs' in name or name == 'log'):
            tags.add('resource_log')
            tags.add('skill_woodcutting')
            tags.add('skill_firemaking')

        # Planks
        if 'plank' in name:
            tags.add('resource_plank')
            tags.add('skill_construction')

        # Fish
        if ('raw ' in name or 'cooked ' in name or 'burnt ' in name) and any(fish in name for fish in ['shrimp', 'anchovies', 'sardine', 'herring', 'mackerel', 'trout', 'cod', 'pike', 'salmon', 'tuna', 'lobster', 'bass', 'swordfish', 'monkfish', 'shark', 'sea turtle', 'manta ray', 'anglerfish']):
            if 'raw ' in name:
                tags.add('resource_fish_raw')
            elif 'cooked ' in name:
                tags.add('resource_fish_cooked')
            tags.add('skill_fishing')
            tags.add('skill_cooking')

        # Herbs
        if ('grimy ' in name or 'clean ' in name) and any(herb in name for herb in ['guam', 'marrentill', 'tarromin', 'harralander', 'ranarr', 'irit', 'avantoe', 'kwuarm', 'cadantine', 'lantadyme', 'dwarf weed', 'torstol', 'snapdragon']):
            if 'grimy' in name:
                tags.add('resource_herb_grimy')
            else:
                tags.add('resource_herb_clean')
            tags.add('skill_herblore')
            tags.add('skill_farming')

        # Seeds
        if ' seed' in name:
            if any(herb in name for herb in ['guam', 'marrentill', 'tarromin', 'harralander', 'ranarr', 'irit', 'avantoe', 'kwuarm', 'cadantine', 'lantadyme', 'dwarf weed', 'torstol', 'snapdragon']):
                tags.add('resource_seed_herb')
            elif any(tree in name for tree in ['tree', 'oak', 'willow', 'maple', 'yew', 'magic']):
                if any(fruit in name for fruit in ['apple', 'banana', 'orange', 'curry', 'pineapple', 'papaya', 'palm', 'calquat', 'dragonfruit']):
                    tags.add('resource_seed_fruit_tree')
                else:
                    tags.add('resource_seed_tree')
            elif any(flower in name for flower in ['flower', 'marigold', 'rosemary', 'nasturtium', 'woad', 'limpwurt']):
                tags.add('resource_seed_flower')
            else:
                tags.add('resource_seed_allotment')
            tags.add('skill_farming')

        # Hides & Leather
        if 'hide' in name or 'dragonhide' in name:
            tags.add('resource_hide')
            tags.add('skill_crafting')
        if 'leather' in name and 'armor' not in name and 'armour' not in name:
            tags.add('resource_leather')
            tags.add('skill_crafting')

        # Gems
        if 'uncut' in name and any(gem in name for gem in ['sapphire', 'emerald', 'ruby', 'diamond', 'dragonstone', 'onyx', 'zenyte']):
            tags.add('resource_gem_uncut')
            tags.add('skill_mining')
            tags.add('skill_crafting')
        elif any(gem in name for gem in ['sapphire', 'emerald', 'ruby', 'diamond', 'dragonstone', 'onyx', 'zenyte']) and 'ring' not in name and 'necklace' not in name and 'amulet' not in name and 'bracelet' not in name:
            tags.add('resource_gem_cut')
            tags.add('skill_crafting')

        # Runes
        if 'rune' in name and item.get('stackable'):
            if any(rune in name for rune in ['air', 'water', 'earth', 'fire']):
                tags.add('resource_rune_elemental')
            elif any(rune in name for rune in ['mind', 'body', 'cosmic', 'chaos', 'nature', 'law', 'death', 'blood', 'soul', 'astral', 'wrath']):
                tags.add('resource_rune_catalytic')
            elif any(combo in name for combo in ['mist', 'dust', 'mud', 'smoke', 'steam', 'lava']):
                tags.add('resource_rune_combination')
            tags.add('skill_runecraft')
            tags.add('skill_magic')

        # Bones
        if 'bone' in name or 'bones' in name:
            tags.add('resource_bone')
            tags.add('skill_prayer')

        # Ashes
        if 'ash' in name or 'ashes' in name:
            tags.add('resource_ash')
            tags.add('skill_prayer')

        return tags

    def _get_consumable_tags(self, item: Dict, name: str, examine: str) -> Set[str]:
        """Get consumable-related tags"""
        tags = set()

        # Food
        food_items = ['shark', 'lobster', 'swordfish', 'tuna', 'salmon', 'trout', 'pike', 'bread', 'cake', 'pie', 'stew', 'karambwan', 'manta ray', 'sea turtle', 'anglerfish', 'monkfish']
        if any(food in name for food in food_items) and 'raw' not in name:
            tags.add('consume_food')
            tags.add('skill_cooking')

        # Potions
        if 'potion' in name:
            if any(combat in name for combat in ['attack', 'strength', 'defence', 'magic', 'ranging', 'super', 'combat']):
                tags.add('consume_potion_combat')
            if 'prayer' in name or 'restore' in name:
                tags.add('consume_potion_prayer')
            if '(unf)' in name or 'unfinished' in name:
                tags.add('consume_potion_unf')
            if 'anti-poison' in name or 'antipoison' in name:
                tags.add('consume_potion_antipoison')
            if 'antifire' in name or 'anti-fire' in name:
                tags.add('consume_potion_antifire')
            tags.add('skill_herblore')

        # Ammunition
        if 'arrow' in name and 'arrow' in name.split() and item.get('stackable'):
            tags.add('consume_ammo_arrow')
            tags.add('equip_ammo')
            tags.add('skill_ranged')
            tags.add('skill_fletching')

        if 'bolt' in name and item.get('stackable'):
            tags.add('consume_ammo_bolt')
            tags.add('equip_ammo')
            tags.add('skill_ranged')
            tags.add('skill_fletching')

        if 'dart' in name and item.get('stackable'):
            tags.add('consume_ammo_dart')
            tags.add('equip_ammo')
            tags.add('skill_ranged')
            tags.add('skill_fletching')

        if 'javelin' in name and item.get('stackable'):
            tags.add('consume_ammo_javelin')
            tags.add('equip_ammo')
            tags.add('skill_ranged')
            tags.add('skill_fletching')

        if 'knife' in name and item.get('stackable'):
            tags.add('consume_ammo_knife')
            tags.add('equip_ammo')
            tags.add('skill_ranged')

        if 'cannonball' in name:
            tags.add('consume_ammo_cannonball')
            tags.add('skill_smithing')

        # Teleport tablets
        if 'tablet' in name and 'teleport' in examine:
            tags.add('consume_teleport_tablet')
            tags.add('transport_teleport')

        return tags

    def _get_tool_tags(self, item: Dict, name: str, examine: str) -> Set[str]:
        """Get tool-related tags"""
        tags = set()

        # Pickaxes
        if 'pickaxe' in name:
            tags.add('tool_pickaxe')
            tags.add('skill_mining')

        # Axes (woodcutting)
        if 'axe' in name and not item.get('equipable_weapon'):
            tags.add('tool_axe')
            tags.add('skill_woodcutting')

        # Fishing equipment
        if any(tool in name for tool in ['fishing rod', 'fly fishing rod', 'harpoon', 'lobster pot', 'small fishing net', 'big fishing net', 'fishing net']):
            tags.add('tool_fishing_equipment')
            tags.add('skill_fishing')

        # Hunter tools
        if any(tool in name for tool in ['butterfly net', 'magic butterfly net', 'bird snare', 'box trap', 'rabbit snare']):
            tags.add('tool_hunter_trap')
            tags.add('skill_hunter')

        # Farming tools
        if 'secateurs' in name:
            tags.add('tool_secateurs')
            tags.add('skill_farming')

        if 'rake' in name:
            tags.add('tool_rake')
            tags.add('skill_farming')

        if 'spade' in name:
            tags.add('tool_spade')

        if 'watering can' in name:
            tags.add('tool_watering_can')
            tags.add('skill_farming')

        # Processing tools
        if 'hammer' in name and not item.get('equipable_weapon'):
            tags.add('tool_hammer')
            tags.add('skill_smithing')
            tags.add('skill_construction')

        if 'needle' in name:
            tags.add('tool_needle')
            tags.add('skill_crafting')

        if 'chisel' in name:
            tags.add('tool_chisel')
            tags.add('skill_crafting')

        if 'saw' in name:
            tags.add('tool_saw')
            tags.add('skill_construction')

        if 'knife' in name and not item.get('stackable'):
            tags.add('tool_knife')
            tags.add('skill_crafting')
            tags.add('skill_fletching')

        if 'pestle and mortar' in name:
            tags.add('tool_pestle_mortar')
            tags.add('skill_herblore')

        if 'vial' in name and 'empty' in name:
            tags.add('tool_vial')
            tags.add('skill_herblore')

        # Utility tools
        if 'tinderbox' in name:
            tags.add('tool_tinderbox')
            tags.add('skill_firemaking')

        if 'rope' in name:
            tags.add('tool_rope')

        if 'bucket' in name:
            tags.add('tool_bucket')

        return tags

    def _get_currency_tags(self, item: Dict, name: str) -> Set[str]:
        """Get currency-related tags"""
        tags = set()

        if 'coins' in name:
            tags.add('currency_coin')

        if 'token' in name and item.get('stackable'):
            if 'platinum' in name:
                tags.add('currency_platinum')
            else:
                tags.add('currency_token')

        if 'tokkul' in name:
            tags.add('currency_tokkul')

        if 'trading stick' in name:
            tags.add('currency_trading_stick')

        return tags

    def _get_clue_tags(self, item: Dict, name: str) -> Set[str]:
        """Get clue scroll related tags"""
        tags = set()

        if 'clue scroll' in name:
            if 'easy' in name:
                tags.add('clue_easy')
            elif 'medium' in name:
                tags.add('clue_medium')
            elif 'hard' in name:
                tags.add('clue_hard')
            elif 'elite' in name:
                tags.add('clue_elite')
            elif 'master' in name:
                tags.add('clue_master')
            elif 'beginner' in name:
                tags.add('clue_beginner')

        # Clue rewards (common cosmetics)
        if any(reward in name for reward in ['elegant', 'trimmed', '(t)', '(g)', 'gilded', 'vestment', 'mitre', 'stole', 'crozier']):
            tags.add('clue_reward_cosmetic')

        return tags

    def _get_skill_tags(self, item: Dict, name: str, examine: str) -> Set[str]:
        """Get skill-related tags based on context"""
        tags = set()
        text = (name + ' ' + examine).lower()

        for skill, keywords in self.skill_keywords.items():
            if any(keyword in text for keyword in keywords):
                tags.add(skill)

        return tags

    def _is_cosmetic(self, item: Dict, name: str, examine: str) -> bool:
        """Check if item is primarily cosmetic"""
        cosmetic_keywords = ['fashionscape', 'holiday', 'cosmetic', 'ornament kit', 'recolour', 'recolor']
        text = (name + ' ' + examine).lower()

        # Not cosmetic if it's equipable with stats
        if item.get('equipable') and item.get('equipment'):
            equipment = item['equipment']
            # Has any combat stats
            if any(equipment.get(stat, 0) != 0 for stat in ['attack_stab', 'attack_slash', 'attack_crush', 'attack_magic', 'attack_ranged', 'defence_stab', 'defence_slash', 'defence_crush', 'defence_magic', 'defence_ranged', 'melee_strength', 'ranged_strength', 'magic_damage', 'prayer']):
                return False

        return any(keyword in text for keyword in cosmetic_keywords)

    def _get_minigame_tags(self, item: Dict, name: str, examine: str) -> Set[str]:
        """Get minigame-related tags"""
        tags = set()
        text = (name + ' ' + examine).lower()

        minigame_keywords = {
            'minigame_ba': ['fighter', 'ranger', 'runner', 'healer', 'penance'],
            'minigame_pc': ['void', 'pest control', 'commendation'],
            'minigame_cw': ['castle wars', 'decorative'],
            'minigame_fight_caves': ['tzrek', 'fire cape', 'jad'],
            'minigame_inferno': ['infernal cape', 'jal'],
            'minigame_nmz': ['nightmare zone', 'imbued'],
            'minigame_cox': ['raids', 'twisted', 'olmlet', 'chambers'],
            'minigame_tob': ['theatre of blood', 'scythe', 'avernic', 'sanguinesti', 'justiciar'],
        }

        for minigame, keywords in minigame_keywords.items():
            if any(keyword in text for keyword in keywords):
                tags.add(minigame)

        return tags

    def _get_pvp_tags(self, item: Dict, name: str, examine: str) -> Set[str]:
        """Get PvP-related tags"""
        tags = set()
        text = (name + ' ' + examine).lower()

        pvp_keywords = ['emblem', 'wilderness', 'pvp', 'bounty', 'revenant', 'ancient']
        if any(keyword in text for keyword in pvp_keywords):
            if item.get('equipable_weapon'):
                tags.add('pvp_weapon')
            elif 'emblem' in name:
                tags.add('pvp_emblem')

        return tags

def main():
    print("=" * 80)
    print("OSRS Item Tagging System")
    print("=" * 80)
    print()

    # Load database
    print("Loading OSRSBox database...")
    with open('/tmp/osrsbox-items-complete.json', 'r') as f:
        items_db = json.load(f)

    print(f"Loaded {len(items_db)} items")
    print()

    # Initialize tagger
    tagger = ItemTagger()

    # Tag all items
    print("Tagging all items...")
    tagged_items = {}
    stats = {
        'total': len(items_db),
        'core_groups': {},
        'tagged': 0
    }

    for item_id, item in items_db.items():
        tags = tagger.tag_item(item)

        # Add tags to item
        item['tags'] = sorted(list(tags))
        item['core_groups'] = sorted([tag.replace('CORE:', '') for tag in tags if tag.startswith('CORE:')])

        tagged_items[item_id] = item
        stats['tagged'] += 1

        # Count core groups
        for tag in tags:
            if tag.startswith('CORE:'):
                group = tag.replace('CORE:', '')
                stats['core_groups'][group] = stats['core_groups'].get(group, 0) + 1

        # Progress indicator
        if stats['tagged'] % 1000 == 0:
            print(f"  Tagged {stats['tagged']} / {stats['total']} items...")

    print(f"✓ Tagged all {stats['tagged']} items")
    print()

    # Save tagged database
    print("Saving tagged database...")
    output_file = '/home/user/xh1px-tidy-bank/osrsbox-items-tagged.json'
    with open(output_file, 'w') as f:
        json.dump(tagged_items, f, indent=2)

    print(f"✓ Saved to: {output_file}")
    print()

    # Print statistics
    print("=" * 80)
    print("TAGGING STATISTICS")
    print("=" * 80)
    print(f"Total Items: {stats['total']}")
    print(f"Tagged Items: {stats['tagged']}")
    print()
    print("Items per Core Group:")
    for group, count in sorted(stats['core_groups'].items(), key=lambda x: x[1], reverse=True):
        print(f"  {group:20s}: {count:6d} items")
    print()

    # Show example tagged items
    print("=" * 80)
    print("EXAMPLE TAGGED ITEMS")
    print("=" * 80)

    examples = ['Abyssal whip', 'Rune scimitar', 'Raw shark', 'Ranarr seed', 'Super combat potion(4)', 'Dragon platebody']

    for example_name in examples:
        for item_id, item in tagged_items.items():
            if item['name'] == example_name:
                print(f"\n{item['name']}:")
                print(f"  Core Groups: {', '.join(item['core_groups'])}")
                print(f"  Tags: {', '.join([t for t in item['tags'] if not t.startswith('CORE:')])}")
                break

    print()
    print("=" * 80)
    print("COMPLETE!")
    print("=" * 80)

if __name__ == '__main__':
    main()
