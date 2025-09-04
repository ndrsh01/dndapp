import SwiftUI

struct CharacterView: View {
    @StateObject private var viewModel = CharacterViewModel()
    @State private var showCharacterSelection = false
    @State private var showAddCharacter = false
    @State private var editingCharacter: DnDCharacter?
    
    var body: some View {
        NavigationView {
            VStack {
                if let character = viewModel.selectedCharacter {
                    CharacterSheetView(character: character) { updatedCharacter in
                        viewModel.updateCharacter(updatedCharacter)
                    }
                } else {
                    EmptyStateView(
                        icon: "person",
                        title: "Нет персонажа",
                        description: "Создайте или импортируйте персонажа для начала игры",
                        actionTitle: "Создать персонажа",
                        action: {
                            showAddCharacter = true
                        }
                    )
                }
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Персонаж")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showCharacterSelection = true
                    }) {
                        Image(systemName: "person.2")
                            .foregroundColor(.orange)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Создать персонажа") {
                            showAddCharacter = true
                        }
                        
                        Button("Импорт персонажа") {
                            // TODO: Implement character import
                        }
                        
                        if viewModel.selectedCharacter != nil {
                            Button("Экспорт персонажа") {
                                // TODO: Implement character export
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $showCharacterSelection) {
            CharacterSelectionView(
                characters: viewModel.characters,
                selectedCharacter: viewModel.selectedCharacter
            ) { character in
                viewModel.selectCharacter(character)
            }
        }
        .sheet(isPresented: $showAddCharacter) {
            AddCharacterView { character in
                viewModel.addCharacter(character)
            }
        }
        .sheet(item: $editingCharacter) { character in
            EditCharacterView(character: character) { updatedCharacter in
                viewModel.updateCharacter(updatedCharacter)
            }
        }
    }
}

struct CharacterSheetView: View {
    let character: DnDCharacter
    let onUpdate: (DnDCharacter) -> Void
    @State private var showEditView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Character Header
                CharacterHeaderView(character: character)
                
                // Health Section
                HealthSectionView(character: character) { updatedCharacter in
                    onUpdate(updatedCharacter)
                }
                
                // Main Stats
                MainStatsView(character: character) { updatedCharacter in
                    onUpdate(updatedCharacter)
                }
                
                // Combat Stats
                CombatStatsView(character: character) { updatedCharacter in
                    onUpdate(updatedCharacter)
                }
                
                // Skills
                SkillsView(character: character) { updatedCharacter in
                    onUpdate(updatedCharacter)
                }
                
                // Weapons
                WeaponsView(character: character) { updatedCharacter in
                    onUpdate(updatedCharacter)
                }
            }
            .padding(.horizontal, 16)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Редактировать") {
                    showEditView = true
                }
            }
        }
        .sheet(isPresented: $showEditView) {
            EditCharacterView(character: character) { updatedCharacter in
                onUpdate(updatedCharacter)
            }
        }
    }
}

struct CharacterHeaderView: View {
    let character: DnDCharacter
    
    var body: some View {
        CardView {
            HStack {
                // Character Avatar
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(character.info.race)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Уровень \(character.info.level)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text(character.info.charClass)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
}

struct HealthSectionView: View {
    let character: DnDCharacter
    let onUpdate: (DnDCharacter) -> Void
    @State private var currentHP: Int
    
    init(character: DnDCharacter, onUpdate: @escaping (DnDCharacter) -> Void) {
        self.character = character
        self.onUpdate = onUpdate
        self._currentHP = State(initialValue: character.vitality.hpMax)
    }
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("Хиты")
                        .font(.headline)
                }
                
                HStack {
                    Text("\(currentHP) / \(character.vitality.hpMax)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(Int(Double(currentHP) / Double(character.vitality.hpMax) * 100))% здоровья")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(currentHP), total: Double(character.vitality.hpMax))
                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
            }
            .padding(16)
        }
    }
}

struct MainStatsView: View {
    let character: DnDCharacter
    let onUpdate: (DnDCharacter) -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("Основные характеристики")
                        .font(.headline)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    StatCardView(stat: character.stats.str)
                    StatCardView(stat: character.stats.dex)
                    StatCardView(stat: character.stats.con)
                    StatCardView(stat: character.stats.int)
                    StatCardView(stat: character.stats.wis)
                    StatCardView(stat: character.stats.cha)
                }
            }
            .padding(16)
        }
    }
}

struct StatCardView: View {
    let stat: StatValue
    
    var body: some View {
        VStack(spacing: 4) {
            Text(stat.label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(stat.score)")
                .font(.title2)
                .fontWeight(.bold)
            
            if let modifier = stat.modifier {
                Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                    .font(.caption)
                    .foregroundColor(modifier >= 0 ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct CombatStatsView: View {
    let character: DnDCharacter
    let onUpdate: (DnDCharacter) -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.blue)
                    Text("Боевые характеристики")
                        .font(.headline)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    CombatStatView(title: "КЗ", value: "\(character.vitality.ac)")
                    CombatStatView(title: "Инициатива", value: "+\(character.stats.dex.modifier ?? 0)")
                    CombatStatView(title: "Скорость", value: "\(character.vitality.speed) фт.")
                    CombatStatView(title: "Спасбросок", value: "+2")
                }
            }
            .padding(16)
        }
    }
}

struct CombatStatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SkillsView: View {
    let character: DnDCharacter
    let onUpdate: (DnDCharacter) -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.green)
                    Text("Навыки")
                        .font(.headline)
                }
                
                // TODO: Implement skills display
                Text("Навыки будут добавлены в следующих версиях")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
    }
}

struct WeaponsView: View {
    let character: DnDCharacter
    let onUpdate: (DnDCharacter) -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sword")
                        .foregroundColor(.red)
                    Text("Оружие")
                        .font(.headline)
                }
                
                if character.weaponsList.isEmpty {
                    Text("Нет оружия")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(character.weaponsList) { weapon in
                        HStack {
                            Text(weapon.name)
                            Spacer()
                            Text(weapon.dmg)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct CharacterSelectionView: View {
    let characters: [DnDCharacter]
    let selectedCharacter: DnDCharacter?
    let onSelect: (DnDCharacter) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(characters) { character in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(character.name)
                                .font(.headline)
                            Text("\(character.info.race) - \(character.info.charClass)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedCharacter?.id == character.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(character)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Выбор персонажа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddCharacterView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (DnDCharacter) -> Void
    
    var body: some View {
        CharacterCreationView { character in
            onSave(character)
        }
    }
}

struct EditCharacterView: View {
    @Environment(\.dismiss) private var dismiss
    let character: DnDCharacter
    let onSave: (DnDCharacter) -> Void
    
    var body: some View {
        NavigationView {
            Text("Редактирование персонажа будет добавлено в следующих версиях")
                .navigationTitle("Редактировать")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Готово") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    CharacterView()
}
