import SwiftUI

struct CharacterFeaturesView: View {
    @Binding var character: Character
    @Environment(\.dismiss) private var dismiss
    let onCharacterUpdate: ((Character) -> Void)?
    @State private var newFeature = ""
    @State private var showingAddField = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if character.features.isEmpty {
                        Text("Нет особенностей")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(character.features, id: \.self) { feature in
                            Text(feature)
                        }
                        .onDelete(perform: deleteFeature)
                    }
                }
                
                Section {
                    if showingAddField {
                        HStack {
                            TextField("Название особенности", text: $newFeature)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Добавить") {
                                if !newFeature.isEmpty {
                                    character.features.append(newFeature)
                                    character.dateModified = Date()
                                    onCharacterUpdate?(character)
                                    newFeature = ""
                                    showingAddField = false
                                }
                            }
                            .disabled(newFeature.isEmpty)
                            
                            Button("Отмена") {
                                newFeature = ""
                                showingAddField = false
                            }
                        }
                    } else {
                        Button(action: {
                            showingAddField = true
                        }) {
                            Label("Добавить особенность", systemImage: "plus")
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Особенности")
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
    
    private func deleteFeature(at offsets: IndexSet) {
        character.features.remove(atOffsets: offsets)
        character.dateModified = Date()
        onCharacterUpdate?(character)
    }
}

#Preview {
    CharacterFeaturesView(
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
