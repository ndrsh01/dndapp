import Foundation
import SwiftUI

// MARK: - Character Equipment Model

struct CharacterEquipment: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: EquipmentType
    var cost: Int // в медных монетах
    var weight: Double // в кг
    var rarity: Rarity
    var description: String
    
    // Для оружия
    var attackBonus: Int?
    var damage: String?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.type = .misc
        self.cost = 0
        self.weight = 0.0
        self.rarity = .common
        self.description = ""
        self.attackBonus = nil
        self.damage = nil
    }
    
    init(name: String, type: EquipmentType, cost: Int = 0, weight: Double = 0.0, rarity: Rarity = .common, description: String = "", attackBonus: Int? = nil, damage: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.cost = cost
        self.weight = weight
        self.rarity = rarity
        self.description = description
        self.attackBonus = attackBonus
        self.damage = damage
    }
}

enum EquipmentType: String, CaseIterable, Codable {
    case weapon = "Оружие"
    case armor = "Доспехи"
    case shield = "Щит"
    case tool = "Инструмент"
    case consumable = "Расходник"
    case misc = "Разное"
    
    var icon: String {
        switch self {
        case .weapon:
            return "sword.fill"
        case .armor:
            return "shield.lefthalf.filled"
        case .shield:
            return "shield.fill"
        case .tool:
            return "wrench.and.screwdriver.fill"
        case .consumable:
            return "drop.fill"
        case .misc:
            return "bag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .weapon:
            return .red
        case .armor:
            return .blue
        case .shield:
            return .blue
        case .tool:
            return .orange
        case .consumable:
            return .green
        case .misc:
            return .gray
        }
    }
}

enum Rarity: String, CaseIterable, Codable {
    case common = "Обычное"
    case uncommon = "Необычное"
    case rare = "Редкое"
    case veryRare = "Очень редкое"
    case legendary = "Легендарное"
    case artifact = "Артефакт"
    
    var color: Color {
        switch self {
        case .common:
            return .gray
        case .uncommon:
            return .green
        case .rare:
            return .blue
        case .veryRare:
            return .purple
        case .legendary:
            return .orange
        case .artifact:
            return .red
        }
    }
    
    var multiplier: Double {
        switch self {
        case .common:
            return 1.0
        case .uncommon:
            return 2.0
        case .rare:
            return 5.0
        case .veryRare:
            return 10.0
        case .legendary:
            return 25.0
        case .artifact:
            return 100.0
        }
    }
}

// MARK: - Treasure Model

struct Treasure: Codable, Identifiable {
    let id: UUID
    var name: String
    var category: TreasureCategory
    var value: Int // в золотых монетах
    var description: String
    var quantity: Int
    
    init(name: String, category: TreasureCategory = .misc, value: Int = 0, description: String = "", quantity: Int = 1) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.value = value
        self.description = description
        self.quantity = quantity
    }
}

enum TreasureCategory: String, CaseIterable, Codable {
    case gems = "Драгоценные камни"
    case jewelry = "Украшения"
    case art = "Произведения искусства"
    case coins = "Монеты"
    case magic = "Магические предметы"
    case misc = "Разное"
    
    var icon: String {
        switch self {
        case .gems:
            return "diamond.fill"
        case .jewelry:
            return "sparkles"
        case .art:
            return "paintbrush.fill"
        case .coins:
            return "circle.fill"
        case .magic:
            return "wand.and.stars"
        case .misc:
            return "bag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .gems:
            return .blue
        case .jewelry:
            return .purple
        case .art:
            return .orange
        case .coins:
            return .yellow
        case .magic:
            return .green
        case .misc:
            return .gray
        }
    }
}

