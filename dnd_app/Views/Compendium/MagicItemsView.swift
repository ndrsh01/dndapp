import SwiftUI

struct MagicItemsView: View {
    @StateObject private var magicItemService = MagicItemService()
    @State private var searchText = ""
    @State private var expandedItems: Set<String> = []
    @State private var favoriteItems: Set<String> = []
    @State private var showFilters = false
    @State private var selectedRarities: Set<String> = []
    @State private var selectedTypes: Set<String> = []
    @Environment(\.colorScheme) private var colorScheme
    
    var filteredItems: [MagicItem] {
        let items = magicItemService.magicItems
        var filtered = items
        
        // Поиск по тексту
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.displayName.localizedCaseInsensitiveContains(searchText) ||
                item.descriptions.joined().localizedCaseInsensitiveContains(searchText) ||
                item.type.localizedCaseInsensitiveContains(searchText) ||
                item.rarity.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Фильтр по редкости
        if !selectedRarities.isEmpty {
            filtered = filtered.filter { item in
                selectedRarities.contains(item.extractedRarity)
            }
        }
        
        // Фильтр по типу
        if !selectedTypes.isEmpty {
            filtered = filtered.filter { item in
                selectedTypes.contains(item.extractedType)
            }
        }
        
        return filtered
    }
    
    var favoriteItemsList: [MagicItem] {
        magicItemService.magicItems.filter { favoriteItems.contains($0.id) }
    }

    var allItemsList: [MagicItem] {
        filteredItems
    }
    
    var availableRarities: [String] {
        let items = magicItemService.magicItems
        return Set(items.map { $0.extractedRarity }).sorted()
    }
    
