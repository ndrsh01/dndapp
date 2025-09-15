import SwiftUI

enum SheetContent {
    case spells
    case backgrounds
    case feats
    case bestiary
    case favorites
}

struct CompendiumView: View {
    @EnvironmentObject private var viewModel: CompendiumViewModel
    @State private var selectedItem: Any?
    @State private var showSheet = false
    @State private var sheetContent: SheetContent = .spells
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
                LazyVStack(spacing: 16) {
                    Spacer()
                        .frame(height: 8)

                    // Карточки категорий согласно изображению
                    CompendiumCategoryCard(
                        title: "Заклинания",
                        subtitle: "Магические заклинания и их описания",
                        icon: "wand.and.stars",
                        iconColor: .purple,
                        action: {
                            print("Spells button tapped")
                            sheetContent = .spells
                            showSheet = true
                        }
                    )
                    
                    CompendiumCategoryCard(
                        title: "Предыстории",
                        subtitle: "Происхождение и история персонажа",
                        icon: "person.3",
                        iconColor: .blue,
                        action: {
                            print("Backgrounds button tapped")
                            sheetContent = .backgrounds
                            showSheet = true
                        }
                    )
                    
                    CompendiumCategoryCard(
                        title: "Черты",
                        subtitle: "Особые способности и умения",
                        icon: "star",
                        iconColor: .orange,
                        action: {
                            print("Feats button tapped")
                            sheetContent = .feats
                            showSheet = true
                        }
                    )
                    
                    CompendiumCategoryCard(
                        title: "Бестиарий",
                        subtitle: "Монстры и существа",
                        icon: "pawprint",
                        iconColor: .green,
                        action: {
                            print("Bestiary button tapped")
                            sheetContent = .bestiary
                            showSheet = true
                        }
                    )
                    
                    CompendiumCategoryCard(
                        title: "Избранное",
                        subtitle: "Сохраненные элементы",
                        icon: "heart.fill",
                        iconColor: .red,
                        action: {
                            print("Favorites button tapped")
                            sheetContent = .favorites
                            showSheet = true
                        }
                    )
                    
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, 20)
        }
        .background(adaptiveBackgroundColor)
        .navigationTitle("Глоссарий")
        .navigationBarTitleDisplayMode(.large)
        .ignoresSafeArea(.all, edges: .bottom)
        .sheet(isPresented: $showSheet) {
            switch sheetContent {
            case .spells:
                SpellsView()
                    .environmentObject(viewModel)
            case .backgrounds:
                BackgroundsView()
                    .environmentObject(viewModel)
            case .feats:
                FeatsView()
                    .environmentObject(viewModel)
            case .bestiary:
                BestiaryView()
            case .favorites:
                FavoritesView()
                    .environmentObject(viewModel)
            }
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







struct CompendiumCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
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
            .background(adaptiveCardBackgroundColor)
            .cornerRadius(12)
            .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
            return .black.opacity(0.05)
        @unknown default:
            return .black.opacity(0.1)
        }
    }
}

#Preview {
    CompendiumView()
}
