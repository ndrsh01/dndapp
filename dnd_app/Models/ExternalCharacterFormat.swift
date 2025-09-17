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
    let name: SimpleField?
    let info: CharacterInfo
    let subInfo: CharacterSubInfo
    let spellsInfo: CharacterSpellsInfo
    let spells: [String: String]
    let spellsPact: [String: String]
    let spellsLevel0: CharacterField?
    let spellsLevel1: CharacterField?
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
    let inspiration: Bool
    let casterClass: SimpleField
    let avatar: [String: String]
    
    // Кастомный инициализатор для правильной обработки опциональных полей
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
        jsonType = try container.decode(String.self, forKey: .jsonType)
        template = try container.decode(String.self, forKey: .template)
        
        // Безопасное декодирование поля name
        if container.contains(.name) {
            name = try container.decode(SimpleField.self, forKey: .name)
        } else {
            name = nil
        }
        info = try container.decode(CharacterInfo.self, forKey: .info)
        subInfo = try container.decode(CharacterSubInfo.self, forKey: .subInfo)
        spellsInfo = try container.decode(CharacterSpellsInfo.self, forKey: .spellsInfo)
        spells = try container.decode([String: String].self, forKey: .spells)
        spellsPact = try container.decode([String: String].self, forKey: .spellsPact)
        spellsLevel0 = try container.decodeIfPresent(CharacterField.self, forKey: .spellsLevel0)
        spellsLevel1 = try container.decodeIfPresent(CharacterField.self, forKey: .spellsLevel1)
        proficiency = try container.decode(Int.self, forKey: .proficiency)
        stats = try container.decode(CharacterStats.self, forKey: .stats)
        saves = try container.decode(CharacterSaves.self, forKey: .saves)
        skills = try container.decode(CharacterSkills.self, forKey: .skills)
        vitality = try container.decode(CharacterVitality.self, forKey: .vitality)
        attunementsList = try container.decode([AttunementItem].self, forKey: .attunementsList)
        weaponsList = try container.decode([WeaponItem].self, forKey: .weaponsList)
        weapons = try container.decode([String: String].self, forKey: .weapons)
        text = try container.decode(CharacterText.self, forKey: .text)
        prof = try container.decode(CharacterField.self, forKey: .prof)
        equipment = try container.decode(CharacterField.self, forKey: .equipment)
        background = try container.decode(CharacterField.self, forKey: .background)
        allies = try container.decode(CharacterField.self, forKey: .allies)
        personality = try container.decode(CharacterField.self, forKey: .personality)
        ideals = try container.decode(CharacterField.self, forKey: .ideals)
        flaws = try container.decode(CharacterField.self, forKey: .flaws)
        bonds = try container.decode(CharacterField.self, forKey: .bonds)
        coins = try container.decode(CharacterCoins.self, forKey: .coins)
        resources = try container.decode([String: CharacterResource].self, forKey: .resources)
        bonusesSkills = try container.decode([String: String].self, forKey: .bonusesSkills)
        bonusesStats = try container.decode([String: String].self, forKey: .bonusesStats)
        conditions = try container.decode([String].self, forKey: .conditions)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        inspiration = try container.decode(Bool.self, forKey: .inspiration)
        casterClass = try container.decode(SimpleField.self, forKey: .casterClass)
        avatar = try container.decode([String: String].self, forKey: .avatar)
    }
    
    // Кастомный инициализатор для создания объектов
    init(isDefault: Bool, jsonType: String, template: String, name: SimpleField?, info: CharacterInfo, subInfo: CharacterSubInfo, spellsInfo: CharacterSpellsInfo, spells: [String: String], spellsPact: [String: String], spellsLevel0: CharacterField?, spellsLevel1: CharacterField?, proficiency: Int, stats: CharacterStats, saves: CharacterSaves, skills: CharacterSkills, vitality: CharacterVitality, attunementsList: [AttunementItem], weaponsList: [WeaponItem], weapons: [String: String], text: CharacterText, prof: CharacterField, equipment: CharacterField, background: CharacterField, allies: CharacterField, personality: CharacterField, ideals: CharacterField, flaws: CharacterField, bonds: CharacterField, coins: CharacterCoins, resources: [String: CharacterResource], bonusesSkills: [String: String], bonusesStats: [String: String], conditions: [String], createdAt: String, inspiration: Bool, casterClass: SimpleField, avatar: [String: String]) {
        self.isDefault = isDefault
        self.jsonType = jsonType
        self.template = template
        self.name = name
        self.info = info
        self.subInfo = subInfo
        self.spellsInfo = spellsInfo
        self.spells = spells
        self.spellsPact = spellsPact
        self.spellsLevel0 = spellsLevel0
        self.spellsLevel1 = spellsLevel1
        self.proficiency = proficiency
        self.stats = stats
        self.saves = saves
        self.skills = skills
        self.vitality = vitality
        self.attunementsList = attunementsList
        self.weaponsList = weaponsList
        self.weapons = weapons
        self.text = text
        self.prof = prof
        self.equipment = equipment
        self.background = background
        self.allies = allies
        self.personality = personality
        self.ideals = ideals
        self.flaws = flaws
        self.bonds = bonds
        self.coins = coins
        self.resources = resources
        self.bonusesSkills = bonusesSkills
        self.bonusesStats = bonusesStats
        self.conditions = conditions
        self.createdAt = createdAt
        self.inspiration = inspiration
        self.casterClass = casterClass
        self.avatar = avatar
    }
}

