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
    
    init(title: String, description: String = "", importance: Int = 3, category: NoteCategory = .all, isAlive: Bool = true) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.importance = importance
        self.category = category
        self.isAlive = isAlive
        self.dateCreated = Date()
        self.dateModified = Date()
    }
}

enum NoteCategory: String, CaseIterable, Codable {
    case all = "Все"
    case places = "Места"
    case people = "Люди"
    case enemies = "Враги"
    case items = "Вещи"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .places: return "mappin"
        case .people: return "person.2"
        case .enemies: return "exclamationmark.triangle"
        case .items: return "cube.box"
        }
    }
    
    var color: String {
        switch self {
        case .all: return "gray"
        case .places: return "blue"
        case .people: return "green"
        case .enemies: return "red"
        case .items: return "orange"
        }
    }
}
