import SwiftUI

struct BestiaryView: View {
    @StateObject private var monsterService = MonsterService.shared
    @State private var searchText = ""
    @State private var selectedType: MonsterType = .all
    @State private var showFilters = false
    @State private var expandedMonsters: Set<UUID> = []
    
    var filteredMonsters: [Monster] {
        let typeFiltered = monsterService.filterMonsters(by: selectedType)
        return monsterService.searchMonsters(query: searchText).filter { monster in
            typeFiltered.contains { $0.id == monster.id }
        }
    }
    
    var body: some View {
        VStack {
            // Search Bar
            SearchBar(text: $searchText, placeholder: "Поиск монстров...")
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            // Filters
            HStack {
                Button(action: {
                    showFilters = true
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text("Фильтры")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Monsters List
            if monsterService.isLoading {
                ProgressView("Загрузка монстров...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = monsterService.error {
                ErrorView(error: error) {
                    monsterService.loadMonsters()
                }
            } else if filteredMonsters.isEmpty {
                EmptyStateView(
                    icon: "pawprint",
                    title: "Монстры не найдены",
                    description: searchText.isEmpty ? "Нет монстров в базе данных" : "Попробуйте изменить поисковый запрос"
                )
            } else {
                List {
                    ForEach(filteredMonsters) { monster in
                        MonsterCardView(
                            monster: monster,
                            isExpanded: expandedMonsters.contains(monster.id)
                        ) {
                            toggleExpansion(for: monster)
                        }
                        .contextMenu(
                            onEdit: {
                                // TODO: Implement monster editing
                            },
                            onDelete: {
                                // TODO: Implement monster deletion
                            },
                            onDuplicate: {
                                // TODO: Implement monster duplication
                            }
                        )
                    }
                }
            }
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        .navigationTitle("Бестиарий")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showFilters) {
            MonsterFiltersView(selectedType: $selectedType)
        }
    }
    
    private func toggleExpansion(for monster: Monster) {
        if expandedMonsters.contains(monster.id) {
            expandedMonsters.remove(monster.id)
        } else {
            expandedMonsters.insert(monster.id)
        }
    }
}

struct MonsterCardView: View {
    let monster: Monster
    let isExpanded: Bool
    let onToggleExpansion: () -> Void
    @State private var isFavorite = false
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(monster.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(monster.sizeTypeAlignment)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isFavorite.toggle()
                        MonsterService.shared.toggleFavorite(monster)
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                    }
                }
                
                // Key Stats
                HStack(spacing: 20) {
                    StatItemView(icon: "shield", label: "КД", value: "\(monster.armorClass)", color: .blue)
                    StatItemView(icon: "heart.fill", label: "ХП", value: "\(monster.hitPoints)", color: .red)
                    StatItemView(icon: "star.fill", label: "CR", value: monster.challengeRating, color: .yellow)
                }
                
                // Abilities
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Характеристики")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 16) {
                            AbilityView(name: "СИЛ", score: monster.strength, modifier: monster.strengthModifier)
                            AbilityView(name: "ЛОВ", score: monster.dexterity, modifier: monster.dexterityModifier)
                            AbilityView(name: "ТЕЛ", score: monster.constitution, modifier: monster.constitutionModifier)
                            AbilityView(name: "ИНТ", score: monster.intelligence, modifier: monster.intelligenceModifier)
                            AbilityView(name: "МДР", score: monster.wisdom, modifier: monster.wisdomModifier)
                            AbilityView(name: "ХАР", score: monster.charisma, modifier: monster.charismaModifier)
                        }
                        
                        // Speed
                        if !monster.speed.isEmpty {
                            HStack {
                                Image(systemName: "figure.walk")
                                    .foregroundColor(.green)
                                Text("Скорость")
                                Text(monster.speed)
                                    .fontWeight(.medium)
                            }
                            .font(.caption)
                        }
                        
                        // Skills
                        if let skills = monster.skills, !skills.isEmpty {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.purple)
                                Text("Навыки")
                                Text(skills)
                                    .fontWeight(.medium)
                            }
                            .font(.caption)
                        }
                        
                        // Actions
                        if let actions = monster.actions, !actions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Действия")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                ForEach(actions.prefix(3), id: \.name) { action in
                                    ActionView(action: action)
                                }
                                
                                if actions.count > 3 {
                                    Text("... и еще \(actions.count - 3) действий")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Expand/Collapse Button
                Button(action: onToggleExpansion) {
                    HStack {
                        Text(isExpanded ? "Свернуть" : "Развернуть")
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }
            .padding(16)
        }
        .onAppear {
            isFavorite = monster.isFavorite
        }
    }
}

struct StatItemView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

struct AbilityView: View {
    let name: String
    let score: Int
    let modifier: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(name)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("\(score)")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(modifier)
                .font(.caption2)
                .foregroundColor(.orange)
        }
    }
}

struct ActionView: View {
    let action: Action
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(action.name)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(action.desc)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }
}

struct MonsterFiltersView: View {
    @Binding var selectedType: MonsterType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Тип монстра") {
                    ForEach(MonsterType.allCases, id: \.self) { type in
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text(type.rawValue)
                            
                            Spacer()
                            
                            if selectedType == type {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedType = type
                        }
                    }
                }
            }
            .navigationTitle("Фильтры")
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

struct ErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Ошибка загрузки")
                .font(.headline)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Повторить", action: onRetry)
                .buttonStyle(DnDButtonStyle(color: .orange))
        }
        .padding()
    }
}

#Preview {
    BestiaryView()
}
