import Foundation

class MagicItemService: ObservableObject {
    @Published var magicItems: [MagicItem] = []
    @Published var favoriteMagicItems: [String: Set<UUID>] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let favoriteMagicItemsKey = "favoriteMagicItems"
    
    init() {
        loadMagicItems()
        loadFavoriteMagicItems()
    }
    
    private func loadMagicItems() {
        guard let url = Bundle.main.url(forResource: "items", withExtension: "json") else {
            print("Could not find items.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode([MagicItem].self, from: data)
            self.magicItems = items
            print("Loaded \(items.count) magic items")
        } catch {
            print("Error loading magic items: \(error)")
        }
    }
    
    private func loadFavoriteMagicItems() {
        if let data = userDefaults.data(forKey: favoriteMagicItemsKey),
           let favorites = try? JSONDecoder().decode([String: Set<UUID>].self, from: data) {
            self.favoriteMagicItems = favorites
        }
    }
    
    private func saveFavoriteMagicItems() {
        if let data = try? JSONEncoder().encode(favoriteMagicItems) {
            userDefaults.set(data, forKey: favoriteMagicItemsKey)
        }
    }
    
    func toggleFavorite(_ item: MagicItem, for characterId: UUID) {
        if favoriteMagicItems[item.id]?.contains(characterId) == true {
            favoriteMagicItems[item.id]?.remove(characterId)
            if favoriteMagicItems[item.id]?.isEmpty == true {
                favoriteMagicItems.removeValue(forKey: item.id)
            }
        } else {
            if favoriteMagicItems[item.id] == nil {
                favoriteMagicItems[item.id] = Set<UUID>()
            }
            favoriteMagicItems[item.id]?.insert(characterId)
        }
        saveFavoriteMagicItems()
    }
    
    func getFavoriteMagicItems(for characterId: UUID) -> [MagicItem] {
        let favoriteIds = favoriteMagicItems.compactMap { (itemId, characterIds) in
            characterIds.contains(characterId) ? itemId : nil
        }
        return magicItems.filter { favoriteIds.contains($0.id) }
    }
    
    func isFavorite(_ item: MagicItem, for characterId: UUID) -> Bool {
        return favoriteMagicItems[item.id]?.contains(characterId) == true
    }
    
    func searchMagicItems(query: String) -> [MagicItem] {
        if query.isEmpty {
            return magicItems
        }
        
        return magicItems.filter { item in
            item.displayName.localizedCaseInsensitiveContains(query) ||
            item.type.localizedCaseInsensitiveContains(query) ||
            item.rarity.localizedCaseInsensitiveContains(query) ||
            item.descriptions.joined().localizedCaseInsensitiveContains(query)
        }
    }
}
