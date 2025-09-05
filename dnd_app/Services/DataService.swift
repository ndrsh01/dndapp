import Foundation
import Combine

// MARK: - DataService Errors
enum DataServiceError: Error, LocalizedError {
    case fileNotFound(String)
    case decodingError(String)
    case cacheError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Файл не найден: \(filename)"
        case .decodingError(let message):
            return "Ошибка декодирования: \(message)"
        case .cacheError(let message):
            return "Ошибка кэша: \(message)"
        }
    }
}

class DataService: ObservableObject {
    static let shared = DataService()
    
    // MARK: - Published Properties
    @Published var quotes: QuotesData?
    @Published var spells: [Spell] = []
    @Published var feats: [Feat] = []
    @Published var backgrounds: [Background] = []
    @Published var monsters: [Monster] = []
    @Published var relationships: [Relationship] = []
    @Published var notes: [Note] = []
    @Published var characters: [Character] = []
    @Published var dndClasses: [DnDClass] = []
    @Published var classTables: [ClassTable] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let cacheManager = CacheManager.shared
    
    // MARK: - Keys for UserDefaults
    private enum Keys {
        static let relationships = "relationships"
        static let notes = "notes"
        static let characters = "characters"
        static let selectedCharacter = "selectedCharacter"
        static let selectedQuoteCategory = "selectedQuoteCategory"
    }
    
    private init() {
        // Сначала загружаем персистентные данные
        loadPersistedData()
        
        // Затем синхронно загружаем критически важные данные
        loadQuotesSynchronously()
        loadSpellsSynchronously()
        loadFeatsSynchronously()
        loadBackgroundsSynchronously()
        loadMonstersSynchronously()
        loadDnDClasses()
        loadClassTables()
        
        // Затем асинхронно обновляем данные в фоне
        Task {
            await refreshDataInBackground()
        }
    }
    
    // MARK: - Background Data Refresh
    private func refreshDataInBackground() async {
        // Обновляем данные в фоне только если нужно
        await loadQuotes()
        await loadSpells()
        await loadFeats()
        await loadBackgrounds()
        await loadMonsters()
    }
    
    // MARK: - Cache Loading (синхронно)
    private func loadQuotesFromCache() {
        if let cachedQuotes = cacheManager.get(QuotesData.self, forKey: .quotes) {
            self.quotes = cachedQuotes
        }
    }

    private func loadQuotesSynchronously() {
        // Если данные уже загружены из кэша, используем их
        if quotes != nil {
            return
        }

        // Загружаем из bundle синхронно
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let quotesData = try? JSONDecoder().decode(QuotesData.self, from: data) {
            self.quotes = quotesData
            print("Quotes loaded synchronously from bundle")
        } else {
            print("Failed to load quotes synchronously from bundle")
        }

        // Загружаем пользовательские цитаты
        loadCustomQuotesData()
    }
    
