import SwiftUI
import Foundation

struct CharacterEquipmentView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showingAdvancedAddItem = false
    @State private var showingEditItem = false
    @State private var newEquipment = CharacterEquipment(name: "")
    @State private var editingEquipment: CharacterEquipment?
    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Добавить") {
                        showingAdvancedAddItem = true
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingAdvancedAddItem) {
            advancedAddEquipmentSheet
        }
        .sheet(isPresented: $showingEditItem) {
            if let editingEquipment = editingEquipment {
                editEquipmentSheet(equipment: editingEquipment)
            }
        }
    }
    
    private var equipmentHeader: some View {
        VStack(spacing: 16) {
            // Главная карточка с общей информацией
            HStack(spacing: 20) {
                // Иконка снаряжения
                VStack(spacing: 8) {
                    Image(systemName: "backpack.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 4)
                    
                    Text("Снаряжение")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Статистика
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 16) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(String(format: "%.1f", totalWeight))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("кг")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(character.equipment.count)")
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
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
            
            // Прогресс бар загрузки
            if maxCarryingCapacity > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text("Загрузка")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", totalWeight)) / \(String(format: "%.1f", maxCarryingCapacity)) кг")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
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
                        Text(loadPercentage <= 0.5 ? "Легкая загрузка" : loadPercentage <= 0.75 ? "Средняя загрузка" : "Тяжелая загрузка")
                            .font(.caption)
                            .foregroundColor(loadColor)
                        
                        Spacer()
                        
                        Text("\(Int(loadPercentage * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var equipmentList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if character.equipment.isEmpty {
                    emptyStateView
                } else {
                    ForEach(character.equipment, id: \.id) { item in
                        equipmentItemRow(item: item)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func equipmentItemRow(item: CharacterEquipment) -> some View {
        HStack(spacing: 16) {
            // Иконка предмета с фоном
            ZStack {
                Circle()
                    .fill(item.type.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: item.type.icon)
                    .font(.title3)
                    .foregroundColor(item.type.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(item.rarity.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(item.rarity.color)
                        .cornerRadius(8)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "scalemass.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("\(String(format: "%.1f", item.weight)) кг")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("\(item.cost) м")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.type.color.opacity(0.2), lineWidth: 1)
        )
        .contextMenu {
            Button(action: {
                editEquipment(item: item)
            }) {
                Label("Редактировать", systemImage: "pencil")
            }
            
            Button(action: {
                removeEquipment(item: item)
            }) {
                Label("Удалить", systemImage: "trash")
            }
        }
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
                Section {
                    HStack {
                        Image(systemName: "backpack.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        TextField("Название предмета", text: $newEquipment.name)
                    }
                    
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
                } header: {
                    Text("Основная информация")
                }
                
                Section {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        TextField("Стоимость", value: $newEquipment.cost, format: .number)
                            .keyboardType(.numberPad)
                            .background(Color(.systemBackground))
                        Text("медных")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "scalemass.fill")
                            .foregroundColor(.blue)
                        TextField("Вес", value: $newEquipment.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .background(Color(.systemBackground))
                        Text("кг")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Характеристики")
                }
                
                if newEquipment.type == .weapon {
                    Section {
                        HStack {
                            Text("Бонус к попаданию")
                            Spacer()
                            TextField("0", value: Binding(
                                get: { newEquipment.attackBonus ?? 0 },
                                set: { newEquipment.attackBonus = $0 }
                            ), format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Урон")
                            Spacer()
                            TextField("1d4", text: Binding(
                                get: { newEquipment.damage ?? "" },
                                set: { newEquipment.damage = $0 }
                            ))
                            .frame(width: 120)
                            .multilineTextAlignment(.trailing)
                        }
                    } header: {
                        Text("Боевые характеристики")
                    }
                }
            }
            .navigationTitle("Новое снаряжение")
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
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        hideKeyboard()
                    }
                }
            }
        }
    }
    
    private func editEquipmentSheet(equipment: CharacterEquipment) -> some View {
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
                            .background(Color(.systemBackground))
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
                            .background(Color(.systemBackground))
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
            }
            .navigationTitle("Редактировать предмет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        showingEditItem = false
                        editingEquipment = nil
                        newEquipment = CharacterEquipment(name: "")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        updateEquipment()
                    }
                    .disabled(newEquipment.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
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
    
    private func editEquipment(item: CharacterEquipment) {
        editingEquipment = item
        newEquipment = item
        showingEditItem = true
    }
    
    private func removeEquipment(item: CharacterEquipment) {
        character.equipment.removeAll { $0.id == item.id }
        character.dateModified = Date()
        onCharacterUpdate?(character)
    }
    
    private func updateEquipment() {
        guard let editingEquipment = editingEquipment else { return }
        
        let trimmedName = newEquipment.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        if let index = character.equipment.firstIndex(where: { $0.id == editingEquipment.id }) {
            character.equipment[index] = newEquipment
            character.equipment[index].name = trimmedName
            character.dateModified = Date()
            onCharacterUpdate?(character)
        }
        
        newEquipment = CharacterEquipment(name: "")
        showingEditItem = false
        self.editingEquipment = nil
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Computed Properties
    
    private var totalWeight: Double {
        character.equipment.reduce(0) { total, item in
            total + item.weight
        }
    }
    
    private var maxCarryingCapacity: Double {
        let strength = character.strength
        return Double(strength * 15) // Базовое правило D&D
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
