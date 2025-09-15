import Foundation
import SwiftUI

class CharacterManager: ObservableObject {
    static let shared = CharacterManager()
    
    @Published var characters: [Character] = []
    @Published var selectedCharacter: Character?
    
    private let userDefaults = UserDefaults.standard
    private let charactersKey = "saved_characters"
    private let selectedCharacterKey = "selected_character_id"
    
    private init() {
        print("=== CHARACTER MANAGER INIT ===")
        print("CharacterManager singleton is being initialized")
        loadCharacters()
        loadSelectedCharacter()
        print("CharacterManager initialization complete")
    }
    
    // MARK: - Character Management
    
    func addCharacter(_ character: Character) {
        characters.append(character)
        saveCharacters()
    }
    
    func updateCharacter(_ character: Character) {
        print("=== CHARACTER MANAGER UPDATE ===")
        print("Updating character: '\(character.name)' with ID: \(character.id)")
        print("Character class: \(character.characterClass)")
        print("Character race: \(character.race)")
        print("Character alignment: \(character.alignment)")
        print("Current characters count: \(characters.count)")
        for (index, char) in characters.enumerated() {
            print("  [\(index)] \(char.name) (ID: \(char.id))")
        }
        
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            print("Found character at index: \(index)")
            characters[index] = character
            saveCharacters()
            
            // Обновляем выбранного персонажа, если это он
            if selectedCharacter?.id == character.id {
                selectedCharacter = character
                print("Updated selected character")
            }
            
            print("Character updated successfully in CharacterManager")
        } else {
            print("ERROR: Character not found for update: \(character.name)")
            print("Available character IDs: \(characters.map { $0.id })")
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
        print("=== CHARACTER MANAGER ===")
        print("Selecting character: '\(character.name)' with ID: \(character.id)")
        print("Previous selected character: '\(selectedCharacter?.name ?? "nil")' with ID: \(selectedCharacter?.id.uuidString ?? "nil")")
        
        // Принудительно обновляем selectedCharacter
        selectedCharacter = character
        
        // Принудительно уведомляем об изменении
        objectWillChange.send()
        
        saveSelectedCharacter()
        print("Character selected successfully")
        print("New selected character: '\(selectedCharacter?.name ?? "nil")' with ID: \(selectedCharacter?.id.uuidString ?? "nil")")
    }
    
    func deselectCharacter() {
        selectedCharacter = nil
        saveSelectedCharacter()
    }
    
    // MARK: - Persistence
    
    private func saveCharacters() {
        print("=== CHARACTER MANAGER SAVE ===")
        print("Saving \(characters.count) characters to UserDefaults with key: \(charactersKey)")
        for character in characters {
            print("- \(character.name): class=\(character.characterClass), race=\(character.race), alignment=\(character.alignment)")
        }
        
        if let encoded = try? JSONEncoder().encode(characters) {
            userDefaults.set(encoded, forKey: charactersKey)
            print("Characters saved successfully to UserDefaults")
        } else {
            print("ERROR: Failed to encode characters for saving")
        }
    }
    
