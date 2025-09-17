import Foundation

// Новая модель для classes.json
struct DnDClass: Codable, Identifiable {
    let id: String
    let nameRu: String
    let nameEn: String
    let description: String?
    let hitDice: String?
    let hitDie: Int?
    let primaryAbility: [String]?
    let savingThrowProficiencies: [String]?
    let skillChoices: SkillChoicesData?
    let skillOptions: [String]?
    let armorProficiencies: [String]?
    let weaponProficiencies: [String]?
    let toolProficiencies: [String]?
    let startingEquipment: StartingEquipmentData?
    let startingGold: String?
    let spellcasting: SpellcastingData?
    let levelFeatures: [LevelFeature]?
    let subclasses: [DnDSubclass]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameRu = "name_ru"
        case nameEn = "name_en"
        case description
        case hitDice = "hit_dice"
        case hitDie = "hit_die"
        case primaryAbility = "primary_ability"
        case savingThrowProficiencies = "saving_throw_proficiencies"
        case skillChoices = "skill_choices"
        case skillOptions = "skill_options"
        case armorProficiencies = "armor_proficiencies"
        case weaponProficiencies = "weapon_proficiencies"
        case toolProficiencies = "tool_proficiencies"
        case startingEquipment = "starting_equipment"
        case startingGold = "starting_gold"
        case spellcasting
        case levelFeatures = "level_features"
        case subclasses
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        nameRu = try container.decode(String.self, forKey: .nameRu)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        hitDice = try container.decodeIfPresent(String.self, forKey: .hitDice)
        hitDie = try container.decodeIfPresent(Int.self, forKey: .hitDie)
        primaryAbility = try container.decodeIfPresent([String].self, forKey: .primaryAbility)
        savingThrowProficiencies = try container.decodeIfPresent([String].self, forKey: .savingThrowProficiencies)
        skillChoices = try container.decodeIfPresent(SkillChoicesData.self, forKey: .skillChoices)
        skillOptions = try container.decodeIfPresent([String].self, forKey: .skillOptions)
        armorProficiencies = try container.decodeIfPresent([String].self, forKey: .armorProficiencies)
        weaponProficiencies = try container.decodeIfPresent([String].self, forKey: .weaponProficiencies)
        toolProficiencies = try container.decodeIfPresent([String].self, forKey: .toolProficiencies)
        startingEquipment = try container.decodeIfPresent(StartingEquipmentData.self, forKey: .startingEquipment)
        startingGold = try container.decodeIfPresent(String.self, forKey: .startingGold)
        spellcasting = try container.decodeIfPresent(SpellcastingData.self, forKey: .spellcasting)
        levelFeatures = try container.decodeIfPresent([LevelFeature].self, forKey: .levelFeatures)
        subclasses = try container.decodeIfPresent([DnDSubclass].self, forKey: .subclasses)
    }
    
    // Получаем названия подклассов
    var subclassNames: [String] {
        return subclasses?.map { $0.nameRu } ?? []
    }
    
    // Получаем hit dice в удобном формате
    var hitDiceString: String {
        if let hitDice = hitDice {
            return hitDice
        } else if let hitDie = hitDie {
            return "1к\(hitDie)"
        } else {
            return "1к8" // Значение по умолчанию
        }
    }
}

// Универсальная структура для skill_choices
struct SkillChoicesData: Codable {
    let count: Int
    let options: [String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Пытаемся декодировать как число
        if let count = try? container.decode(Int.self) {
            self.count = count
            self.options = nil
            return
        }
        
        // Пытаемся декодировать как объект
        let objectContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try objectContainer.decode(Int.self, forKey: .count)
        self.options = try objectContainer.decodeIfPresent([String].self, forKey: .options)
    }
    
