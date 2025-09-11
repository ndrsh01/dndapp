import SwiftUI
import Foundation

struct CharacterEquipmentView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showingAdvancedAddItem = false
    @State private var newEquipment = CharacterEquipment(name: "")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок с общей информацией
                equipmentHeader
                
                // Список снаряжения
                equipmentList
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Снаряжение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Убрали дублирующую кнопку - оставили только в emptyStateView
            }
        }
        .sheet(isPresented: $showingAdvancedAddItem) {
            advancedAddEquipmentSheet
        }
    }
    
    private var equipmentHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Общий вес снаряжения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(totalWeight) кг")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Предметов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(character.equipment.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            // Прогресс бар загрузки
            if maxCarryingCapacity > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(loadColor)
                            .frame(width: geometry.size.width * loadPercentage, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: loadPercentage)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(Int(loadPercentage * 100))% от максимальной грузоподъемности")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(maxCarryingCapacity) кг макс.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var equipmentList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(character.equipment) { item in
                    equipmentItemRow(item: item)
                }
                
                if character.equipment.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func equipmentItemRow(item: CharacterEquipment) -> some View {
        HStack(spacing: 12) {
            // Иконка предмета
            Image(systemName: item.type.icon)
                .font(.title3)
                .foregroundColor(item.type.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(item.rarity.rawValue)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.rarity.color)
                        .cornerRadius(4)
                }
                
                HStack {
                    Text("\(item.weight) кг")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(item.cost) м")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Для оружия показываем бонус к попаданию и урон
                if let attackBonus = item.attackBonus, let damage = item.damage {
                    HStack {
                        Text("+\(attackBonus) к попаданию")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("\(damage) урона")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Кнопка удаления
            Button(action: {
                removeEquipment(item: item)
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
            Image(systemName: "bag")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Снаряжение пусто")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Добавьте предметы снаряжения для вашего персонажа")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Добавить предмет") {
                showingAdvancedAddItem = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
    
    
    private var advancedAddEquipmentSheet: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название предмета", text: $newEquipment.name)
                    
                    Picker("Тип", selection: $newEquipment.type) {
                        ForEach(EquipmentType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    Picker("Редкость", selection: $newEquipment.rarity) {
                        ForEach(Rarity.allCases, id: \.self) { rarity in
                            HStack {
                                Circle()
                                    .fill(rarity.color)
                                    .frame(width: 12, height: 12)
                                Text(rarity.rawValue)
                            }
                            .tag(rarity)
                        }
                    }
                }
                
                Section("Характеристики") {
                    HStack {
                        Text("Стоимость")
                        Spacer()
                        TextField("0", value: $newEquipment.cost, format: .number)
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
                        Text("медных монет")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Вес")
                        Spacer()
                        TextField("0.0", value: $newEquipment.weight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("кг")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Для оружия
                if newEquipment.type == .weapon {
                    Section("Боевые характеристики") {
                        HStack {
                            Text("Бонус к попаданию")
                            Spacer()
                            TextField("0", value: Binding(
                                get: { newEquipment.attackBonus ?? 0 },
                                set: { newEquipment.attackBonus = $0 }
                            ), format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                        }
                        
                        HStack {
                            Text("Урон")
                            Spacer()
                            TextField("1d4", text: Binding(
                                get: { newEquipment.damage ?? "" },
                                set: { newEquipment.damage = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                        }
                    }
                }
                
                Section("Описание") {
                    TextField("Описание предмета", text: $newEquipment.description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Новый предмет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        showingAdvancedAddItem = false
                        newEquipment = CharacterEquipment(name: "")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addAdvancedEquipment()
                    }
                    .disabled(newEquipment.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalWeight: Double {
        character.equipment.reduce(0) { total, item in
            total + item.weight
        }
    }
    
    private var maxCarryingCapacity: Double {
        // Базовая грузоподъемность: 15 * СИЛ
        let strengthScore = character.strength
        return Double(strengthScore * 15)
    }
    
    private var loadPercentage: Double {
        guard maxCarryingCapacity > 0 else { return 0 }
        return min(totalWeight / maxCarryingCapacity, 1.0)
    }
    
    private var loadColor: Color {
        if loadPercentage <= 0.5 {
            return .green
        } else if loadPercentage <= 0.75 {
            return .yellow
        } else {
            return .red
        }
    }
    
    
    // MARK: - Helper Functions
    
    private func estimatedWeight(for item: String) -> Double {
        let itemLower = item.lowercased()
        
        // Примерные веса предметов
        if itemLower.contains("меч") || itemLower.contains("sword") {
            return 1.5
        } else if itemLower.contains("щит") || itemLower.contains("shield") {
            return 3.0
        } else if itemLower.contains("лук") || itemLower.contains("bow") {
            return 1.0
        } else if itemLower.contains("стрел") || itemLower.contains("arrow") {
            return 0.05
        } else if itemLower.contains("доспех") || itemLower.contains("armor") {
            return 15.0
        } else if itemLower.contains("кольцо") || itemLower.contains("ring") {
            return 0.01
        } else if itemLower.contains("зелье") || itemLower.contains("potion") {
            return 0.5
        } else if itemLower.contains("свиток") || itemLower.contains("scroll") {
            return 0.1
        } else if itemLower.contains("веревк") || itemLower.contains("rope") {
            return 2.0
        } else if itemLower.contains("факел") || itemLower.contains("torch") {
            return 0.5
        } else if itemLower.contains("еда") || itemLower.contains("food") {
            return 0.5
        } else if itemLower.contains("вода") || itemLower.contains("water") {
            return 1.0
        } else {
            return 1.0 // Вес по умолчанию
        }
    }
    
    private func itemIcon(for item: String) -> String {
        let itemLower = item.lowercased()
        
        if itemLower.contains("меч") || itemLower.contains("sword") {
            return "sword.fill"
        } else if itemLower.contains("щит") || itemLower.contains("shield") {
            return "shield.fill"
        } else if itemLower.contains("лук") || itemLower.contains("bow") {
            return "bow.and.arrow"
        } else if itemLower.contains("стрел") || itemLower.contains("arrow") {
            return "arrow"
        } else if itemLower.contains("доспех") || itemLower.contains("armor") {
            return "shield.lefthalf.filled"
        } else if itemLower.contains("кольцо") || itemLower.contains("ring") {
            return "circle.fill"
        } else if itemLower.contains("зелье") || itemLower.contains("potion") {
            return "drop.fill"
        } else if itemLower.contains("свиток") || itemLower.contains("scroll") {
            return "scroll.fill"
        } else if itemLower.contains("веревк") || itemLower.contains("rope") {
            return "line.3.horizontal"
        } else if itemLower.contains("факел") || itemLower.contains("torch") {
            return "flame.fill"
        } else if itemLower.contains("еда") || itemLower.contains("food") {
            return "fork.knife"
        } else if itemLower.contains("вода") || itemLower.contains("water") {
            return "drop"
        } else {
            return "bag.fill"
        }
    }
    
    private func itemColor(for item: String) -> Color {
        let itemLower = item.lowercased()
        
        if itemLower.contains("меч") || itemLower.contains("sword") {
            return .gray
        } else if itemLower.contains("щит") || itemLower.contains("shield") {
            return .blue
        } else if itemLower.contains("лук") || itemLower.contains("bow") {
            return .brown
        } else if itemLower.contains("стрел") || itemLower.contains("arrow") {
            return .brown
        } else if itemLower.contains("доспех") || itemLower.contains("armor") {
            return .blue
        } else if itemLower.contains("кольцо") || itemLower.contains("ring") {
            return .yellow
        } else if itemLower.contains("зелье") || itemLower.contains("potion") {
            return .red
        } else if itemLower.contains("свиток") || itemLower.contains("scroll") {
            return .purple
        } else if itemLower.contains("веревк") || itemLower.contains("rope") {
            return .brown
        } else if itemLower.contains("факел") || itemLower.contains("torch") {
            return .orange
        } else if itemLower.contains("еда") || itemLower.contains("food") {
            return .green
        } else if itemLower.contains("вода") || itemLower.contains("water") {
            return .blue
        } else {
            return .gray
        }
    }
    
    
    private func removeEquipment(item: CharacterEquipment) {
        character.equipment.removeAll { $0.id == item.id }
        character.dateModified = Date()
        onCharacterUpdate?(character)
    }
    
    private func addAdvancedEquipment() {
        let trimmedName = newEquipment.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        var equipment = newEquipment
        equipment.name = trimmedName
        
        character.equipment.append(equipment)
        character.dateModified = Date()
        onCharacterUpdate?(character)
        
        newEquipment = CharacterEquipment(name: "")
        showingAdvancedAddItem = false
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CharacterEquipmentView(
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
