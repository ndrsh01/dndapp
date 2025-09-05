import Foundation
import Combine

class RelationshipsViewModel: ObservableObject {
    @Published var relationships: [Relationship] = []
    @Published var showAddRelationship = false
    @Published var editingRelationship: Relationship?
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$relationships
            .assign(to: \.relationships, on: self)
            .store(in: &cancellables)
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
    
    func showAddRelationshipView() {
        showAddRelationship = true
    }
    
    func showEditRelationshipView(_ relationship: Relationship) {
        editingRelationship = relationship
    }
}
