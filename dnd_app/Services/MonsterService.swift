import Foundation
import Combine

class MonsterService: ObservableObject {
    static let shared = MonsterService()
    
    @Published var monsters: [Monster] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {
        // Don't load automatically in init
    }
    
    func loadMonsters() async {
        isLoading = true
        error = nil

        do {
            let monsters = try parseNDJSON()

            await MainActor.run {
                self.monsters = monsters
                self.isLoading = false
                print("Loaded \(monsters.count) monsters successfully")
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
                print("Failed to load monsters: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseNDJSON() throws -> [Monster] {
        guard let url = Bundle.main.url(forResource: "bestiary_5e", withExtension: "ndjson") else {
            throw MonsterServiceError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let content = String(data: data, encoding: .utf8) ?? ""
        
        let lines = content.components(separatedBy: .newlines)
        var monsters: [Monster] = []
        var parseErrors = 0

        print("Starting to parse \(lines.count) lines from bestiary file")

        for line in lines {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }

            guard let lineData = line.data(using: .utf8) else { continue }

            do {
                let monster = try JSONDecoder().decode(Monster.self, from: lineData)
                monsters.append(monster)
            } catch {
                parseErrors += 1
                if parseErrors <= 5 { // Log only first 5 errors to avoid spam
                    print("Failed to parse monster: \(error)")
                }
            }
        }

        print("Successfully parsed \(monsters.count) monsters, \(parseErrors) parse errors")
        return monsters.sorted { $0.name < $1.name }
    }
    
    func searchMonsters(query: String) -> [Monster] {
        guard !query.isEmpty else { return monsters }
        
        let queryLower = query.lowercased()
        return monsters.filter { monster in
            monster.name.lowercased().hasPrefix(queryLower) ||
            monster.type.lowercased().hasPrefix(queryLower) ||
            monster.alignment.lowercased().hasPrefix(queryLower) ||
            monster.name.lowercased().contains(queryLower) ||
            monster.type.lowercased().contains(queryLower) ||
            monster.alignment.lowercased().contains(queryLower)
        }
    }
    
    func filterMonsters(by type: MonsterType) -> [Monster] {
        switch type {
        case .all:
            return monsters
        case .aberration:
            return monsters.filter { $0.type.lowercased().contains("aberration") }
        case .beast:
            return monsters.filter { $0.type.lowercased().contains("beast") }
        case .celestial:
            return monsters.filter { $0.type.lowercased().contains("celestial") }
        case .construct:
            return monsters.filter { $0.type.lowercased().contains("construct") }
        case .dragon:
            return monsters.filter { $0.type.lowercased().contains("dragon") }
        case .elemental:
            return monsters.filter { $0.type.lowercased().contains("elemental") }
        case .fey:
            return monsters.filter { $0.type.lowercased().contains("fey") }
        case .fiend:
            return monsters.filter { $0.type.lowercased().contains("fiend") }
        case .giant:
            return monsters.filter { $0.type.lowercased().contains("giant") }
        case .humanoid:
            return monsters.filter { $0.type.lowercased().contains("humanoid") }
        case .monstrosity:
            return monsters.filter { $0.type.lowercased().contains("monstrosity") }
        case .ooze:
            return monsters.filter { $0.type.lowercased().contains("ooze") }
        case .plant:
            return monsters.filter { $0.type.lowercased().contains("plant") }
        case .undead:
            return monsters.filter { $0.type.lowercased().contains("undead") }
        }
    }
    
    func toggleFavorite(_ monster: Monster) {
        if let index = monsters.firstIndex(where: { $0.id == monster.id }) {
            monsters[index].isFavorite.toggle()
        }
    }
}

enum MonsterType: String, CaseIterable {
    case all = "Все"
    case aberration = "Аберрация"
    case beast = "Зверь"
    case celestial = "Небожитель"
    case construct = "Конструкт"
    case dragon = "Дракон"
    case elemental = "Элементаль"
    case fey = "Фея"
    case fiend = "Исчадие"
    case giant = "Великан"
    case humanoid = "Гуманоид"
    case monstrosity = "Чудовище"
    case ooze = "Слизь"
    case plant = "Растение"
    case undead = "Нежить"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .aberration: return "brain.head.profile"
        case .beast: return "pawprint"
        case .celestial: return "star.circle"
        case .construct: return "gear"
        case .dragon: return "flame"
        case .humanoid: return "person.2"
        case .undead: return "skull"
        case .elemental: return "wind"
        case .fey: return "sparkles"
        case .fiend: return "exclamationmark.triangle"
        case .giant: return "person.3"
        case .monstrosity: return "eye"
        case .ooze: return "drop"
        case .plant: return "leaf"
        }
    }
}

enum MonsterServiceError: Error, LocalizedError {
    case fileNotFound
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Файл бестиария не найден"
        case .parsingError:
            return "Ошибка при парсинге данных"
        }
    }
}