    private func loadSpellsSynchronously() {
        if !spells.isEmpty {
            return
        }
        
        if let url = Bundle.main.url(forResource: "spells", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let spellsData = try? JSONDecoder().decode([Spell].self, from: data) {
            self.spells = spellsData
            print("Spells loaded synchronously: \(spellsData.count)")
        } else {
            print("Failed to load spells synchronously")
        }
    }
    
    private func loadFeatsSynchronously() {
        if !feats.isEmpty {
            return
        }
        
        if let url = Bundle.main.url(forResource: "feats", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let featsData = try? JSONDecoder().decode([Feat].self, from: data) {
            self.feats = featsData
            print("Feats loaded synchronously: \(featsData.count)")
        } else {
            print("Failed to load feats synchronously")
        }
    }
    
    private func loadBackgroundsSynchronously() {
        if !backgrounds.isEmpty {
            return
        }
        
        if let url = Bundle.main.url(forResource: "backgrounds", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let backgroundsData = try? JSONDecoder().decode([Background].self, from: data) {
            self.backgrounds = backgroundsData
            print("Backgrounds loaded synchronously: \(backgroundsData.count)")
        } else {
            print("Failed to load backgrounds synchronously")
        }
    }

    private func loadMonstersSynchronously() {
        print("=== STARTING MONSTER LOADING ===")

        // Если данные уже загружены, выходим
        if !monsters.isEmpty {
            print("Monsters already loaded: \(monsters.count) monsters")
            return
        }

        // Проверяем bundle
        print("Bundle path: \(Bundle.main.bundlePath)")
        print("Resource path: \(Bundle.main.resourcePath ?? "nil")")

        // Загружаем из bundle
        var url: URL?

        // Сначала пробуем найти в bundle
        url = Bundle.main.url(forResource: "bestiary_5e", withExtension: "ndjson")

        // Если не нашли в bundle, пробуем найти в исходной директории проекта
        if url == nil {
            print("Trying to find bestiary file in project directory...")
            let projectPath = "/Users/alexanderaferenok/Documents/GitHub/dnd_app/dnd_app/Sources/Resources/bestiary_5e.ndjson"
            if FileManager.default.fileExists(atPath: projectPath) {
                url = URL(fileURLWithPath: projectPath)
                print("Found bestiary file in project directory: \(projectPath)")
            }
        }

        guard let finalUrl = url else {
            print("ERROR: bestiary_5e.ndjson not found in bundle or project directory")
            // Попробуем найти все доступные ресурсы
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    print("Available resources: \(contents.filter { $0.contains("bestiary") || $0.contains("json") || $0.contains("ndjson") })")
                } catch {
                    print("ERROR: Cannot list bundle contents: \(error)")
                }
            }
            return
        }

        print("Found bestiary file at: \(finalUrl.path)")

        guard let data = try? Data(contentsOf: finalUrl) else {
            print("ERROR: Cannot read data from bestiary_5e.ndjson")
            return
        }

        print("File found, data size: \(data.count) bytes")

        // Парсим NDJSON
        guard let content = String(data: data, encoding: .utf8) else {
            print("ERROR: Cannot convert data to string")
            return
        }

        let lines = content.components(separatedBy: .newlines)
        print("Total lines in file: \(lines.count)")

        var monsters: [Monster] = []
        var successfulParses = 0
        var parseErrors = 0

        let decoder = JSONDecoder()

        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // Пропускаем пустые строки
            if trimmedLine.isEmpty {
                continue
            }

            guard let lineData = trimmedLine.data(using: .utf8) else {
                parseErrors += 1
                if parseErrors <= 3 {
                    print("ERROR: Cannot convert line \(index) to data")
                }
                continue
            }

            do {
                let monster = try decoder.decode(Monster.self, from: lineData)
                monsters.append(monster)
                successfulParses += 1

                if successfulParses <= 5 {
                    print("✓ Successfully parsed monster: \(monster.name)")
                }
            } catch {
                parseErrors += 1
                if parseErrors <= 5 {
                    print("✗ Failed to parse monster at line \(index): \(error.localizedDescription)")
                    if index < 10 {
                        print("   Problematic line: \(trimmedLine.prefix(100))...")
                    }
                }
            }
        }

        // Сортируем по имени
        monsters.sort { $0.name < $1.name }

        // Сохраняем результат
        self.monsters = monsters

        print("=== MONSTER LOADING COMPLETE ===")
        print("Successfully loaded: \(successfulParses) monsters")
        print("Parse errors: \(parseErrors)")
        print("Total monsters in array: \(monsters.count)")

        if monsters.isEmpty {
            print("WARNING: No monsters were loaded!")
        } else {
            print("Sample monsters:")
            for i in 0..<min(3, monsters.count) {
                print("  - \(monsters[i].name)")
            }
        }
    }
    
    private func loadSpellsFromCache() {
        if let cachedSpells = cacheManager.get([Spell].self, forKey: .spells) {
            self.spells = cachedSpells
        }
    }
    
    private func loadFeatsFromCache() {
        if let cachedFeats = cacheManager.get([Feat].self, forKey: .feats) {
            self.feats = cachedFeats
        }
    }
    
    private func loadBackgroundsFromCache() {
        if let cachedBackgrounds = cacheManager.get([Background].self, forKey: .backgrounds) {
            self.backgrounds = cachedBackgrounds
        }
    }

    private func loadMonstersFromCache() {
        if let cachedMonsters = cacheManager.get([Monster].self, forKey: .monsters) {
            self.monsters = cachedMonsters
            print("Loaded \(cachedMonsters.count) monsters from cache")
        } else {
            print("No cached monsters found")
        }
    }

    func loadQuotes() async {
        do {
            let quotesData = try await cacheManager.loadWithCache(
                QuotesData.self,
                forKey: .quotes
            ) {
                guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
                      let data = try? Data(contentsOf: url) else {
                    throw DataServiceError.fileNotFound("quotes.json")
                }
                return try JSONDecoder().decode(QuotesData.self, from: data)
            }
            
            await MainActor.run {
                self.quotes = quotesData
                // После загрузки стандартных цитат, загружаем пользовательские
                self.loadCustomQuotesData()
            }
        } catch {
            print("Failed to load quotes: \(error)")
        }
    }
    
