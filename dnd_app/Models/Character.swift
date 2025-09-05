import Foundation

struct Character: Codable, Identifiable {
    let id: UUID
    var name: String
    var race: String
    var characterClass: String
    var subclass: String?
    var background: String
    var alignment: String
    var level: Int
    
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
    
    var dateCreated: Date
    var dateModified: Date
    
    init(name: String, race: String, characterClass: String, background: String, alignment: String, level: Int = 1) {
        self.id = UUID()
        self.name = name
        self.race = race
        self.characterClass = characterClass
        self.background = background
        self.alignment = alignment
        self.level = level
        
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
        
        self.dateCreated = Date()
        self.dateModified = Date()
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