    func encode(to encoder: Encoder) throws {
        if let options = options {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(count, forKey: .count)
            try container.encodeIfPresent(options, forKey: .options)
        } else {
            var container = encoder.singleValueContainer()
            try container.encode(count)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case count
        case options
    }
}

// Структура для spellcasting
struct SpellcastingData: Codable {
    let ability: String
    let spellSaveDc: String
    let spellAttackBonus: String
    
    enum CodingKeys: String, CodingKey {
        case ability
        case spellSaveDc = "spell_save_dc"
        case spellAttackBonus = "spell_attack_bonus"
    }
}

// Универсальная структура для starting_equipment
struct StartingEquipmentData: Codable {
    let optionA: [String]?
    let optionB: [String]?
    let armor: String?
    let weapons: [String]?
    let pack: String?
    let other: [String]?
    let items: [String]? // Для простого массива строк
    
    enum CodingKeys: String, CodingKey {
        case optionA = "option_a"
        case optionB = "option_b"
        case armor
        case weapons
        case pack
        case other
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Пытаемся декодировать как массив строк
        if let items = try? container.decode([String].self) {
            self.items = items
            self.optionA = nil
            self.optionB = nil
            self.armor = nil
            self.weapons = nil
            self.pack = nil
            self.other = nil
            return
        }
        
        // Пытаемся декодировать как объект
        let objectContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.optionA = try objectContainer.decodeIfPresent([String].self, forKey: .optionA)
        self.optionB = try objectContainer.decodeIfPresent([String].self, forKey: .optionB)
        self.armor = try objectContainer.decodeIfPresent(String.self, forKey: .armor)
        self.weapons = try objectContainer.decodeIfPresent([String].self, forKey: .weapons)
        self.pack = try objectContainer.decodeIfPresent(String.self, forKey: .pack)
        self.other = try objectContainer.decodeIfPresent([String].self, forKey: .other)
        self.items = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let items = items {
            try container.encode(items)
        } else {
            var objectContainer = encoder.container(keyedBy: CodingKeys.self)
            try objectContainer.encodeIfPresent(optionA, forKey: .optionA)
            try objectContainer.encodeIfPresent(optionB, forKey: .optionB)
            try objectContainer.encodeIfPresent(armor, forKey: .armor)
            try objectContainer.encodeIfPresent(weapons, forKey: .weapons)
            try objectContainer.encodeIfPresent(pack, forKey: .pack)
            try objectContainer.encodeIfPresent(other, forKey: .other)
        }
    }
    
    // Получаем все предметы в удобном формате
    var allItems: [String] {
        var result: [String] = []
        
        if let items = items {
            result.append(contentsOf: items)
        } else {
            if let optionA = optionA {
                result.append(contentsOf: optionA)
            }
            if let optionB = optionB {
                result.append(contentsOf: optionB)
            }
            if let armor = armor {
                result.append(armor)
            }
            if let weapons = weapons {
                result.append(contentsOf: weapons)
            }
            if let pack = pack {
                result.append(pack)
            }
            if let other = other {
                result.append(contentsOf: other)
            }
        }
        
        return result
    }
}

struct LevelFeature: Codable {
    let level: Int
    let proficiencyBonus: Int?
    let features: [ClassFeature]?
    
    // Поля для умений, которые находятся прямо в объекте уровня
    let name: String?
    let description: String?
    
    // Дополнительные поля для разных классов (опциональные)
    let rages: Int?
    let rageDamage: Int?
    let weaponMastery: Int?
    let weaponMasteryCount: Int?
    let cantripsKnown: Int?
    let spellsKnown: Int?
    let spellsPrepared: Int?
    let spellSlots: [Int]?
    let bardicInspirationDie: String?
    let kiPoints: Int?
    let martialArtsDie: String?
    let channelDivinity: Int?
    let layOnHandsPool: Int?
    let wildShapeUses: Int?
    let sorceryPoints: Int?
    let warlockSpellSlots: Int?
    let warlockSpellLevel: Int?
    let invocationsKnown: Int?
    let wizardSpellSlots: [Int]?
    let wizardSpellsKnown: Int?
    let secondWindUses: Int?
    
