import Foundation
import Combine

class RelationshipsViewModel: ObservableObject {
    @Published var relationships: [Relationship] = []
    @Published var showAddRelationship = false
    @Published var editingRelationship: Relationship?
    @Published var selectedCharacterId: UUID?
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Подписываемся на изменения отношений и персонажа
        Publishers.CombineLatest(dataService.$relationships, $selectedCharacterId)
            .map { [weak self] relationships, characterId in
                return self?.dataService.getRelationships(for: characterId) ?? []
            }
            .assign(to: \.relationships, on: self)
            .store(in: &cancellables)
    }
    
    func setSelectedCharacter(_ characterId: UUID?) {
        print("=== RELATIONSHIPS VIEWMODEL ===")
        print("Setting selected character for relationships: \(characterId?.uuidString ?? "nil")")
        selectedCharacterId = characterId
        
        // Принудительно обновляем отношения
        let filteredRelationships = dataService.getRelationships(for: characterId)
        relationships = filteredRelationships
        
        print("Selected character set. Current relationships count: \(relationships.count)")
        print("Filtered relationships: \(relationships.map { $0.name })")
    }
    
    func addRelationship(_ relationship: Relationship) {
        dataService.addRelationship(relationship)
    }
    
    func updateRelationship(_ relationship: Relationship) {
        dataService.updateRelationship(relationship)
    }
    
    func deleteRelationship(_ relationship: Relationship) {
        dataService.deleteRelationship(relationship)
    }
    
    func duplicateRelationship(_ relationship: Relationship) {
        dataService.duplicateRelationship(relationship)
    }
    
    func updateRelationshipLevel(_ relationship: Relationship, level: Int) {
        var updatedRelationship = relationship
        updatedRelationship.relationshipLevel = level
        updatedRelationship.dateModified = Date()
        updateRelationship(updatedRelationship)
    }
    
    func setRelationshipType(_ relationship: Relationship, type: RelationshipStatus) {
        var updatedRelationship = relationship
        switch type {
        case .enemy:
            updatedRelationship.relationshipLevel = 1 // Уровень для врага
        case .neutral:
            updatedRelationship.relationshipLevel = 5 // Уровень для нейтрала
        case .friend:
            updatedRelationship.relationshipLevel = 6 // Минимальный уровень для друга
        }
        updatedRelationship.dateModified = Date()
        updateRelationship(updatedRelationship)
    }
    
    func refreshRelationships() {
        print("=== REFRESH RELATIONSHIPS ===")
        print("Refreshing relationships for character: \(selectedCharacterId?.uuidString ?? "nil")")
        
        // Принудительно обновляем отношения
        let filteredRelationships = dataService.getRelationships(for: selectedCharacterId)
        relationships = filteredRelationships
        
        print("Relationships refreshed. Count: \(relationships.count)")
        print("Current relationships: \(relationships.map { $0.name })")
    }
    
    func showAddRelationshipView() {
        showAddRelationship = true
    }
    
    func showEditRelationshipView(_ relationship: Relationship) {
        editingRelationship = relationship
    }
}
