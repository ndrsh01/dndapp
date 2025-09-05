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
                                RelationshipCardView(relationship: relationship, viewModel: viewModel)
                                    .contextMenu {
                                        Button(action: {
                                            viewModel.setRelationshipType(relationship, type: .enemy)
                                        }) {
                                            Label("Враг", systemImage: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }

                                        Button(action: {
                                            viewModel.setRelationshipType(relationship, type: .neutral)
                                        }) {
                                            Label("Нейтрал", systemImage: "circle")
                                                .foregroundColor(.gray)
                                        }

                                        Button(action: {
                                            viewModel.setRelationshipType(relationship, type: .friend)
                                        }) {
                                            Label("Друг", systemImage: "heart.fill")
                                                .foregroundColor(.red)
                                        }

                                        Divider()

                                        Button(action: {
                                            editingRelationship = relationship
                                        }) {
                                            Label("Редактировать", systemImage: "pencil")
                                        }

                                        Button(action: {
                                            viewModel.deleteRelationship(relationship)
                                        }) {
                                            Label("Удалить", systemImage: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
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
                        print("Plus button tapped for relationships")
                        showAddRelationship = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
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
    let viewModel: RelationshipsViewModel?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(relationship.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let organization = relationship.organization, !organization.isEmpty {
                        Text(organization)
                            .font(.subheadline)
                            .foregroundColor(.blue.opacity(0.8))
                            .lineLimit(1)
                    }

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

            // Relationship Hearts - только для друзей, 10 сердечек
            if relationship.relationshipStatus == .friend {
                HStack(spacing: 4) {
                    ForEach(0..<10, id: \.self) { index in
                        Button(action: {
                            // Изменяем уровень отношений (6-10 для друзей)
                            let newLevel = index + 6
                            if let viewModel = viewModel {
                                viewModel.updateRelationshipLevel(relationship, level: newLevel)
                            }
                        }) {
                            Image(systemName: index < (relationship.relationshipLevel - 5) ? "heart.fill" : "heart")
                                .foregroundColor(index < (relationship.relationshipLevel - 5) ? .red : .gray.opacity(0.3))
                                .font(.title3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 8)
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
    @State private var organization = ""
    @State private var relationshipLevel = 5
    @State private var isAlive = true
    @State private var showOrganizationSuggestions = false

    let onSave: (Relationship) -> Void

    init(onSave: @escaping (Relationship) -> Void) {
        self.onSave = onSave
    }

    private var dataService = DataService.shared
    private var organizationSuggestions: [String] {
        if organization.isEmpty {
            return dataService.uniqueOrganizations
        } else {
            return dataService.uniqueOrganizations.filter {
                $0.localizedCaseInsensitiveContains(organization)
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя персонажа", text: $name)

                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .leading) {
                            TextField("Организация", text: $organization)
                                .onChange(of: organization) { _ in
                                    showOrganizationSuggestions = !organizationSuggestions.isEmpty
                                }

                            if organization.isEmpty {
                                Text("Организация (опционально)")
                                    .foregroundColor(.gray.opacity(0.7))
                                    .allowsHitTesting(false)
                            }
                        }

                        if showOrganizationSuggestions && !organizationSuggestions.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(organizationSuggestions.prefix(5), id: \.self) { suggestion in
                                        Button(action: {
                                            organization = suggestion
                                            showOrganizationSuggestions = false
                                            print("Selected organization suggestion: \(suggestion)")
                                        }) {
                                            HStack {
                                                Text(suggestion)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Image(systemName: "arrow.up.left")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .frame(maxHeight: 150)
                        }
                    }

                    ZStack(alignment: .bottomTrailing) {
                        TextField("Описание", text: $description, axis: .vertical)
                            .lineLimit(3...6)

                        // Оранжевая галочка в правом нижнем углу
                        Button(action: {
                            // Скрываем клавиатуру
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                        }
                        .padding(8)
                        .opacity(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1.0)
                        .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
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
    @State private var organization: String
    @State private var relationshipLevel: Int
    @State private var isAlive: Bool

    let relationship: Relationship
    let onSave: (Relationship) -> Void

    init(relationship: Relationship, onSave: @escaping (Relationship) -> Void) {
        self.relationship = relationship
        self.onSave = onSave
        self._name = State(initialValue: relationship.name)
        self._description = State(initialValue: relationship.description)
        self._organization = State(initialValue: relationship.organization ?? "")
        self._relationshipLevel = State(initialValue: relationship.relationshipLevel)
        self._isAlive = State(initialValue: relationship.isAlive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя персонажа", text: $name)
                    
                    TextField("Организация (опционально)", text: $organization)

                    ZStack(alignment: .bottomTrailing) {
                        TextField("Описание", text: $description, axis: .vertical)
                            .lineLimit(3...6)

                        // Оранжевая галочка в правом нижнем углу
                        Button(action: {
                            // Скрываем клавиатуру
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                        }
                        .padding(8)
                        .opacity(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1.0)
                        .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
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
                        updatedRelationship.organization = organization.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : organization.trimmingCharacters(in: .whitespacesAndNewlines)
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
