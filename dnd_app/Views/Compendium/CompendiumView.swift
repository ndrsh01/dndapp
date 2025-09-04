import SwiftUI

struct CompendiumView: View {
    @StateObject private var viewModel = CompendiumViewModel()
    @State private var selectedItem: Any?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Карточки категорий согласно изображению
                    NavigationLink(destination: SpellsView()) {
                        CompendiumCategoryCard(
                            title: "Заклинания",
                            subtitle: "Магические заклинания и их описания",
                            icon: "wand.and.stars",
                            iconColor: .purple,
                            action: {}
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: BackgroundsListView(backgrounds: viewModel.filteredBackgrounds) { background in
                        viewModel.toggleBackgroundFavorite(background)
                    }) {
                        CompendiumCategoryCard(
                            title: "Предыстории",
                            subtitle: "Происхождение и история персонажа",
                            icon: "person.3",
                            iconColor: .blue,
                            action: {}
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: FeatsListView(feats: viewModel.filteredFeats) { feat in
                        viewModel.toggleFeatFavorite(feat)
                    }) {
                        CompendiumCategoryCard(
                            title: "Черты",
                            subtitle: "Особые способности и умения",
                            icon: "star",
                            iconColor: .orange,
                            action: {}
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: BestiaryView()) {
                        CompendiumCategoryCard(
                            title: "Бестиарий",
                            subtitle: "Монстры и существа",
                            icon: "pawprint",
                            iconColor: .green,
                            action: {}
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Глоссарий")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}



struct FeatsListView: View {
    let feats: [Feat]
    let onToggleFavorite: (Feat) -> Void
    
    var body: some View {
        List {
            ForEach(feats) { feat in
                FeatCardView(feat: feat) {
                    onToggleFavorite(feat)
                }
                .contextMenu(
                    onEdit: {
                        // TODO: Implement feat editing
                    },
                    onDelete: {
                        // TODO: Implement feat deletion
                    },
                    onDuplicate: {
                        // TODO: Implement feat duplication
                    }
                )
            }
        }
    }
}

struct FeatCardView: View {
    let feat: Feat
    let onToggleFavorite: () -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feat.название)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(feat.категория)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Button(action: onToggleFavorite) {
                        Image(systemName: feat.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(feat.isFavorite ? .red : .gray)
                    }
                }
                
                Text(feat.описание)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding(12)
        }
    }
}

struct BackgroundsListView: View {
    let backgrounds: [Background]
    let onToggleFavorite: (Background) -> Void
    
    var body: some View {
        List {
            ForEach(backgrounds) { background in
                BackgroundCardView(background: background) {
                    onToggleFavorite(background)
                }
                .contextMenu(
                    onEdit: {
                        // TODO: Implement background editing
                    },
                    onDelete: {
                        // TODO: Implement background deletion
                    },
                    onDuplicate: {
                        // TODO: Implement background duplication
                    }
                )
            }
        }
    }
}

struct BackgroundCardView: View {
    let background: Background
    let onToggleFavorite: () -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(background.название)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(background.черта)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Button(action: onToggleFavorite) {
                        Image(systemName: background.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(background.isFavorite ? .red : .gray)
                    }
                }
                
                Text(background.описание)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding(12)
        }
    }
}



struct CompendiumCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка слева
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(8)
                
                // Текст по центру
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Стрелка справа
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color(red: 0.95, green: 0.94, blue: 0.92))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CompendiumView()
}
