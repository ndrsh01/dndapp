import Foundation
import SwiftUI

class CharacterViewModel: ObservableObject {
    @Published var character: Character
    
    init(character: Character) {
        self.character = character
    }
    
    func updateCharacter(_ updatedCharacter: Character) {
        character = updatedCharacter
        character.dateModified = Date()
    }
    
    func updateHitPoints(_ newHitPoints: Int) {
        character.hitPoints = max(0, min(newHitPoints, character.maxHitPoints))
        character.dateModified = Date()
    }
    
    func updateMaxHitPoints(_ newMaxHitPoints: Int) {
        character.maxHitPoints = max(1, newMaxHitPoints)
        if character.hitPoints > character.maxHitPoints {
            character.hitPoints = character.maxHitPoints
        }
        character.dateModified = Date()
    }
    
    func updateAbilityScore(ability: AbilityScore, newValue: Int) {
        let clampedValue = max(1, min(30, newValue))
        
        switch ability {
        case .strength:
            character.strength = clampedValue
        case .dexterity:
            character.dexterity = clampedValue
        case .constitution:
            character.constitution = clampedValue
        case .intelligence:
            character.intelligence = clampedValue
        case .wisdom:
            character.wisdom = clampedValue
        case .charisma:
            character.charisma = clampedValue
        }
        
        character.dateModified = Date()
    }
    
    func updateCombatStat(stat: CombatStat, newValue: Int) {
        switch stat {
        case .armorClass:
            character.armorClass = max(0, newValue)
        case .initiative:
            character.initiative = newValue
        case .speed:
            character.speed = max(0, newValue)
        case .proficiencyBonus:
            character.proficiencyBonus = max(0, newValue)
        case .inspiration:
            character.inspiration = newValue > 0
        }
        
        character.dateModified = Date()
    }
}

enum AbilityScore: String, CaseIterable {
    case strength = "СИЛ"
    case dexterity = "ЛОВ"
    case constitution = "ТЕЛ"
    case intelligence = "ИНТ"
    case wisdom = "МДР"
    case charisma = "ХАР"
    
    var fullName: String {
        switch self {
        case .strength: return "Сила"
        case .dexterity: return "Ловкость"
        case .constitution: return "Телосложение"
        case .intelligence: return "Интеллект"
        case .wisdom: return "Мудрость"
        case .charisma: return "Харизма"
        }
    }
    
    var icon: String {
        switch self {
        case .strength: return "figure.strengthtraining.traditional"
        case .dexterity: return "figure.run"
        case .constitution: return "heart.fill"
        case .intelligence: return "brain.head.profile"
        case .wisdom: return "eye.fill"
        case .charisma: return "person.2.fill"
        }
    }
    
    var iconName: String {
        return icon
    }
    
    var color: Color {
        switch self {
        case .strength: return .red
        case .dexterity: return .green
        case .constitution: return .orange
        case .intelligence: return .blue
        case .wisdom: return .purple
        case .charisma: return .pink
        }
    }
    
    var displayName: String {
        return fullName
    }
}

enum CombatStat: String, CaseIterable {
    case armorClass = "КЗ"
    case initiative = "Инициатива"
    case speed = "Скорость"
    case proficiencyBonus = "БМ"
    case inspiration = "Вдохновение"
    
    var fullName: String {
        switch self {
        case .armorClass: return "Класс брони"
        case .initiative: return "Инициатива"
        case .speed: return "Скорость"
        case .proficiencyBonus: return "Бонус мастерства"
        case .inspiration: return "Вдохновение"
        }
    }
    
    var icon: String {
        switch self {
        case .armorClass: return "shield.fill"
        case .initiative: return "bolt.fill"
        case .speed: return "figure.run"
        case .proficiencyBonus: return "star.fill"
        case .inspiration: return "sparkles"
        }
    }
    
    var iconName: String {
        return icon
    }
    
    var color: Color {
        switch self {
        case .armorClass: return .blue
        case .initiative: return .yellow
        case .speed: return .green
        case .proficiencyBonus: return .purple
        case .inspiration: return .orange
        }
    }
    
    var displayName: String {
        return fullName
    }
}