import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    // MARK: - Published Properties
    @Published var quotes: QuotesData?
    @Published var spells: [Spell] = []
    @Published var feats: [Feat] = []
    @Published var backgrounds: [Background] = []
    @Published var relationships: [Relationship] = []
    @Published var notes: [Note] = []
    @Published var characters: [DnDCharacter] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys for UserDefaults
    private enum Keys {
        static let relationships = "relationships"
        static let notes = "notes"
        static let characters = "characters"
        static let selectedCharacter = "selectedCharacter"
        static let selectedQuoteCategory = "selectedQuoteCategory"
    }
    
    private init() {
        loadData()
        loadPersistedData()
    }
    
    // MARK: - Data Loading
    private func loadData() {
        loadQuotes()
        loadSpells()
        loadFeats()
        loadBackgrounds()
    }
    
    private func loadQuotes() {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quotesData = try? JSONDecoder().decode(QuotesData.self, from: data) else {
            print("Failed to load quotes.json")
            return
        }
        self.quotes = quotesData
    }
    
    private func loadSpells() {
        guard let url = Bundle.main.url(forResource: "spells", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let spellsData = try? JSONDecoder().decode([Spell].self, from: data) else {
            print("Failed to load spells.json")
            return
        }
        self.spells = spellsData
    }
    
    private func loadFeats() {
        guard let url = Bundle.main.url(forResource: "feats", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let featsData = try? JSONDecoder().decode([Feat].self, from: data) else {
            print("Failed to load feats.json")
            return
        }
        self.feats = featsData
    }
    
    private func loadBackgrounds() {
        guard let url = Bundle.main.url(forResource: "backgrounds", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let backgroundsData = try? JSONDecoder().decode([Background].self, from: data) else {
            print("Failed to load backgrounds.json")
            return
        }
        self.backgrounds = backgroundsData
    }
    
    // MARK: - Persistence
    private func loadPersistedData() {
        loadRelationships()
        loadNotes()
        loadCharacters()
    }
    
    private func loadRelationships() {
        if let data = userDefaults.data(forKey: Keys.relationships),
           let relationships = try? JSONDecoder().decode([Relationship].self, from: data) {
            self.relationships = relationships
        }
    }
    
    private func loadNotes() {
        if let data = userDefaults.data(forKey: Keys.notes),
           let notes = try? JSONDecoder().decode([Note].self, from: data) {
            self.notes = notes
        }
    }
    
    private func loadCharacters() {
        if let data = userDefaults.data(forKey: Keys.characters),
           let characters = try? JSONDecoder().decode([DnDCharacter].self, from: data) {
            self.characters = characters
        }
    }
    
    private func saveRelationships() {
        if let data = try? JSONEncoder().encode(relationships) {
            userDefaults.set(data, forKey: Keys.relationships)
        }
    }
    
    private func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            userDefaults.set(data, forKey: Keys.notes)
        }
    }
    
    private func saveCharacters() {
        if let data = try? JSONEncoder().encode(characters) {
            userDefaults.set(data, forKey: Keys.characters)
        }
    }
    
    // MARK: - Public Methods
    
    // MARK: - Quotes
    func getRandomQuote(from category: String) -> Quote? {
        return quotes?.randomQuote(from: category)
    }
    
    func getRandomTabaxiImage() -> String {
        return TabaxiImages.getRandomImageName()
    }
    
    // MARK: - Relationships
    func addRelationship(_ relationship: Relationship) {
        relationships.append(relationship)
        saveRelationships()
    }
    
    func updateRelationship(_ relationship: Relationship) {
        if let index = relationships.firstIndex(where: { $0.id == relationship.id }) {
            relationships[index] = relationship
            saveRelationships()
        }
    }
    
    func deleteRelationship(_ relationship: Relationship) {
        relationships.removeAll { $0.id == relationship.id }
        saveRelationships()
    }
    
    func duplicateRelationship(_ relationship: Relationship) {
        var newRelationship = relationship
        newRelationship.name = "\(relationship.name) (копия)"
        newRelationship.dateCreated = Date()
        newRelationship.dateModified = Date()
        addRelationship(newRelationship)
    }
    
    // MARK: - Notes
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    func duplicateNote(_ note: Note) {
        var newNote = note
        newNote.title = "\(note.title) (копия)"
        newNote.dateCreated = Date()
        newNote.dateModified = Date()
        addNote(newNote)
    }
    
    // MARK: - Characters
    func addCharacter(_ character: DnDCharacter) {
        characters.append(character)
        saveCharacters()
    }
    
    func updateCharacter(_ character: DnDCharacter) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index] = character
            saveCharacters()
        }
    }
    
    func deleteCharacter(_ character: DnDCharacter) {
        characters.removeAll { $0.id == character.id }
        saveCharacters()
    }
    
    func duplicateCharacter(_ character: DnDCharacter) {
        var newCharacter = character
        newCharacter.name = "\(character.name) (копия)"
        newCharacter.dateCreated = Date()
        newCharacter.dateModified = Date()
        addCharacter(newCharacter)
    }
    
    // MARK: - Favorites
    func toggleSpellFavorite(_ spell: Spell) {
        if let index = spells.firstIndex(where: { $0.id == spell.id }) {
            spells[index].isFavorite.toggle()
        }
    }
    
    func toggleFeatFavorite(_ feat: Feat) {
        if let index = feats.firstIndex(where: { $0.id == feat.id }) {
            feats[index].isFavorite.toggle()
        }
    }
    
    func toggleBackgroundFavorite(_ background: Background) {
        if let index = backgrounds.firstIndex(where: { $0.id == background.id }) {
            backgrounds[index].isFavorite.toggle()
        }
    }
    
    // MARK: - Session Management
    func getSelectedCharacter() -> DnDCharacter? {
        guard let characterId = userDefaults.string(forKey: Keys.selectedCharacter),
              let character = characters.first(where: { $0.id.uuidString == characterId }) else {
            return characters.first
        }
        return character
    }
    
    func setSelectedCharacter(_ character: DnDCharacter) {
        userDefaults.set(character.id.uuidString, forKey: Keys.selectedCharacter)
    }
    
    func getSelectedQuoteCategory() -> String {
        return userDefaults.string(forKey: Keys.selectedQuoteCategory) ?? "общение"
    }
    
    func setSelectedQuoteCategory(_ category: String) {
        userDefaults.set(category, forKey: Keys.selectedQuoteCategory)
    }
    
    // MARK: - Quote Category Management
    func addQuoteCategory(_ name: String) {
        guard var quotesData = quotes else { return }
        
        // Создаем новую категорию с пустым массивом цитат
        var newCategories = quotesData.categories
        newCategories[name] = []
        
        // Создаем новый объект QuotesData с обновленными категориями
        let updatedQuotesData = QuotesData(categories: newCategories)
        
        // Сохраняем обновленные данные
        saveQuotesData(updatedQuotesData)
    }
    
    func deleteQuoteCategory(_ name: String) {
        guard var quotesData = quotes else { return }
        
        // Удаляем категорию
        var newCategories = quotesData.categories
        newCategories.removeValue(forKey: name)
        
        // Создаем новый объект QuotesData с обновленными категориями
        let updatedQuotesData = QuotesData(categories: newCategories)
        
        // Сохраняем обновленные данные
        saveQuotesData(updatedQuotesData)
    }
    
    func renameQuoteCategory(from oldName: String, to newName: String) {
        guard var quotesData = quotes else { return }
        
        // Получаем цитаты из старой категории
        if let quotes = quotesData.categories[oldName] {
            var newCategories = quotesData.categories
            
            // Создаем новую категорию с теми же цитатами
            newCategories[newName] = quotes
            // Удаляем старую категорию
            newCategories.removeValue(forKey: oldName)
            
            // Создаем новый объект QuotesData с обновленными категориями
            let updatedQuotesData = QuotesData(categories: newCategories)
            
            // Сохраняем обновленные данные
            saveQuotesData(updatedQuotesData)
        }
    }
    
    func duplicateQuoteCategory(from sourceName: String, to newName: String) {
        guard var quotesData = quotes else { return }
        
        // Получаем цитаты из исходной категории
        if let sourceQuotes = quotesData.categories[sourceName] {
            var newCategories = quotesData.categories
            
            // Добавляем новую категорию с копированными цитатами
            newCategories[newName] = sourceQuotes
            
            // Создаем новый объект QuotesData с обновленными категориями
            let updatedQuotesData = QuotesData(categories: newCategories)
            
            // Сохраняем обновленные данные
            saveQuotesData(updatedQuotesData)
        }
    }
    
    private func saveQuotesData(_ quotesData: QuotesData) {
        // Обновляем локальную копию
        self.quotes = quotesData
        
        // Сохраняем в UserDefaults (если нужно)
        // Здесь можно добавить сохранение в файл или базу данных
    }
}
