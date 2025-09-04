import Foundation
import Combine

class CharacterViewModel: ObservableObject {
    @Published var characters: [DnDCharacter] = []
    @Published var selectedCharacter: DnDCharacter?
    @Published var showCharacterSelection = false
    @Published var showAddCharacter = false
    @Published var editingCharacter: DnDCharacter?
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadSelectedCharacter()
    }
    
    private func setupBindings() {
        dataService.$characters
            .assign(to: \.characters, on: self)
            .store(in: &cancellables)
    }
    
    private func loadSelectedCharacter() {
        selectedCharacter = dataService.getSelectedCharacter()
    }
    
    func addCharacter(_ character: DnDCharacter) {
        dataService.addCharacter(character)
        if selectedCharacter == nil {
            selectCharacter(character)
        }
    }
    
    func updateCharacter(_ character: DnDCharacter) {
        dataService.updateCharacter(character)
        if selectedCharacter?.id == character.id {
            selectedCharacter = character
        }
    }
    
    func deleteCharacter(_ character: DnDCharacter) {
        dataService.deleteCharacter(character)
        if selectedCharacter?.id == character.id {
            selectedCharacter = characters.first
            if let newSelected = selectedCharacter {
                dataService.setSelectedCharacter(newSelected)
            }
        }
    }
    
    func duplicateCharacter(_ character: DnDCharacter) {
        dataService.duplicateCharacter(character)
    }
    
    func selectCharacter(_ character: DnDCharacter) {
        selectedCharacter = character
        dataService.setSelectedCharacter(character)
    }
    
    func showCharacterSelectionView() {
        showCharacterSelection = true
    }
    
    func showAddCharacterView() {
        showAddCharacter = true
    }
    
    func showEditCharacterView(_ character: DnDCharacter) {
        editingCharacter = character
    }
    
    // MARK: - Character Import/Export
    func exportCharacter(_ character: DnDCharacter) -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(character)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to export character: \(error)")
            return nil
        }
    }
    
    func importCharacter(from jsonString: String) -> DnDCharacter? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            let character = try decoder.decode(DnDCharacter.self, from: data)
            return character
        } catch {
            print("Failed to import character: \(error)")
            return nil
        }
    }
}
