import Foundation

struct Monster: Codable, Identifiable {
    let id = UUID()
    let name: String
    let slug: String?
    let url: String?
    let image: String?
    let subtitle: String?
    let size: String
    let type: String
    let alignment: String
    let armorClass: Int?
    let hitPoints: Int?
    let hitDice: String?
    let speed: String
    let strength: Int?
    let dexterity: Int?
    let constitution: Int?
    let intelligence: Int?
    let wisdom: Int?
    let charisma: Int?
    let skills: String?
    let saves: String?
    let damageResistances: String?
    let damageImmunities: String?
    let damageVulnerabilities: String?
    let conditionImmunities: String?
    let senses: String?
    let languages: String?
    let challengeRating: String?
    let xp: Int?
    let challengeRaw: String?
    let proficiencyBonus: String?
    let challengeSpecial: String?
    let specialAbilities: [SpecialAbility]?
    let actions: [Action]?
    let legendaryActions: [LegendaryAction]?
    let reactions: [Reaction]?
    
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name, slug, url, image, subtitle, size, type, alignment
        case ac, hp, speed, skills, saves
        case damageResistances = "damage_resistances"
        case damageImmunities = "damage_immunities"
        case damageVulnerabilities = "damage_vulnerabilities"
        case conditionImmunities = "condition_immunities"
        case senses, languages
        case challenge = "challenge"
        case abilities, blocks
    }
    
    private enum ACKeys: String, CodingKey {
        case ac
    }
    
    private enum HPKeys: String, CodingKey {
        case hp, formula
    }
    
    private enum ChallengeKeys: String, CodingKey {
        case cr, xp, raw, proficiencyBonus = "proficiency_bonus", special
    }
    
    private enum AbilitiesKeys: String, CodingKey {
        case str, dex, con, int, wis, cha
    }
    
    private enum AbilityKeys: String, CodingKey {
        case score
    }
    
    private enum SpeedKeys: String, CodingKey {
        case walk
    }
    
    private enum AbilityScoreKeys: String, CodingKey {
        case score
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Initialize all properties explicitly
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        size = try container.decodeIfPresent(String.self, forKey: .size)?.nilIfEmpty ?? "Средний"
        type = try container.decodeIfPresent(String.self, forKey: .type)?.nilIfEmpty ?? "Неизвестно"
        alignment = try container.decodeIfPresent(String.self, forKey: .alignment)?.nilIfEmpty ?? "Неизвестно"

        // Parse JSON data and initialize properties


        // Initialize properties with parsed JSON data or defaults
        let acContainer = try? container.nestedContainer(keyedBy: ACKeys.self, forKey: .ac)
        armorClass = acContainer.flatMap { try? $0.decode(Int.self, forKey: .ac) } ?? 10

        let hpContainer = try? container.nestedContainer(keyedBy: HPKeys.self, forKey: .hp)
        hitPoints = hpContainer.flatMap { try? $0.decode(Int.self, forKey: .hp) } ?? 10
        hitDice = hpContainer.flatMap { try? $0.decodeIfPresent(String.self, forKey: .formula) } ?? "1d8"

        let speedDict = try? container.decodeIfPresent([String: String].self, forKey: .speed)
        speed = speedDict?["walk"] ?? "30 футов"

        let abilitiesContainer = try? container.nestedContainer(keyedBy: AbilitiesKeys.self, forKey: .abilities)
        strength = abilitiesContainer.flatMap { try? $0.nestedContainer(keyedBy: AbilityKeys.self, forKey: .str).decode(Int.self, forKey: .score) } ?? 10
        dexterity = abilitiesContainer.flatMap { try? $0.nestedContainer(keyedBy: AbilityKeys.self, forKey: .dex).decode(Int.self, forKey: .score) } ?? 10
        constitution = abilitiesContainer.flatMap { try? $0.nestedContainer(keyedBy: AbilityKeys.self, forKey: .con).decode(Int.self, forKey: .score) } ?? 10
        intelligence = abilitiesContainer.flatMap { try? $0.nestedContainer(keyedBy: AbilityKeys.self, forKey: .int).decode(Int.self, forKey: .score) } ?? 10
        wisdom = abilitiesContainer.flatMap { try? $0.nestedContainer(keyedBy: AbilityKeys.self, forKey: .wis).decode(Int.self, forKey: .score) } ?? 10
        charisma = abilitiesContainer.flatMap { try? $0.nestedContainer(keyedBy: AbilityKeys.self, forKey: .cha).decode(Int.self, forKey: .score) } ?? 10

        let skillsDict = try? container.decodeIfPresent([String: String].self, forKey: .skills)
        skills = skillsDict?.map { "\($0.key): \($0.value)" }.joined(separator: ", ")

        let savesDict = try? container.decodeIfPresent([String: String].self, forKey: .saves)
        saves = savesDict?.map { "\($0.key): \($0.value)" }.joined(separator: ", ")

        damageResistances = (try? container.decodeIfPresent(String.self, forKey: .damageResistances)) ?? nil
        damageImmunities = (try? container.decodeIfPresent(String.self, forKey: .damageImmunities)) ?? nil
        damageVulnerabilities = (try? container.decodeIfPresent(String.self, forKey: .damageVulnerabilities)) ?? nil
        conditionImmunities = (try? container.decodeIfPresent(String.self, forKey: .conditionImmunities)) ?? nil
        senses = (try? container.decodeIfPresent(String.self, forKey: .senses)) ?? nil
        languages = (try? container.decodeIfPresent(String.self, forKey: .languages)) ?? nil

        let challengeContainer = try? container.nestedContainer(keyedBy: ChallengeKeys.self, forKey: .challenge)
        if let crString = try? challengeContainer?.decode(String.self, forKey: .cr) {
            challengeRating = crString
        } else if let crInt = try? challengeContainer?.decode(Int.self, forKey: .cr) {
            challengeRating = String(crInt)
        } else {
            challengeRating = "1/8"
        }
        xp = try? challengeContainer?.decodeIfPresent(Int.self, forKey: .xp)
        challengeRaw = try? challengeContainer?.decodeIfPresent(String.self, forKey: .raw)
        proficiencyBonus = try? challengeContainer?.decodeIfPresent(String.self, forKey: .proficiencyBonus)
        challengeSpecial = try? challengeContainer?.decodeIfPresent(String.self, forKey: .special)

        let blocksContainer = try? container.decodeIfPresent(MonsterBlocks.self, forKey: .blocks)
        actions = blocksContainer?.actions
        legendaryActions = blocksContainer?.legendaryActions

        specialAbilities = nil
        reactions = nil
        isFavorite = false
    }
    
}