    enum CodingKeys: String, CodingKey {
        case level
        case proficiencyBonus = "proficiency_bonus"
        case features
        case name
        case description
        case rages
        case rageDamage = "rage_damage"
        case weaponMastery = "weapon_mastery"
        case weaponMasteryCount = "weapon_mastery_count"
        case cantripsKnown = "cantrips_known"
        case spellsKnown = "spells_known"
        case spellsPrepared = "spells_prepared"
        case spellSlots = "spell_slots"
        case bardicInspirationDie = "bardic_inspiration_die"
        case kiPoints = "ki_points"
        case martialArtsDie = "martial_arts_die"
        case channelDivinity = "channel_divinity"
        case layOnHandsPool = "lay_on_hands_pool"
        case wildShapeUses = "wild_shape_uses"
        case sorceryPoints = "sorcery_points"
        case warlockSpellSlots = "warlock_spell_slots"
        case warlockSpellLevel = "warlock_spell_level"
        case invocationsKnown = "invocations_known"
        case wizardSpellSlots = "wizard_spell_slots"
        case wizardSpellsKnown = "wizard_spells_known"
        case secondWindUses = "second_wind_uses"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        level = try container.decode(Int.self, forKey: .level)
        proficiencyBonus = try container.decodeIfPresent(Int.self, forKey: .proficiencyBonus)
        features = try container.decodeIfPresent([ClassFeature].self, forKey: .features)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        
        // Декодируем числовые поля с поддержкой строк
        rages = try LevelFeature.decodeIntOrString(from: container, forKey: .rages)
        rageDamage = try LevelFeature.decodeIntOrString(from: container, forKey: .rageDamage)
        weaponMastery = try LevelFeature.decodeIntOrString(from: container, forKey: .weaponMastery)
        weaponMasteryCount = try LevelFeature.decodeIntOrString(from: container, forKey: .weaponMasteryCount)
        cantripsKnown = try LevelFeature.decodeIntOrString(from: container, forKey: .cantripsKnown)
        spellsKnown = try LevelFeature.decodeIntOrString(from: container, forKey: .spellsKnown)
        spellsPrepared = try LevelFeature.decodeIntOrString(from: container, forKey: .spellsPrepared)
        kiPoints = try LevelFeature.decodeIntOrString(from: container, forKey: .kiPoints)
        channelDivinity = try LevelFeature.decodeIntOrString(from: container, forKey: .channelDivinity)
        layOnHandsPool = try LevelFeature.decodeIntOrString(from: container, forKey: .layOnHandsPool)
        wildShapeUses = try LevelFeature.decodeIntOrString(from: container, forKey: .wildShapeUses)
        sorceryPoints = try LevelFeature.decodeIntOrString(from: container, forKey: .sorceryPoints)
        warlockSpellSlots = try LevelFeature.decodeIntOrString(from: container, forKey: .warlockSpellSlots)
        warlockSpellLevel = try LevelFeature.decodeIntOrString(from: container, forKey: .warlockSpellLevel)
        invocationsKnown = try LevelFeature.decodeIntOrString(from: container, forKey: .invocationsKnown)
        wizardSpellsKnown = try LevelFeature.decodeIntOrString(from: container, forKey: .wizardSpellsKnown)
        secondWindUses = try LevelFeature.decodeIntOrString(from: container, forKey: .secondWindUses)
        
        // Строковые поля
        bardicInspirationDie = try container.decodeIfPresent(String.self, forKey: .bardicInspirationDie)
        martialArtsDie = try container.decodeIfPresent(String.self, forKey: .martialArtsDie)
        
        // Массивы
        spellSlots = try container.decodeIfPresent([Int].self, forKey: .spellSlots)
        wizardSpellSlots = try container.decodeIfPresent([Int].self, forKey: .wizardSpellSlots)
    }
    
