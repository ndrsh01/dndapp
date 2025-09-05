import SwiftUI

struct BestiaryView: View {
    @StateObject private var dataService = DataService.shared
    @State private var searchText = ""
    @State private var selectedType: MonsterType = .all
    @State private var selectedSize: String? = nil
    @State private var selectedAlignment: String? = nil
    @State private var selectedChallengeRating: String? = nil
    @State private var showFilters = false
    @State private var expandedMonsters: Set<UUID> = []
    
    var filteredMonsters: [Monster] {
<<<<<<< Updated upstream
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
        
=======
        let searchQuery = searchText.lowercased()
        var filtered = dataService.monsters

        // Поиск
        if !searchText.isEmpty {
            filtered = filtered.filter { monster in
                let name = monster.name.lowercased()
                let type = monster.type.lowercased()
                let alignment = monster.alignment.lowercased()

                return name.hasPrefix(searchQuery) || type.hasPrefix(searchQuery) ||
                       alignment.hasPrefix(searchQuery) || name.contains(searchQuery) ||
                       type.contains(searchQuery) || alignment.contains(searchQuery)
            }
        }

        // Фильтр по типу
        if selectedType != .all {
            let typeString = selectedType.rawValue.lowercased()
            filtered = filtered.filter { monster in
                monster.type.lowercased().contains(typeString)
            }
        }

>>>>>>> Stashed changes
        // Фильтр по рейтингу опасности
        if let challengeRating = selectedChallengeRating {
            filtered = filtered.filter { $0.challengeRating == challengeRating }
        }

        return filtered
    }
<<<<<<< Updated upstream
    
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
=======

    var body: some View {
        VStack(spacing: 0) {
>>>>>>> Stashed changes
            HStack {
                Text("Бестиарий")
                    .font(.largeTitle)
                    .fontWeight(.bold)
<<<<<<< Updated upstream
                
                Spacer()
                
                Button(action: {
                    showFilters = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease")
=======

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showQuickFilters.toggle()
                    }
                }) {
                    Image(systemName: showQuickFilters ? "chevron.up" : "line.3.horizontal.decrease")
>>>>>>> Stashed changes
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
<<<<<<< Updated upstream
            
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
=======

            SearchBar(text: $searchText, placeholder: "Поиск монстров...")
                .padding(.horizontal, 16)
                .padding(.bottom, showQuickFilters ? 8 : 16)

            if showQuickFilters {
                VStack(spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(MonsterType.allCases, id: \.self) { type in
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
                                
                                if selectedChallengeRating != nil {
                                    FilterTagView(
                                        text: "КО: \(selectedChallengeRating!)",
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
                    print("=== BESTIARY VIEW APPEARED ===")
                    print("DataService monsters count: \(dataService.monsters.count)")

                    if dataService.monsters.isEmpty {
                        print("WARNING: No monsters loaded! Attempting to reload...")
                        Task {
                            await dataService.loadMonsters()
                            print("After reload attempt: \(dataService.monsters.count) monsters")
                        }
                    } else {
                        print("Monsters are loaded. First 5 monsters:")
                        for i in 0..<min(5, dataService.monsters.count) {
                            print("  \(i+1). \(dataService.monsters[i].name)")
>>>>>>> Stashed changes
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
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
<<<<<<< Updated upstream
                    Text(monster.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(monster.sizeTypeAlignment)
=======
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
>>>>>>> Stashed changes
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
<<<<<<< Updated upstream
                    Text("КЗ \(monster.armorClass)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(6)
                    
                    Text("КД \(monster.challengeRating)")
=======
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
                    }

                    Text("КО \(monster.challengeRating ?? "1/8")")
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                StatView(title: "Размер", value: monster.size)
=======
                StatView(title: "БМ", value: "+\(monster.proficiencyBonusValue)")
                StatView(title: "ПВ", value: "\(monster.passivePerception)")
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                    
=======

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

>>>>>>> Stashed changes
                    // Actions
                    if let actions = monster.actions, !actions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Действия")
                                .font(.subheadline)
                                .fontWeight(.semibold)
<<<<<<< Updated upstream
                            
                            ForEach(actions.prefix(3), id: \.name) { action in
=======

                            ForEach(actions, id: \.name) { action in
>>>>>>> Stashed changes
                                ActionView(action: action)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
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
}

#Preview {
    BestiaryView()
}