    private func loadCharacters() {
        print("=== CHARACTER MANAGER LOAD ===")
        print("Loading characters from UserDefaults with key: \(charactersKey)")
        
        if let data = userDefaults.data(forKey: charactersKey),
           let decoded = try? JSONDecoder().decode([Character].self, from: data) {
            characters = decoded
            print("Loaded \(characters.count) characters from UserDefaults")
            for character in characters {
                print("- \(character.name): class=\(character.characterClass), race=\(character.race), alignment=\(character.alignment)")
            }
        } else {
            print("No saved characters found, creating default character")
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
    
    func exportCharacterExtended(_ character: Character) -> String? {
        print("=== EXPORT CHARACTER (EXTENDED) ===")
        print("Character: \(character.name)")
        print("Character ID: \(character.id)")

        let dataService = DataService.shared

        // Получаем связанные данные
        print("Getting related data...")
        let relationships = dataService.getRelationships(for: character.id)
        let notes = dataService.getNotes(for: character.id)
        let favoriteSpells = dataService.getFavoriteSpells(for: character.id)

        print("Related data counts:")
        print("- Relationships: \(relationships.count)")
        print("- Notes: \(notes.count)")
        print("- Favorite spells: \(favoriteSpells.count)")

        // Создаем упрощенную версию персонажа для экспорта
        var exportCharacter = character
        if let imageData = character.avatarImageData {
            print("Avatar image data size: \(imageData.count) bytes")
            exportCharacter.avatarImageData = imageData.base64EncodedData()
        }

        // Создаем расширенную структуру экспорта
        print("Creating ExtendedCharacterExport...")
        let extendedExport = ExtendedCharacterExport(
            character: exportCharacter,
            relationships: relationships,
            notes: notes,
            favoriteSpells: favoriteSpells
        )
        print("ExtendedCharacterExport created successfully")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        do {
            print("Encoding ExtendedCharacterExport to JSON...")
            let data = try encoder.encode(extendedExport)
            print("Successfully encoded extended export, data size: \(data.count) bytes")

            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("ERROR: Failed to convert extended export data to UTF-8 string")
                return nil
            }

            print("Successfully created extended JSON string, length: \(jsonString.count) characters")
            print("First 200 characters: \(String(jsonString.prefix(200)))")
            return jsonString

        } catch {
            print("ERROR encoding extended export: \(error)")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")

            // Попробуем без avatar данных
            print("Trying extended export without avatar data...")
            exportCharacter.avatarImageData = nil
            let extendedExportWithoutAvatar = ExtendedCharacterExport(
                character: exportCharacter,
                relationships: relationships,
                notes: notes,
                favoriteSpells: favoriteSpells
            )

            do {
                let data = try encoder.encode(extendedExportWithoutAvatar)
                print("Successfully encoded extended export without avatar, data size: \(data.count) bytes")

                guard let jsonString = String(data: data, encoding: .utf8) else {
                    print("ERROR: Failed to convert extended export data to UTF-8 string (without avatar)")
                    return nil
                }

                print("Successfully created extended JSON string without avatar, length: \(jsonString.count) characters")
                return jsonString

            } catch {
                print("ERROR encoding extended export even without avatar: \(error)")
                return nil
            }
        }
    }
    
    func exportCharacter(_ character: Character) -> String? {
        print("=== EXPORT CHARACTER (BASIC) ===")
        print("Character: \(character.name)")
        print("Character ID: \(character.id)")

        // Создаем упрощенную версию персонажа без потенциально проблемных полей
        var exportCharacter = character

        // Конвертируем avatarImageData в base64 или убираем совсем
        if let imageData = character.avatarImageData {
            print("Avatar image data size: \(imageData.count) bytes")
            // Для экспорта конвертируем в base64
            exportCharacter.avatarImageData = imageData.base64EncodedData()
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            print("Encoding character to JSON...")
            let data = try encoder.encode(exportCharacter)
            print("Successfully encoded character, data size: \(data.count) bytes")

            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("ERROR: Failed to convert data to UTF-8 string")
                return nil
            }

            print("Successfully created JSON string, length: \(jsonString.count) characters")
            print("First 200 characters: \(String(jsonString.prefix(200)))")
            return jsonString

        } catch {
            print("ERROR encoding character: \(error)")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")

            // Попробуем закодировать без avatarImageData
            print("Trying to encode without avatar data...")
            exportCharacter.avatarImageData = nil

            do {
                let data = try encoder.encode(exportCharacter)
                print("Successfully encoded character without avatar, data size: \(data.count) bytes")

                guard let jsonString = String(data: data, encoding: .utf8) else {
                    print("ERROR: Failed to convert data to UTF-8 string (without avatar)")
                    return nil
                }

                print("Successfully created JSON string without avatar, length: \(jsonString.count) characters")
                return jsonString

            } catch {
                print("ERROR encoding character even without avatar: \(error)")
                return nil
            }
        }
    }
    
