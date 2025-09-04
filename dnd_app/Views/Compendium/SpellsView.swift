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

// MARK: - Supporting Views
struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .cornerRadius(8)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.black)
            
            Spacer()
        }
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
            VStack(spacing: 20) {
                // Level Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Уровень заклинания")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterButton(
                                title: "Все",
                                isSelected: selectedLevel == nil,
                                action: { selectedLevel = nil }
                            )
                            
                            ForEach(availableLevels, id: \.self) { level in
                                FilterButton(
                                    title: level,
                                    isSelected: selectedLevel == level,
                                    action: { selectedLevel = level }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // School Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Школа магии")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterButton(
                                title: "Все",
                                isSelected: selectedSchool == nil,
                                action: { selectedSchool = nil }
                            )
                            
                            ForEach(availableSchools, id: \.self) { school in
                                FilterButton(
                                    title: school,
                                    isSelected: selectedSchool == school,
                                    action: { selectedSchool = school }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Class Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Класс персонажа")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterButton(
                                title: "Все",
                                isSelected: selectedClass == nil,
                                action: { selectedClass = nil }
                            )
                            
                            ForEach(availableClasses, id: \.self) { className in
                                FilterButton(
                                    title: className,
                                    isSelected: selectedClass == className,
                                    action: { selectedClass = className }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        selectedLevel = nil
                        selectedSchool = nil
                        selectedClass = nil
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange, lineWidth: 1)
                )
        }
    }
}

#Preview {
    SpellsView()
}
