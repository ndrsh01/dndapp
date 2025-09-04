import Foundation

// MARK: - Main Character Model
struct DnDCharacter: Codable, Identifiable {
    let id = UUID()
    var name: String
    var info: CharacterInfo
    var subInfo: CharacterSubInfo
    var stats: CharacterStats
    var saves: CharacterSaves
    var skills: CharacterSkills
    var vitality: CharacterVitality
    var weaponsList: [Weapon]
    var text: CharacterText
    var coins: CharacterCoins
    var resources: [String: CharacterResource]
    var dateCreated: Date
    var dateModified: Date
    
    init() {
        self.name = ""
        self.info = CharacterInfo()
        self.subInfo = CharacterSubInfo()
        self.stats = CharacterStats()
        self.saves = CharacterSaves()
        self.skills = CharacterSkills()
        self.vitality = CharacterVitality()
        self.weaponsList = []
        self.text = CharacterText()
        self.coins = CharacterCoins()
        self.resources = [:]
        self.dateCreated = Date()
        self.dateModified = Date()
    }
}

// MARK: - Character Info
struct CharacterInfo: Codable {
    var charClass: String
    var charSubclass: String
    var level: Int
    var background: String
    var playerName: String
    var race: String
    var alignment: String
    var experience: String
    
    init() {
        self.charClass = ""
        self.charSubclass = ""
        self.level = 1
        self.background = ""
        self.playerName = ""
        self.race = ""
        self.alignment = ""
        self.experience = ""
    }
}

// MARK: - Character Sub Info
struct CharacterSubInfo: Codable {
    var age: String
    var height: String
    var weight: String
    var eyes: String
    var skin: String
    var hair: String
    
    init() {
        self.age = ""
        self.height = ""
        self.weight = ""
        self.eyes = ""
        self.skin = ""
        self.hair = ""
    }
}

// MARK: - Character Stats
struct CharacterStats: Codable {
    var str: StatValue
    var dex: StatValue
    var con: StatValue
    var int: StatValue
    var wis: StatValue
    var cha: StatValue
    
    init() {
        self.str = StatValue(name: "str", score: 10, modifier: 0, label: "Сила")
        self.dex = StatValue(name: "dex", score: 10, modifier: 0, label: "Ловкость")
        self.con = StatValue(name: "con", score: 10, modifier: 0, label: "Телосложение")
        self.int = StatValue(name: "int", score: 10, modifier: 0, label: "Интеллект")
        self.wis = StatValue(name: "wis", score: 10, modifier: 0, label: "Мудрость")
        self.cha = StatValue(name: "cha", score: 10, modifier: 0, label: "Харизма")
    }
}

struct StatValue: Codable {
    var name: String
    var score: Int
    var modifier: Int?
    var label: String
}

// MARK: - Character Saves
struct CharacterSaves: Codable {
    var str: SaveValue
    var dex: SaveValue
    var con: SaveValue
    var int: SaveValue
    var wis: SaveValue
    var cha: SaveValue
    
    init() {
        self.str = SaveValue(name: "str", isProf: false)
        self.dex = SaveValue(name: "dex", isProf: false)
        self.con = SaveValue(name: "con", isProf: false)
        self.int = SaveValue(name: "int", isProf: false)
        self.wis = SaveValue(name: "wis", isProf: false)
        self.cha = SaveValue(name: "cha", isProf: false)
    }
}

struct SaveValue: Codable {
    var name: String
    var isProf: Bool
}

// MARK: - Character Skills
struct CharacterSkills: Codable {
    var acrobatics: SkillValue
    var investigation: SkillValue
    var athletics: SkillValue
    var perception: SkillValue
    var survival: SkillValue
    var performance: SkillValue
    var intimidation: SkillValue
    var history: SkillValue
    var sleightOfHand: SkillValue
    var arcana: SkillValue
    var medicine: SkillValue
    var deception: SkillValue
    var nature: SkillValue
    var insight: SkillValue
    var religion: SkillValue
    var stealth: SkillValue
    var persuasion: SkillValue
    var animalHandling: SkillValue
    
