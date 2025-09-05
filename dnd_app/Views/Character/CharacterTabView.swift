import SwiftUI

struct CharacterTabView: View {
    @EnvironmentObject var characterManager: CharacterManager
    
    var body: some View {
        Group {
            if let selectedCharacter = characterManager.selectedCharacter {
                CharacterView(character: selectedCharacter) { updatedCharacter in
                    characterManager.updateCharacter(updatedCharacter)
                }
            } else {
                CharacterSelectionView()
            }
        }
    }
}

#Preview {
    CharacterTabView()
}
