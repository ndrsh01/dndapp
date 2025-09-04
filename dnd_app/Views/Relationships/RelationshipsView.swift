import SwiftUI

struct RelationshipsView: View {
    @StateObject private var viewModel = RelationshipsViewModel()
    @State private var showAddRelationship = false
    @State private var editingRelationship: Relationship?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.relationships.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "Нет отношений",
                        description: "Добавьте отношения с персонажами для отслеживания ваших связей",
                        actionTitle: "Добавить отношение",
                        action: {
                            showAddRelationship = true
                        }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.relationships) { relationship in
                                RelationshipCardView(relationship: relationship)
                                    .relationshipContextMenu(
                                        onSetEnemy: { viewModel.setRelationshipType(relationship, type: .enemy) },
                                        onSetNeutral: { viewModel.setRelationshipType(relationship, type: .neutral) },
                                        onSetFriend: { viewModel.setRelationshipType(relationship, type: .friend) },
                                        onEdit: { editingRelationship = relationship },
                                        onDelete: { viewModel.deleteRelationship(relationship) }
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(relationship.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !relationship.description.isEmpty {
                        Text(relationship.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: relationship.isAlive ? "heart.fill" : "heart.slash")
                            .foregroundColor(relationship.isAlive ? .red : .gray)
                            .font(.caption)
                        
                        Text(relationship.isAlive ? "Жив" : "Мертв")
                            .font(.caption)
                            .foregroundColor(relationship.isAlive ? .red : .gray)
                    }
                    
                    Text(relationshipStatusText)
                        .font(.caption)
                        .foregroundColor(relationshipStatusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(relationshipStatusColor.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            // Relationship Hearts - только для друзей, 7 сердечек
            if relationship.relationshipStatus == .friend {
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        Button(action: {
                            // Здесь можно добавить логику для изменения уровня отношений
                            // Например, viewModel.setRelationshipLevel(relationship, level: index + 1)
                        }) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(index < relationship.relationshipLevel ? .red : .gray.opacity(0.3))
                                .font(.title3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var relationshipStatusText: String {
        switch relationship.relationshipStatus {
        case .enemy:
            return "Враг"
        case .neutral:
            return "Нейтрал"
        case .friend:
            return "Друг"
        }
    }
    
    private var relationshipStatusColor: Color {
        switch relationship.relationshipStatus {
        case .enemy:
            return .red
        case .neutral:
            return .gray
        case .friend:
            return .green
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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Уровень отношений:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(relationshipLevel)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(relationshipLevel) },
                            set: { relationshipLevel = Int($0) }
                        ), in: 0...10, step: 1)
                        .accentColor(.orange)
                        
                        Text("0: Нейтрал | 1: Враг | 2-10: Друзья")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Новое отношение")
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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Уровень отношений:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(relationshipLevel)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(relationshipLevel) },
                            set: { relationshipLevel = Int($0) }
                        ), in: 0...10, step: 1)
                        .accentColor(.orange)
                        
                        Text("0: Нейтрал | 1: Враг | 2-10: Друзья")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Редактировать отношение")
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
}

#Preview {
    RelationshipsView()
}