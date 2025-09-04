import SwiftUI

struct MainTabView: View {
    var body: some View {
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
    }
}

#Preview {
    MainTabView()
}
