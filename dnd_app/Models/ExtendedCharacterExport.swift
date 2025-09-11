import Foundation

// Расширенная структура для экспорта персонажа с дополнительными данными
struct ExtendedCharacterExport: Codable {
    let version: String // Версия формата экспорта
    let exportDate: Date
    
    // Основные данные персонажа
    let character: Character
    
    // Связанные данные
    let relationships: [Relationship]
    let notes: [Note]
    let favoriteSpells: [Spell]
    
    init(character: Character, relationships: [Relationship], notes: [Note], favoriteSpells: [Spell]) {
        self.version = "1.0"
        self.exportDate = Date()
        self.character = character
        self.relationships = relationships
        self.notes = notes
        self.favoriteSpells = favoriteSpells
    }
}
