import Foundation
import Combine

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: NoteCategory = .all
    @Published var showAddNote = false
    @Published var editingNote: Note?
    @Published var selectedCharacterId: UUID?
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Подписываемся на изменения заметок и персонажа
        Publishers.CombineLatest(dataService.$notes, $selectedCharacterId)
            .map { [weak self] notes, characterId in
                return self?.dataService.getNotes(for: characterId) ?? []
            }
            .assign(to: \.notes, on: self)
            .store(in: &cancellables)
    }
    
    func setSelectedCharacter(_ characterId: UUID?) {
        print("=== NOTES VIEWMODEL ===")
        print("Setting selected character for notes: \(characterId?.uuidString ?? "nil")")
        selectedCharacterId = characterId
        
        // Принудительно обновляем заметки
        let filteredNotes = dataService.getNotes(for: characterId)
        notes = filteredNotes
        
        print("Selected character set. Current notes count: \(notes.count)")
        print("Filtered notes: \(notes.map { $0.title })")
    }
    
    var filteredNotes: [Note] {
        let notes = selectedCategory == .all ? self.notes : self.notes.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return notes.sorted { $0.dateModified > $1.dateModified }
        } else {
            return notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.description.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dateModified > $1.dateModified }
        }
    }
    
    func addNote(_ note: Note) {
        dataService.addNote(note)
    }
    
    func updateNote(_ note: Note) {
        dataService.updateNote(note)
    }
    
    func deleteNote(_ note: Note) {
        dataService.deleteNote(note)
    }
    
    func duplicateNote(_ note: Note) {
        dataService.duplicateNote(note)
    }
    
    func selectCategory(_ category: NoteCategory) {
        selectedCategory = category
    }
    
    func showAddNoteView() {
        showAddNote = true
    }
    
    func showEditNoteView(_ note: Note) {
        editingNote = note
    }
}
