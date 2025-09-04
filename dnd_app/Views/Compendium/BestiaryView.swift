import SwiftUI

struct BestiaryView: View {
    @StateObject private var monsterService = MonsterService.shared
    @State private var searchText = ""
    @State private var selectedType: MonsterType = .all
    @State private var selectedSize: String? = nil
    @State private var selectedAlignment: String? = nil
    @State private var selectedChallengeRating: String? = nil
    @State private var showFilters = false
    @State private var expandedMonsters: Set<UUID> = []
    
    var filteredMonsters: [Monster] {
        var filtered = monsterService.searchMonsters(query: searchText)
        
        // Фильтр по типу
        if selectedType != .all {
            filtered = filtered.filter { monster in
                switch selectedType {
                case .all:
                    return true
                case .beast:
                    return monster.type.lowercased().contains("beast")
                case .dragon:
                    return monster.type.lowercased().contains("dragon")
                case .humanoid:
                    return monster.type.lowercased().contains("humanoid")
                case .undead:
                    return monster.type.lowercased().contains("undead")
                case .fiend:
                    return monster.type.lowercased().contains("fiend")
                }
            }
        }
        
        // Фильтр по размеру
        if let size = selectedSize {
            filtered = filtered.filter { $0.size == size }
        }
        
        // Фильтр по мировоззрению
        if let alignment = selectedAlignment {
            filtered = filtered.filter { $0.alignment == alignment }
        }
        
        // Фильтр по рейтингу опасности
        if let challengeRating = selectedChallengeRating {
            filtered = filtered.filter { $0.challengeRating == challengeRating }
        }
        
        return filtered
    }
    
    var availableSizes: [String] {
        let sizes = monsterService.monsters.map { $0.size }
        return Array(Set(sizes)).sorted()
    }
    
    var availableAlignments: [String] {
        let alignments = monsterService.monsters.map { $0.alignment }
        return Array(Set(alignments)).sorted()
    }
    
    var availableChallengeRatings: [String] {
        let challengeRatings = monsterService.monsters.map { $0.challengeRating }
        return Array(Set(challengeRatings)).sorted { first, second in
            // Sort by numeric value if possible
            if let firstNum = Double(first), let secondNum = Double(second) {
                return firstNum < secondNum
            }
            return first < second
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and filter button
            HStack {
                Text("Бестиарий")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showFilters = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            // Search Bar
            SearchBar(text: $searchText, placeholder: "Поиск монстров...")
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            
            // Active Filters
            if selectedType != .all || selectedSize != nil || selectedAlignment != nil || selectedChallengeRating != nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if selectedType != .all {
                            FilterTagView(
                                text: selectedType.rawValue,
                                onRemove: { selectedType = .all }
                            )
                        }
                        
                        if let size = selectedSize {
                            FilterTagView(
                                text: "Размер: \(size)",
                                onRemove: { selectedSize = nil }
                            )
                        }
                        
                        if let alignment = selectedAlignment {
                            FilterTagView(
                                text: "Мировоззрение: \(alignment)",
                                onRemove: { selectedAlignment = nil }
                            )
                        }
                        
                        if let challengeRating = selectedChallengeRating {
                            FilterTagView(
                                text: "Класс опасности: \(challengeRating)",
                                onRemove: { selectedChallengeRating = nil }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
            
            // Monsters List
            if filteredMonsters.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "pawprint",
                    title: "Нет монстров",
                    description: "Попробуйте изменить фильтры или поисковый запрос",
                    actionTitle: nil,
                    action: nil
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredMonsters) { monster in
                            MonsterCardView(
                                monster: monster,
                                isExpanded: expandedMonsters.contains(monster.id)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if expandedMonsters.contains(monster.id) {
                                        expandedMonsters.remove(monster.id)
                                    } else {
                                        expandedMonsters.insert(monster.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        .onAppear {
            Task {
                await monsterService.loadMonsters()
            }
        }
        .sheet(isPresented: $showFilters) {
            MonsterFiltersView(
                selectedType: $selectedType,
                selectedSize: $selectedSize,
                selectedAlignment: $selectedAlignment,
                selectedChallengeRating: $selectedChallengeRating,
                availableSizes: availableSizes,
                availableAlignments: availableAlignments,
                availableChallengeRatings: availableChallengeRatings
            )
        }
    }
}

struct FilterTagView: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .foregroundColor(.orange)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct MonsterCardView: View {
    let monster: Monster
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(monster.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(monster.sizeTypeAlignment)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("КЗ \(monster.armorClass)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(6)
                    
                    Text("КД \(monster.challengeRating)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(6)
                }
            }
            
            // Stats
            HStack(spacing: 16) {
                StatView(title: "ХП", value: "\(monster.hitPoints)")
                StatView(title: "Скорость", value: monster.speed)
                StatView(title: "Размер", value: monster.size)
            }
            
            // Expandable Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    // Abilities
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Характеристики")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 16) {
                            AbilityView(name: "СИЛ", score: monster.strength, modifier: monster.strengthModifier)
                            AbilityView(name: "ЛОВ", score: monster.dexterity, modifier: monster.dexterityModifier)
                            AbilityView(name: "ТЕЛ", score: monster.constitution, modifier: monster.constitutionModifier)
                            AbilityView(name: "ИНТ", score: monster.intelligence, modifier: monster.intelligenceModifier)
                            AbilityView(name: "МУД", score: monster.wisdom, modifier: monster.wisdomModifier)
                            AbilityView(name: "ХАР", score: monster.charisma, modifier: monster.charismaModifier)
                        }
                    }
                    
                    // Skills
                    if let skills = monster.skills, !skills.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Навыки")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(skills)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
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
    @Binding var selectedSize: String?
    @Binding var selectedAlignment: String?
    @Binding var selectedChallengeRating: String?
    @Environment(\.dismiss) private var dismiss
    
    let availableSizes: [String]
    let availableAlignments: [String]
    let availableChallengeRatings: [String]
    
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
                
                Section("Размер") {
                    HStack {
                        Text("Все размеры")
                        Spacer()
                        if selectedSize == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSize = nil
                    }
                    
                    ForEach(availableSizes, id: \.self) { size in
                        HStack {
                            Text(size)
                            Spacer()
                            if selectedSize == size {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSize = size
                        }
                    }
                }
                
                Section("Мировоззрение") {
                    HStack {
                        Text("Все мировоззрения")
                        Spacer()
                        if selectedAlignment == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedAlignment = nil
                    }
                    
                    ForEach(availableAlignments, id: \.self) { alignment in
                        HStack {
                            Text(alignment)
                            Spacer()
                            if selectedAlignment == alignment {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedAlignment = alignment
                        }
                    }
                }
                
                Section("Класс опасности") {
                    HStack {
                        Text("Все классы опасности")
                        Spacer()
                        if selectedChallengeRating == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedChallengeRating = nil
                    }
                    
                    ForEach(availableChallengeRatings, id: \.self) { challengeRating in
                        HStack {
                            Text(challengeRating)
                            Spacer()
                            if selectedChallengeRating == challengeRating {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedChallengeRating = challengeRating
                        }
                    }
                }
                
                Section {
                    Button("Сбросить все фильтры") {
                        selectedType = .all
                        selectedSize = nil
                        selectedAlignment = nil
                        selectedChallengeRating = nil
                    }
                    .foregroundColor(.red)
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

#Preview {
    BestiaryView()
}