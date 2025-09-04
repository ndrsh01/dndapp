import SwiftUI

struct BestiaryView: View {
    @StateObject private var monsterService = MonsterService.shared
    @State private var searchText = ""
    @State private var selectedType: MonsterType = .all
    @State private var selectedChallengeRating: String? = nil
    @State private var showQuickFilters = false
    @State private var expandedMonsters: Set<UUID> = []
    @State private var isLoading = true
    
    var filteredMonsters: [Monster] {
        var filtered = monsterService.searchMonsters(query: searchText)
        
        // Фильтр по типу
        if selectedType != .all {
            filtered = filtered.filter { monster in
                switch selectedType {
                case .all:
                    return true
                case .beast:
                    return monster.type.lowercased().contains("beast") || monster.type.lowercased().contains("зверь")
                case .dragon:
                    return monster.type.lowercased().contains("dragon") || monster.type.lowercased().contains("дракон")
                case .humanoid:
                    return monster.type.lowercased().contains("humanoid") || monster.type.lowercased().contains("гуманоид")
                case .undead:
                    return monster.type.lowercased().contains("undead") || monster.type.lowercased().contains("нежить")
                case .fiend:
                    return monster.type.lowercased().contains("fiend") || monster.type.lowercased().contains("демон") || monster.type.lowercased().contains("devil") || monster.type.lowercased().contains("бес")
                }
            }
        }
        
        
        // Фильтр по рейтингу опасности
        if let challengeRating = selectedChallengeRating {
            filtered = filtered.filter { $0.challengeRating == challengeRating }
        }
        
        return filtered
    }
    
    
    var body: some View {
        ZStack {
            if isLoading {
                // Loading screen
                VStack(spacing: 20) {
                    Spacer()

                    VStack(spacing: 16) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                            .symbolEffect(.pulse)

                        Text("Загрузка бестиария...")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(1.5)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.98, green: 0.97, blue: 0.95))
                .transition(.opacity)
            } else {
                // Main content
                VStack(spacing: 0) {
                    // Header with title and filter button
                    HStack {
                        Text("Бестиарий")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                
                Spacer()

                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showQuickFilters.toggle()
                            }
                        }) {
                            Image(systemName: showQuickFilters ? "chevron.up" : "line.3.horizontal.decrease")
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
                        .padding(.bottom, showQuickFilters ? 8 : 16)

                    // Quick Filters (expandable)
                    if showQuickFilters {
                        VStack(spacing: 12) {
                            // Тип монстра
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach([MonsterType.all, .beast, .dragon, .humanoid, .undead, .fiend], id: \.self) { type in
                                        FilterButton(
                                            title: type.rawValue,
                                            icon: type.icon,
                                            isSelected: selectedType == type
                                        ) {
                                            selectedType = type
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            // Класс опасности
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterButton(
                                        title: "Все КО",
                                        icon: "star",
                                        isSelected: selectedChallengeRating == nil
                                    ) {
                                        selectedChallengeRating = nil
                                    }

                                    ForEach(["0", "1/8", "1/4", "1/2", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "30"], id: \.self) { rating in
                                        FilterButton(
                                            title: rating,
                                            icon: "star.fill",
                                            isSelected: selectedChallengeRating == rating
                                        ) {
                                            selectedChallengeRating = rating
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Active Filters
                    if selectedType != .all || selectedChallengeRating != nil {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if selectedType != .all {
                                    FilterTagView(
                                        text: selectedType.rawValue,
                                        onRemove: { selectedType = .all }
                                    )
                                }

                                if let challengeRating = selectedChallengeRating {
                                    FilterTagView(
                                        text: "КО: \(challengeRating)",
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
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .onAppear {
            Task {
                isLoading = true
                await monsterService.loadMonsters()
                // Добавляем небольшую задержку для плавности анимации
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 секунды
                isLoading = false
            }
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

struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Color.orange
                    : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                isSelected
                    ? .white
                    : .primary
            )
            .cornerRadius(20)
        }
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

                    Text("\(monster.size) \(monster.type)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if !monster.alignment.isEmpty {
                        Text(monster.alignment)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    }
                    
                    Spacer()
                    
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("КЗ \(monster.armorClass)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(6)

                        Text("ХП \(monster.hitPoints)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(6)
                    }

                    Text("КО \(monster.challengeRating)")
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
                StatView(title: "Скорость", value: monster.speed)
                StatView(title: "БМ", value: "+\(monster.proficiencyBonus)")
                StatView(title: "ПВ", value: "\(monster.passivePerception)")
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

                    // Damage Vulnerabilities, Resistances, Immunities
                    if let damageResistances = monster.damageResistances, !damageResistances.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Сопротивления урону")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(damageResistances)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    if let damageImmunities = monster.damageImmunities, !damageImmunities.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Иммунитет к урону")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(damageImmunities)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    if let conditionImmunities = monster.conditionImmunities, !conditionImmunities.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Иммунитет к состояниям")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(conditionImmunities)
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }

                    // Senses and Languages
                    if let senses = monster.senses, !senses.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Чувства")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(senses)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let languages = monster.languages, !languages.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Языки")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(languages)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Legendary Actions
                    if let legendaryActions = monster.legendaryActions, !legendaryActions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Легендарные действия")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            ForEach(legendaryActions.prefix(2), id: \.name) { action in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(action.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)

                                    Text(action.desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                }
                            }
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