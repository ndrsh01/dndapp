import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var importance: Int // 1-5
    var category: NoteCategory
    var isAlive: Bool
    var dateCreated: Date
    var dateModified: Date

    // Дополнительные поля для персонажей
    var race: String?
    var occupation: String?
    var organization: String?
    var age: String?
    var appearance: String?

    // Дополнительные поля для локаций
    var locationType: String?
    var population: String?
    var government: String?
    var climate: String?

    // Дополнительные поля для предметов
    var itemType: String?
    var rarity: String?
    var value: String?

    // Дополнительные поля для квестов
    var questType: String?
    var status: String?
    var reward: String?

    // Дополнительные поля для лора
    var loreType: String?
    var era: String?
    
    init(title: String, description: String = "", importance: Int = 3, category: NoteCategory = .all, isAlive: Bool = true,
         race: String? = nil, occupation: String? = nil, organization: String? = nil, age: String? = nil, appearance: String? = nil,
         locationType: String? = nil, population: String? = nil, government: String? = nil, climate: String? = nil,
         itemType: String? = nil, rarity: String? = nil, value: String? = nil,
         questType: String? = nil, status: String? = nil, reward: String? = nil,
         loreType: String? = nil, era: String? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.importance = importance
        self.category = category
        self.isAlive = isAlive
        self.dateCreated = Date()
        self.dateModified = Date()

        // Инициализация дополнительных полей
        self.race = race
        self.occupation = occupation
        self.organization = organization
        self.age = age
        self.appearance = appearance
        self.locationType = locationType
        self.population = population
        self.government = government
        self.climate = climate
        self.itemType = itemType
        self.rarity = rarity
        self.value = value
        self.questType = questType
        self.status = status
        self.reward = reward
        self.loreType = loreType
        self.era = era
    }
}

enum NoteCategory: String, CaseIterable, Codable {
    case all = "Все"
    case campaign = "Кампания"
    case characters = "Персонажи"
    case locations = "Локации"
    case quests = "Квесты"
    case lore = "Лор"
    case items = "Предметы"

    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .campaign: return "book.closed"
        case .characters: return "person.2"
        case .locations: return "map"
        case .quests: return "target"
        case .lore: return "scroll"
        case .items: return "cube.box"
        }
    }

    var color: String {
        switch self {
        case .all: return "gray"
        case .campaign: return "purple"
        case .characters: return "blue"
        case .locations: return "green"
        case .quests: return "orange"
        case .lore: return "red"
        case .items: return "indigo"
        }
    }
}