// Extension to handle empty strings
extension String {
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
}

extension Monster {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(slug, forKey: .slug)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
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
        var abilitiesContainer = container.nestedContainer(keyedBy: AbilitiesKeys.self, forKey: .abilities)
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
        
        // Encode saves
        if let saves = saves {
            var savesDict: [String: String] = [:]
            let savePairs = saves.components(separatedBy: ", ").compactMap { save -> (String, String)? in
                let parts = save.components(separatedBy: ": ")
                guard parts.count >= 1 else { return nil }
                return (parts[0], parts.count > 1 ? parts[1] : "")
            }
            for (key, value) in savePairs {
                savesDict[key] = value
            }
            try container.encode(savesDict, forKey: .saves)
        }
        
        try container.encodeIfPresent(damageResistances, forKey: .damageResistances)
        try container.encodeIfPresent(damageImmunities, forKey: .damageImmunities)
        try container.encodeIfPresent(damageVulnerabilities, forKey: .damageVulnerabilities)
        try container.encodeIfPresent(conditionImmunities, forKey: .conditionImmunities)
        try container.encodeIfPresent(senses, forKey: .senses)
        try container.encodeIfPresent(languages, forKey: .languages)
        
        // Encode challenge rating
        var challengeContainer = container.nestedContainer(keyedBy: ChallengeKeys.self, forKey: .challenge)
        try challengeContainer.encode(challengeRating, forKey: .cr)
        try challengeContainer.encodeIfPresent(xp, forKey: .xp)
        try challengeContainer.encodeIfPresent(challengeRaw, forKey: .raw)
        try challengeContainer.encodeIfPresent(proficiencyBonus, forKey: .proficiencyBonus)
        try challengeContainer.encodeIfPresent(challengeSpecial, forKey: .special)
        
        // Encode actions
        if let actions = actions {
            let blocks = MonsterBlocks(actions: actions, legendaryActions: legendaryActions)
            try container.encode(blocks, forKey: .blocks)
        }
    }
}

struct MonsterBlocks: Codable {
    let actions: [Action]?
    let legendaryActions: [LegendaryAction]?
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
        if !alignment.isEmpty {
            result += ", \(alignment)"
        }
        return result
    }
    
    var abilityModifier: (Int?) -> String {
        return { score in
            let actualScore = score ?? 10
            let modifier = (actualScore - 10) / 2
            return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
        }
    }

    var strengthModifier: String { abilityModifier(strength) }
    var dexterityModifier: String { abilityModifier(dexterity) }
    var constitutionModifier: String { abilityModifier(constitution) }
    var intelligenceModifier: String { abilityModifier(intelligence) }
    var wisdomModifier: String { abilityModifier(wisdom) }
    var charismaModifier: String { abilityModifier(charisma) }
<<<<<<< Updated upstream
=======

    // Бонус мастерства на основе уровня опасности
    var proficiencyBonusValue: Int {
        let cr = challengeRating ?? "1/8"
        switch cr {
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
        let wisMod = ((wisdom ?? 10) - 10) / 2
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
>>>>>>> Stashed changes
}