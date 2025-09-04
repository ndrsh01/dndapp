import SwiftUI

enum SheetContent {
    case spells
    case backgrounds
    case feats
    case bestiary
    case favorites
}

struct CompendiumView: View {
    @StateObject private var viewModel = CompendiumViewModel()
    @State private var selectedItem: Any?
    @State private var showSheet = false
    @State private var sheetContent: SheetContent = .spells
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
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
                .padding(.top, 8)
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Глоссарий")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showSheet) {
            switch sheetContent {
            case .spells:
                SpellsView()
            case .backgrounds:
                BackgroundsView()
            case .feats:
                FeatsView()
            case .bestiary:
                BestiaryView()
            case .favorites:
                FavoritesView()
            }
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
