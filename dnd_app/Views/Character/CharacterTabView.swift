import SwiftUI

struct CharacterTabView: View {
    @EnvironmentObject var characterManager: CharacterManager
    let onCharacterContextMenu: (() -> Void)?
    
    var body: some View {
        Group {
            if let selectedCharacter = characterManager.selectedCharacter {
                CharacterView(
                    character: selectedCharacter,
                    onCharacterUpdate: { updatedCharacter in
                        characterManager.updateCharacter(updatedCharacter)
                    },
                    onCharacterContextMenu: onCharacterContextMenu
                )
            } else {
                CharacterSelectionView()
            }
        }
    }
}

#Preview {
    CharacterTabView(onCharacterContextMenu: nil)
}
