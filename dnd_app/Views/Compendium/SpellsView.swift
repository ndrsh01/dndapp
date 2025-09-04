import SwiftUI

struct SpellsView: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var searchText = ""
    @State private var expandedSpells: Set<UUID> = []
    @State private var favoriteSpells: Set<UUID> = []
    @State private var showFilters = false
    @State private var selectedLevel: String? = nil
    @State private var selectedSchool: String? = nil
    @State private var selectedClass: String? = nil
    
    var filteredSpells: [Spell] {
        let spells = dataService.spells
        var filtered = spells
        
        // Поиск по тексту
        if !searchText.isEmpty {
            filtered = filtered.filter { spell in
                spell.название.localizedCaseInsensitiveContains(searchText) ||
                spell.описание.localizedCaseInsensitiveContains(searchText) ||
                spell.классы.localizedCaseInsensitiveContains(searchText) ||
                spell.школа.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Фильтр по уровню
        if let level = selectedLevel {
            filtered = filtered.filter { spell in
                if level == "Заговор" {
                    return spell.уровень == "Заговор"
                } else {
                    return spell.уровень == level
                }
            }
        }
        
        // Фильтр по школе
        if let school = selectedSchool {
            filtered = filtered.filter { spell in
                spell.школа == school
            }
        }
        
        // Фильтр по классу
        if let className = selectedClass {
            filtered = filtered.filter { spell in
                spell.классы.contains(className)
            }
        }
        
        return filtered
    }
    
    var favoriteSpellsList: [Spell] {
        dataService.spells.filter { favoriteSpells.contains($0.id) }
    }

    var allSpellsList: [Spell] {
        filteredSpells
    }
    
    var availableLevels: [String] {
        let spells = dataService.spells
        let levels = Set(spells.map { $0.уровень }).sorted { level1, level2 in
            if level1 == "Заговор" { return true }
            if level2 == "Заговор" { return false }
            return level1 < level2
        }
        return levels
    }
    
    var availableSchools: [String] {
        let spells = dataService.spells
        return Set(spells.map { $0.школа }).sorted()
    }
    
    var availableClasses: [String] {
        let spells = dataService.spells
        let allClasses = spells.flatMap { $0.классы.components(separatedBy: ", ") }
        return Set(allClasses.map { $0.trimmingCharacters(in: .whitespaces) }).sorted()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Поиск заклинаний...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // All Spells
                    ForEach(allSpellsList) { spell in
                        SpellCardView(
                            spell: spell,
                            isExpanded: expandedSpells.contains(spell.id),
                            isFavorite: favoriteSpells.contains(spell.id),
                            onToggleExpanded: {
                                toggleExpanded(spell.id)
                            },
                            onToggleFavorite: {
                                toggleFavorite(spell.id)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Заклинания")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            .onAppear {
                loadFavoriteSpells()
                // Загружаем заклинания если они не загружены
                print("SpellsView appeared, spells count: \(dataService.spells.count)")
                if dataService.spells.isEmpty {
                    print("Loading spells...")
                    Task {
                        await dataService.loadSpells()
                        ;()
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FiltersView(
                    selectedLevel: $selectedLevel,
                    selectedSchool: $selectedSchool,
                    selectedClass: $selectedClass,
                    availableLevels: availableLevels,
                    availableSchools: availableSchools,
                    availableClasses: availableClasses
                )
            }
        }
    }
    
    private func toggleExpanded(_ spellId: UUID) {
        if expandedSpells.contains(spellId) {
            expandedSpells.remove(spellId)
        } else {
            expandedSpells.insert(spellId)
        }
    }

    private func toggleFavorite(_ spellId: UUID) {
        if favoriteSpells.contains(spellId) {
            favoriteSpells.remove(spellId)
        } else {
            favoriteSpells.insert(spellId)
        }
        saveFavoriteSpells()
    }

    private func loadFavoriteSpells() {
        if let data = UserDefaults.standard.data(forKey: "favoriteSpells"),
           let favorites = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteSpells = favorites
        }
    }

    private func saveFavoriteSpells() {
        if let data = try? JSONEncoder().encode(favoriteSpells) {
            UserDefaults.standard.set(data, forKey: "favoriteSpells")
        }
    }
}

// MARK: - Spell Card View
struct SpellCardView: View {
    let spell: Spell
    let isExpanded: Bool
    let isFavorite: Bool
    let onToggleExpanded: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(spell.название)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Favorite Button
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .font(.title3)
                }
                
                // Expand/Collapse Button
                Button(action: onToggleExpanded) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            
            // Tags
            HStack(spacing: 8) {
                if spell.уровень == "Заговор" {
                    TagView(text: "Заговор", color: .blue)
                } else {
                    TagView(text: "\(spell.уровень) уровень", color: .blue)
                }
                
                TagView(text: spell.школа, color: .purple)
                
                if spell.концентрация {
                    TagView(text: "Концентрация", color: .orange)
                }
            }
            
            // Basic Info (always visible)
            VStack(alignment: .leading, spacing: 6) {
                InfoRow(icon: "person.2", text: spell.классы)
                InfoRow(icon: "clock", text: spell.времяСотворения)
                InfoRow(icon: "paperplane", text: spell.дистанция)
                InfoRow(icon: "hand.raised", text: spell.компоненты)
                InfoRow(icon: "stopwatch", text: spell.длительность)
            }
            
            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Description
                    Text(spell.описание)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    // Improvements
                    if !spell.улучшения.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Улучшение заговора:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .underline()
                            
                            Text(spell.улучшения)
                                .font(.body)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Filters View
struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLevel: String?
    @Binding var selectedSchool: String?
    @Binding var selectedClass: String?
    let availableLevels: [String]
    let availableSchools: [String]
    let availableClasses: [String]
    
    var body: some View {
        NavigationView {
            List {
                Section("Уровень заклинания") {
                    HStack {
                        Text("Все уровни")
                        Spacer()
                        if selectedLevel == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedLevel = nil
                    }
                    
                    ForEach(availableLevels, id: \.self) { level in
                        HStack {
                            Text(level)
                            Spacer()
                            if selectedLevel == level {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedLevel = level
                        }
                    }
                }
                
                Section("Школа магии") {
                    HStack {
                        Text("Все школы")
                        Spacer()
                        if selectedSchool == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSchool = nil
                    }
                    
                    ForEach(availableSchools, id: \.self) { school in
                        HStack {
                            Text(school)
                            Spacer()
                            if selectedSchool == school {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSchool = school
                        }
                    }
                }
                
                Section("Класс персонажа") {
                    HStack {
                        Text("Все классы")
                        Spacer()
                        if selectedClass == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedClass = nil
                    }
                    
                    ForEach(availableClasses, id: \.self) { className in
                        HStack {
                            Text(className)
                            Spacer()
                            if selectedClass == className {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedClass = className
                        }
                    }
                }
                
                Section {
                    Button("Сбросить все фильтры") {
                        selectedLevel = nil
                        selectedSchool = nil
                        selectedClass = nil
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
    SpellsView()
}