// Test monster parsing
import Foundation

let jsonString = """
{"name": "Test Monster", "size": "medium", "type": "humanoid", "alignment": "neutral", "armorClass": 15, "hitPoints": 30, "speed": "30 ft", "strength": 14, "dexterity": 12, "constitution": 13, "intelligence": 10, "wisdom": 11, "charisma": 8}
"""

struct TestMonster: Codable {
    let name: String
    let size: String
    let type: String
    let alignment: String
    let armorClass: Int
    let hitPoints: Int
    let speed: String
    let strength: Int
    let dexterity: Int
    let constitution: Int
    let intelligence: Int
    let wisdom: Int
    let charisma: Int
}

if let data = jsonString.data(using: .utf8) {
    do {
        let monster = try JSONDecoder().decode(TestMonster.self, from: data)
        print("✓ Successfully parsed test monster: \(monster.name)")
    } catch {
        print("✗ Failed to parse test monster: \(error)")
    }
} else {
    print("✗ Cannot convert string to data")
}