enum Skill: String, CaseIterable {
    case acrobatics = "Акробатика"
    case animalHandling = "Обращение с животными"
    case arcana = "Магия"
    case athletics = "Атлетика"
    case deception = "Обман"
    case history = "История"
    case insight = "Проницательность"
    case intimidation = "Запугивание"
    case investigation = "Расследование"
    case medicine = "Медицина"
    case nature = "Природа"
    case perception = "Восприятие"
    case performance = "Выступление"
    case persuasion = "Убеждение"
    case religion = "Религия"
    case sleightOfHand = "Ловкость рук"
    case stealth = "Скрытность"
    case survival = "Выживание"
    
    var ability: AbilityScore {
        switch self {
        case .acrobatics, .sleightOfHand, .stealth:
            return .dexterity
        case .athletics:
            return .strength
        case .animalHandling, .insight, .medicine, .perception, .survival:
            return .wisdom
        case .arcana, .history, .investigation, .nature, .religion:
            return .intelligence
        case .deception, .intimidation, .performance, .persuasion:
            return .charisma
        }
    }
}

struct Character: Codable, Identifiable {
    let id: UUID
    var name: String
    var race: String
    var characterClass: String
    var subclass: String?
    var background: String
    var alignment: String
    var level: Int
    var avatarImageData: Data? // Данные изображения аватара
    
    // Основные характеристики
    var strength: Int
    var dexterity: Int
    var constitution: Int
    var intelligence: Int
    var wisdom: Int
    var charisma: Int
    
    // Боевые характеристики
    var armorClass: Int
    var initiative: Int
    var speed: Int
    var hitPoints: Int
    var maxHitPoints: Int
    var proficiencyBonus: Int
    
    // Навыки
    var skills: [String: Bool] // Название навыка: владеет ли
    var skillsExpertise: [String: Bool] // Название навыка: есть ли компетенция (удваивает бонус владения)
    
    // Спасброски
    var savingThrows: [String: Bool] // Название характеристики: владеет ли спасброском
    
    // Классовые умения
    var classAbilities: [String]
    
    // Снаряжение
    var equipment: [CharacterEquipment]
    
    // Сокровища
    var treasures: [Treasure]
    
    // Монеты
    var copperPieces: Int
    var silverPieces: Int
    var electrumPieces: Int
    var goldPieces: Int
    var platinumPieces: Int
    
    // Личность
    var personalityTraits: String
    var ideals: String
    var bonds: String
    var flaws: String
    
    // Особенности
    var features: [String]
    
    // Ресурсы классов
    var classResources: [String: ClassResource]

    // Мультикласс
    var classes: [CharacterClass]

    // Эффекты и статусы
    var activeEffects: [CharacterEffect]

    // Временные HP
    var temporaryHitPoints: Int
    
    // Вдохновение
    var inspiration: Bool

    var dateCreated: Date
    var dateModified: Date
    
