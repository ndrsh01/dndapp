import Foundation

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
    
    // Классовые умения
    var classAbilities: [String]
    
    // Снаряжение
    var equipment: [String]
    
    // Сокровища
    var treasures: [String]
    
    // Личность
    var personalityTraits: String
    var ideals: String
    var bonds: String
    var flaws: String
    
    // Особенности
    var features: [String]
    
    // Ресурсы классов
    var classResources: [String: ClassResource]
    
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
        
        // Классовые умения
        self.classAbilities = []
        
        // Снаряжение
        self.equipment = []
        
        // Сокровища
        self.treasures = []
        
        // Личность
        self.personalityTraits = ""
        self.ideals = ""
        self.bonds = ""
        self.flaws = ""
        
        // Особенности
        self.features = []
        
        // Ресурсы классов
        self.classResources = [:]
        
        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    // CodingKeys для кастомного декодирования
    enum CodingKeys: String, CodingKey {
        case id, name, race, characterClass, subclass, background, alignment, level, avatarImageData
        case strength, dexterity, constitution, intelligence, wisdom, charisma
        case armorClass, initiative, speed, hitPoints, maxHitPoints, proficiencyBonus
        case skills, skillsExpertise, classAbilities, equipment, treasures
        case personalityTraits, ideals, bonds, flaws, features, classResources, dateCreated, dateModified
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
        avatarImageData = try container.decodeIfPresent(Data.self, forKey: .avatarImageData)
        
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
        
        classAbilities = try container.decode([String].self, forKey: .classAbilities)
        equipment = try container.decode([String].self, forKey: .equipment)
        treasures = try container.decode([String].self, forKey: .treasures)
        personalityTraits = try container.decode(String.self, forKey: .personalityTraits)
        ideals = try container.decode(String.self, forKey: .ideals)
        bonds = try container.decode(String.self, forKey: .bonds)
        flaws = try container.decode(String.self, forKey: .flaws)
        features = try container.decode([String].self, forKey: .features)
        // Безопасное декодирование нового поля classResources
        classResources = try container.decodeIfPresent([String: ClassResource].self, forKey: .classResources) ?? [:]
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        dateModified = try container.decode(Date.self, forKey: .dateModified)
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
        case .proficiencyBonus: return proficiencyBonus
        }
    }
    
    func modifier(for ability: AbilityScore) -> Int {
        return (value(for: ability) - 10) / 2
    }
    
    func formatModifier(_ modifier: Int) -> String {
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}

struct ClassResource: Codable {
    let name: String
    let icon: String
    let maxValue: Int
    var currentValue: Int
    let type: ResourceType
    
    enum ResourceType: String, Codable {
        case rage = "rage"
        case spellSlot = "spell_slot"
        case bardInspiration = "bard_inspiration"
        case ki = "ki"
        case sorceryPoints = "sorcery_points"
        case eldritchInvocations = "eldritch_invocations"
        case other = "other"
    }
}