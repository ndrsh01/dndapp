import SwiftUI

struct SpellsView: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var searchText = ""
    @State private var expandedSpells: Set<UUID> = []
    @State private var favoriteSpells: Set<UUID> = []
    @State private var showFilters = false
    @State private var selectedLevels: Set<String> = []
    @State private var selectedSchools: Set<String> = []
    @State private var selectedClasses: Set<String> = []
    
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
        if !selectedLevels.isEmpty {
            filtered = filtered.filter { spell in
                selectedLevels.contains(spell.уровень)
            }
        }
        
        // Фильтр по школе
        if !selectedSchools.isEmpty {
            filtered = filtered.filter { spell in
                selectedSchools.contains(spell.школа)
            }
        }
        
        // Фильтр по классу
        if !selectedClasses.isEmpty {
            filtered = filtered.filter { spell in
                selectedClasses.contains { className in
                    spell.классы.contains(className)
                }
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
                    Spacer()
                        .frame(height: 12)

                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Поиск заклинаний...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Active Filters
                    if !selectedLevels.isEmpty || !selectedSchools.isEmpty || !selectedClasses.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedLevels), id: \.self) { level in
                                    SpellFilterTagView(
                                        text: "Уровень: \(level)",
                                        onRemove: { selectedLevels.remove(level) }
                                    )
                                }

                                ForEach(Array(selectedSchools), id: \.self) { school in
                                    SpellFilterTagView(
                                        text: "Школа: \(school)",
                                        onRemove: { selectedSchools.remove(school) }
                                    )
                                }

                                ForEach(Array(selectedClasses), id: \.self) { className in
                                    SpellFilterTagView(
                                        text: "Класс: \(className)",
                                        onRemove: { selectedClasses.remove(className) }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 8)
                    }

                    // Loading indicator or spells
                    if allSpellsList.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Загрузка заклинаний...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 200)
                    } else {
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
                SpellFiltersView(
                    selectedLevels: $selectedLevels,
                    selectedSchools: $selectedSchools,
                    selectedClasses: $selectedClasses,
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
        .onTapGesture {
            onToggleExpanded()
        }
    }
}

// MARK: - Spell Filters View
struct SpellFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLevels: Set<String>
    @Binding var selectedSchools: Set<String>
    @Binding var selectedClasses: Set<String>
    let availableLevels: [String]
    let availableSchools: [String]
    let availableClasses: [String]
    
    var body: some View {
        NavigationView {
            List {
                Section("Уровень заклинания") {
                    ForEach(availableLevels, id: \.self) { level in
                        HStack {
                            Text(level)
                            Spacer()
                            if selectedLevels.contains(level) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedLevels.contains(level) {
                                selectedLevels.remove(level)
                            } else {
                                selectedLevels.insert(level)
                            }
                        }
                    }
                }
                
                Section("Школа магии") {
                    ForEach(availableSchools, id: \.self) { school in
                        HStack {
                            Text(school)
                            Spacer()
                            if selectedSchools.contains(school) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedSchools.contains(school) {
                                selectedSchools.remove(school)
                            } else {
                                selectedSchools.insert(school)
                            }
                        }
                    }
                }
                
                Section("Класс персонажа") {
                    ForEach(availableClasses, id: \.self) { className in
                        HStack {
                            Text(className)
                            Spacer()
                            if selectedClasses.contains(className) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedClasses.contains(className) {
                                selectedClasses.remove(className)
                            } else {
                                selectedClasses.insert(className)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Сбросить все фильтры") {
                        selectedLevels.removeAll()
                        selectedSchools.removeAll()
                        selectedClasses.removeAll()
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

struct SpellFilterTagView: View {
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

#Preview {
    SpellsView()
}