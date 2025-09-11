import SwiftUI

struct CharacterTreasuresView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showingAdvancedAddItem = false
    @State private var newTreasure = Treasure(name: "")
    @State private var showingCoinsView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок с общей информацией
                treasuresHeader
                
                // Список сокровищ
                treasuresList
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Сокровища")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCoinsView = true
                    }) {
                        Image(systemName: "dollarsign.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdvancedAddItem) {
            advancedAddTreasureSheet
        }
        .sheet(isPresented: $showingCoinsView) {
            CharacterCoinsView(
                character: $character,
                onCharacterUpdate: onCharacterUpdate
            )
        }
    }
    
    private var treasuresHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Общая стоимость")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(totalValue) зм")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Предметов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(character.treasures.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            // Информация о монетах (без кнопки)
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                
                Text("Общая стоимость монет")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(totalCoinsValue) зм")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var treasuresList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(character.treasures) { item in
                    treasureItemRow(item: item)
                }
                
                if character.treasures.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func treasureItemRow(item: Treasure) -> some View {
        HStack(spacing: 12) {
            // Иконка предмета
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundColor(item.category.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if item.value > 0 {
                        Text("\(item.value) зм")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Кнопка удаления
            Button(action: {
                removeTreasure(item: item)
            }) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "diamond")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Сокровища пусты")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Добавьте сокровища и драгоценности для вашего персонажа")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Добавить сокровище") {
                showingAdvancedAddItem = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
        }
        .padding(40)
    }
    
    
    // MARK: - Computed Properties
    
    private var totalValue: Int {
        character.treasures.reduce(0) { total, item in
            total + item.value
        }
    }
    
    private var totalCoinsValue: Int {
        let copperValue = character.copperPieces / 100
        let silverValue = character.silverPieces / 10
        let electrumValue = character.electrumPieces / 2
        let goldValue = character.goldPieces
        let platinumValue = character.platinumPieces * 10
        
        return copperValue + silverValue + electrumValue + goldValue + platinumValue
    }
    
    
    // MARK: - Helper Functions
    
    
    
    private func removeTreasure(item: Treasure) {
        character.treasures.removeAll { $0.id == item.id }
        character.dateModified = Date()
        onCharacterUpdate?(character)
    }
    
    private func addAdvancedTreasure() {
        let trimmedName = newTreasure.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        var treasure = newTreasure
        treasure.name = trimmedName
        
        character.treasures.append(treasure)
        character.dateModified = Date()
        onCharacterUpdate?(character)
        
        newTreasure = Treasure(name: "")
        showingAdvancedAddItem = false
    }
    
    private var advancedAddTreasureSheet: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название сокровища", text: $newTreasure.name)
                    
                    Picker("Категория", selection: $newTreasure.category) {
                        ForEach(TreasureCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    HStack {
                        Text("Количество")
                        Spacer()
                        TextField("1", value: $newTreasure.quantity, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Готово") {
                                        hideKeyboard()
                                    }
                                }
                            }
                    }
                }
                
                Section("Стоимость") {
                    HStack {
                        Text("Стоимость")
                        Spacer()
                        TextField("0", value: $newTreasure.value, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Готово") {
                                        hideKeyboard()
                                    }
                                }
                            }
                        Text("золотых монет")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Описание") {
                    TextField("Описание сокровища", text: $newTreasure.description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Новое сокровище")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        showingAdvancedAddItem = false
                        newTreasure = Treasure(name: "")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addAdvancedTreasure()
                    }
                    .disabled(newTreasure.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CharacterTreasuresView(
        character: .constant(Character(
            name: "Тестовый персонаж",
            race: "Человек",
            characterClass: "Воин",
            background: "Солдат",
            alignment: "Законно-добрый"
        )),
        onCharacterUpdate: nil
    )
}
