import SwiftUI

struct BestiaryView: View {
    @StateObject private var dataService = DataService.shared
    @State private var searchText = ""
    @State private var selectedTypes: Set<MonsterType> = []
    @State private var selectedChallengeRatings: Set<String> = []
    @State private var showFilters = false
    @State private var expandedMonsters: Set<UUID> = []
    @Environment(\.colorScheme) private var colorScheme

    var filteredMonsters: [Monster] {
        let searchQuery = searchText.lowercased()
        var filtered = dataService.monsters
        
        print("=== FILTERING MONSTERS ===")
        print("Total monsters: \(dataService.monsters.count)")
        print("Search text: '\(searchText)'")
        print("Selected types: \(selectedTypes)")
        print("Selected CRs: \(selectedChallengeRatings)")
        
        // Если монстры не загружены, возвращаем пустой массив
        if dataService.monsters.isEmpty {
            print("No monsters loaded, returning empty array")
            return []
        }

        // Поиск
        if !searchText.isEmpty {
            filtered = filtered.filter { monster in
                let name = monster.name.lowercased()
                let type = monster.type.lowercased()

                return name.hasPrefix(searchQuery) || type.hasPrefix(searchQuery) ||
                       name.contains(searchQuery) || type.contains(searchQuery)
            }
        }

        // Фильтр по типу
        if !selectedTypes.isEmpty {
            filtered = filtered.filter { monster in
                selectedTypes.contains { type in
                    if type == .all {
                        return true
                    } else {
                        return monster.type.lowercased().contains(type.rawValue.lowercased())
                    }
                }
            }
        }

        // Фильтр по рейтингу опасности
        if !selectedChallengeRatings.isEmpty {
            filtered = filtered.filter { monster in
                guard let challengeRating = monster.challengeRating else { return false }
                return selectedChallengeRatings.contains(challengeRating)
            }
        }

        return filtered
    }


    var availableChallengeRatings: [String] {
        let challengeRatings = dataService.monsters.compactMap { $0.challengeRating }
        let uniqueRatings = Set(challengeRatings)
        let arrayFromSet = Array(uniqueRatings)
        return arrayFromSet.sorted { (first, second) in
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
            if !selectedTypes.isEmpty || !selectedChallengeRatings.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedTypes.filter { $0 != .all }), id: \.self) { type in
                            FilterTagView(
                                text: type.rawValue,
                                onRemove: { selectedTypes.remove(type) }
                            )
                        }

