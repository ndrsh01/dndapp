import Foundation

// Модель для внешнего формата персонажа (как в приложенном файле)
struct ExternalCharacterFormat: Codable {
    let tags: [String]
    let disabledBlocks: DisabledBlocks
    let edition: String
    let spells: SpellsInfo
    let data: String // JSON строка с данными персонажа
    let jsonType: String
    let version: String
}

struct DisabledBlocks: Codable {
    let infoLeft: [String]
    let infoRight: [String]
    let subinfoLeft: [String]
    let subinfoRight: [String]
    let notesLeft: [String]
    let notesRight: [String]
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case infoLeft = "info-left"
        case infoRight = "info-right"
        case subinfoLeft = "subinfo-left"
        case subinfoRight = "subinfo-right"
        case notesLeft = "notes-left"
        case notesRight = "notes-right"
        case id = "_id"
    }
}

struct SpellsInfo: Codable {
    let mode: String
    let prepared: [String]
    let book: [String]
}

// Внутренние данные персонажа (JSON строка)
struct ExternalCharacterData: Codable {
    let isDefault: Bool
    let jsonType: String
    let template: String
    let name: CharacterField
    let info: CharacterInfo
    let subInfo: CharacterSubInfo
    let spellsInfo: CharacterSpellsInfo
    let spells: [String: String]
    let spellsPact: [String: String]
    let proficiency: Int
    let stats: CharacterStats
    let saves: CharacterSaves
    let skills: CharacterSkills
    let vitality: CharacterVitality
    let attunementsList: [AttunementItem]
    let weaponsList: [WeaponItem]
    let weapons: [String: String]
    let text: CharacterText
    let prof: CharacterField
    let equipment: CharacterField
    let background: CharacterField
    let allies: CharacterField
    let personality: CharacterField
    let ideals: CharacterField
    let flaws: CharacterField
    let bonds: CharacterField
    let coins: CharacterCoins
    let resources: [String: CharacterResource]
    let bonusesSkills: [String: String]
    let bonusesStats: [String: String]
    let conditions: [String]
    let createdAt: String
}

struct CharacterField: Codable {
    let value: CharacterFieldValue
}

struct CharacterFieldValue: Codable {
    let data: CharacterFieldData?
    let size: Int?
}

struct CharacterFieldData: Codable {
    let type: String
    let content: [CharacterFieldContent]?
}

struct CharacterFieldContent: Codable {
    let type: String
    let content: [CharacterFieldContent]?
    let text: String?
    let marks: [CharacterFieldMark]?
    let attrs: [String: String]?
}

struct CharacterFieldMark: Codable {
    let type: String
    let attrs: [String: String]?
}

struct CharacterInfo: Codable {
    let charClass: CharacterField
    let charSubclass: CharacterField
    let level: CharacterField
    let background: CharacterField
    let playerName: CharacterField
    let race: CharacterField
    let alignment: CharacterField
    let experience: CharacterField
}

struct CharacterSubInfo: Codable {
    let age: CharacterField
    let height: CharacterField
    let weight: CharacterField
    let eyes: CharacterField
    let skin: CharacterField
    let hair: CharacterField
}

struct CharacterSpellsInfo: Codable {
    let base: CharacterField
    let save: CharacterField
    let mod: CharacterField
}

struct CharacterStats: Codable {
    let str: CharacterStat
    let dex: CharacterStat
    let con: CharacterStat
    let int: CharacterStat
    let wis: CharacterStat
    let cha: CharacterStat
}

struct CharacterStat: Codable {
    let name: String
    let score: Int
    let modifier: Int?
    let label: String
}

struct CharacterSaves: Codable {
    let str: CharacterSave
    let dex: CharacterSave
    let con: CharacterSave
    let int: CharacterSave
    let wis: CharacterSave
    let cha: CharacterSave
}

struct CharacterSave: Codable {
    let name: String
    let isProf: Bool
}

struct CharacterSkills: Codable {
    let acrobatics: CharacterSkill
    let investigation: CharacterSkill
    let athletics: CharacterSkill
    let perception: CharacterSkill
    let survival: CharacterSkill
    let performance: CharacterSkill
    let intimidation: CharacterSkill
    let history: CharacterSkill
    let sleightOfHand: CharacterSkill
    let arcana: CharacterSkill
    let medicine: CharacterSkill
    let deception: CharacterSkill
    let nature: CharacterSkill
    let insight: CharacterSkill
    let religion: CharacterSkill
    let stealth: CharacterSkill
    let persuasion: CharacterSkill
    let animalHandling: CharacterSkill
    
    enum CodingKeys: String, CodingKey {
        case acrobatics, investigation, athletics, perception, survival, performance, intimidation, history
        case sleightOfHand = "sleight of hand"
        case arcana, medicine, deception, nature, insight, religion, stealth, persuasion
        case animalHandling = "animal handling"
    }
}

struct CharacterSkill: Codable {
    let baseStat: String
    let name: String
    let isProf: Int?
}

struct CharacterVitality: Codable {
    let hpDiceCurrent: CharacterField
    let hpDiceMulti: [String: String]
    let speed: CharacterField
    let hpMax: CharacterField
    let ac: CharacterField
    let isDying: Bool
    
    enum CodingKeys: String, CodingKey {
        case hpDiceCurrent = "hp-dice-current"
        case hpDiceMulti = "hp-dice-multi"
        case speed
        case hpMax = "hp-max"
        case ac
        case isDying
    }
}

struct AttunementItem: Codable {
    let id: String
    let checked: Bool
    let value: String
}

struct WeaponItem: Codable {
    let id: String
    let name: CharacterField
    let mod: CharacterField
    let dmg: CharacterField
    let ability: String
    let isProf: Bool
}

struct CharacterText: Codable {
    let traits: CharacterField
    let attacks: CharacterField
    let features: CharacterField
}

struct CharacterCoins: Codable {
    let gp: CharacterField
}

struct CharacterResource: Codable {
    let id: String
    let name: String
    let current: Int
    let max: Int
    let location: String
    let isLongRest: Bool
    let icon: String
    let isShortRest: Bool?
}