    func loadSpells() async {
        do {
            let spellsData = try await cacheManager.loadWithCache(
                [Spell].self,
                forKey: .spells
            ) {
                guard let url = Bundle.main.url(forResource: "spells", withExtension: "json"),
                      let data = try? Data(contentsOf: url) else {
                    throw DataServiceError.fileNotFound("spells.json")
                }
                return try JSONDecoder().decode([Spell].self, from: data)
            }
            
            await MainActor.run {
                self.spells = spellsData
            }
        } catch {
            print("Failed to load spells: \(error)")
        }
    }
    
    func loadFeats() async {
        do {
            let featsData = try await cacheManager.loadWithCache(
                [Feat].self,
                forKey: .feats
            ) {
                guard let url = Bundle.main.url(forResource: "feats", withExtension: "json"),
                      let data = try? Data(contentsOf: url) else {
                    throw DataServiceError.fileNotFound("feats.json")
                }
                return try JSONDecoder().decode([Feat].self, from: data)
            }
            
            await MainActor.run {
                self.feats = featsData
            }
        } catch {
            print("Failed to load feats: \(error)")
        }
    }
    
    func loadBackgrounds() async {
        do {
            let backgroundsData = try await cacheManager.loadWithCache(
                [Background].self,
                forKey: .backgrounds
            ) {
                guard let url = Bundle.main.url(forResource: "backgrounds", withExtension: "json"),
                      let data = try? Data(contentsOf: url) else {
                    throw DataServiceError.fileNotFound("backgrounds.json")
                }
                return try JSONDecoder().decode([Background].self, from: data)
            }
            
            await MainActor.run {
                self.backgrounds = backgroundsData
            }
        } catch {
            print("Failed to load backgrounds: \(error)")
        }
    }
    
