import Foundation

// Новая модель для classes.json
struct DnDClass: Codable, Identifiable {
    let id = UUID()
    let nameRu: String
    let nameEn: String
    let hitDice: String
    let proficiencies: Proficiencies
    let equipment: Equipment
    let levelProgression: [LevelProgression]
    let subclasses: [DnDSubclass]
    
    enum CodingKeys: String, CodingKey {
        case nameRu = "name_ru"
        case nameEn = "name_en"
        case hitDice = "hit_dice"
        case proficiencies
        case equipment
        case levelProgression = "level_progression"
        case subclasses
    }
    
    // Получаем названия подклассов
    var subclassNames: [String] {
        return subclasses.map { $0.nameRu }
    }
}

struct Proficiencies: Codable {
    let savingThrows: [String]
    let skills: String
    let weapons: [String]
    let armor: [String]
    
    enum CodingKeys: String, CodingKey {
        case savingThrows = "saving_throws"
        case skills
        case weapons
        case armor
    }
}

struct Equipment: Codable {
    let optionA: [String]
    let optionB: [String]
    
    enum CodingKeys: String, CodingKey {
        case optionA = "option_a"
        case optionB = "option_b"
    }
}

struct LevelProgression: Codable {
    let level: Int
    let proficiencyBonus: String
    let features: [ClassFeature]?
    
    // Дополнительные поля для разных классов (опциональные)
    let rages: Int?
    let rageDamage: String?
    let weaponMastery: Int?
    let spellSlots: SpellSlots?
    
    enum CodingKeys: String, CodingKey {
        case level
        case proficiencyBonus = "proficiency_bonus"
        case features
        case rages
        case rageDamage = "rage_damage"
        case weaponMastery = "weapon_mastery"
        case spellSlots = "spell_slots"
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
    let id = UUID()
    let nameRu: String
    let nameEn: String
    
    enum CodingKeys: String, CodingKey {
        case nameRu = "name_ru"
        case nameEn = "name_en"
    }
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