    init(name: String, race: String, characterClass: String, background: String, alignment: String, level: Int = 1, avatarImageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.race = race
        self.characterClass = characterClass
        self.background = background
        self.alignment = alignment
        self.level = level
        self.avatarImageData = avatarImageData
        
        // Инициализация характеристик значениями по умолчанию
        self.strength = 10
        self.dexterity = 10
        self.constitution = 10
        self.intelligence = 10
        self.wisdom = 10
        self.charisma = 10
        
        // Боевые характеристики
        self.armorClass = 10
        self.initiative = 0
        self.speed = 30
        self.hitPoints = 8
        self.maxHitPoints = 8
        self.proficiencyBonus = 2
        
        // Навыки
        self.skills = [:]
        self.skillsExpertise = [:]
        
        // Спасброски
        self.savingThrows = [:]
        
        // Классовые умения
        self.classAbilities = []
        
        // Снаряжение
        self.equipment = []
        
        // Сокровища
        self.treasures = []
        
        // Монеты
        self.copperPieces = 0
        self.silverPieces = 0
        self.electrumPieces = 0
        self.goldPieces = 0
        self.platinumPieces = 0
        
        // Личность
        self.personalityTraits = ""
        self.ideals = ""
        self.bonds = ""
        self.flaws = ""
        
        // Особенности
        self.features = []

        // Ресурсы классов
        self.classResources = [:]

        // Мультикласс
        self.classes = [CharacterClass(name: characterClass, level: level, subclass: subclass)]

        // Эффекты
        self.activeEffects = []

        // Временные HP
        self.temporaryHitPoints = 0
        
        // Вдохновение
        self.inspiration = false

        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    // CodingKeys для кастомного декодирования
    enum CodingKeys: String, CodingKey {
        case id, name, race, characterClass, subclass, background, alignment, level, avatarImageData
        case strength, dexterity, constitution, intelligence, wisdom, charisma
        case armorClass, initiative, speed, hitPoints, maxHitPoints, proficiencyBonus
        case skills, skillsExpertise, savingThrows, classAbilities, equipment, treasures
        case copperPieces, silverPieces, electrumPieces, goldPieces, platinumPieces
        case personalityTraits, ideals, bonds, flaws, features, classResources
        case classes, activeEffects, temporaryHitPoints, inspiration
        case dateCreated, dateModified
    }
    
    // Кастомный декодер для безопасного декодирования старых данных
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        race = try container.decode(String.self, forKey: .race)
        characterClass = try container.decode(String.self, forKey: .characterClass)
        subclass = try container.decodeIfPresent(String.self, forKey: .subclass)
        background = try container.decode(String.self, forKey: .background)
        alignment = try container.decode(String.self, forKey: .alignment)
        level = try container.decode(Int.self, forKey: .level)
        // Декодируем avatarImageData, обрабатывая возможный base64 формат
        if let avatarDataString = try container.decodeIfPresent(String.self, forKey: .avatarImageData) {
            // Если это base64 строка, конвертируем обратно в Data
            if let decodedData = Data(base64Encoded: avatarDataString) {
                avatarImageData = decodedData
                print("Decoded avatar image from base64, size: \(decodedData.count) bytes")
            } else {
                avatarImageData = nil
                print("Failed to decode avatar image from base64")
            }
        } else {
            avatarImageData = try container.decodeIfPresent(Data.self, forKey: .avatarImageData)
        }
        
        strength = try container.decode(Int.self, forKey: .strength)
        dexterity = try container.decode(Int.self, forKey: .dexterity)
        constitution = try container.decode(Int.self, forKey: .constitution)
        intelligence = try container.decode(Int.self, forKey: .intelligence)
        wisdom = try container.decode(Int.self, forKey: .wisdom)
        charisma = try container.decode(Int.self, forKey: .charisma)
        
        armorClass = try container.decode(Int.self, forKey: .armorClass)
        initiative = try container.decode(Int.self, forKey: .initiative)
        speed = try container.decode(Int.self, forKey: .speed)
        hitPoints = try container.decode(Int.self, forKey: .hitPoints)
        maxHitPoints = try container.decode(Int.self, forKey: .maxHitPoints)
        proficiencyBonus = try container.decode(Int.self, forKey: .proficiencyBonus)
        
        skills = try container.decode([String: Bool].self, forKey: .skills)
        // Безопасное декодирование нового поля skillsExpertise
        skillsExpertise = try container.decodeIfPresent([String: Bool].self, forKey: .skillsExpertise) ?? [:]
        // Безопасное декодирование нового поля savingThrows
        savingThrows = try container.decodeIfPresent([String: Bool].self, forKey: .savingThrows) ?? [:]
        
        classAbilities = try container.decode([String].self, forKey: .classAbilities)
        // Безопасное декодирование equipment (для обратной совместимости)
        if let equipmentStrings = try? container.decode([String].self, forKey: .equipment) {
            equipment = equipmentStrings.map { CharacterEquipment(name: $0) }
        } else {
            equipment = try container.decode([CharacterEquipment].self, forKey: .equipment)
        }
        // Безопасное декодирование treasures (для обратной совместимости)
        if let treasureStrings = try? container.decode([String].self, forKey: .treasures) {
            treasures = treasureStrings.map { Treasure(name: $0) }
        } else {
            treasures = try container.decode([Treasure].self, forKey: .treasures)
        }
        
        // Безопасное декодирование полей монет (для обратной совместимости)
        copperPieces = try container.decodeIfPresent(Int.self, forKey: .copperPieces) ?? 0
        silverPieces = try container.decodeIfPresent(Int.self, forKey: .silverPieces) ?? 0
        electrumPieces = try container.decodeIfPresent(Int.self, forKey: .electrumPieces) ?? 0
        goldPieces = try container.decodeIfPresent(Int.self, forKey: .goldPieces) ?? 0
        platinumPieces = try container.decodeIfPresent(Int.self, forKey: .platinumPieces) ?? 0
        
        personalityTraits = try container.decode(String.self, forKey: .personalityTraits)
        ideals = try container.decode(String.self, forKey: .ideals)
        bonds = try container.decode(String.self, forKey: .bonds)
        flaws = try container.decode(String.self, forKey: .flaws)
        features = try container.decode([String].self, forKey: .features)
        // Безопасное декодирование нового поля classResources
        classResources = try container.decodeIfPresent([String: ClassResource].self, forKey: .classResources) ?? [:]

        // Безопасное декодирование новых полей (для обратной совместимости)
        classes = try container.decodeIfPresent([CharacterClass].self, forKey: .classes) ?? [CharacterClass(name: characterClass, level: level, subclass: subclass)]
        activeEffects = try container.decodeIfPresent([CharacterEffect].self, forKey: .activeEffects) ?? []
        temporaryHitPoints = try container.decodeIfPresent(Int.self, forKey: .temporaryHitPoints) ?? 0
        inspiration = try container.decodeIfPresent(Bool.self, forKey: .inspiration) ?? false

        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        dateModified = try container.decode(Date.self, forKey: .dateModified)
    }