    func loadMonsters() async {
        // Если монстры уже загружены, не загружаем снова
        if !monsters.isEmpty {
            print("Monsters already loaded (\(monsters.count)), skipping async load")
            return
        }

        do {
            print("=== STARTING MONSTERS LOAD ===")
            print("Current monsters count: \(monsters.count)")
            let monstersData = try await cacheManager.loadWithCache(
                [Monster].self,
                forKey: .monsters
            ) {
                print("Loading monsters from file async...")
                print("Bundle path: \(Bundle.main.bundlePath)")
                print("Resource path: \(Bundle.main.resourcePath ?? "nil")")

                var url: URL?

                // Сначала пробуем найти в bundle
                url = Bundle.main.url(forResource: "bestiary_5e", withExtension: "ndjson")
                if url != nil {
                    print("Found bestiary file in bundle: \(url!.path)")
                } else {
                    print("Bestiary file NOT found in bundle")
                    // Показываем все доступные ресурсы в bundle
                    if let resourcePath = Bundle.main.resourcePath {
                        do {
                            let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                            print("Available resources in bundle (\(contents.count) files):")
                            let jsonFiles = contents.filter { $0.contains("json") || $0.contains("ndjson") }
                            print("JSON/NDJSON files: \(jsonFiles)")
                        } catch {
                            print("ERROR: Cannot list bundle contents: \(error)")
                        }
                    } else {
                        print("ERROR: Bundle has no resource path")
                    }
                }

                // Если не нашли в bundle, пробуем найти в исходной директории проекта
                if url == nil {
                    print("Trying to find bestiary file in project directory...")

                    // Сначала пробуем маленький тестовый файл
                    let testPath = "/Users/alexanderaferenok/Documents/GitHub/dnd_app/test_first_3_monsters.ndjson"
                    if FileManager.default.fileExists(atPath: testPath) {
                        url = URL(fileURLWithPath: testPath)
                        print("Using small test file: \(testPath)")
                    } else {
                        // Если тестового файла нет, используем полный файл
                        let projectPath = "/Users/alexanderaferenok/Documents/GitHub/dnd_app/dnd_app/Sources/Resources/bestiary_5e.ndjson"
                        if FileManager.default.fileExists(atPath: projectPath) {
                            url = URL(fileURLWithPath: projectPath)
                            print("Found bestiary file in project directory: \(projectPath)")
                        } else {
                            print("Bestiary file NOT found in project directory: \(projectPath)")
                        }
                    }
                }

                guard let finalUrl = url else {
                    print("ERROR: bestiary_5e.ndjson not found in bundle or project directory")
                    throw DataServiceError.fileNotFound("bestiary_5e.ndjson")
                }

                print("Found bestiary file at: \(finalUrl.path)")

                guard let data = try? Data(contentsOf: finalUrl) else {
                    print("Failed to read data from bestiary_5e.ndjson")
                    throw DataServiceError.fileNotFound("bestiary_5e.ndjson")
                }

                print("File found, data size: \(data.count) bytes")

                // Парсим NDJSON
                guard let content = String(data: data, encoding: .utf8) else {
                    print("ERROR: Cannot convert data to string")
                    throw DataServiceError.decodingError("Cannot convert data to string")
                }

                let lines = content.components(separatedBy: .newlines)
                print("Total lines in file: \(lines.count)")
                var monsters: [Monster] = []
                var successfulParses = 0
                var parseErrors = 0

                let decoder = JSONDecoder()

                print("Starting to parse \(lines.count) lines...")

                for (index, line) in lines.enumerated() {
                    let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

                    // Пропускаем пустые строки
                    if trimmedLine.isEmpty {
                        continue
                    }

                    // Проверяем, что строка начинается с '{'
                    if !trimmedLine.hasPrefix("{") {
                        parseErrors += 1
                        if parseErrors <= 3 {
                            print("ERROR: Line \(index) doesn't start with '{': \(trimmedLine.prefix(50))...")
                        }
                        continue
                    }

                    guard let lineData = trimmedLine.data(using: .utf8) else {
                        parseErrors += 1
                        if parseErrors <= 3 {
                            print("ERROR: Cannot convert line \(index) to data")
                        }
                        continue
                    }

                    do {
                        let monster = try decoder.decode(Monster.self, from: lineData)
                        monsters.append(monster)
                        successfulParses += 1

                        if successfulParses <= 5 {
                            print("✓ Successfully parsed monster \(successfulParses): \(monster.name)")
                        }
                    } catch {
                        parseErrors += 1
                        print("✗ Failed to decode monster at line \(index): \(error.localizedDescription)")
                        if parseErrors <= 3 {
                            print("   Problematic JSON: \(trimmedLine.prefix(200))...")
                        }
                        if parseErrors >= 10 {
                            print("Too many parse errors (\(parseErrors)), stopping...")
                            break
                        }
                    }
                }

                print("Successfully parsed \(successfulParses) monsters, \(parseErrors) parse errors")
                print("Total monsters in array: \(monsters.count)")
                return monsters.sorted { $0.name < $1.name }
            }

            await MainActor.run {
                // Не перезаписываем, если уже есть данные
                if monstersData.isEmpty && !self.monsters.isEmpty {
                    print("Async load returned empty array, keeping existing \(self.monsters.count) monsters")
                } else {
                    self.monsters = monstersData
                    print("Loaded \(monstersData.count) monsters from async load")
                }
            }
        } catch {
            print("Failed to load monsters: \(error)")
            // Если загрузка не удалась, но у нас уже есть данные, оставляем их
            if !self.monsters.isEmpty {
                print("Keeping existing \(self.monsters.count) monsters after load failure")
            }
        }
    }
    
    // MARK: - Persistence
    private func loadPersistedData() {
        loadRelationships()
        loadNotes()
        loadCharacters()
        loadCustomQuotesData()
    }
    
    // MARK: - Cache Management
    func clearCache() {
        cacheManager.clearAll()
    }
    
    func getCacheInfo() -> (memory: Int, disk: Int) {
        return cacheManager.getCacheSize()
    }
    