struct CharacterField: Codable {
    let value: CharacterFieldValue
    
    // Кастомный инициализатор для обработки разных структур
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Пытаемся декодировать как сложную структуру
        if let complexValue = try? container.decode(CharacterFieldValue.self, forKey: .value) {
            value = complexValue
        } else {
            // Если не получилось, создаем простую структуру из примитивного значения
            let simpleValue = try container.decode(SimpleFieldValue.self, forKey: .value)
            value = CharacterFieldValue(data: CharacterFieldData(type: "text", content: [CharacterFieldContent(type: "text", content: nil, text: simpleValue.text, marks: nil, attrs: nil)]), size: nil)
        }
    }
    
    // Извлечение текста из поля
    func extractText() -> String {
        guard let data = value.data,
              let content = data.content else {
            return ""
        }
        
        var text = ""
        for item in content {
            if let itemText = item.text {
                text += itemText
            }
            if let subContent = item.content {
                for subItem in subContent {
                    if let subText = subItem.text {
                        text += subText
                    }
                }
            }
        }
        return text
    }
    
    enum CodingKeys: String, CodingKey {
        case value
    }
}

// Вспомогательная структура для простых значений
struct SimpleFieldValue: Codable {
    let text: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            text = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            text = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            text = String(Int(doubleValue))
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected String, Int, or Double"
            ))
        }
    }
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
    let charClass: SimpleField
    let charSubclass: SimpleField
    let level: SimpleField
    let background: SimpleField
    let playerName: SimpleField
    let race: SimpleField
    let alignment: SimpleField
    let experience: SimpleField
}

struct SimpleField: Codable {
    let name: String?
    let value: String
    
    // Кастомный инициализатор для обработки разных структур
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Пытаемся декодировать name, если его нет - устанавливаем nil
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
        // value может быть как строкой, так и числом
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .value) {
            value = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .value) {
            value = String(Int(doubleValue))
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected String, Int, or Double for value"
            ))
        }
    }
    
    // Программный инициализатор
    init(name: String?, value: String) {
        self.name = name
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case name, value
    }
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
    let ability: String?
    let isProf: Bool
    let modBonus: CharacterField?
    
    // Конвертация в CharacterEquipment
    func toCharacterEquipment() -> CharacterEquipment {
        let weaponName = name.value.data?.content?.first?.text ?? "Неизвестное оружие"
        let damage = dmg.value.data?.content?.first?.text ?? ""
        let attackBonus = mod.value.data?.content?.first?.text ?? "+0"
        
        // Парсим бонус атаки
        let bonus = Int(attackBonus.replacingOccurrences(of: "+", with: "")) ?? 0
        
        return CharacterEquipment(
            name: weaponName,
            type: .weapon,
            attackBonus: bonus,
            damage: damage
        )
    }
}

struct CharacterText: Codable {
    let traits: CharacterField
    let attacks: CharacterField
    let features: CharacterField
    let background: CharacterField?
    let allies: CharacterField?
    let personality: CharacterField?
    let ideals: CharacterField?
    let flaws: CharacterField?
    let bonds: CharacterField?
    let equipment: CharacterField?
    let prof: CharacterField?
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
    
    // Конвертация в ClassResource с динамическим определением типа
    func toClassResource() -> ClassResource {
        let resourceType = ClassResource.determineResourceType(from: name, icon: icon, location: location)
        
        return ClassResource(
            id: id,
            name: name,
            icon: icon,
            maxValue: max,
            currentValue: current,
            type: resourceType,
            location: location,
            isLongRest: isLongRest,
            isShortRest: isShortRest
        )
    }
}