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
    
    func loadMonsters() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let monsters = try self.parseNDJSON()
                
                DispatchQueue.main.async {
                    self.monsters = monsters
                    self.isLoading = false
                    print("Loaded \(monsters.count) monsters successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    print("Failed to load monsters: \(error.localizedDescription)")
                }
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
        
        return monsters.filter { monster in
            monster.name.localizedCaseInsensitiveContains(query) ||
            monster.type.localizedCaseInsensitiveContains(query) ||
            monster.alignment.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterMonsters(by type: MonsterType) -> [Monster] {
        switch type {
        case .all:
            return monsters
        case .beast:
            return monsters.filter { $0.type.lowercased().contains("beast") }
        case .dragon:
            return monsters.filter { $0.type.lowercased().contains("dragon") }
        case .humanoid:
            return monsters.filter { $0.type.lowercased().contains("humanoid") }
        case .undead:
            return monsters.filter { $0.type.lowercased().contains("undead") }
        case .fiend:
            return monsters.filter { $0.type.lowercased().contains("fiend") }
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
    case beast = "Звери"
    case dragon = "Драконы"
    case humanoid = "Гуманоиды"
    case undead = "Нежить"
    case fiend = "Демоны"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .beast: return "pawprint"
        case .dragon: return "flame"
        case .humanoid: return "person.2"
        case .undead: return "skull"
        case .fiend: return "exclamationmark.triangle"
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
