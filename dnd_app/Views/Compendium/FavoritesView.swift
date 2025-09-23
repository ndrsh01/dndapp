import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var selectedTab = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Табы - горизонтальный скроллинг
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<5) { index in
                            Button(action: {
                                selectedTab = index
                            }) {
                                Text(tabTitle(for: index))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedTab == index ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedTab == index ? Color(.systemOrange) : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
                
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
                    
                    // Избранные магические предметы
                    FavoriteMagicItemsSection()
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(adaptiveBackgroundColor)
            .navigationTitle("Избранное")
            .navigationBarTitleDisplayMode(.large)
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    // MARK: - Helper Functions
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Заклинания"
        case 1: return "Предыстории"
        case 2: return "Черты"
        case 3: return "Бестиарий"
        case 4: return "Предметы"
        default: return ""
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
    @State private var expandedMonsters: Set<UUID> = []
    
    var favoriteMonstersList: [Monster] {
        dataService.getFavoriteMonsters(for: CharacterManager.shared.selectedCharacter?.id)
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
                            },
                            onToggleFavorite: { monster in
                                dataService.toggleMonsterFavorite(monster, for: CharacterManager.shared.selectedCharacter?.id)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            // Загружаем монстров если они не загружены
            if dataService.monsters.isEmpty {
                Task {
                    await dataService.loadMonsters()
                    print("Monsters loaded")
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
}

struct FavoriteMagicItemsSection: View {
    @StateObject private var magicItemService = MagicItemService()
    @State private var favoriteItems: Set<String> = []
    @State private var expandedItems: Set<String> = []
    
    var favoriteItemsList: [MagicItem] {
        magicItemService.magicItems.filter { favoriteItems.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if favoriteItemsList.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        title: "Нет избранных предметов",
                        description: "Добавьте магические предметы в избранное, нажав на сердечко",
                        actionTitle: nil,
                        action: nil
                    )
                    .padding(.top, 50)
                } else {
                    ForEach(favoriteItemsList, id: \.id) { item in
                        MagicItemCardView(
                            item: item,
                            isExpanded: expandedItems.contains(item.id),
                            isFavorite: favoriteItems.contains(item.id),
                            onToggleExpanded: {
                                toggleExpanded(item.id)
                            },
                            onToggleFavorite: {
                                toggleFavorite(item.id)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            loadFavoriteItems()
        }
    }
    
    private func toggleExpanded(_ id: String) {
        if expandedItems.contains(id) {
            expandedItems.remove(id)
        } else {
            expandedItems.insert(id)
        }
    }
    
    private func toggleFavorite(_ id: String) {
        if favoriteItems.contains(id) {
            favoriteItems.remove(id)
        } else {
            favoriteItems.insert(id)
        }
        saveFavoriteItems()
    }
    
    private func loadFavoriteItems() {
        if let data = UserDefaults.standard.data(forKey: "favoriteMagicItems"),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteItems = favorites
        }
    }
    
    private func saveFavoriteItems() {
        if let data = try? JSONEncoder().encode(favoriteItems) {
            UserDefaults.standard.set(data, forKey: "favoriteMagicItems")
        }
    }
}

#Preview {
    FavoritesView()
}
