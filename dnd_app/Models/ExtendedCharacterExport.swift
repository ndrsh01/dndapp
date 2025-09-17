import Foundation

// Расширенная структура для экспорта персонажа с дополнительными данными
struct ExtendedCharacterExport: Codable {
    let version: String // Версия формата экспорта
    let exportDate: Date?
    
    // Основные данные персонажа
    let character: Character?
    
    // Связанные данные
    let relationships: [Relationship]?
    let notes: [Note]?
    let favoriteSpells: [Spell]?
    
    init(character: Character, relationships: [Relationship], notes: [Note], favoriteSpells: [Spell]) {
        self.version = "1.0"
        self.exportDate = Date()
        self.character = character
        self.relationships = relationships
        self.notes = notes
        self.favoriteSpells = favoriteSpells
    }
    
    // Кастомный инициализатор для декодирования
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        version = try container.decode(String.self, forKey: .version)
        exportDate = try container.decodeIfPresent(Date.self, forKey: .exportDate)
        character = try container.decodeIfPresent(Character.self, forKey: .character)
        relationships = try container.decodeIfPresent([Relationship].self, forKey: .relationships)
        notes = try container.decodeIfPresent([Note].self, forKey: .notes)
        favoriteSpells = try container.decodeIfPresent([Spell].self, forKey: .favoriteSpells)
    }
    
    enum CodingKeys: String, CodingKey {
        case version, exportDate, character, relationships, notes, favoriteSpells
    }
}