    enum CodingKeys: String, CodingKey {
        case acrobatics, investigation, athletics, perception, survival, performance
        case intimidation, history, arcana, medicine, deception, nature, insight
        case religion, stealth, persuasion
        case sleightOfHand = "sleight of hand"
        case animalHandling = "animal handling"
    }
    
    init() {
        self.acrobatics = SkillValue(baseStat: "dex", name: "acrobatics", isProf: 0)
        self.investigation = SkillValue(baseStat: "int", name: "investigation", isProf: 0)
        self.athletics = SkillValue(baseStat: "str", name: "athletics", isProf: 0)
        self.perception = SkillValue(baseStat: "wis", name: "perception", isProf: 0)
        self.survival = SkillValue(baseStat: "wis", name: "survival", isProf: 0)
        self.performance = SkillValue(baseStat: "cha", name: "performance", isProf: 0)
        self.intimidation = SkillValue(baseStat: "cha", name: "intimidation", isProf: 0)
        self.history = SkillValue(baseStat: "int", name: "history", isProf: 0)
        self.sleightOfHand = SkillValue(baseStat: "dex", name: "sleight of hand", isProf: 0)
        self.arcana = SkillValue(baseStat: "int", name: "arcana", isProf: 0)
        self.medicine = SkillValue(baseStat: "wis", name: "medicine", isProf: 0)
        self.deception = SkillValue(baseStat: "cha", name: "deception", isProf: 0)
        self.nature = SkillValue(baseStat: "int", name: "nature", isProf: 0)
        self.insight = SkillValue(baseStat: "wis", name: "insight", isProf: 0)
        self.religion = SkillValue(baseStat: "int", name: "religion", isProf: 0)
        self.stealth = SkillValue(baseStat: "dex", name: "stealth", isProf: 0)
        self.persuasion = SkillValue(baseStat: "cha", name: "persuasion", isProf: 0)
        self.animalHandling = SkillValue(baseStat: "wis", name: "animal handling", isProf: 0)
    }
}

struct SkillValue: Codable {
    var baseStat: String
    var name: String
    var isProf: Int
}

// MARK: - Character Vitality
struct CharacterVitality: Codable {
    var hpDiceCurrent: Int
    var speed: String
    var hpMax: Int
    var ac: Int
    var isDying: Bool
    
    enum CodingKeys: String, CodingKey {
        case hpDiceCurrent = "hp-dice-current"
        case speed
        case hpMax = "hp-max"
        case ac
        case isDying
    }
    
    init() {
        self.hpDiceCurrent = 1
        self.speed = "30"
        self.hpMax = 10
        self.ac = 10
        self.isDying = false
    }
}

// MARK: - Weapon
struct Weapon: Codable, Identifiable {
    let id = UUID()
    var name: String
    var mod: String
    var dmg: String
    var ability: String
    var isProf: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, mod, dmg, ability, isProf
    }
    
    init(name: String, mod: String, dmg: String, ability: String, isProf: Bool) {
        self.name = name
        self.mod = mod
        self.dmg = dmg
        self.ability = ability
        self.isProf = isProf
    }
}

// MARK: - Character Text
struct CharacterText: Codable {
    var traits: String
    var attacks: String
    var features: String
    var prof: String
    var equipment: String
    var background: String
    var allies: String
    var personality: String
    var ideals: String
    var flaws: String
    var bonds: String
    
    init() {
        self.traits = ""
        self.attacks = ""
        self.features = ""
        self.prof = ""
        self.equipment = ""
        self.background = ""
        self.allies = ""
        self.personality = ""
        self.ideals = ""
        self.flaws = ""
        self.bonds = ""
    }
}

// MARK: - Character Coins
struct CharacterCoins: Codable {
    var gp: Int
    
    init() {
        self.gp = 0
    }
}

// MARK: - Character Resource
struct CharacterResource: Codable {
    var id: String
    var name: String
    var current: Int
    var max: Int
    var location: String
    var isLongRest: Bool
    var icon: String
    var isShortRest: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, current, max, location, icon
        case isLongRest = "isLongRest"
        case isShortRest = "isShortRest"
    }
}
