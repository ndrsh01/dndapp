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
        VStack(spacing: 16) {
            // Главная карточка с общей информацией
            HStack(spacing: 20) {
                // Иконка сокровищ
                VStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.3), radius: 4)
                    
                    Text("Сокровища")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Статистика
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 16) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(totalValue)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            Text("золотых")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(character.treasures.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("предметов")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
            )
            
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
        HStack(spacing: 16) {
            // Иконка предмета с фоном
            ZStack {
                Circle()
                    .fill(item.category.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: item.category.icon)
                    .font(.title3)
                    .foregroundColor(item.category.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
                
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if item.value > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "diamond.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("\(item.value) зм")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            
            // Кнопка удаления
            Button(action: {
                removeTreasure(item: item)
            }) {
                Image(systemName: "trash.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.category.color.opacity(0.2), lineWidth: 1)
        )
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
                Section {
                    HStack {
                        Image(systemName: "diamond.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        TextField("Название сокровища", text: $newTreasure.name)
                    }
                    
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
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                            .background(Color(.systemBackground))
                    }
                } header: {
                    Text("Основная информация")
                }
                
                Section {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        TextField("Стоимость", value: $newTreasure.value, format: .number)
                            .keyboardType(.numberPad)
                            .background(Color(.systemBackground))
                        Text("золотых")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Стоимость")
                }
                
                Section {
                    TextField("Описание сокровища", text: $newTreasure.description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Описание")
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
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        hideKeyboard()
                    }
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