    private static func decodeIntOrString(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Int? {
        // Сначала пробуем декодировать как Int
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        }
        
        // Если не получилось, пробуем как String и извлекаем число
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return Int(stringValue)
        }
        
        // Если ничего не получилось, возвращаем nil
        return nil
    }
}

struct SpellSlots: Codable {
    let cantripsKnown: Int?
    let spellsKnown: Int?
    let firstLevel: Int?
    let secondLevel: Int?
    let thirdLevel: Int?
    let fourthLevel: Int?
    let fifthLevel: Int?
    let sixthLevel: Int?
    let seventhLevel: Int?
    let eighthLevel: Int?
    let ninthLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case cantripsKnown = "cantrips_known"
        case spellsKnown = "spells_known"
        case firstLevel = "1st_level"
        case secondLevel = "2nd_level"
        case thirdLevel = "3rd_level"
        case fourthLevel = "4th_level"
        case fifthLevel = "5th_level"
        case sixthLevel = "6th_level"
        case seventhLevel = "7th_level"
        case eighthLevel = "8th_level"
        case ninthLevel = "9th_level"
    }
}

struct ClassFeature: Codable {
    let name: String
    let description: String
}

struct DnDSubclass: Codable, Identifiable {
    let id: String
    let nameRu: String
    let nameEn: String
    let description: String?
    let features: [SubclassFeature]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameRu = "name_ru"
        case nameEn = "name_en"
        case description
        case features
    }
}

struct SubclassFeature: Codable {
    let level: Int
    let name: String
    let description: String
}

struct DnDClassesData: Codable {
    let classes: [DnDClass]
}

// Модель для class_tables.json
struct ClassTable: Codable, Identifiable {
    let id = UUID()
    let className: String
    let slug: String
    let sourceUrl: String
    let columns: [String]
    let rows: [ClassTableRow]
    
    enum CodingKeys: String, CodingKey {
        case className = "class"
        case slug
        case sourceUrl = "source_url"
        case columns
        case rows
    }
}

struct ClassTableRow: Codable {
    let level: String
    let proficiencyBonus: String
    let classFeatures: String
    let additionalData: [String: String] // Для всех остальных колонок
    
    enum CodingKeys: String, CodingKey {
        case level = "Уровень"
        case proficiencyBonus = "Бонус владения"
        case classFeatures = "Классовые умения"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        level = try container.decode(String.self, forKey: .level)
        proficiencyBonus = try container.decode(String.self, forKey: .proficiencyBonus)
        classFeatures = try container.decode(String.self, forKey: .classFeatures)
        
        // Декодируем все остальные поля в additionalData
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        var additionalData: [String: String] = [:]
        
        for key in dynamicContainer.allKeys {
            if key.stringValue != "Уровень" && 
               key.stringValue != "Бонус владения" && 
               key.stringValue != "Классовые умения" {
                if let value = try? dynamicContainer.decode(String.self, forKey: key) {
                    additionalData[key.stringValue] = value
                }
            }
        }
        
        self.additionalData = additionalData
    }
}

struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

typealias ClassTablesData = [ClassTable]


// Расширение для работы с мировоззрениями
extension Character {
    var alignmentShort: String {
        switch alignment.lowercased() {
        case "законно-добрый", "законно добрый":
            return "ЗД"
        case "нейтрально-добрый", "нейтрально добрый":
            return "НД"
        case "хаотично-добрый", "хаотично добрый":
            return "ХД"
        case "законно-нейтральный", "законно нейтральный":
            return "ЗН"
        case "нейтральный":
            return "Н"
        case "хаотично-нейтральный", "хаотично нейтральный":
            return "ХН"
        case "законно-злой", "законно злой":
            return "ЗЗ"
        case "нейтрально-злой", "нейтрально злой":
            return "НЗ"
        case "хаотично-злой", "хаотично злой":
            return "ХЗ"
        default:
            return alignment
        }
    }
}



