import SwiftUI

struct MainTabView: View {
    @StateObject private var globalContextMenu = GlobalContextMenuManager.shared
    
    var body: some View {
        ZStack {
            TabView {
                QuotesView()
                    .tabItem {
                        Image(systemName: "quote.bubble")
                        Text("Цитаты")
                    }
                
                RelationshipsView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Отношения")
                    }
                
                CompendiumView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Глоссарий")
                    }
                
                NotesView()
                    .tabItem {
                        Image(systemName: "note.text")
                        Text("Заметки")
                    }
                
                CharacterView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Персонаж")
                    }
            }
            .accentColor(.orange)
            .preferredColorScheme(.light)
            
            // Глобальное контекстное меню поверх всего
            if globalContextMenu.showContextMenu {
                // Затемненный фон
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        globalContextMenu.hideMenu()
                    }
                    .zIndex(9998)
                
                // Подсветка элемента (активный элемент)
                Rectangle()
                    .fill(Color.clear)
                    .frame(
                        width: globalContextMenu.highlightedElementFrame.width,
                        height: globalContextMenu.highlightedElementFrame.height
                    )
                    .position(
                        x: globalContextMenu.highlightedElementFrame.midX,
                        y: globalContextMenu.highlightedElementFrame.midY
                    )
                    .zIndex(9999)
                
                // Само меню под элементом
                if let onEdit = globalContextMenu.onEdit,
                   let onDelete = globalContextMenu.onDelete,
                   let onDuplicate = globalContextMenu.onDuplicate {
                    ContextMenuView(
                        onEdit: {
                            onEdit()
                            globalContextMenu.hideMenu()
                        },
                        onDelete: {
                            onDelete()
                            globalContextMenu.hideMenu()
                        },
                        onDuplicate: {
                            onDuplicate()
                            globalContextMenu.hideMenu()
                        }
                    )
                    .position(
                        x: globalContextMenu.highlightedElementFrame.midX,
                        y: globalContextMenu.highlightedElementFrame.maxY + 60
                    )
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: globalContextMenu.showContextMenu)
                    .zIndex(10000)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
