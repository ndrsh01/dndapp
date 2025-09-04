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
        case name, size, type, subtype, alignment
        case armorClass = "armor_class"
        case hitPoints = "hit_points"
        case hitDice = "hit_dice"
        case speed, strength, dexterity, constitution, intelligence, wisdom, charisma
        case skills
        case damageResistances = "damage_resistances"
        case damageImmunities = "damage_immunities"
        case conditionImmunities = "condition_immunities"
        case senses, languages
        case challengeRating = "challenge_rating"
        case xp
        case specialAbilities = "special_abilities"
        case actions
        case legendaryActions = "legendary_actions"
        case reactions
    }
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
        case name, desc
        case attackBonus = "attack_bonus"
        case damageDice = "damage_dice"
        case damageBonus = "damage_bonus"
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
}
