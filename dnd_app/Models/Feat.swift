import Foundation

struct Feat: Codable, Identifiable {
    let id = UUID()
    let название: String
    let категория: String
    let требования: String
    let повышениеХарактеристики: String
    let описание: String
    
    var isFavorite: Bool = false
    var characterId: UUID? = nil
    
    // Computed property for name compatibility
    var name: String {
        return название
    }
    
    enum CodingKeys: String, CodingKey {
        case название = "Название"
        case категория = "Категория"
        case требования = "Требования"
        case повышениеХарактеристики = "Повышение характеристики"
        case описание = "Описание"
    }
}

typealias FeatsData = [Feat]
