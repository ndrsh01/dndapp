import Foundation

struct TabaxiImages {
    static let maxImageCount = 24
    
    static func getRandomImageName() -> String {
        let randomIndex = Int.random(in: 1...maxImageCount)
        return "tabaxi_pose\(randomIndex)"
    }
    
    static func getAllImageNames() -> [String] {
        return (1...maxImageCount).map { "tabaxi_pose\($0)" }
    }
}
