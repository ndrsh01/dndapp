import Foundation

struct Equipment: Codable {
    let optionA: [String]
    let optionB: [String]
    
    enum CodingKeys: String, CodingKey {
        case optionA = "option_a"
        case optionB = "option_b"
    }
}
