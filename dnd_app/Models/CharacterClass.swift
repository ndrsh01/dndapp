import Foundation

struct CharacterClass: Codable, Identifiable {
    let id = UUID()
    let className: String
    let slug: String
    let sourceUrl: String
    let columns: [String]
    let rows: [ClassLevel]
    
    enum CodingKeys: String, CodingKey {
        case className = "class"
        case slug
        case sourceUrl = "source_url"
        case columns
        case rows
    }
    
    // Получаем подклассы для данного класса
    var subclasses: [String] {
        // Пока возвращаем базовые подклассы, позже можно расширить
        switch className.lowercased() {
        case "варвар":
            return ["Путь берсерка", "Путь тотема"]
        case "бард":
            return ["Колледж знаний", "Колледж доблести"]
        case "жрец":
            return ["Домен жизни", "Домен войны"]
        case "друид":
            return ["Круг луны", "Круг земли"]
        case "воин":
            return ["Боевой мастер", "Чемпион"]
        case "монах":
            return ["Путь тени", "Путь четырех стихий"]
        case "паладин":
            return ["Клятва преданности", "Клятва древних"]
        case "следопыт":
            return ["Звериный товарищ", "Охотник"]
        case "плут":
            return ["Вор", "Убийца"]
        case "чародей":
            return ["Дикая магия", "Божественная душа"]
        case "колдун":
            return ["Великий древний", "Небесный покровитель"]
        case "волшебник":
            return ["Школа иллюзий", "Школа некромантии"]
        default:
            return ["Нет подкласса"]
        }
    }
}

struct ClassLevel: Codable {
    let level: String
    let proficiencyBonus: String
    let classFeatures: String
    let specialFeatures: [String: String]
    
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
        
        // Остальные поля динамически
        var specialFeatures: [String: String] = [:]
        let allKeys = container.allKeys
        for key in allKeys {
            if key != .level && key != .proficiencyBonus && key != .classFeatures {
                if let value = try? container.decode(String.self, forKey: key) {
                    specialFeatures[key.stringValue] = value
                }
            }
        }
        self.specialFeatures = specialFeatures
    }
}

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

