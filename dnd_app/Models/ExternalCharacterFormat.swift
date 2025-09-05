import Foundation

// Модели для внешнего формата персонажа (как в JSON файле)
struct ExternalCharacter: Codable {
    let tags: [String]
    let disabledBlocks: DisabledBlocks
    let edition: String
    let spells: ExternalSpells
    let data: String // Это JSON строка, нужно парсить отдельно
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

struct ExternalSpells: Codable {
    let mode: String
    let prepared: [String]
    let book: [String]
}

// Внутренняя структура данных персонажа
struct ExternalCharacterData: Codable {
    let isDefault: Bool
    let jsonType: String
    let template: String
    let name: ExternalValue
    let info: ExternalInfo
    let subInfo: ExternalSubInfo
    let spellsInfo: ExternalSpellsInfo
    let spells: [String: String]
    let spellsPact: [String: String]
    let proficiency: Int
    let stats: ExternalStats
    let saves: ExternalSaves
    let skills: ExternalSkills
    let vitality: ExternalVitality
    let attunementsList: [ExternalAttunement]
    let weaponsList: [ExternalWeapon]
    let weapons: [String: String]
    let text: ExternalText
    let coins: ExternalCoins
    let resources: [String: ExternalResource]
    let bonusesSkills: [String: String]
    let bonusesStats: [String: String]
    let conditions: [String]
    let createdAt: String
}

struct ExternalValue: Codable {
    let value: String
}

struct ExternalInfo: Codable {
    let charClass: ExternalValue
    let charSubclass: ExternalValue
    let level: ExternalIntValue
    let background: ExternalValue
    let playerName: ExternalValue
    let race: ExternalValue
    let alignment: ExternalValue
    let experience: ExternalValue
}

struct ExternalIntValue: Codable {
    let value: Int
}

struct ExternalSubInfo: Codable {
    let age: ExternalValue
    let height: ExternalValue
    let weight: ExternalValue
    let eyes: ExternalValue
    let skin: ExternalValue
    let hair: ExternalValue
}

struct ExternalSpellsInfo: Codable {
    let base: ExternalValue
    let save: ExternalValue
    let mod: ExternalValue
}

struct ExternalStats: Codable {
    let str: ExternalStat
    let dex: ExternalStat
    let con: ExternalStat
    let int: ExternalStat
    let wis: ExternalStat
    let cha: ExternalStat
}

struct ExternalStat: Codable {
    let name: String
    let score: Int
    let modifier: Int?
    let label: String
}

struct ExternalSaves: Codable {
    let str: ExternalSave
    let dex: ExternalSave
    let con: ExternalSave
    let int: ExternalSave
    let wis: ExternalSave
    let cha: ExternalSave
}

struct ExternalSave: Codable {
    let name: String
    let isProf: Bool
}

struct ExternalSkills: Codable {
    let acrobatics: ExternalSkill
    let investigation: ExternalSkill
    let athletics: ExternalSkill
    let perception: ExternalSkill
    let survival: ExternalSkill
    let performance: ExternalSkill
    let intimidation: ExternalSkill
    let history: ExternalSkill
    let sleightOfHand: ExternalSkill
    let arcana: ExternalSkill
    let medicine: ExternalSkill
    let deception: ExternalSkill
    let nature: ExternalSkill
    let insight: ExternalSkill
    let religion: ExternalSkill
    let stealth: ExternalSkill
    let persuasion: ExternalSkill
    let animalHandling: ExternalSkill
    
    enum CodingKeys: String, CodingKey {
        case acrobatics, investigation, athletics, perception, survival, performance, intimidation, history, arcana, medicine, deception, nature, insight, religion, stealth, persuasion
        case sleightOfHand = "sleight of hand"
        case animalHandling = "animal handling"
    }
}

struct ExternalSkill: Codable {
    let baseStat: String
    let name: String
    let isProf: Int?
}

struct ExternalVitality: Codable {
    let hpDiceCurrent: ExternalIntValue
    let hpDiceMulti: [String: String]
    let speed: ExternalValue
    let hpMax: ExternalIntValue
    let ac: ExternalIntValue
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

struct ExternalAttunement: Codable {
    let id: String
    let checked: Bool
    let value: String
}

struct ExternalWeapon: Codable {
    let id: String
    let name: ExternalValue
    let mod: ExternalValue
    let dmg: ExternalValue
    let ability: String
    let isProf: Bool
}

struct ExternalText: Codable {
    let traits: ExternalTextValue
    let attacks: ExternalTextValue
    let features: ExternalTextValue
    let prof: ExternalTextValue
    let equipment: ExternalTextValue
    let background: ExternalTextValue
    let allies: ExternalTextValue
    let personality: ExternalTextValue
    let ideals: ExternalTextValue
    let flaws: ExternalTextValue
    let bonds: ExternalTextValue
}

struct ExternalTextValue: Codable {
    let value: ExternalTextData
    let size: Int
}

struct ExternalTextData: Codable {
    let data: ExternalTextContent
}

struct ExternalTextContent: Codable {
    let type: String
    let content: [ExternalTextNode]
}

struct ExternalTextNode: Codable {
    let type: String
    let content: [ExternalTextContent]?
    let text: String?
    let marks: [ExternalTextMark]?
    let attrs: ExternalTextAttrs?
}

struct ExternalTextMark: Codable {
    let type: String
    let attrs: ExternalTextAttrs?
}

struct ExternalTextAttrs: Codable {
    let id: String?
    let textName: String?
    let href: String?
    let target: String?
    let rel: String?
    let `class`: String?
}

struct ExternalCoins: Codable {
    let gp: ExternalIntValue
}

struct ExternalResource: Codable {
    let id: String
    let name: String
    let current: Int
    let max: Int
    let location: String
    let isLongRest: Bool
    let icon: String
    let isShortRest: Bool?
}

