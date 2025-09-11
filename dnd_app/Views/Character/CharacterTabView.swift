import SwiftUI

struct CharacterTabView: View {
    @EnvironmentObject var characterManager: CharacterManager
    @State private var currentCharacterId: UUID?
    let onCharacterContextMenu: (() -> Void)?

    var body: some View {
        NavigationView {
            if let selectedCharacter = characterManager.selectedCharacter {
                CharacterView(
                    character: selectedCharacter,
                    onCharacterUpdate: { updatedCharacter in
                        characterManager.updateCharacter(updatedCharacter)
                    },
                    onCharacterContextMenu: onCharacterContextMenu
                )
                .id(selectedCharacter.id) // Используем только ID персонажа для принудительного обновления
            } else {
                CharacterSelectionView()
            }
        }
        .onReceive(characterManager.$selectedCharacter) { newCharacter in
            // Логируем смену персонажа и принудительно обновляем view
            if let newCharacter = newCharacter {
                print("CharacterTabView: Character changed to \(newCharacter.name) (ID: \(newCharacter.id))")
                if currentCharacterId != newCharacter.id {
                    print("CharacterTabView: Forcing view update for new character")
                    currentCharacterId = newCharacter.id
                }
            } else {
                print("CharacterTabView: No character selected")
                currentCharacterId = nil
            }
        }
    }
}

#Preview {
    CharacterTabView(onCharacterContextMenu: nil)
}