    func refreshData() {
        Task {
            // Очищаем кэш и перезагружаем данные
            cacheManager.clearAll()
            await refreshDataInBackground()
        }
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
           let characters = try? JSONDecoder().decode([Character].self, from: data) {
            self.characters = characters
        }
    }
    
    
    private func loadDnDClasses() {
        guard let url = Bundle.main.url(forResource: "classes", withExtension: "json") else {
            print("classes.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let classesData = try JSONDecoder().decode(DnDClassesData.self, from: data)
            self.dndClasses = classesData.classes
            print("Loaded \(classesData.classes.count) D&D classes")
        } catch {
            print("Error loading D&D classes: \(error)")
        }
    }
    
    private func loadClassTables() {
        guard let url = Bundle.main.url(forResource: "class_tables", withExtension: "json") else {
            print("class_tables.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let classTablesData = try JSONDecoder().decode(ClassTablesData.self, from: data)
            self.classTables = classTablesData
            print("Loaded \(classTablesData.count) class tables")
        } catch {
            print("Error loading class tables: \(error)")
        }
    }

    private func loadCustomQuotesData() {
        let key = "custom_quotes_data"
        if let data = userDefaults.data(forKey: key),
           let customQuotesData = try? JSONDecoder().decode(QuotesData.self, from: data) {
            // Если есть сохраненные пользовательские данные, объединяем их с данными из bundle
            if let existingQuotesData = self.quotes {
                // Создаем новую структуру с объединенными категориями
                var mergedCategories = existingQuotesData.categories
                // Объединяем категории: пользовательские категории заменяют встроенные
                for (category, quotes) in customQuotesData.categories {
                    mergedCategories[category] = quotes
                    print("Loaded custom category: \(category) with \(quotes.count) quotes")
                }
                self.quotes = QuotesData(categories: mergedCategories)
            } else {
                // Если встроенных данных нет, используем пользовательские
                self.quotes = customQuotesData
            }
            print("Custom quotes data loaded from UserDefaults - \(customQuotesData.categories.count) categories")
        } else {
            print("No custom quotes data found in UserDefaults")
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

    var uniqueOrganizations: [String] {
        let organizations = relationships.compactMap { $0.organization }
        return Array(Set(organizations)).sorted()
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
        let newRelationship = Relationship(duplicating: relationship)
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
    func addCharacter(_ character: Character) {
        characters.append(character)
        saveCharacters()
    }
    
    func updateCharacter(_ character: Character) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index] = character
            saveCharacters()
        }
    }
    
    func deleteCharacter(_ character: Character) {
        characters.removeAll { $0.id == character.id }
        saveCharacters()
    }
    
    func duplicateCharacter(_ character: Character) {
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
    func getSelectedCharacter() -> Character? {
        guard let characterId = userDefaults.string(forKey: Keys.selectedCharacter),
              let character = characters.first(where: { $0.id.uuidString == characterId }) else {
            return characters.first
        }
        return character
    }
    
    func setSelectedCharacter(_ character: Character) {
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
        guard let quotesData = quotes else { return }
        
        // Создаем новую категорию с пустым массивом цитат
        var newCategories = quotesData.categories
        newCategories[name] = []
        
        // Создаем новый объект QuotesData с обновленными категориями
        let updatedQuotesData = QuotesData(categories: newCategories)
        
        // Сохраняем обновленные данные
        saveQuotesData(updatedQuotesData)
    }
    
    func deleteQuoteCategory(_ name: String) {
        guard let quotesData = quotes else { return }
        
        // Удаляем категорию
        var newCategories = quotesData.categories
        newCategories.removeValue(forKey: name)
        
        // Создаем новый объект QuotesData с обновленными категориями
        let updatedQuotesData = QuotesData(categories: newCategories)
        
        // Сохраняем обновленные данные
        saveQuotesData(updatedQuotesData)
    }
    
    func renameQuoteCategory(from oldName: String, to newName: String) {
        guard let quotesData = quotes else { return }
        
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
        guard let quotesData = quotes else { return }
        
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
    
    // MARK: - Quote Management
    func addQuote(_ quote: Quote) {
        guard let quotesData = quotes else { return }
        
        var newCategories = quotesData.categories
        if newCategories[quote.category] == nil {
            newCategories[quote.category] = []
        }
        newCategories[quote.category]?.append(quote.text)
        
        let updatedQuotesData = QuotesData(categories: newCategories)
        saveQuotesData(updatedQuotesData)
    }
    
    func updateQuote(_ quote: Quote) {
        // Для обновления цитаты нужно знать старый текст
        // Пока что просто добавляем новую цитату
        addQuote(quote)
    }
    
    func updateQuote(from oldQuote: Quote, to newQuote: Quote) {
        guard let quotesData = quotes else { return }
        
        var newCategories = quotesData.categories
        if var categoryQuotes = newCategories[oldQuote.category] {
            // Удаляем старую цитату
            categoryQuotes.removeAll { $0 == oldQuote.text }
            // Добавляем новую цитату
            categoryQuotes.append(newQuote.text)
            newCategories[oldQuote.category] = categoryQuotes
        }
        
        let updatedQuotesData = QuotesData(categories: newCategories)
        saveQuotesData(updatedQuotesData)
    }
    
    func deleteQuote(_ quote: Quote) {
        guard let quotesData = quotes else { return }
        
        var newCategories = quotesData.categories
        if var categoryQuotes = newCategories[quote.category] {
            categoryQuotes.removeAll { $0 == quote.text }
            newCategories[quote.category] = categoryQuotes
        }
        
        let updatedQuotesData = QuotesData(categories: newCategories)
        saveQuotesData(updatedQuotesData)
    }
    
    func duplicateQuote(_ quote: Quote) {
        let duplicatedQuote = Quote(text: "\(quote.text) (копия)", category: quote.category)
        addQuote(duplicatedQuote)
    }
}