    // Метод кодирования для поддержки Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(race, forKey: .race)
        try container.encode(characterClass, forKey: .characterClass)
        try container.encode(subclass, forKey: .subclass)
        try container.encode(background, forKey: .background)
        try container.encode(alignment, forKey: .alignment)
        try container.encode(level, forKey: .level)
        try container.encode(avatarImageData, forKey: .avatarImageData)

        try container.encode(strength, forKey: .strength)
        try container.encode(dexterity, forKey: .dexterity)
        try container.encode(constitution, forKey: .constitution)
        try container.encode(intelligence, forKey: .intelligence)
        try container.encode(wisdom, forKey: .wisdom)
        try container.encode(charisma, forKey: .charisma)

        try container.encode(armorClass, forKey: .armorClass)
        try container.encode(initiative, forKey: .initiative)
        try container.encode(speed, forKey: .speed)
        try container.encode(hitPoints, forKey: .hitPoints)
        try container.encode(maxHitPoints, forKey: .maxHitPoints)
        try container.encode(proficiencyBonus, forKey: .proficiencyBonus)

        try container.encode(skills, forKey: .skills)
        try container.encode(skillsExpertise, forKey: .skillsExpertise)
        try container.encode(savingThrows, forKey: .savingThrows)
        try container.encode(classAbilities, forKey: .classAbilities)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(treasures, forKey: .treasures)

        try container.encode(copperPieces, forKey: .copperPieces)
        try container.encode(silverPieces, forKey: .silverPieces)
        try container.encode(electrumPieces, forKey: .electrumPieces)
        try container.encode(goldPieces, forKey: .goldPieces)
        try container.encode(platinumPieces, forKey: .platinumPieces)

        try container.encode(personalityTraits, forKey: .personalityTraits)
        try container.encode(ideals, forKey: .ideals)
        try container.encode(bonds, forKey: .bonds)
        try container.encode(flaws, forKey: .flaws)
        try container.encode(features, forKey: .features)
        try container.encode(classResources, forKey: .classResources)

