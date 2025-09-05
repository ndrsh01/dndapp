import Foundation

struct Relationship: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var relationshipLevel: Int // 0-10, где 0-4 враги, 5 нейтрал, 6-10 друзья
    var isAlive: Bool
    var organization: String?
    var dateCreated: Date
    var dateModified: Date
    
    init(name: String, description: String = "", relationshipLevel: Int = 5, isAlive: Bool = true, organization: String? = nil) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.relationshipLevel = relationshipLevel
        self.isAlive = isAlive
        self.organization = organization
        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    // Инициализатор для дублирования с новым ID
    init(duplicating relationship: Relationship) {
        self.id = UUID() // Новый уникальный ID
        self.name = "\(relationship.name) (копия)"
        self.description = relationship.description
        self.relationshipLevel = relationship.relationshipLevel
        self.isAlive = relationship.isAlive
        self.organization = relationship.organization
        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    var isFriend: Bool {
        relationshipLevel >= 6
    }
    
    var isEnemy: Bool {
        relationshipLevel <= 4
    }
    
    var isNeutral: Bool {
        relationshipLevel == 5
    }
    
    var relationshipStatus: RelationshipStatus {
        if isFriend {
            return .friend
        } else if isEnemy {
            return .enemy
        } else {
            return .neutral
        }
    }
}

enum RelationshipStatus {
    case friend
    case neutral
    case enemy
    
    var icon: String {
        switch self {
        case .friend: return "heart.fill"
        case .neutral: return "circle.fill"
        case .enemy: return "xmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .friend: return "red"
        case .neutral: return "gray"
        case .enemy: return "black"
        }
    }
}
