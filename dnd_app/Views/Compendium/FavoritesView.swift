import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Табы
                Picker("Тип", selection: $selectedTab) {
                    Text("Заклинания").tag(0)
                    Text("Предыстории").tag(1)
                    Text("Черты").tag(2)
                    Text("Бестиарий").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Контент
                TabView(selection: $selectedTab) {
                    // Избранные заклинания
                    FavoriteSpellsSection()
                        .tag(0)
                    
                    // Избранные предыстории
                    FavoriteBackgroundsSection()
                        .tag(1)
                    
                    // Избранные черты
                    FavoriteFeatsSection()
                        .tag(2)
                    
                    // Избранные монстры
                    FavoriteBestiarySection()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Избранное")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FavoriteSpellsSection: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var favoriteSpells: Set<UUID> = []
    @State private var expandedSpells: Set<UUID> = []
    
    var favoriteSpellsList: [Spell] {
        dataService.spells.filter { favoriteSpells.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if favoriteSpellsList.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        title: "Нет избранных заклинаний",
                        description: "Добавьте заклинания в избранное, нажав на сердечко",
                        actionTitle: nil,
                        action: nil
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(favoriteSpellsList) { spell in
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
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            loadFavoriteSpells()
        }
    }
    
    private func toggleExpanded(_ id: UUID) {
        if expandedSpells.contains(id) {
            expandedSpells.remove(id)
        } else {
            expandedSpells.insert(id)
        }
    }
    
    private func toggleFavorite(_ id: UUID) {
        if favoriteSpells.contains(id) {
            favoriteSpells.remove(id)
        } else {
            favoriteSpells.insert(id)
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

struct FavoriteBackgroundsSection: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var favoriteBackgrounds: Set<UUID> = []
    @State private var expandedBackgrounds: Set<UUID> = []
    
    var favoriteBackgroundsList: [Background] {
        dataService.backgrounds.filter { favoriteBackgrounds.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if favoriteBackgroundsList.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        title: "Нет избранных предысторий",
                        description: "Добавьте предыстории в избранное, нажав на сердечко",
                        actionTitle: nil,
                        action: nil
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(favoriteBackgroundsList) { background in
                        BackgroundCardView(
                            background: background,
                            isExpanded: expandedBackgrounds.contains(background.id),
                            isFavorite: favoriteBackgrounds.contains(background.id),
                            onToggleExpanded: {
                                toggleExpanded(background.id)
                            },
                            onToggleFavorite: {
                                toggleFavorite(background.id)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            loadFavoriteBackgrounds()
        }
    }
    
    private func toggleExpanded(_ id: UUID) {
        if expandedBackgrounds.contains(id) {
            expandedBackgrounds.remove(id)
        } else {
            expandedBackgrounds.insert(id)
        }
    }
    
    private func toggleFavorite(_ id: UUID) {
        if favoriteBackgrounds.contains(id) {
            favoriteBackgrounds.remove(id)
        } else {
            favoriteBackgrounds.insert(id)
        }
        saveFavoriteBackgrounds()
    }
    
    private func loadFavoriteBackgrounds() {
        if let data = UserDefaults.standard.data(forKey: "favoriteBackgrounds"),
           let favorites = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteBackgrounds = favorites
        }
    }
    
    private func saveFavoriteBackgrounds() {
        if let data = try? JSONEncoder().encode(favoriteBackgrounds) {
            UserDefaults.standard.set(data, forKey: "favoriteBackgrounds")
        }
    }
}

struct FavoriteFeatsSection: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var favoriteFeats: Set<UUID> = []
    @State private var expandedFeats: Set<UUID> = []
    
    var favoriteFeatsList: [Feat] {
        dataService.feats.filter { favoriteFeats.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if favoriteFeatsList.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        title: "Нет избранных черт",
                        description: "Добавьте черты в избранное, нажав на сердечко",
                        actionTitle: nil,
                        action: nil
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(favoriteFeatsList) { feat in
                        FeatCardView(
                            feat: feat,
                            isExpanded: expandedFeats.contains(feat.id),
                            isFavorite: favoriteFeats.contains(feat.id),
                            onToggleExpanded: {
                                toggleExpanded(feat.id)
                            },
                            onToggleFavorite: {
                                toggleFavorite(feat.id)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            loadFavoriteFeats()
        }
    }
    
    private func toggleExpanded(_ id: UUID) {
        if expandedFeats.contains(id) {
            expandedFeats.remove(id)
        } else {
            expandedFeats.insert(id)
        }
    }
    
    private func toggleFavorite(_ id: UUID) {
        if favoriteFeats.contains(id) {
            favoriteFeats.remove(id)
        } else {
            favoriteFeats.insert(id)
        }
        saveFavoriteFeats()
    }
    
    private func loadFavoriteFeats() {
        if let data = UserDefaults.standard.data(forKey: "favoriteFeats"),
           let favorites = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteFeats = favorites
        }
    }
    
    private func saveFavoriteFeats() {
        if let data = try? JSONEncoder().encode(favoriteFeats) {
            UserDefaults.standard.set(data, forKey: "favoriteFeats")
        }
    }
}

struct FavoriteBestiarySection: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var favoriteMonsters: Set<UUID> = []
    @State private var expandedMonsters: Set<UUID> = []
    
    var favoriteMonstersList: [Monster] {
        dataService.monsters.filter { favoriteMonsters.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if favoriteMonstersList.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        title: "Нет избранных монстров",
                        description: "Добавьте монстров в избранное, нажав на сердечко",
                        actionTitle: nil,
                        action: nil
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(favoriteMonstersList) { monster in
                        MonsterCardView(
                            monster: monster,
                            isExpanded: expandedMonsters.contains(monster.id),
                            onTap: {
                                toggleExpanded(monster.id)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            loadFavoriteMonsters()
            // Загружаем монстров если они не загружены
            if dataService.monsters.isEmpty {
                Task {
                    await dataService.loadMonsters()
                    ;print("Monsters loaded")
                }
            }
        }
    }
    
    private func toggleExpanded(_ id: UUID) {
        if expandedMonsters.contains(id) {
            expandedMonsters.remove(id)
        } else {
            expandedMonsters.insert(id)
        }
    }
    
    private func loadFavoriteMonsters() {
        if let data = UserDefaults.standard.data(forKey: "favoriteMonsters"),
           let favorites = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteMonsters = favorites
        }
    }
}

#Preview {
    FavoritesView()
}