        try container.encode(classes, forKey: .classes)
        try container.encode(activeEffects, forKey: .activeEffects)
        try container.encode(temporaryHitPoints, forKey: .temporaryHitPoints)

        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateModified, forKey: .dateModified)
    }

    // Вычисляемые свойства для модификаторов
    var strengthModifier: Int {
        return (strength - 10) / 2
    }
    
    var dexterityModifier: Int {
        return (dexterity - 10) / 2
    }
    
    var constitutionModifier: Int {
        return (constitution - 10) / 2
    }
    
    var intelligenceModifier: Int {
        return (intelligence - 10) / 2
    }
    
    var wisdomModifier: Int {
        return (wisdom - 10) / 2
    }
    
    var charismaModifier: Int {
        return (charisma - 10) / 2
    }
    
    // Процент здоровья
    var healthPercentage: Double {
        guard maxHitPoints > 0 else { return 0 }
        return Double(hitPoints) / Double(maxHitPoints)
    }
    
    // Методы для получения значений характеристик
    func value(for ability: AbilityScore) -> Int {
        switch ability {
        case .strength: return strength
        case .dexterity: return dexterity
        case .constitution: return constitution
        case .intelligence: return intelligence
        case .wisdom: return wisdom
        case .charisma: return charisma
        }
    }
    
    func value(for stat: CombatStat) -> Int {
        switch stat {
        case .armorClass: return armorClass
        case .initiative: return initiative
        case .speed: return speed
        case .proficiencyBonus: return updatedProficiencyBonus
        case .inspiration: return inspiration ? 1 : 0
        }
    }
    
    func modifier(for ability: AbilityScore) -> Int {
        return (value(for: ability) - 10) / 2
    }
    
    func formatModifier(_ modifier: Int) -> String {
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
    
    // MARK: - Saving Throws
    
    func savingThrowModifier(for ability: AbilityScore) -> Int {
        let baseModifier = modifier(for: ability)
        let abilityName = ability.rawValue
        
        if savingThrows[abilityName] == true {
            return baseModifier + updatedProficiencyBonus
        }
        return baseModifier
    }
    
    func formattedSavingThrowModifier(for ability: AbilityScore) -> String {
        let modifier = savingThrowModifier(for: ability)
        return formatModifier(modifier)
    }
    
    mutating func toggleSavingThrow(for ability: AbilityScore) {
        let abilityName = ability.rawValue
        savingThrows[abilityName] = !(savingThrows[abilityName] ?? false)
    }
    
    func hasSavingThrowProficiency(for ability: AbilityScore) -> Bool {
        let abilityName = ability.rawValue
        return savingThrows[abilityName] ?? false
    }
    
    // MARK: - Multiclass Support
    
    /// Общий уровень персонажа (сумма всех уровней классов)
    var totalLevel: Int {
        if classes.isEmpty {
            return level
        }
        return classes.reduce(0) { $0 + $1.level }
    }
    
    /// Эффективный бонус владения для мультикласса
    var effectiveProficiencyBonus: Int {
        return (totalLevel - 1) / 4 + 2
    }
    
    /// Обновленный бонус владения (использует эффективный для мультикласса)
    var updatedProficiencyBonus: Int {
        return effectiveProficiencyBonus
    }
    
    /// Отображение классов для UI
    var classDisplayText: String {
        if classes.count > 1 {
            // Мультикласс: "Воин 5 / Маг 3"
            return classes
                .sorted(by: { $0.level > $1.level })
                .map { "\($0.name) \($0.level)" }
                .joined(separator: " / ")
        } else if let firstClass = classes.first {
            return "\(firstClass.name) \(firstClass.level)"
        } else {
            return "\(characterClass) \(level)"
        }
    }
    
    /// Отображение подклассов для UI
    var subclassDisplayText: String {
        if classes.count > 1 {
            // Мультикласс: показываем все подклассы
            let subclasses = classes
                .sorted(by: { $0.level > $1.level })
                .compactMap { classInfo in
                    if let subclass = classInfo.subclass, !subclass.isEmpty {
                        return "\(classInfo.name): \(subclass)"
                    } else {
                        return "\(classInfo.name): Нет подкласса"
                    }
                }
            return subclasses.joined(separator: " | ")
        } else if let firstClass = classes.first {
            return firstClass.subclass ?? "Нет подкласса"
        } else {
            return subclass ?? "Нет подкласса"
        }
    }
    
    /// Проверка, является ли персонаж мультиклассом
    var isMulticlass: Bool {
        return classes.count > 1
    }
    
    /// Получить основной класс (с наибольшим уровнем)
    var primaryClass: CharacterClass? {
        return classes.max(by: { $0.level < $1.level })
    }
    
    /// Инициализация мультикласса из основного класса
    mutating func initializeMulticlass() {
        if classes.isEmpty {
            let newClass = CharacterClass(name: characterClass, level: level, subclass: subclass)
            classes = [newClass]
        }
    }
    
    /// Добавить новый класс к мультиклассу
    mutating func addClass(_ className: String, level: Int = 1, subclass: String? = nil) {
        let newClass = CharacterClass(name: className, level: level, subclass: subclass)
        classes.append(newClass)
        
        // Обновить общий уровень
        self.level = totalLevel
    }
    
    /// Удалить класс из мультикласса
    mutating func removeClass(_ classId: UUID) {
        classes.removeAll { $0.id == classId }
        
        // Обновить общий уровень
        self.level = totalLevel
        
        // Если остался только один класс, обновить основной класс
        if classes.count == 1 {
            let remainingClass = classes.first!
            characterClass = remainingClass.name
            subclass = remainingClass.subclass
        }
    }
    
    /// Обновить уровень класса
    mutating func updateClassLevel(_ classId: UUID, newLevel: Int) {
        if let index = classes.firstIndex(where: { $0.id == classId }) {
            classes[index].level = newLevel
            self.level = totalLevel
        }
    }
}

