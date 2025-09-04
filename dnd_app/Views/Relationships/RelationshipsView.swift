import SwiftUI

struct RelationshipsView: View {
    @StateObject private var viewModel = RelationshipsViewModel()
    @State private var showAddRelationship = false
    @State private var editingRelationship: Relationship?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.relationships.isEmpty {
                    // Пустое состояние согласно изображению
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Иконка людей
                        Image(systemName: "person.2")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        // Заголовок
                        Text("Нет персонажей")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // Описание
                        Text("Добавьте персонажей для отслеживания отношений")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                        
                        // Кнопка добавления
                        Button(action: {
                            showAddRelationship = true
                        }) {
                            Text("Добавить персонажа")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(25)
                        }
                        .padding(.bottom, 50)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.relationships) { relationship in
                            RelationshipCardView(relationship: relationship) { level in
                                viewModel.updateRelationshipLevel(relationship, level: level)
                            }
                            .contextMenu(
                                onEdit: {
                                    editingRelationship = relationship
                                },
                                onDelete: {
                                    viewModel.deleteRelationship(relationship)
                                },
                                onDuplicate: {
                                    viewModel.duplicateRelationship(relationship)
                                }
                            )
                        }
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Отношения")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddRelationship = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddRelationship) {
            AddRelationshipView { relationship in
                viewModel.addRelationship(relationship)
            }
        }
        .sheet(item: $editingRelationship) { relationship in
            EditRelationshipView(relationship: relationship) { updatedRelationship in
                viewModel.updateRelationship(updatedRelationship)
            }
        }
    }
}

struct RelationshipCardView: View {
    let relationship: Relationship
    let onLevelChange: (Int) -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(relationship.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if !relationship.description.isEmpty {
                            Text(relationship.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: relationship.isAlive ? "heart.fill" : "skull.fill")
                            .foregroundColor(relationship.isAlive ? .red : .black)
                            .font(.title2)
                        
                        Text(relationship.isAlive ? "Жив" : "Мертв")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Relationship Level Indicator
                VStack(alignment: .leading, spacing: 8) {
                    Text("Отношение")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    RelationshipIndicator(level: relationship.relationshipLevel) { level in
                        onLevelChange(level)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct AddRelationshipView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var relationshipLevel = 5
    @State private var isAlive = true
    
    let onSave: (Relationship) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя персонажа", text: $name)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Статус") {
                    Toggle("Жив", isOn: $isAlive)
                }
                
                Section("Отношение") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Уровень отношения")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        RelationshipIndicator(level: relationshipLevel) { level in
                            relationshipLevel = level
                        }
                        
                        Text(relationshipStatusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Новый персонаж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let relationship = Relationship(
                            name: name,
                            description: description,
                            relationshipLevel: relationshipLevel,
                            isAlive: isAlive
                        )
                        onSave(relationship)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private var relationshipStatusText: String {
        if relationshipLevel >= 6 {
            return "Друг"
        } else if relationshipLevel <= 4 {
            return "Враг"
        } else {
            return "Нейтрал"
        }
    }
}

struct EditRelationshipView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var description: String
    @State private var relationshipLevel: Int
    @State private var isAlive: Bool
    
    let relationship: Relationship
    let onSave: (Relationship) -> Void
    
    init(relationship: Relationship, onSave: @escaping (Relationship) -> Void) {
        self.relationship = relationship
        self.onSave = onSave
        self._name = State(initialValue: relationship.name)
        self._description = State(initialValue: relationship.description)
        self._relationshipLevel = State(initialValue: relationship.relationshipLevel)
        self._isAlive = State(initialValue: relationship.isAlive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя персонажа", text: $name)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Статус") {
                    Toggle("Жив", isOn: $isAlive)
                }
                
                Section("Отношение") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Уровень отношения")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        RelationshipIndicator(level: relationshipLevel) { level in
                            relationshipLevel = level
                        }
                        
                        Text(relationshipStatusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
                        var updatedRelationship = relationship
                        updatedRelationship.name = name
                        updatedRelationship.description = description
                        updatedRelationship.relationshipLevel = relationshipLevel
                        updatedRelationship.isAlive = isAlive
                        updatedRelationship.dateModified = Date()
                        onSave(updatedRelationship)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private var relationshipStatusText: String {
        if relationshipLevel >= 6 {
            return "Друг"
        } else if relationshipLevel <= 4 {
            return "Враг"
        } else {
            return "Нейтрал"
        }
    }
}

#Preview {
    RelationshipsView()
}
