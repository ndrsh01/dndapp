import SwiftUI

struct MulticlassManagementView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var dataService: DataService
    @State private var showingAddClass = false
    @State private var editingClass: CharacterClass?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Управление классами")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Общий уровень: \(character.totalLevel)")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Бонус владения: +\(character.effectiveProficiencyBonus)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Список классов
                    LazyVStack(spacing: 12) {
                        ForEach(character.classes) { classInfo in
                            ClassLevelCard(
                                classInfo: classInfo,
                                character: $character,
                                onCharacterUpdate: onCharacterUpdate,
                                onEdit: { editingClass = classInfo },
                                onDelete: { deleteClass(classInfo) }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка добавления класса
                    Button(action: {
                        showingAddClass = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Добавить класс")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(adaptiveBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddClass) {
            AddClassView(character: $character, onCharacterUpdate: onCharacterUpdate)
                .environmentObject(dataService)
        }
        .sheet(item: $editingClass) { classInfo in
            EditClassView(classInfo: classInfo, character: $character, onCharacterUpdate: onCharacterUpdate)
                .environmentObject(dataService)
        }
        .onAppear {
            // Инициализируем мультикласс если нужно
            if character.classes.isEmpty {
                character.initializeMulticlass()
                onCharacterUpdate?(character)
            }
        }
    }
    
    private func deleteClass(_ classInfo: CharacterClass) {
        character.removeClass(classInfo.id)
        onCharacterUpdate?(character)
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.systemBackground)
        case .light:
            return Color(red: 0.98, green: 0.97, blue: 0.95)
        @unknown default:
            return Color(UIColor.systemBackground)
        }
    }
}

struct ClassLevelCard: View {
    let classInfo: CharacterClass
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка класса
            Circle()
                .fill(classColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: classIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(classInfo.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let subclass = classInfo.subclass {
                    Text(subclass)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Уровень \(classInfo.level)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(classColor)
                    .cornerRadius(6)
            }
            
            Spacer()
            
            // Кнопки управления
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var classColor: Color {
        switch classInfo.name {
        case "Воин": return .red
        case "Маг": return .blue
        case "Жрец": return .white
        case "Плут": return .yellow
        case "Бард": return .purple
        case "Варвар": return .orange
        case "Паладин": return .pink
        case "Следопыт": return .green
        case "Монах": return .brown
        case "Друид": return .mint
        case "Колдун": return .indigo
        case "Чародей": return .cyan
        default: return .gray
        }
    }
    
    private var classIcon: String {
        switch classInfo.name {
        case "Воин": return "sword.fill"
        case "Маг": return "wand.and.stars"
        case "Жрец": return "cross.fill"
        case "Плут": return "eye.fill"
        case "Бард": return "music.note"
        case "Варвар": return "flame.fill"
        case "Паладин": return "shield.fill"
        case "Следопыт": return "leaf.fill"
        case "Монах": return "figure.martial.arts"
        case "Друид": return "tree.fill"
        case "Колдун": return "hexagon.fill"
        case "Чародей": return "sparkles"
        default: return "star.fill"
        }
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveCardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        case .light:
            return Color(red: 0.95, green: 0.94, blue: 0.92)
        @unknown default:
            return Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var adaptiveShadowColor: Color {
        switch colorScheme {
        case .dark:
            return .black.opacity(0.3)
        case .light:
            return .black.opacity(0.05)
        @unknown default:
            return .black.opacity(0.1)
        }
    }
}

struct AddClassView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataService: DataService
    @State private var selectedClass = ""
    @State private var selectedSubclass = ""
    @State private var level = 1
    
    private var availableClasses: [String] {
        return dataService.dndClasses.map { $0.nameRu }
    }
    
    private var availableSubclasses: [String] {
        guard let dndClass = dataService.dndClasses.first(where: { $0.nameRu == selectedClass }) else {
            return []
        }
        return dndClass.subclassNames
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Выбор класса") {
                    Picker("Класс", selection: $selectedClass) {
                        ForEach(availableClasses, id: \.self) { className in
                            Text(className).tag(className)
                        }
                    }
                    
                    if !availableSubclasses.isEmpty {
                        Picker("Подкласс", selection: $selectedSubclass) {
                            Text("Нет подкласса").tag("")
                            ForEach(availableSubclasses, id: \.self) { subclassName in
                                Text(subclassName).tag(subclassName)
                            }
                        }
                    }
                    
                    Stepper("Уровень: \(level)", value: $level, in: 1...20)
                }
            }
            .navigationTitle("Добавить класс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addClass()
                    }
                    .disabled(selectedClass.isEmpty)
                }
            }
        }
    }
    
    private func addClass() {
        let subclass = selectedSubclass.isEmpty ? nil : selectedSubclass
        character.addClass(selectedClass, level: level, subclass: subclass)
        onCharacterUpdate?(character)
        dismiss()
    }
}

struct EditClassView: View {
    let classInfo: CharacterClass
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataService: DataService
    @State private var level: Int
    
    init(classInfo: CharacterClass, character: Binding<Character>, onCharacterUpdate: ((Character) -> Void)?) {
        self.classInfo = classInfo
        self._character = character
        self.onCharacterUpdate = onCharacterUpdate
        self._level = State(initialValue: classInfo.level)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о классе") {
                    HStack {
                        Text("Класс")
                        Spacer()
                        Text(classInfo.name)
                            .foregroundColor(.secondary)
                    }
                    
                    if let subclass = classInfo.subclass {
                        HStack {
                            Text("Подкласс")
                            Spacer()
                            Text(subclass)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Stepper("Уровень: \(level)", value: $level, in: 1...20)
                }
            }
            .navigationTitle("Редактировать класс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        character.updateClassLevel(classInfo.id, newLevel: level)
        onCharacterUpdate?(character)
        dismiss()
    }
}

#Preview {
    MulticlassManagementView(
        character: .constant(Character(
            name: "Тестовый персонаж",
            race: "Человек",
            characterClass: "Воин",
            background: "Солдат",
            alignment: "Законно-добрый"
        )),
        onCharacterUpdate: nil
    )
    .environmentObject(DataService.shared)
}
