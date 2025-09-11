import Foundation

// Модель для классов персонажа (мультикласс)
struct CharacterClass: Codable, Identifiable {
    let id: UUID
    var name: String
    var level: Int
    var subclass: String?

    init(name: String, level: Int, subclass: String? = nil) {
        self.id = UUID()
        self.name = name
        self.level = level
        self.subclass = subclass
    }
}

// Модель для эффектов и статусов
struct CharacterEffect: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var duration: Int // в раундах, -1 для постоянных
    var type: EffectType
    var remainingRounds: Int

    enum EffectType: String, Codable {
        case buff, debuff, condition
    }

    init(name: String, description: String, duration: Int, type: EffectType) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.duration = duration
        self.type = type
        self.remainingRounds = duration
    }

    var isExpired: Bool {
        return remainingRounds == 0 && duration != -1
    }

    mutating func advanceRound() {
        if duration != -1 && remainingRounds > 0 {
            remainingRounds -= 1
        }
    }
}
