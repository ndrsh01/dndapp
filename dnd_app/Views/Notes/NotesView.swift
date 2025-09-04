import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showAddNote = false
    @State private var editingNote: Note?
    
    var body: some View {
        NavigationView {
            VStack {
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
                
                // Notes List
                if viewModel.filteredNotes.isEmpty {
                    EmptyStateView(
                        icon: "note.text",
                        title: "Нет заметок",
                        description: "Добавьте свою первую заметку для отслеживания важной информации",
                        actionTitle: "Добавить заметку",
                        action: {
                            showAddNote = true
                        }
                    )
                } else {
                    List {
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
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            // Category Badge
                            HStack(spacing: 4) {
                                Image(systemName: note.category.icon)
                                    .font(.caption2)
                                Text(note.category.rawValue)
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(note.category.color))
                            .cornerRadius(8)
                            
                            // Importance Indicator
                            ImportanceIndicator(importance: note.importance) { _ in
                                // TODO: Allow editing importance
                            }
                            
                            Spacer()
                            
                            // Status Indicator
                            Image(systemName: note.isAlive ? "heart.fill" : "xmark.circle.fill")
                                .foregroundColor(note.isAlive ? .red : .black)
                                .font(.caption)
                        }
                    }
                }
                
                if !note.description.isEmpty {
                    Text(note.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                HStack {
                    Text(note.dateModified, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(16)
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var importance = 3
    @State private var category: NoteCategory = .all
    @State private var isAlive = true
    
    let onSave: (Note) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Заголовок", text: $title)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...8)
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
                
                Section("Важность") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Уровень важности")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ImportanceIndicator(importance: importance) { level in
                            importance = level
                        }
                    }
                }
                
                Section("Статус") {
                    Toggle("Жив", isOn: $isAlive)
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
                            description: description,
                            importance: importance,
                            category: category,
                            isAlive: isAlive
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
    @State private var description: String
    @State private var importance: Int
    @State private var category: NoteCategory
    @State private var isAlive: Bool
    
    let note: Note
    let onSave: (Note) -> Void
    
    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        self._title = State(initialValue: note.title)
        self._description = State(initialValue: note.description)
        self._importance = State(initialValue: note.importance)
        self._category = State(initialValue: note.category)
        self._isAlive = State(initialValue: note.isAlive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Заголовок", text: $title)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...8)
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
                
                Section("Важность") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Уровень важности")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ImportanceIndicator(importance: importance) { level in
                            importance = level
                        }
                    }
                }
                
                Section("Статус") {
                    Toggle("Жив", isOn: $isAlive)
                }
            }
            .navigationTitle("Редактировать")
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
                        updatedNote.description = description
                        updatedNote.importance = importance
                        updatedNote.category = category
                        updatedNote.isAlive = isAlive
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
