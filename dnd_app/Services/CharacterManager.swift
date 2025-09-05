import Foundation
import SwiftUI

class CharacterManager: ObservableObject {
    @Published var characters: [Character] = []
    @Published var selectedCharacter: Character?
    
    private let userDefaults = UserDefaults.standard
    private let charactersKey = "saved_characters"
    private let selectedCharacterKey = "selected_character_id"
    
    init() {
        loadCharacters()
        loadSelectedCharacter()
    }
    
    // MARK: - Character Management
    
    func addCharacter(_ character: Character) {
        characters.append(character)
        saveCharacters()
    }
    
    func updateCharacter(_ character: Character) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index] = character
            saveCharacters()
            
            // Обновляем выбранного персонажа, если это он
            if selectedCharacter?.id == character.id {
                selectedCharacter = character
            }
        }
    }
    
    func deleteCharacter(_ character: Character) {
        characters.removeAll { $0.id == character.id }
        saveCharacters()
        
        // Если удаляем выбранного персонажа, сбрасываем выбор
        if selectedCharacter?.id == character.id {
            selectedCharacter = nil
            saveSelectedCharacter()
        }
    }
    
    func selectCharacter(_ character: Character) {
        selectedCharacter = character
        saveSelectedCharacter()
    }
    
    func deselectCharacter() {
        selectedCharacter = nil
        saveSelectedCharacter()
    }
    
    // MARK: - Persistence
    
    private func saveCharacters() {
        if let encoded = try? JSONEncoder().encode(characters) {
            userDefaults.set(encoded, forKey: charactersKey)
        }
    }
    
    private func loadCharacters() {
        if let data = userDefaults.data(forKey: charactersKey),
           let decoded = try? JSONDecoder().decode([Character].self, from: data) {
            characters = decoded
        } else {
            // Создаем персонажа по умолчанию, если нет сохраненных
            createDefaultCharacter()
        }
    }
    
    private func saveSelectedCharacter() {
        if let selectedCharacter = selectedCharacter {
            userDefaults.set(selectedCharacter.id.uuidString, forKey: selectedCharacterKey)
        } else {
            userDefaults.removeObject(forKey: selectedCharacterKey)
        }
    }
    
    private func loadSelectedCharacter() {
        if let selectedIdString = userDefaults.string(forKey: selectedCharacterKey),
           let selectedId = UUID(uuidString: selectedIdString) {
            selectedCharacter = characters.first { $0.id == selectedId }
        }
    }
    
    // MARK: - Default Character
    
    private func createDefaultCharacter() {
        let defaultCharacter = Character(
            name: "Абоба",
            race: "Человек",
            characterClass: "Монах",
            background: "Чужеземец",
            alignment: "Хаотично-нейтральный",
            level: 8
        )
        
        // Устанавливаем характеристики согласно изображению
        var character = defaultCharacter
        character.strength = 17
        character.dexterity = 18
        character.constitution = 18
        character.intelligence = 12
        character.wisdom = 14
        character.charisma = 16
        character.armorClass = 15
        character.initiative = 4
        character.speed = 30
        character.hitPoints = 22
        character.maxHitPoints = 22
        character.proficiencyBonus = 3
        
        characters.append(character)
        selectedCharacter = character
        saveCharacters()
        saveSelectedCharacter()
    }
    
    // MARK: - Import/Export
    
    func exportCharacter(_ character: Character) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(character)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Ошибка экспорта персонажа: \(error)")
            return nil
        }
    }
    
    func importCharacter(from jsonString: String) -> Character? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let character = try decoder.decode(Character.self, from: data)
            // Создаем новый персонаж с новым ID для импорта
            let importedCharacter = Character(
                name: character.name,
                race: character.race,
                characterClass: character.characterClass,
                background: character.background,
                alignment: character.alignment,
                level: character.level
            )
            // Копируем остальные свойства
            var newCharacter = importedCharacter
            newCharacter.subclass = character.subclass
            newCharacter.strength = character.strength
            newCharacter.dexterity = character.dexterity
            newCharacter.constitution = character.constitution
            newCharacter.intelligence = character.intelligence
            newCharacter.wisdom = character.wisdom
            newCharacter.charisma = character.charisma
            newCharacter.armorClass = character.armorClass
            newCharacter.initiative = character.initiative
            newCharacter.speed = character.speed
            newCharacter.hitPoints = character.hitPoints
            newCharacter.maxHitPoints = character.maxHitPoints
            newCharacter.proficiencyBonus = character.proficiencyBonus
            newCharacter.skills = character.skills
            newCharacter.classAbilities = character.classAbilities
            newCharacter.equipment = character.equipment
            newCharacter.treasures = character.treasures
            newCharacter.personalityTraits = character.personalityTraits
            newCharacter.ideals = character.ideals
            newCharacter.bonds = character.bonds
            newCharacter.flaws = character.flaws
            newCharacter.features = character.features
            newCharacter.dateCreated = Date()
            newCharacter.dateModified = Date()
            return newCharacter
        } catch {
            print("Ошибка импорта персонажа: \(error)")
            return nil
        }
    }
    
    func importCharacter(from data: Data) -> Character? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let character = try decoder.decode(Character.self, from: data)
            // Создаем новый персонаж с новым ID для импорта
            let importedCharacter = Character(
                name: character.name,
                race: character.race,
                characterClass: character.characterClass,
                background: character.background,
                alignment: character.alignment,
                level: character.level
            )
            // Копируем остальные свойства
            var newCharacter = importedCharacter
            newCharacter.subclass = character.subclass
            newCharacter.strength = character.strength
            newCharacter.dexterity = character.dexterity
            newCharacter.constitution = character.constitution
            newCharacter.intelligence = character.intelligence
            newCharacter.wisdom = character.wisdom
            newCharacter.charisma = character.charisma
            newCharacter.armorClass = character.armorClass
            newCharacter.initiative = character.initiative
            newCharacter.speed = character.speed
            newCharacter.hitPoints = character.hitPoints
            newCharacter.maxHitPoints = character.maxHitPoints
            newCharacter.proficiencyBonus = character.proficiencyBonus
            newCharacter.skills = character.skills
            newCharacter.classAbilities = character.classAbilities
            newCharacter.equipment = character.equipment
            newCharacter.treasures = character.treasures
            newCharacter.personalityTraits = character.personalityTraits
            newCharacter.ideals = character.ideals
            newCharacter.bonds = character.bonds
            newCharacter.flaws = character.flaws
            newCharacter.features = character.features
            newCharacter.dateCreated = Date()
            newCharacter.dateModified = Date()
            return newCharacter
        } catch {
            print("Ошибка импорта персонажа: \(error)")
            return nil
        }
    }
    
    // Импорт из внешнего формата (как в JSON файле)
    func importExternalCharacter(from jsonString: String) -> Character? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let externalCharacter: ExternalCharacter = try decoder.decode(ExternalCharacter.self, from: data)
            
            // Парсим внутренние данные
            guard let characterData = externalCharacter.data.data(using: String.Encoding.utf8) else { return nil }
            let characterDataObj: ExternalCharacterData = try decoder.decode(ExternalCharacterData.self, from: characterData)
            
            // Создаем персонаж из внешних данных
            let character = Character(
                name: characterDataObj.name.value,
                race: characterDataObj.info.race.value,
                characterClass: characterDataObj.info.charClass.value,
                background: characterDataObj.info.background.value,
                alignment: characterDataObj.info.alignment.value,
                level: characterDataObj.info.level.value
            )
            
            // Обновляем дополнительные свойства
            var newCharacter = character
            newCharacter.subclass = characterDataObj.info.charSubclass.value.isEmpty ? nil : characterDataObj.info.charSubclass.value
            newCharacter.strength = characterDataObj.stats.str.score
            newCharacter.dexterity = characterDataObj.stats.dex.score
            newCharacter.constitution = characterDataObj.stats.con.score
            newCharacter.intelligence = characterDataObj.stats.int.score
            newCharacter.wisdom = characterDataObj.stats.wis.score
            newCharacter.charisma = characterDataObj.stats.cha.score
            newCharacter.armorClass = characterDataObj.vitality.ac.value
            newCharacter.speed = Int(characterDataObj.vitality.speed.value) ?? 30
            newCharacter.maxHitPoints = characterDataObj.vitality.hpMax.value
            newCharacter.hitPoints = characterDataObj.vitality.hpMax.value // Текущие хиты = максимальные при импорте
            newCharacter.proficiencyBonus = characterDataObj.proficiency
            
            // Извлекаем текстовые поля
            newCharacter.personalityTraits = extractTextFromExternalData(characterDataObj.text.personality.value.data.content)
            newCharacter.ideals = extractTextFromExternalData(characterDataObj.text.ideals.value.data.content)
            newCharacter.bonds = extractTextFromExternalData(characterDataObj.text.bonds.value.data.content)
            newCharacter.flaws = extractTextFromExternalData(characterDataObj.text.flaws.value.data.content)
            
            newCharacter.dateCreated = Date()
            newCharacter.dateModified = Date()
            
            return newCharacter
        } catch {
            print("Ошибка импорта внешнего персонажа: \(error)")
            return nil
        }
    }
    
    func importExternalCharacter(from data: Data) -> Character? {
        guard let jsonString = String(data: data, encoding: .utf8) else { return nil }
        return importExternalCharacter(from: jsonString)
    }
    
    // Вспомогательная функция для извлечения текста из внешних данных
    private func extractTextFromExternalData(_ content: [ExternalTextNode]) -> String {
        var result = ""
        for node in content {
            if let text = node.text {
                result += text
            }
            if let subContent = node.content {
                // Extract ExternalTextNode arrays from ExternalTextContent
                for contentItem in subContent {
                    result += extractTextFromExternalData(contentItem.content)
                }
            }
        }
        return result
    }
    
    // MARK: - Statistics
    
    var totalCharacters: Int {
        return characters.count
    }
    
    var charactersByClass: [String: Int] {
        var counts: [String: Int] = [:]
        for character in characters {
            counts[character.characterClass, default: 0] += 1
        }
        return counts
    }
    
    var charactersByRace: [String: Int] {
        var counts: [String: Int] = [:]
        for character in characters {
            counts[character.race, default: 0] += 1
        }
        return counts
    }
}