    func exportCharacterExternal(_ character: Character) -> String? {
        print("=== EXPORT CHARACTER (EXTERNAL) ===")
        print("Character: \(character.name)")
        print("Character ID: \(character.id)")
        
        // Сначала попробуем простой экспорт для тестирования
        print("Creating simple format...")
        let simpleFormat = [
            "name": character.name,
            "race": character.race,
            "class": character.characterClass,
            "level": character.level,
            "background": character.background,
            "alignment": character.alignment,
            "coins": [
                "copper": character.copperPieces,
                "silver": character.silverPieces,
                "electrum": character.electrumPieces,
                "gold": character.goldPieces,
                "platinum": character.platinumPieces
            ],
            "treasures": character.treasures
        ] as [String: Any]
        
        print("Simple format created with \(simpleFormat.count) fields")
        print("Coins data: \(simpleFormat["coins"] ?? "nil")")
        print("Treasures count: \(character.treasures.count)")
        
        do {
            print("Converting simple format to JSON...")
            let data = try JSONSerialization.data(withJSONObject: simpleFormat, options: .prettyPrinted)
            print("JSONSerialization successful, data size: \(data.count) bytes")
            
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("ERROR: Failed to convert simple format data to UTF-8 string")
                return nil
            }
            
            print("Simple export successful, length: \(jsonString.count) characters")
            print("First 200 characters: \(String(jsonString.prefix(200)))")
            return jsonString
            
        } catch {
            print("Simple export failed: \(error)")
            print("Error type: \(type(of: error))")
            
            // Если простой экспорт не работает, попробуем сложный
            print("Trying complex external format...")
            let externalFormat = createExternalCharacterFormat(from: character)
            print("Created external format")
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            do {
                print("Encoding complex external format...")
                let data = try encoder.encode(externalFormat)
                print("Complex encoding successful, data size: \(data.count) bytes")
                
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    print("ERROR: Failed to convert complex format data to UTF-8 string")
                    return nil
                }
                
                print("Successfully encoded external format, length: \(jsonString.count) characters")
                print("First 200 characters: \(String(jsonString.prefix(200)))")
                return jsonString
                
            } catch {
                print("ERROR encoding external format: \(error)")
                print("Error type: \(type(of: error))")
                if let encodingError = error as? EncodingError {
                    print("Encoding error details: \(encodingError)")
                }
                return nil
            }
        }
    }
    
    private func createExternalCharacterFormat(from character: Character) -> ExternalCharacterFormat {
        print("=== CREATE EXTERNAL CHARACTER FORMAT ===")
        print("Character: \(character.name)")
        
        // Создаем внутренние данные персонажа
        print("Creating external character data...")
        let characterData = createExternalCharacterData(from: character)
        print("External character data created successfully")
        
        // Кодируем данные персонажа в JSON строку
        print("Encoding character data to JSON string...")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(characterData)
            print("Character data encoded successfully, size: \(data.count) bytes")
            
            guard let dataString = String(data: data, encoding: .utf8) else {
                print("ERROR: Failed to convert character data to UTF-8 string")
                return ExternalCharacterFormat(
                    tags: [],
                    disabledBlocks: DisabledBlocks(
                        infoLeft: [], infoRight: [], subinfoLeft: [], subinfoRight: [],
                        notesLeft: [], notesRight: [], id: UUID().uuidString
                    ),
                    edition: "2014",
                    spells: SpellsInfo(mode: "cards", prepared: [], book: []),
                    data: "",
                    jsonType: "character",
                    version: "2"
                )
            }
            
            print("Character data string created, length: \(dataString.count) characters")
            print("First 200 characters: \(String(dataString.prefix(200)))")
            
            let format = ExternalCharacterFormat(
                tags: [],
                disabledBlocks: DisabledBlocks(
                    infoLeft: [],
                    infoRight: [],
                    subinfoLeft: [],
                    subinfoRight: [],
                    notesLeft: [],
                    notesRight: [],
                    id: UUID().uuidString
                ),
                edition: "2014",
                spells: SpellsInfo(
                    mode: "cards",
                    prepared: [],
                    book: []
                ),
                data: dataString,
                jsonType: "character",
                version: "2"
            )
            print("External format created successfully")
            return format
            
        } catch {
            print("ERROR encoding character data: \(error)")
            print("Error type: \(type(of: error))")
            if let encodingError = error as? EncodingError {
                print("Encoding error details: \(encodingError)")
            }
            
            // Возвращаем пустой формат в случае ошибки
            return ExternalCharacterFormat(
                tags: [],
                disabledBlocks: DisabledBlocks(
                    infoLeft: [], infoRight: [], subinfoLeft: [], subinfoRight: [],
                    notesLeft: [], notesRight: [], id: UUID().uuidString
                ),
                edition: "2014",
                spells: SpellsInfo(mode: "cards", prepared: [], book: []),
                data: "",
                jsonType: "character",
                version: "2"
            )
        }
    }
    
    private func createExternalCharacterData(from character: Character) -> ExternalCharacterData {
        return ExternalCharacterData(
            isDefault: true,
            jsonType: "character",
            template: "default",
            name: createTextField(character.name),
            info: CharacterInfo(
                charClass: createTextField(character.characterClass),
                charSubclass: createTextField(character.subclass ?? ""),
                level: createNumberField(character.level),
                background: createTextField(character.background),
                playerName: createTextField(""),
                race: createTextField(character.race),
                alignment: createTextField(character.alignment),
                experience: createTextField("")
            ),
            subInfo: CharacterSubInfo(
                age: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                height: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                weight: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                eyes: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                skin: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                hair: CharacterField(value: CharacterFieldValue(data: nil, size: nil))
            ),
            spellsInfo: CharacterSpellsInfo(
                base: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                save: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                mod: CharacterField(value: CharacterFieldValue(data: nil, size: nil))
            ),
            spells: [:],
            spellsPact: [:],
            proficiency: character.proficiencyBonus,
            stats: CharacterStats(
                str: CharacterStat(name: "str", score: character.strength, modifier: character.strengthModifier, label: "Сила"),
                dex: CharacterStat(name: "dex", score: character.dexterity, modifier: character.dexterityModifier, label: "Ловкость"),
                con: CharacterStat(name: "con", score: character.constitution, modifier: character.constitutionModifier, label: "Телосложение"),
                int: CharacterStat(name: "int", score: character.intelligence, modifier: character.intelligenceModifier, label: "Интеллект"),
                wis: CharacterStat(name: "wis", score: character.wisdom, modifier: character.wisdomModifier, label: "Мудрость"),
                cha: CharacterStat(name: "cha", score: character.charisma, modifier: character.charismaModifier, label: "Харизма")
            ),
            saves: CharacterSaves(
                str: CharacterSave(name: "str", isProf: false),
                dex: CharacterSave(name: "dex", isProf: false),
                con: CharacterSave(name: "con", isProf: false),
                int: CharacterSave(name: "int", isProf: false),
                wis: CharacterSave(name: "wis", isProf: false),
                cha: CharacterSave(name: "cha", isProf: false)
            ),
            skills: CharacterSkills(
                acrobatics: CharacterSkill(baseStat: "dex", name: "acrobatics", isProf: nil),
                investigation: CharacterSkill(baseStat: "int", name: "investigation", isProf: nil),
                athletics: CharacterSkill(baseStat: "str", name: "athletics", isProf: nil),
                perception: CharacterSkill(baseStat: "wis", name: "perception", isProf: nil),
                survival: CharacterSkill(baseStat: "wis", name: "survival", isProf: nil),
                performance: CharacterSkill(baseStat: "cha", name: "performance", isProf: nil),
                intimidation: CharacterSkill(baseStat: "cha", name: "intimidation", isProf: nil),
                history: CharacterSkill(baseStat: "int", name: "history", isProf: nil),
                sleightOfHand: CharacterSkill(baseStat: "dex", name: "sleight of hand", isProf: nil),
                arcana: CharacterSkill(baseStat: "int", name: "arcana", isProf: nil),
                medicine: CharacterSkill(baseStat: "wis", name: "medicine", isProf: nil),
                deception: CharacterSkill(baseStat: "cha", name: "deception", isProf: nil),
                nature: CharacterSkill(baseStat: "int", name: "nature", isProf: nil),
                insight: CharacterSkill(baseStat: "wis", name: "insight", isProf: nil),
                religion: CharacterSkill(baseStat: "int", name: "religion", isProf: nil),
                stealth: CharacterSkill(baseStat: "dex", name: "stealth", isProf: nil),
                persuasion: CharacterSkill(baseStat: "cha", name: "persuasion", isProf: nil),
                animalHandling: CharacterSkill(baseStat: "wis", name: "animal handling", isProf: nil)
            ),
            vitality: CharacterVitality(
                hpDiceCurrent: createNumberField(1),
                hpDiceMulti: [:],
                speed: createNumberField(character.speed),
                hpMax: createNumberField(character.maxHitPoints),
                ac: createNumberField(character.armorClass),
                isDying: false
            ),
            attunementsList: [],
            weaponsList: [],
            weapons: [:],
            text: CharacterText(
                traits: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                attacks: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
                features: CharacterField(value: CharacterFieldValue(data: nil, size: nil))
            ),
            prof: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            equipment: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            background: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            allies: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            personality: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            ideals: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            flaws: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            bonds: CharacterField(value: CharacterFieldValue(data: nil, size: nil)),
            coins: CharacterCoins(gp: createNumberField(character.goldPieces)),
            resources: [:],
            bonusesSkills: [:],
            bonusesStats: [:],
            conditions: [],
            createdAt: character.dateCreated.ISO8601Format()
        )
    }
    
    func importExtendedCharacter(from jsonString: String) -> (Character, [Relationship], [Note], [Spell])? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let extendedExport = try decoder.decode(ExtendedCharacterExport.self, from: data)
            
            // Создаем новый персонаж с новым ID для импорта
            let importedCharacter = Character(
                name: extendedExport.character.name,
                race: extendedExport.character.race,
                characterClass: extendedExport.character.characterClass,
                background: extendedExport.character.background,
                alignment: extendedExport.character.alignment,
                level: extendedExport.character.level
            )
            
            // Копируем остальные свойства
            var newCharacter = importedCharacter
            newCharacter.subclass = extendedExport.character.subclass
            newCharacter.strength = extendedExport.character.strength
            newCharacter.dexterity = extendedExport.character.dexterity
            newCharacter.constitution = extendedExport.character.constitution
            newCharacter.intelligence = extendedExport.character.intelligence
            newCharacter.wisdom = extendedExport.character.wisdom
            newCharacter.charisma = extendedExport.character.charisma
            newCharacter.armorClass = extendedExport.character.armorClass
            newCharacter.initiative = extendedExport.character.initiative
            newCharacter.speed = extendedExport.character.speed
            newCharacter.hitPoints = extendedExport.character.hitPoints
            newCharacter.maxHitPoints = extendedExport.character.maxHitPoints
            newCharacter.proficiencyBonus = extendedExport.character.proficiencyBonus
            newCharacter.skills = extendedExport.character.skills
            newCharacter.skillsExpertise = extendedExport.character.skillsExpertise
            newCharacter.savingThrows = extendedExport.character.savingThrows
            newCharacter.classAbilities = extendedExport.character.classAbilities
            newCharacter.equipment = extendedExport.character.equipment
            newCharacter.treasures = extendedExport.character.treasures
            newCharacter.copperPieces = extendedExport.character.copperPieces
            newCharacter.silverPieces = extendedExport.character.silverPieces
            newCharacter.electrumPieces = extendedExport.character.electrumPieces
            newCharacter.goldPieces = extendedExport.character.goldPieces
            newCharacter.platinumPieces = extendedExport.character.platinumPieces
            newCharacter.personalityTraits = extendedExport.character.personalityTraits
            newCharacter.ideals = extendedExport.character.ideals
            newCharacter.bonds = extendedExport.character.bonds
            newCharacter.flaws = extendedExport.character.flaws
            newCharacter.features = extendedExport.character.features
            newCharacter.classResources = extendedExport.character.classResources
            newCharacter.classes = extendedExport.character.classes
            newCharacter.activeEffects = extendedExport.character.activeEffects
            newCharacter.temporaryHitPoints = extendedExport.character.temporaryHitPoints
            newCharacter.inspiration = extendedExport.character.inspiration
            newCharacter.avatarImageData = extendedExport.character.avatarImageData
            newCharacter.dateCreated = Date()
            newCharacter.dateModified = Date()
            
            // Обновляем связанные данные с новым ID персонажа
            let newRelationships = extendedExport.relationships.map { relationship in
                Relationship(
                    name: relationship.name,
                    description: relationship.description,
                    relationshipLevel: relationship.relationshipLevel,
                    isAlive: relationship.isAlive,
                    organization: relationship.organization,
                    characterId: newCharacter.id
                )
            }
            
            let newNotes = extendedExport.notes.map { note in
                Note(
                    title: note.title,
                    description: note.description,
                    importance: note.importance,
                    category: note.category,
                    isAlive: note.isAlive,
                    characterId: newCharacter.id,
                    race: note.race,
                    occupation: note.occupation,
                    organization: note.organization,
                    age: note.age,
                    appearance: note.appearance,
                    locationType: note.locationType,
                    population: note.population,
                    government: note.government,
                    climate: note.climate,
                    itemType: note.itemType,
                    rarity: note.rarity,
                    value: note.value,
                    questType: note.questType,
                    status: note.status,
                    reward: note.reward,
                    loreType: note.loreType,
                    era: note.era
                )
            }
            
            let newSpells = extendedExport.favoriteSpells.map { spell in
                var newSpell = spell
                newSpell.characterId = newCharacter.id
                return newSpell
            }
            
            return (newCharacter, newRelationships, newNotes, newSpells)
        } catch {
            print("Ошибка импорта расширенного персонажа: \(error)")
            return nil
        }
    }
    
    func importCharacterWithData(from jsonString: String) -> (Character, [Relationship], [Note], [Spell])? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            // Пробуем декодировать как ExtendedCharacterExport
            let extendedExport = try decoder.decode(ExtendedCharacterExport.self, from: data)
            print("Успешно импортирован ExtendedCharacterExport с дополнительными данными")
            
            // Создаем новый персонаж с новым ID для импорта
            let importedCharacter = Character(
                name: extendedExport.character.name,
                race: extendedExport.character.race,
                characterClass: extendedExport.character.characterClass,
                background: extendedExport.character.background,
                alignment: extendedExport.character.alignment,
                level: extendedExport.character.level
            )
            
            // Копируем остальные свойства
            var newCharacter = importedCharacter
            newCharacter.subclass = extendedExport.character.subclass
            newCharacter.strength = extendedExport.character.strength
            newCharacter.dexterity = extendedExport.character.dexterity
            newCharacter.constitution = extendedExport.character.constitution
            newCharacter.intelligence = extendedExport.character.intelligence
            newCharacter.wisdom = extendedExport.character.wisdom
            newCharacter.charisma = extendedExport.character.charisma
            newCharacter.armorClass = extendedExport.character.armorClass
            newCharacter.initiative = extendedExport.character.initiative
            newCharacter.speed = extendedExport.character.speed
            newCharacter.hitPoints = extendedExport.character.hitPoints
            newCharacter.maxHitPoints = extendedExport.character.maxHitPoints
            newCharacter.proficiencyBonus = extendedExport.character.proficiencyBonus
            newCharacter.skills = extendedExport.character.skills
            newCharacter.skillsExpertise = extendedExport.character.skillsExpertise
            newCharacter.savingThrows = extendedExport.character.savingThrows
            newCharacter.classAbilities = extendedExport.character.classAbilities
            newCharacter.equipment = extendedExport.character.equipment
            newCharacter.treasures = extendedExport.character.treasures
            newCharacter.copperPieces = extendedExport.character.copperPieces
            newCharacter.silverPieces = extendedExport.character.silverPieces
            newCharacter.electrumPieces = extendedExport.character.electrumPieces
            newCharacter.goldPieces = extendedExport.character.goldPieces
            newCharacter.platinumPieces = extendedExport.character.platinumPieces
            newCharacter.personalityTraits = extendedExport.character.personalityTraits
            newCharacter.ideals = extendedExport.character.ideals
            newCharacter.bonds = extendedExport.character.bonds
            newCharacter.flaws = extendedExport.character.flaws
            newCharacter.features = extendedExport.character.features
            newCharacter.classResources = extendedExport.character.classResources
            newCharacter.classes = extendedExport.character.classes
            newCharacter.activeEffects = extendedExport.character.activeEffects
            newCharacter.temporaryHitPoints = extendedExport.character.temporaryHitPoints
            newCharacter.inspiration = extendedExport.character.inspiration
            newCharacter.avatarImageData = extendedExport.character.avatarImageData
            newCharacter.dateCreated = Date()
            newCharacter.dateModified = Date()
            
            // Обновляем ID для связанных данных
            let newRelationships = extendedExport.relationships.map { relationship in
                var newRelationship = relationship
                newRelationship.characterId = newCharacter.id
                return newRelationship
            }
            
            let newNotes = extendedExport.notes.map { note in
                var newNote = note
                newNote.characterId = newCharacter.id
                return newNote
            }
            
            let newSpells = extendedExport.favoriteSpells.map { spell in
                var newSpell = spell
                newSpell.characterId = newCharacter.id
                return newSpell
            }
            
            return (newCharacter, newRelationships, newNotes, newSpells)
        } catch {
            print("Ошибка импорта расширенного персонажа: \(error)")
            return nil
        }
    }
    
    func importCharacter(from jsonString: String) -> Character? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            // Сначала пробуем декодировать как ExtendedCharacterExport
            let character: Character
            do {
                let extendedExport = try decoder.decode(ExtendedCharacterExport.self, from: data)
                character = extendedExport.character
                print("Успешно импортирован ExtendedCharacterExport")
            } catch {
                print("Не удалось декодировать как ExtendedCharacterExport, пробуем полный Character: \(error)")
                // Пробуем декодировать как полный Character
            do {
                character = try decoder.decode(Character.self, from: data)
                    print("Успешно импортирован полный Character")
            } catch {
                print("Не удалось декодировать как полный Character, пробуем упрощенную версию: \(error)")
                // Если не получилось, пробуем декодировать как словарь и создать Character вручную
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        throw NSError(domain: "CharacterManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Не удалось распарсить JSON"])
                }
                
                guard let name = json["name"] as? String,
                      let race = json["race"] as? String,
                      let characterClass = json["characterClass"] as? String,
                      let background = json["background"] as? String,
                      let alignment = json["alignment"] as? String else {
                    print("Отсутствуют обязательные поля в JSON")
                        throw NSError(domain: "CharacterManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Отсутствуют обязательные поля в JSON"])
                }
                
                let level = json["level"] as? Int ?? 1
                character = Character(
                    name: name,
                    race: race,
                    characterClass: characterClass,
                    background: background,
                    alignment: alignment,
                    level: level
                )
                    print("Успешно импортирован упрощенный Character")
                }
            }
            
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
    
    // Импорт персонажа из данных (Data)
    func importCharacterFromData(_ data: Data) -> Character? {
        guard let jsonString = String(data: data, encoding: .utf8) else { return nil }
        return importCharacter(from: jsonString)
    }
    
    // Импорт из внешнего формата (Data)
    func importExternalCharacterFromData(_ data: Data) -> Character? {
        guard let jsonString = String(data: data, encoding: .utf8) else { return nil }
        return importExternalCharacter(from: jsonString)
    }
    
    // Импорт из внешнего формата (как в JSON файле)
    func importExternalCharacter(from jsonString: String) -> Character? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let externalCharacter: ExternalCharacterFormat = try decoder.decode(ExternalCharacterFormat.self, from: data)
            
            // Парсим внутренние данные
            guard let characterData = externalCharacter.data.data(using: String.Encoding.utf8) else { 
                print("Не удалось преобразовать data в UTF8")
                return nil 
            }
            
            let characterDataObj: ExternalCharacterData
            do {
                characterDataObj = try decoder.decode(ExternalCharacterData.self, from: characterData)
            } catch {
                print("Ошибка декодирования внутренних данных персонажа: \(error)")
                return nil
            }
            
            // Создаем персонаж из внешних данных
            let character = Character(
                name: extractStringFromField(characterDataObj.name.value),
                race: extractStringFromField(characterDataObj.info.race.value),
                characterClass: extractStringFromField(characterDataObj.info.charClass.value),
                background: extractStringFromField(characterDataObj.info.background.value),
                alignment: extractStringFromField(characterDataObj.info.alignment.value),
                level: extractIntFromField(characterDataObj.info.level.value)
            )
            
            // Обновляем дополнительные свойства
            var newCharacter = character
            newCharacter.subclass = extractStringFromField(characterDataObj.info.charSubclass.value).isEmpty ? nil : extractStringFromField(characterDataObj.info.charSubclass.value)
            newCharacter.strength = characterDataObj.stats.str.score
            newCharacter.dexterity = characterDataObj.stats.dex.score
            newCharacter.constitution = characterDataObj.stats.con.score
            newCharacter.intelligence = characterDataObj.stats.int.score
            newCharacter.wisdom = characterDataObj.stats.wis.score
            newCharacter.charisma = characterDataObj.stats.cha.score
            newCharacter.armorClass = extractIntFromField(characterDataObj.vitality.ac.value)
            newCharacter.speed = extractIntFromField(characterDataObj.vitality.speed.value)
            newCharacter.maxHitPoints = extractIntFromField(characterDataObj.vitality.hpMax.value)
            newCharacter.hitPoints = extractIntFromField(characterDataObj.vitality.hpMax.value) // Текущие хиты = максимальные при импорте
            newCharacter.proficiencyBonus = characterDataObj.proficiency
            
            // Извлекаем текстовые поля (внешний формат не содержит эти поля отдельно)
            newCharacter.personalityTraits = ""
            newCharacter.ideals = ""
            newCharacter.bonds = ""
            newCharacter.flaws = ""
            
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
    
    // Вспомогательные функции для создания полей
    private func createTextField(_ text: String) -> CharacterField {
        let content = CharacterFieldContent(
            type: "paragraph",
            content: nil,
            text: text,
            marks: nil,
            attrs: nil
        )
        let data = CharacterFieldData(
            type: "doc",
            content: [content]
        )
        let value = CharacterFieldValue(data: data, size: nil)
        return CharacterField(value: value)
    }
    
    private func createNumberField(_ number: Int) -> CharacterField {
        let content = CharacterFieldContent(
            type: "paragraph",
            content: nil,
            text: String(number),
            marks: nil,
            attrs: nil
        )
        let data = CharacterFieldData(
            type: "doc",
            content: [content]
        )
        let value = CharacterFieldValue(data: data, size: nil)
        return CharacterField(value: value)
    }
    
    // Вспомогательные функции для извлечения данных из CharacterFieldValue
    private func extractStringFromField(_ field: CharacterFieldValue) -> String {
        // Внешний формат может содержать данные в разных форматах
        // Пока возвращаем пустую строку, так как структура сложная
        return ""
    }
    
    private func extractIntFromField(_ field: CharacterFieldValue) -> Int {
        // Внешний формат может содержать данные в разных форматах
        // Пока возвращаем значения по умолчанию
        return 0
    }
    
    // Вспомогательная функция для извлечения текста из внешних данных
    private func extractTextFromExternalData(_ content: [CharacterFieldContent]?) -> String {
        guard let content = content else { return "" }
        var result = ""
        for node in content {
            if let text = node.text {
                result += text
            }
            if let subContent = node.content {
                result += extractTextFromExternalData(subContent)
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