                        ForEach(Array(selectedChallengeRatings), id: \.self) { challengeRating in
                            FilterTagView(
                                text: "Класс опасности: \(challengeRating)",
                                onRemove: { selectedChallengeRatings.remove(challengeRating) }
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
                                isExpanded: expandedMonsters.contains(monster.id),
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        if expandedMonsters.contains(monster.id) {
                                            expandedMonsters.remove(monster.id)
                                        } else {
                                            expandedMonsters.insert(monster.id)
                                        }
                                    }
                                },
                                onToggleFavorite: { monster in
                                    dataService.toggleMonsterFavorite(monster, for: CharacterManager.shared.selectedCharacter?.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(adaptiveBackgroundColor)
        .onAppear {
            print("=== BESTIARY VIEW APPEARED ===")
            print("DataService monsters count: \(dataService.monsters.count)")
            
            // Принудительно загружаем монстров при каждом появлении
            Task {
                await dataService.loadMonsters()
                print("After load attempt: \(dataService.monsters.count) monsters")
                
                if !dataService.monsters.isEmpty {
                    print("First 3 monsters:")
                    for i in 0..<min(3, dataService.monsters.count) {
                        let monster = dataService.monsters[i]
                        print("  \(i+1). \(monster.name) (type: \(monster.type))")
                    }
                } else {
                    print("ERROR: Still no monsters after load attempt!")
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            MonsterFiltersView(
                selectedTypes: $selectedTypes,
                selectedChallengeRatings: $selectedChallengeRatings,
                availableChallengeRatings: availableChallengeRatings
            )
        }
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.systemBackground)
        case .light:
            return Color(red: 0.98, green: 0.97, blue: 0.95)
        @unknown default:
            return Color(UIColor.systemBackground)
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
    let onToggleFavorite: (Monster) -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(monster.name)
                            .font(.headline)
                            .fontWeight(.semibold)

                        if let url = monster.url, !url.isEmpty {
                            Button(action: {
                                if let urlObject = URL(string: url) {
                                    UIApplication.shared.open(urlObject)
                                }
                            }) {
                                Image(systemName: "link")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    Text("\(monster.size) \(monster.type)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: {
                    onToggleFavorite(monster)
                }) {
                    Image(systemName: monster.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(monster.isFavorite ? .red : .gray)
                        .font(.title3)
                }
            }
            
            // Stats
            HStack(spacing: 8) {
                Text("КЗ \(monster.armorClass ?? 10)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(6)

                Text("ХП \(monster.hitPoints ?? 10)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(6)
                
                Text("КО \(monster.challengeRating ?? "1/8")")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(6)
                
                Spacer()
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
                            AbilityView(name: "СИЛ", score: monster.strength ?? 10, modifier: monster.strengthModifier)
                            AbilityView(name: "ЛОВ", score: monster.dexterity ?? 10, modifier: monster.dexterityModifier)
                            AbilityView(name: "ТЕЛ", score: monster.constitution ?? 10, modifier: monster.constitutionModifier)
                            AbilityView(name: "ИНТ", score: monster.intelligence ?? 10, modifier: monster.intelligenceModifier)
                            AbilityView(name: "МУД", score: monster.wisdom ?? 10, modifier: monster.wisdomModifier)
                            AbilityView(name: "ХАР", score: monster.charisma ?? 10, modifier: monster.charismaModifier)
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

                    // Special Abilities
                    if let challengeSpecial = monster.challengeSpecial, !challengeSpecial.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Особые способности")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(challengeSpecial)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    // Legendary Actions
                    if let legendaryActions = monster.legendaryActions, !legendaryActions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Легендарные действия")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            ForEach(legendaryActions, id: \.name) { action in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(action.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)

                                    Text(action.desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
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

                            ForEach(actions, id: \.name) { action in
                                ActionView(action: action)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveCardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        case .light:
            return Color(red: 0.95, green: 0.94, blue: 0.92)
        @unknown default:
            return Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var adaptiveShadowColor: Color {
        switch colorScheme {
        case .dark:
            return .black.opacity(0.3)
        case .light:
            return .black.opacity(0.1)
        @unknown default:
            return .black.opacity(0.1)
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
        }
    }
}

struct MonsterFiltersView: View {
    @Binding var selectedTypes: Set<MonsterType>
    @Binding var selectedChallengeRatings: Set<String>
    @Environment(\.dismiss) private var dismiss

    let availableChallengeRatings: [String]

    var body: some View {
        NavigationView {
            List {
                Section("Тип монстра") {
                    ForEach(MonsterType.allCases.filter { $0 != .all }, id: \.self) { type in
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundColor(.orange)
                                .frame(width: 24)

                            Text(type.rawValue)

                            Spacer()

                            if selectedTypes.contains(type) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        }
                    }
                }

                Section("Класс опасности") {
                    ForEach(availableChallengeRatings, id: \.self) { challengeRating in
                        HStack {
                            Text(challengeRating)
                            Spacer()
                            if selectedChallengeRatings.contains(challengeRating) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedChallengeRatings.contains(challengeRating) {
                                selectedChallengeRatings.remove(challengeRating)
                            } else {
                                selectedChallengeRatings.insert(challengeRating)
                            }
                        }
                    }
                }

                Section {
                    Button("Сбросить все фильтры") {
                        selectedTypes.removeAll()
                        selectedChallengeRatings.removeAll()
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