struct ClassResource: Codable {
    let id: String
    let name: String
    let icon: String
    let maxValue: Int
    var currentValue: Int
    let type: ResourceType
    let location: String // "traits", "spells", etc.
    let isLongRest: Bool
    let isShortRest: Bool?
    
    enum ResourceType: String, Codable {
        case rage = "rage"
        case spellSlot = "spell_slot"
        case bardInspiration = "bard_inspiration"
        case ki = "ki"
        case sorceryPoints = "sorcery_points"
        case eldritchInvocations = "eldritch_invocations"
        case concentrationPoints = "concentration_points"
        case superiorityDice = "superiority_dice"
        case channelDivinity = "channel_divinity"
        case wildShape = "wild_shape"
        case lucky = "lucky" // Везучий
        case innateSpellcasting = "innate_spellcasting" // Врожденное чародейство
        case wildMagic = "wild_magic" // Волны хаоса
        case other = "other"
    }
    
    init(id: String = UUID().uuidString, name: String, icon: String, maxValue: Int, currentValue: Int = 0, type: ResourceType, location: String = "traits", isLongRest: Bool = true, isShortRest: Bool? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.maxValue = maxValue
        self.currentValue = currentValue
        self.type = type
        self.location = location
        self.isLongRest = isLongRest
        self.isShortRest = isShortRest
    }
    
    // Динамическое определение типа ресурса на основе контекста
    static func determineResourceType(from name: String, icon: String, location: String) -> ResourceType {
        // Создаем контекст для анализа
        let context = ResourceContext(name: name, icon: icon, location: location)
        
        // Используем систему правил для определения типа
        return ResourceTypeClassifier.classify(context)
    }
}

// MARK: - Resource Classification System

struct ResourceContext {
    let name: String
    let icon: String
    let location: String
    
    var lowercasedName: String { name.lowercased() }
    var lowercasedIcon: String { icon.lowercased() }
    var lowercasedLocation: String { location.lowercased() }
}

