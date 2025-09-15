import SwiftUI

struct CharacterPersonalityView: View {
    @Binding var character: Character
    @Environment(\.dismiss) private var dismiss
    let onCharacterUpdate: ((Character) -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Черты характера") {
                    TextEditor(text: $character.personalityTraits)
                        .frame(minHeight: 80)
                        .onChange(of: character.personalityTraits) {
                            character.dateModified = Date()
                            onCharacterUpdate?(character)
                        }
                }
                
                Section("Идеалы") {
                    TextEditor(text: $character.ideals)
                        .frame(minHeight: 80)
                        .onChange(of: character.ideals) {
                            character.dateModified = Date()
                            onCharacterUpdate?(character)
                        }
                }
                
                Section("Привязанности") {
                    TextEditor(text: $character.bonds)
                        .frame(minHeight: 80)
                        .onChange(of: character.bonds) {
                            character.dateModified = Date()
                            onCharacterUpdate?(character)
                        }
                }
                
                Section("Слабости") {
                    TextEditor(text: $character.flaws)
                        .frame(minHeight: 80)
                        .onChange(of: character.flaws) {
                            character.dateModified = Date()
                            onCharacterUpdate?(character)
                        }
                }
            }
            .navigationTitle("Личность")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CharacterPersonalityView(
        character: .constant(Character(
            name: "Тест",
            race: "Человек", 
            characterClass: "Воин",
            background: "Солдат",
            alignment: "Законно-добрый"
        )),
        onCharacterUpdate: nil
    )
}

