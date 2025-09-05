import SwiftUI

struct FeatsView: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var searchText = ""
    @State private var favoriteFeats: Set<UUID> = []
    @State private var expandedFeats: Set<UUID> = []
    
    var filteredFeats: [Feat] {
        let feats = dataService.feats
        var filtered = feats
        
        if !searchText.isEmpty {
            filtered = filtered.filter { feat in
                feat.название.localizedCaseInsensitiveContains(searchText) ||
                feat.описание.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.название < $1.название }
    }
    
    var favoriteFeatsList: [Feat] {
        dataService.feats.filter { favoriteFeats.contains($0.id) }
    }

    var regularFeatsList: [Feat] {
        filteredFeats.filter { !favoriteFeats.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Поиск черт...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // All Feats
                    ForEach(filteredFeats) { feat in
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
                .padding(.bottom, 20)
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Черты")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadFavoriteFeats()
                // Загружаем черты если они не загружены
                if dataService.feats.isEmpty {
                    Task {
                        await dataService.loadFeats()
                        ;print("Feats loaded")
                    }
                }
            }
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

struct FeatCardView: View {
    let feat: Feat
    let isExpanded: Bool
    let isFavorite: Bool
    let onToggleExpanded: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feat.название)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !feat.требования.isEmpty {
                        Text("Требование: \(feat.требования)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                            .font(.system(size: 16))
                    }
                    
                }
            }
            
            // Описание
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if !feat.описание.isEmpty {
                        Text(feat.описание)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    // Дополнительная информация
                    if !feat.категория.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Категория:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(feat.категория)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !feat.повышениеХарактеристики.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Повышение характеристики:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(feat.повышениеХарактеристики)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onToggleExpanded()
        }
    }
}

#Preview {
    FeatsView()
}