struct ResourceTypeClassifier {
    // Конфигурируемые правила для определения типа ресурса
    private static let classificationRules: [ClassificationRule] = [
        // Правила для ярости
        ClassificationRule(
            type: .rage,
            namePatterns: ["ярость", "rage"],
            iconPatterns: ["sword", "weapon", "anger"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для ячеек заклинаний
        ClassificationRule(
            type: .spellSlot,
            namePatterns: ["ячейк", "slot", "заклинани"],
            iconPatterns: ["spell", "magic", "star"],
            locationPatterns: ["spell", "magic"]
        ),
        
        // Правила для очков чародейства
        ClassificationRule(
            type: .sorceryPoints,
            namePatterns: ["очк", "point", "чародейств"],
            iconPatterns: ["point", "dot", "magic"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для вдохновения барда
        ClassificationRule(
            type: .bardInspiration,
            namePatterns: ["вдохновен", "inspiration", "бард"],
            iconPatterns: ["music", "note", "sound"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для очков сосредоточенности
        ClassificationRule(
            type: .ki,
            namePatterns: ["сосредоточен", "ki", "мона"],
            iconPatterns: ["heart", "life", "energy"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для призывов колдуна
        ClassificationRule(
            type: .eldritchInvocations,
            namePatterns: ["призыв", "invocation", "колдун"],
            iconPatterns: ["eye", "tentacle", "eldritch"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для концентрации
        ClassificationRule(
            type: .concentrationPoints,
            namePatterns: ["концентрац", "concentration", "фокус"],
            iconPatterns: ["focus", "target", "center"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для костей превосходства
        ClassificationRule(
            type: .superiorityDice,
            namePatterns: ["превосходств", "superiority", "кост"],
            iconPatterns: ["dice", "cube", "battle"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для божественной силы
        ClassificationRule(
            type: .channelDivinity,
            namePatterns: ["божествен", "divinity", "жрец"],
            iconPatterns: ["holy", "cross", "divine"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для дикой формы
        ClassificationRule(
            type: .wildShape,
            namePatterns: ["дикий", "wild", "форма", "shape", "друид"],
            iconPatterns: ["paw", "animal", "nature"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для дикой магии
        ClassificationRule(
            type: .wildMagic,
            namePatterns: ["дикий", "wild", "маги", "magic", "хаос"],
            iconPatterns: ["chaos", "random", "wild"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для везучести
        ClassificationRule(
            type: .lucky,
            namePatterns: ["везуч", "lucky", "удач"],
            iconPatterns: ["clover", "star", "lucky"],
            locationPatterns: ["trait", "ability"]
        ),
        
        // Правила для врожденного чародейства
        ClassificationRule(
            type: .innateSpellcasting,
            namePatterns: ["врожденн", "innate", "природн"],
            iconPatterns: ["natural", "born", "innate"],
            locationPatterns: ["trait", "ability"]
        )
    ]
    
    static func classify(_ context: ResourceContext) -> ClassResource.ResourceType {
        // Ищем наиболее подходящее правило
        for rule in classificationRules {
            if rule.matches(context) {
                return rule.type
            }
        }
        
        // Если ничего не подошло, возвращаем other
        return .other
    }
}

struct ClassificationRule {
    let type: ClassResource.ResourceType
    let namePatterns: [String]
    let iconPatterns: [String]
    let locationPatterns: [String]
    
    func matches(_ context: ResourceContext) -> Bool {
        // Проверяем соответствие по названию
        let nameMatches = namePatterns.contains { pattern in
            context.lowercasedName.contains(pattern)
        }
        
        // Проверяем соответствие по иконке
        let iconMatches = iconPatterns.contains { pattern in
            context.lowercasedIcon.contains(pattern)
        }
        
        // Проверяем соответствие по локации
        let locationMatches = locationPatterns.contains { pattern in
            context.lowercasedLocation.contains(pattern)
        }
        
        // Ресурс подходит, если совпадает хотя бы по одному критерию
        return nameMatches || iconMatches || locationMatches
    }
}