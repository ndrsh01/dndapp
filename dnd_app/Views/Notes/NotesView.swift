import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showAddNote = false
    @State private var editingNote: Note?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Поиск заметок...")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Category Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            Button(action: {
                                viewModel.selectCategory(category)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .font(.caption)
                                .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedCategory == category ? Color.orange : Color(.systemGray6))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                
                // Notes List
                if viewModel.filteredNotes.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "note.text",
                        title: "Нет заметок",
                        description: "Добавьте свою первую заметку для отслеживания важной информации",
                        actionTitle: "Добавить заметку",
                        action: {
                            showAddNote = true
                        }
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredNotes) { note in
                                NoteCardView(note: note)
                                    .contextMenu(
                                        onEdit: {
                                            editingNote = note
                                        },
                                        onDelete: {
                                            viewModel.deleteNote(note)
                                        },
                                        onDuplicate: {
                                            viewModel.duplicateNote(note)
                                        }
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Заметки")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddNote = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddNote) {
            AddNoteView { note in
                viewModel.addNote(note)
            }
        }
        .sheet(item: $editingNote) { note in
            EditNoteView(note: note) { updatedNote in
                viewModel.updateNote(updatedNote)
            }
        }
    }
}

struct NoteCardView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !note.description.isEmpty {
                        Text(note.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(note.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor.opacity(0.8))
                        .cornerRadius(6)
                    
                    Text(note.dateCreated, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var categoryColor: Color {
        switch note.category {
        case .all:
            return .blue
        case .places:
            return .green
        case .people:
            return .purple
        case .enemies:
            return .red
        case .items:
            return .orange
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var category: NoteCategory = .items
    
    let onSave: (Note) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Заголовок", text: $title)
                    TextField("Содержание", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $category) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let note = Note(
                            title: title,
                            description: content,
                            category: category
                        )
                        onSave(note)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var content: String
    @State private var category: NoteCategory
    
    let note: Note
    let onSave: (Note) -> Void
    
    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.description)
        self._category = State(initialValue: note.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Заголовок", text: $title)
                    TextField("Содержание", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $category) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Редактировать заметку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        var updatedNote = note
                        updatedNote.title = title
                        updatedNote.description = content
                        updatedNote.category = category
                        updatedNote.dateModified = Date()
                        onSave(updatedNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NotesView()
}