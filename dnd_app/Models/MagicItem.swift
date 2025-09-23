import Foundation
import SwiftUI

struct MagicItem: Codable, Identifiable, Hashable {
    let id: String
    let names: [Name]
    let rarity: String
    let type: String
    let descriptions: [String]
    let properties: [String]
    let tables: [Table]?
    let url: String?
    
    struct Name: Codable, Hashable {
        let name_ru: String
        let name_en: String
    }
    
    struct Table: Codable, Hashable {
        let title: String
        let headers: [String]
        let rows: [[String]]
    }
    
    var displayName: String {
        return names.first?.name_ru ?? "Неизвестный предмет"
    }
    
    // Извлекаем тип из properties (первый элемент обычно содержит тип)
    var extractedType: String {
        if let firstProperty = properties.first {
            // Разные паттерны:
            // 1. "Чудесный предмет, очень редкий"
            // 2. "Доспех (средний или тяжёлый, кроме шкурного), необычный"
            // 3. "Оружие (любое), необычное"
            // 4. "Чудесный предмет, артефакт (требуется настройка)"
            
            // Проверяем, что это не описание (длинный текст)
            if firstProperty.count > 100 {
                return type // Fallback к полю type из JSON
            }
            
            let components = firstProperty.components(separatedBy: ",")
            if components.count >= 2 {
                let typePart = components[0].trimmingCharacters(in: .whitespaces)
                
                // Если тип содержит скобки, извлекаем только основную часть
                if typePart.contains("(") {
                    let mainType = typePart.components(separatedBy: "(")[0].trimmingCharacters(in: .whitespaces)
                    return mainType
                }
                return typePart
            } else {
                // Если нет запятой, возможно это просто тип без редкости
                // Или редкость в скобках: "Чудесный предмет, артефакт (требуется настройка)"
                if firstProperty.contains("(") {
                    let mainType = firstProperty.components(separatedBy: "(")[0].trimmingCharacters(in: .whitespaces)
                    return mainType
                }
                return firstProperty
            }
        }
        return type // Fallback к полю type из JSON
    }
    
    // Извлекаем редкость из properties
    var extractedRarity: String {
        if let firstProperty = properties.first {
            // Проверяем, что это не описание (длинный текст)
            if firstProperty.count > 100 {
                return rarity // Fallback к полю rarity из JSON
            }
            
            let components = firstProperty.components(separatedBy: ",")
            
            if components.count >= 2 {
                // Паттерн: "тип, редкость"
                let rarityPart = components[1].trimmingCharacters(in: .whitespaces)
                return cleanRarity(rarityPart)
            } else {
                // Паттерн: "тип редкость (настройка)" - ищем редкость в скобках
                if firstProperty.contains("(") {
                    let parts = firstProperty.components(separatedBy: "(")
                    if parts.count >= 2 {
                        let beforeBracket = parts[0].trimmingCharacters(in: .whitespaces)
                        // Ищем редкость в части до скобки
                        let words = beforeBracket.components(separatedBy: " ")
                        for word in words {
                            if isRarity(word) {
                                return word
                            }
                        }
                    }
                }
                
                // Ищем редкость в самой строке
                let words = firstProperty.components(separatedBy: " ")
                for word in words {
                    if isRarity(word) {
                        return word
                    }
                }
            }
        }
        return rarity // Fallback к полю rarity из JSON
    }
    
    // Очищает редкость от лишних слов
    private func cleanRarity(_ rarity: String) -> String {
        let cleanRarity = rarity.components(separatedBy: "(")[0].trimmingCharacters(in: .whitespaces)
        return cleanRarity
    }
    
    // Проверяет, является ли слово редкостью
    private func isRarity(_ word: String) -> Bool {
        let rarities = ["обычный", "необычный", "редкий", "очень", "легендарный", "артефакт"]
        let cleanWord = word.lowercased().trimmingCharacters(in: .whitespaces)
        return rarities.contains(cleanWord)
    }
    
    // Извлекаем стоимость из properties
    var cost: String {
        let costProperty = properties.first { property in
            property.contains("стоимость") && 
            property.contains("зм") && 
            property.count <= 100 // Игнорируем длинные описания
        }
        if let cost = costProperty {
            // Извлекаем только стоимость, например "5 001-50 000 зм"
            let components = cost.components(separatedBy: ":")
            if components.count > 1 {
                return components[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return "Не указана"
    }
    
    // Извлекаем вес из properties
    var weight: String {
        let weightProperty = properties.first { property in
            property.contains("фунт") && 
            property.count <= 100 // Игнорируем длинные описания
        }
        if let weight = weightProperty {
            // Извлекаем только вес, например "25 фунтов"
            let words = weight.components(separatedBy: " ")
            for (index, word) in words.enumerated() {
                if word.contains("фунт") && index > 0 {
                    return "\(words[index-1]) \(word)"
                }
            }
        }
        return "Не указан"
    }
    
    var rarityColor: Color {
        switch extractedRarity {
        case "Обычный":
            return Color(.systemGray)
        case "Необычный":
            return Color(.systemGreen)
        case "Редкий":
            return Color(.systemBlue)
        case "Очень редкий":
            return Color(.systemPurple)
        case "Легендарный":
            return Color(.systemOrange)
        case "Артефакт":
            return Color(.systemRed)
        default:
            return Color(.systemGray)
        }
    }
    
    var rarityIcon: String {
        switch extractedRarity {
        case "Обычный":
            return "circle.fill"
        case "Необычный":
            return "square.fill"
        case "Редкий":
            return "triangle.fill"
        case "Очень редкий":
            return "diamond.fill"
        case "Легендарный":
            return "star.fill"
        case "Артефакт":
            return "crown.fill"
        default:
            return "circle.fill"
        }
    }
}