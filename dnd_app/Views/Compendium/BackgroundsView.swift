import SwiftUI

struct BackgroundsView: View {
    @ObservedObject private var dataService = DataService.shared
    @State private var searchText = ""
    @State private var favoriteBackgrounds: Set<UUID> = []
    @State private var expandedBackgrounds: Set<UUID> = []
    @Environment(\.colorScheme) private var colorScheme
    
    var filteredBackgrounds: [Background] {
        let backgrounds = dataService.backgrounds
        var filtered = backgrounds
        
        if !searchText.isEmpty {
            filtered = filtered.filter { background in
                background.название.localizedCaseInsensitiveContains(searchText) ||
                background.описание.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.название < $1.название }
    }
    
    var favoriteBackgroundsList: [Background] {
        dataService.backgrounds.filter { favoriteBackgrounds.contains($0.id) }
    }

    var regularBackgroundsList: [Background] {
        filteredBackgrounds.filter { !favoriteBackgrounds.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    Spacer()
                        .frame(height: 12)

                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Поиск предысторий...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // All Backgrounds
                    ForEach(filteredBackgrounds) { background in
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
                .padding(.bottom, 20)
            }
            .background(adaptiveBackgroundColor)
            .navigationTitle("Предыстории")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadFavoriteBackgrounds()
                // Загружаем предыстории если они не загружены
                if dataService.backgrounds.isEmpty {
                    Task {
                        await dataService.loadBackgrounds()
                        print("Backgrounds loaded")
                    }
                }
            }
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
    
    private func saveFavoriteBackgrounds() {
        if let data = try? JSONEncoder().encode(favoriteBackgrounds) {
            UserDefaults.standard.set(data, forKey: "favoriteBackgrounds")
        }
    }
}

struct BackgroundCardView: View {
    let background: Background
    let isExpanded: Bool
    let isFavorite: Bool
    let onToggleExpanded: () -> Void
    let onToggleFavorite: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(background.название)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !background.черта.isEmpty {
                        Text(background.черта)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    if !background.описание.isEmpty {
                        Text(background.описание)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    // Дополнительная информация
                    if !background.навыки.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Навыки:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(background.навыки)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !background.инструменты.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Инструменты:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(background.инструменты)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !background.снаряжение.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Снаряжение:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(background.снаряжение)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 2, x: 0, y: 1)
        .onTapGesture {
            onToggleExpanded()
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

#Preview {
    BackgroundsView()
}
