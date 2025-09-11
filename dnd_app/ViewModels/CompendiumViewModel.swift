import Foundation
import Combine

class CompendiumViewModel: ObservableObject {
    @Published var spells: [Spell] = []
    @Published var feats: [Feat] = []
    @Published var backgrounds: [Background] = []
    @Published var searchText: String = ""
    @Published var selectedSection: CompendiumSection = .spells
    @Published var showFavoritesOnly = false
    @Published var selectedCharacterId: UUID?
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum CompendiumSection: String, CaseIterable {
        case spells = "Заклинания"
        case feats = "Черты"
        case backgrounds = "Предыстории"
        case bestiary = "Бестиарий"
        case favorites = "Избранное"
        
        var icon: String {
            switch self {
            case .spells: return "wand.and.stars"
            case .feats: return "star"
            case .backgrounds: return "person.3"
            case .bestiary: return "pawprint"
            case .favorites: return "heart"
            }
        }
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$spells
            .assign(to: \.spells, on: self)
            .store(in: &cancellables)
        
        dataService.$feats
            .assign(to: \.feats, on: self)
            .store(in: &cancellables)
        
        dataService.$backgrounds
            .assign(to: \.backgrounds, on: self)
            .store(in: &cancellables)
    }
    
    func setSelectedCharacter(_ characterId: UUID?) {
        print("=== COMPENDIUM VIEWMODEL ===")
        print("Setting selected character for spells: \(characterId?.uuidString ?? "nil")")
        selectedCharacterId = characterId
        print("Selected character set for compendium")
    }
    
    var filteredSpells: [Spell] {
        let spells = showFavoritesOnly ? dataService.getFavoriteSpells(for: selectedCharacterId) : self.spells
        
        if searchText.isEmpty {
            return spells
        } else {
            return spells.filter { spell in
                spell.название.localizedCaseInsensitiveContains(searchText) ||
                spell.описание.localizedCaseInsensitiveContains(searchText) ||
                spell.школа.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredFeats: [Feat] {
        let feats = showFavoritesOnly ? self.feats.filter { $0.isFavorite } : self.feats
        
        if searchText.isEmpty {
            return feats
        } else {
            return feats.filter { feat in
                feat.название.localizedCaseInsensitiveContains(searchText) ||
                feat.описание.localizedCaseInsensitiveContains(searchText) ||
                feat.категория.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredBackgrounds: [Background] {
        let backgrounds = showFavoritesOnly ? self.backgrounds.filter { $0.isFavorite } : self.backgrounds
        
        if searchText.isEmpty {
            return backgrounds
        } else {
            return backgrounds.filter { background in
                background.название.localizedCaseInsensitiveContains(searchText) ||
                background.описание.localizedCaseInsensitiveContains(searchText) ||
                background.черта.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var favoriteItems: [Any] {
        var items: [Any] = []
        items.append(contentsOf: spells.filter { $0.isFavorite })
        items.append(contentsOf: feats.filter { $0.isFavorite })
        items.append(contentsOf: backgrounds.filter { $0.isFavorite })
        return items
    }
    
    func toggleSpellFavorite(_ spell: Spell) {
        dataService.toggleSpellFavorite(spell, for: selectedCharacterId)
    }
    
    func toggleFeatFavorite(_ feat: Feat) {
        dataService.toggleFeatFavorite(feat)
    }
    
    func toggleBackgroundFavorite(_ background: Background) {
        dataService.toggleBackgroundFavorite(background)
    }
    
    func selectSection(_ section: CompendiumSection) {
        selectedSection = section
    }
}
