import Foundation

struct Spell: Codable, Identifiable {
    let id = UUID()
    let название: String
    let времяСотворения: String
    let уровень: String
    let дистанция: String
    let компоненты: String
    let длительность: String
    let классы: String
    let подклассы: String
    let ритуал: Bool
    let школа: String
    let концентрация: Bool
    let описание: String
    let улучшения: String
    
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case название = "Название"
        case времяСотворения = "Время сотворения"
        case уровень = "Уровень"
        case дистанция = "Дистанция"
        case компоненты = "Компоненты"
        case длительность = "Длительность"
        case классы = "Классы"
        case подклассы = "Подклассы"
        case ритуал = "Ритуал"
        case школа = "Школа"
        case концентрация = "Концентрация"
        case описание = "Описание"
        case улучшения = "Улучшения"
    }
}

typealias SpellsData = [Spell]