import Foundation

struct Background: Codable, Identifiable {
    let id = UUID()
    let название: String
    let характеристики: String
    let черта: String
    let навыки: String
    let инструменты: String
    let снаряжение: String
    let описание: String
    
    var isFavorite: Bool = false
    var characterId: UUID? = nil
    
    // Computed property for name compatibility
    var name: String {
        return название
    }
    
    enum CodingKeys: String, CodingKey {
        case название = "Название"
        case характеристики = "Характеристики"
        case черта = "Черта"
        case навыки = "Навыки"
        case инструменты = "Инструменты"
        case снаряжение = "Снаряжение"
        case описание = "Описание"
    }
}

typealias BackgroundsData = [Background]
