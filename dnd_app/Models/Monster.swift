import Foundation

struct Monster: Codable, Identifiable {
    let id = UUID()
    let name: String
    let size: String
    let type: String
    let subtype: String?
    let alignment: String
    let armorClass: Int
    let hitPoints: Int
    let hitDice: String?
    let speed: String
    let strength: Int
    let dexterity: Int
    let constitution: Int
    let intelligence: Int
    let wisdom: Int
    let charisma: Int
    let skills: String?
    let damageResistances: String?
    let damageImmunities: String?
    let conditionImmunities: String?
    let senses: String?
    let languages: String?
    let challengeRating: String
    let xp: Int?
    let specialAbilities: [SpecialAbility]?
    let actions: [Action]?
    let legendaryActions: [LegendaryAction]?
    let reactions: [Reaction]?
    
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name, size, type, alignment
        case ac, hp, speed, skills
        case damageResistances = "damage_resistances"
        case damageImmunities = "damage_immunities"
        case conditionImmunities = "condition_immunities"
        case senses, languages
        case challenge = "challenge"
        case abilities, blocks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        size = try container.decode(String.self, forKey: .size)
        type = try container.decode(String.self, forKey: .type)
        alignment = try container.decode(String.self, forKey: .alignment)
        subtype = nil // Not in the JSON structure
        
        // Parse AC
        let acContainer = try container.nestedContainer(keyedBy: ACKeys.self, forKey: .ac)
        armorClass = try acContainer.decode(Int.self, forKey: .ac)
        
        // Parse HP
        let hpContainer = try container.nestedContainer(keyedBy: HPKeys.self, forKey: .hp)
        hitPoints = try hpContainer.decode(Int.self, forKey: .hp)
        hitDice = try hpContainer.decodeIfPresent(String.self, forKey: .formula)
        
        // Parse speed
        let speedContainer = try container.nestedContainer(keyedBy: SpeedKeys.self, forKey: .speed)
        speed = try speedContainer.decode(String.self, forKey: .walk)
        
        // Parse abilities
        let abilitiesContainer = try container.nestedContainer(keyedBy: AbilityKeys.self, forKey: .abilities)
        strength = try abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .str).decode(Int.self, forKey: .score)
        dexterity = try abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .dex).decode(Int.self, forKey: .score)
        constitution = try abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .con).decode(Int.self, forKey: .score)
        intelligence = try abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .int).decode(Int.self, forKey: .score)
        wisdom = try abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .wis).decode(Int.self, forKey: .score)
        charisma = try abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .cha).decode(Int.self, forKey: .score)
        
        // Parse skills
        if let skillsDict = try container.decodeIfPresent([String: String].self, forKey: .skills) {
            skills = skillsDict.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        } else {
            skills = nil
        }
        
        damageResistances = try container.decodeIfPresent(String.self, forKey: .damageResistances)
        damageImmunities = try container.decodeIfPresent(String.self, forKey: .damageImmunities)
        conditionImmunities = try container.decodeIfPresent(String.self, forKey: .conditionImmunities)
        senses = try container.decodeIfPresent(String.self, forKey: .senses)
        languages = try container.decodeIfPresent(String.self, forKey: .languages)
        
        // Parse challenge rating
        let challengeContainer = try container.nestedContainer(keyedBy: ChallengeKeys.self, forKey: .challenge)
        challengeRating = try challengeContainer.decode(String.self, forKey: .cr)
        xp = try challengeContainer.decodeIfPresent(Int.self, forKey: .xp)
        
        // Parse actions from blocks
        if let blocksContainer = try container.decodeIfPresent(MonsterBlocks.self, forKey: .blocks) {
            actions = blocksContainer.actions
        } else {
            actions = nil
        }
        
        specialAbilities = nil
        legendaryActions = nil
        reactions = nil
    }
    
    private enum ACKeys: String, CodingKey {
        case ac
    }
    
    private enum HPKeys: String, CodingKey {
        case hp, formula
    }
    
    private enum SpeedKeys: String, CodingKey {
        case walk
    }
    
    private enum AbilityKeys: String, CodingKey {
        case str, dex, con, int, wis, cha
    }
    
    private enum AbilityScoreKeys: String, CodingKey {
        case score
    }
    
    private enum ChallengeKeys: String, CodingKey {
        case cr, xp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(size, forKey: .size)
        try container.encode(type, forKey: .type)
        try container.encode(alignment, forKey: .alignment)
        
        // Encode AC
        var acContainer = container.nestedContainer(keyedBy: ACKeys.self, forKey: .ac)
        try acContainer.encode(armorClass, forKey: .ac)
        
        // Encode HP
        var hpContainer = container.nestedContainer(keyedBy: HPKeys.self, forKey: .hp)
        try hpContainer.encode(hitPoints, forKey: .hp)
        try hpContainer.encodeIfPresent(hitDice, forKey: .formula)
        
        // Encode speed
        var speedContainer = container.nestedContainer(keyedBy: SpeedKeys.self, forKey: .speed)
        try speedContainer.encode(speed, forKey: .walk)
        
        // Encode abilities
        var abilitiesContainer = container.nestedContainer(keyedBy: AbilityKeys.self, forKey: .abilities)
        var strContainer = abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .str)
        try strContainer.encode(strength, forKey: .score)
        var dexContainer = abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .dex)
        try dexContainer.encode(dexterity, forKey: .score)
        var conContainer = abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .con)
        try conContainer.encode(constitution, forKey: .score)
        var intContainer = abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .int)
        try intContainer.encode(intelligence, forKey: .score)
        var wisContainer = abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .wis)
        try wisContainer.encode(wisdom, forKey: .score)
        var chaContainer = abilitiesContainer.nestedContainer(keyedBy: AbilityScoreKeys.self, forKey: .cha)
        try chaContainer.encode(charisma, forKey: .score)
        
        // Encode skills
        if let skills = skills {
            var skillsDict: [String: String] = [:]
            let skillPairs = skills.components(separatedBy: ", ").compactMap { skill -> (String, String)? in
                let parts = skill.components(separatedBy: ": ")
                guard parts.count >= 1 else { return nil }
                return (parts[0], parts.count > 1 ? parts[1] : "")
            }
            for (key, value) in skillPairs {
                skillsDict[key] = value
            }
            try container.encode(skillsDict, forKey: .skills)
        }
        
        try container.encodeIfPresent(damageResistances, forKey: .damageResistances)
        try container.encodeIfPresent(damageImmunities, forKey: .damageImmunities)
        try container.encodeIfPresent(conditionImmunities, forKey: .conditionImmunities)
        try container.encodeIfPresent(senses, forKey: .senses)
        try container.encodeIfPresent(languages, forKey: .languages)
        
        // Encode challenge rating
        var challengeContainer = container.nestedContainer(keyedBy: ChallengeKeys.self, forKey: .challenge)
        try challengeContainer.encode(challengeRating, forKey: .cr)
        try challengeContainer.encodeIfPresent(xp, forKey: .xp)
        
        // Encode actions
        if let actions = actions {
            let blocks = MonsterBlocks(actions: actions)
            try container.encode(blocks, forKey: .blocks)
        }
    }
}

