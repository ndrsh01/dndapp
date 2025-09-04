import Foundation
import Combine

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: NoteCategory = .all
    @Published var showAddNote = false
    @Published var editingNote: Note?
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$notes
            .assign(to: \.notes, on: self)
            .store(in: &cancellables)
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