    var availableTypes: [String] {
        let items = magicItemService.magicItems
        return Set(items.map { $0.extractedType }).sorted()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    Spacer()
                        .frame(height: 12)

                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Поиск магических предметов...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Active Filters
                    if !selectedRarities.isEmpty || !selectedTypes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedRarities), id: \.self) { rarity in
                                    MagicItemFilterTagView(
                                        text: "Редкость: \(rarity)",
                                        onRemove: { selectedRarities.remove(rarity) }
                                    )
                                }

                                ForEach(Array(selectedTypes), id: \.self) { type in
                                    MagicItemFilterTagView(
                                        text: "Тип: \(type)",
                                        onRemove: { selectedTypes.remove(type) }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 8)
                    }

                    // Loading indicator or items
                    if magicItemService.magicItems.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Загрузка магических предметов...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else if allItemsList.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundColor(Color(.systemGray))
                            
                            Text("Предметы не найдены")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Попробуйте изменить поисковый запрос или фильтры")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else {
                        // Items List
                        ForEach(allItemsList, id: \.id) { item in
                            MagicItemCardView(
                                item: item,
                                isExpanded: expandedItems.contains(item.id),
                                isFavorite: favoriteItems.contains(item.id),
                                onToggleExpanded: {
                                    if expandedItems.contains(item.id) {
                                        expandedItems.remove(item.id)
                                    } else {
                                        expandedItems.insert(item.id)
                                    }
                                },
                                onToggleFavorite: {
                                    toggleFavorite(item.id)
                                }
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .background(adaptiveBackgroundColor)
            .navigationTitle("Магические предметы")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(Color(.systemOrange))
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                MagicItemFiltersView(
                    selectedRarities: $selectedRarities,
                    selectedTypes: $selectedTypes,
                    availableRarities: availableRarities,
                    availableTypes: availableTypes
                )
            }
        }
        .onAppear {
            loadFavoriteItems()
        }
    }
    
    private func toggleFavorite(_ itemId: String) {
        if favoriteItems.contains(itemId) {
            favoriteItems.remove(itemId)
        } else {
            favoriteItems.insert(itemId)
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

// MARK: - Magic Item Card View
struct MagicItemCardView: View {
    let item: MagicItem
    let isExpanded: Bool
    let isFavorite: Bool
    let onToggleExpanded: () -> Void
    let onToggleFavorite: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(item.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(adaptiveTextColor)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // URL Link Button (как в бестиарии)
                    if let url = item.url, !url.isEmpty {
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
                    
                    // Favorite Button
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? Color(.systemRed) : Color(.systemGray))
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle()) // Предотвращаем конфликт с onTapGesture
                }
            
            // Tags - сначала тип, потом редкость
            HStack(spacing: 8) {
                TagView(text: item.extractedType, color: Color(.systemPurple))
                TagView(text: item.extractedRarity, color: item.rarityColor)
            }
            
                // Basic Info (always visible) - только стоимость и вес, без описания
                VStack(alignment: .leading, spacing: 6) {
                    InfoRow(icon: "dollarsign.circle", text: item.cost)
                    InfoRow(icon: "scalemass", text: item.weight)
                }
            
                // Expanded Content - только в развернутом виде
                if isExpanded {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            // All Descriptions
                            ForEach(Array(item.descriptions.enumerated()), id: \.offset) { index, description in
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(adaptiveTextColor)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            // Tables
                            if let tables = item.tables, !tables.isEmpty {
                                ForEach(Array(tables.enumerated()), id: \.offset) { tableIndex, table in
                                    MagicItemTableView(table: table)
                                }
                            }
                            
                            // Properties
                            if !item.properties.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Свойства:")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(adaptiveTextColor)
                                    
                                    ForEach(Array(item.properties.enumerated()), id: \.offset) { index, property in
                                        Text("• \(property)")
                                            .font(.body)
                                            .foregroundColor(adaptiveTextColor)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300) // Ограничиваем высоту скролла
                    .padding(.top, 8)
                }
        }
        .padding(16)
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
        .onTapGesture {
            onToggleExpanded()
        }
    }
    
    private var adaptiveTextColor: Color {
        switch colorScheme {
        case .dark:
            return .white
        case .light:
            return .black
        @unknown default:
            return .primary
        }
    }
    
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

// MARK: - Magic Item Filters View
struct MagicItemFiltersView: View {
    @Binding var selectedRarities: Set<String>
    @Binding var selectedTypes: Set<String>
    let availableRarities: [String]
    let availableTypes: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Rarity Filter
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Редкость")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(availableRarities, id: \.self) { rarity in
                                Button(action: {
                                    if selectedRarities.contains(rarity) {
                                        selectedRarities.remove(rarity)
                                    } else {
                                        selectedRarities.insert(rarity)
                                    }
                                }) {
                                    Text(rarity)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedRarities.contains(rarity) ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedRarities.contains(rarity) ? Color(.systemOrange) : Color(.systemGray6))
                                        )
                                }
                            }
                        }
                    }
                    
                    // Type Filter
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Тип")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(availableTypes, id: \.self) { type in
                                Button(action: {
                                    if selectedTypes.contains(type) {
                                        selectedTypes.remove(type)
                                    } else {
                                        selectedTypes.insert(type)
                                    }
                                }) {
                                    Text(type)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedTypes.contains(type) ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedTypes.contains(type) ? Color(.systemOrange) : Color(.systemGray6))
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Очистить") {
                        selectedRarities.removeAll()
                        selectedTypes.removeAll()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Magic Item Filter Tag View
struct MagicItemFilterTagView: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .foregroundColor(Color(.systemOrange))

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(Color(.systemOrange))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemOrange).opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Magic Item Table View
struct MagicItemTableView: View {
    let table: MagicItem.Table
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !table.title.isEmpty {
                Text(table.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(adaptiveTextColor)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Headers
                    HStack(spacing: 0) {
                        ForEach(Array(table.headers.enumerated()), id: \.offset) { index, header in
                            Text(header)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(minWidth: 80, alignment: .leading)
                                .background(Color(.systemBlue))
                        }
                    }
                    
                    // Rows
                    ForEach(Array(table.rows.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 0) {
                            ForEach(Array(row.enumerated()), id: \.offset) { cellIndex, cell in
                                Text(cell)
                                    .font(.caption)
                                    .foregroundColor(adaptiveTextColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .frame(minWidth: 80, alignment: .leading)
                                    .background(rowIndex % 2 == 0 ? Color(.systemGray6) : Color(.systemBackground))
                            }
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
    
    private var adaptiveTextColor: Color {
        switch colorScheme {
        case .dark:
            return .white
        case .light:
            return .black
        @unknown default:
            return .primary
        }
    }
}

#Preview {
    MagicItemsView()
}