struct MonsterBlocks: Codable {
    let actions: [Action]?
}

struct SpecialAbility: Codable {
    let name: String
    let desc: String
}

struct Action: Codable {
    let name: String
    let desc: String
    let attackBonus: Int?
    let damageDice: String?
    let damageBonus: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case desc = "text"
        case attackBonus = "attack_bonus"
        case damageDice = "damage_dice"
        case damageBonus = "damage_bonus"
    }
    
    init(name: String, desc: String, attackBonus: Int?, damageDice: String?, damageBonus: Int?) {
        self.name = name
        self.desc = desc
        self.attackBonus = attackBonus
        self.damageDice = damageDice
        self.damageBonus = damageBonus
    }
}

struct LegendaryAction: Codable {
    let name: String
    let desc: String
}

struct Reaction: Codable {
    let name: String
    let desc: String
}

// MARK: - Monster Extensions
extension Monster {
    var sizeTypeAlignment: String {
        var result = size
        if !type.isEmpty {
            result += ", \(type)"
        }
        if let subtype = subtype, !subtype.isEmpty {
            result += " (\(subtype))"
        }
        if !alignment.isEmpty {
            result += ", \(alignment)"
        }
        return result
    }
    
    var abilityModifier: (Int) -> String {
        return { score in
            let modifier = (score - 10) / 2
            return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
        }
    }
    
    var strengthModifier: String { abilityModifier(strength) }
    var dexterityModifier: String { abilityModifier(dexterity) }
    var constitutionModifier: String { abilityModifier(constitution) }
    var intelligenceModifier: String { abilityModifier(intelligence) }
    var wisdomModifier: String { abilityModifier(wisdom) }
    var charismaModifier: String { abilityModifier(charisma) }

    // Бонус мастерства на основе уровня опасности
    var proficiencyBonus: Int {
        switch challengeRating {
        case "0", "1/8", "1/4", "1/2": return 2
        case "1", "2": return 3
        case "3", "4": return 4
        case "5", "6", "7", "8": return 5
        case "9", "10", "11", "12": return 6
        case "13", "14", "15", "16": return 7
        case "17", "18", "19", "20": return 8
        default: return 2
        }
    }

    // Пассивное восприятие
    var passivePerception: Int {
        let wisMod = (wisdom - 10) / 2
        // Если есть навык Perception, добавляем бонус мастерства
        if let skills = skills, skills.contains("Perception") {
            // Ищем значение Perception в навыках
            let skillComponents = skills.components(separatedBy: ", ")
            for component in skillComponents {
                if component.contains("Perception") {
                    let parts = component.components(separatedBy: ": ")
                    if parts.count > 1, let skillBonus = Int(parts[1]) {
                        return 10 + skillBonus
                    }
                }
            }
        }
        return 10 + wisMod
    }
}