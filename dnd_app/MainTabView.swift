import SwiftUI

struct MainTabView: View {
    @StateObject private var globalContextMenu = GlobalContextMenuManager.shared
    @StateObject private var characterManager = CharacterManager()
    @State private var showingCharacterCreation = false
    @State private var showingCharacterEdit = false
    @State private var showingCharacterSelection = false
    
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
                
                CharacterTabView(onCharacterContextMenu: {
                        showCharacterContextMenu()
                    })
                    .environmentObject(characterManager)
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
                
                // Вырезаем область элемента из затемнения
                if globalContextMenu.showContextMenu {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: globalContextMenu.highlightedElementFrame.width,
                               height: globalContextMenu.highlightedElementFrame.height)
                        .position(x: globalContextMenu.highlightedElementFrame.midX,
                                  y: globalContextMenu.highlightedElementFrame.midY)
                        .zIndex(9999)
                        .blendMode(.destinationOut)
                }
                
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
                        y: globalContextMenu.highlightedElementFrame.maxY + 10
                    )
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: globalContextMenu.showContextMenu)
                    .zIndex(10000)
                }
            }
        }
        .sheet(isPresented: $showingCharacterCreation) {
            CharacterCreationView { newCharacter in
                characterManager.addCharacter(newCharacter)
            }
            .environmentObject(characterManager)
        }
        .sheet(isPresented: $showingCharacterEdit) {
            if let selectedCharacter = characterManager.selectedCharacter {
                CharacterEditView(character: selectedCharacter) { updatedCharacter in
                    characterManager.updateCharacter(updatedCharacter)
                }
                .environmentObject(characterManager)
                .environmentObject(DataService.shared)
            }
        }
        .sheet(isPresented: $showingCharacterSelection) {
            CharacterSelectionView()
                .environmentObject(characterManager)
        }
    }
    
    private func showCharacterContextMenu() {
        // Показываем action sheet с опциями
        let alert = UIAlertController(title: "Персонаж", message: "Выберите действие", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Создать персонажа", style: .default) { _ in
            showingCharacterCreation = true
        })
        
        if characterManager.selectedCharacter != nil {
            alert.addAction(UIAlertAction(title: "Выбрать другого", style: .default) { _ in
                showingCharacterSelection = true
            })
        }
        
        alert.addAction(UIAlertAction(title: "Настройки", style: .default) { _ in
            // TODO: Открыть настройки
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

#Preview {
    MainTabView()
}
