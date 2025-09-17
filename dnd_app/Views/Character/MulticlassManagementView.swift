import SwiftUI

struct MulticlassManagementView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var dataService: DataService
    @State private var editingClass: CharacterClass?
    @State private var showingAddClass = false
    @State private var showingEditMainClass = false
    
    var body: some View {
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
                    
                    // Основной класс (если не мультикласс)
                    if !character.isMulticlass {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Основной класс")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            let mainClass = CharacterClass(name: character.characterClass, level: character.level, subclass: character.subclass)
                            Button(action: {
                                showingEditMainClass = true
                            }) {
                                ClassLevelCard(
                                    classInfo: mainClass,
                                    character: $character,
                                    onCharacterUpdate: onCharacterUpdate,
                                    onEdit: { },
                                    onDelete: nil
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Список классов (для мультикласса)
                    if character.isMulticlass {
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
                    }
                    
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
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(adaptiveBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingAddClass) {
            NavigationView {
                AddClassView(character: $character, onCharacterUpdate: onCharacterUpdate)
                    .environmentObject(dataService)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .fullScreenCover(isPresented: $showingEditMainClass) {
            NavigationView {
                EditMainClassView(character: $character, onCharacterUpdate: onCharacterUpdate)
                    .environmentObject(dataService)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(item: $editingClass) { classInfo in
            EditClassView(classInfo: classInfo, character: $character, onCharacterUpdate: onCharacterUpdate)
                .environmentObject(dataService)
        }
        .onAppear {
            dataService.ensureClassesLoaded()
            
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
    let onDelete: (() -> Void)?
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
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var classColor: Color {
        // Универсальная система цветов для классов
        let colors: [String: Color] = [
            "Варвар": .orange,
            "Бард": .purple,
            "Жрец": .white,
            "Друид": .mint,
            "Воин": .red,
            "Монах": .brown,
            "Паладин": .pink,
            "Следопыт": .green,
            "Плут": .yellow,
            "Чародей": .cyan,
            "Колдун": .indigo,
            "Волшебник": .blue
        ]
        return colors[classInfo.name] ?? .gray
    }
    
    private var classIcon: String {
        // Универсальная система иконок для классов
        let icons: [String: String] = [
            "Варвар": "flame.fill",
            "Бард": "music.note",
            "Жрец": "cross.fill",
            "Друид": "tree.fill",
            "Воин": "sword.fill",
            "Монах": "figure.martial.arts",
            "Паладин": "shield.fill",
            "Следопыт": "leaf.fill",
            "Плут": "eye.fill",
            "Чародей": "sparkles",
            "Колдун": "hexagon.fill",
            "Волшебник": "wand.and.stars"
        ]
        return icons[classInfo.name] ?? "star.fill"
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
    @State private var selectedClass: String = ""
    @State private var selectedSubclass = ""
    @State private var level = 1
    @State private var classesLoaded = false
    
    private var availableClasses: [String] {
        return dataService.dndClasses.map { $0.nameRu }
    }
    
    private var availableSubclasses: [String] {
        var subclasses = [""] // Пустая строка для "Нет подкласса"
        guard !selectedClass.isEmpty, let dndClass = dataService.dndClasses.first(where: { $0.nameRu == selectedClass }) else {
            return subclasses
        }
        subclasses.append(contentsOf: dndClass.subclassNames)
        return subclasses
    }
    
    var body: some View {
        Form {
            Section("Новый класс") {
                Picker("Класс", selection: $selectedClass) {
                    if !classesLoaded || dataService.dndClasses.isEmpty {
                        Text("Загрузка классов...").tag("")
                    } else {
                        ForEach(availableClasses, id: \.self) { className in
                            Text(className).tag(className)
                        }
                    }
                }
                .onChange(of: selectedClass) { newClass in
                    // Сбрасываем подкласс при изменении класса
                    selectedSubclass = ""
                }
                
                if classesLoaded && !availableSubclasses.isEmpty {
                    Picker("Подкласс", selection: $selectedSubclass) {
                        Text("Нет подкласса").tag("")
                        ForEach(availableSubclasses.filter { !$0.isEmpty }, id: \.self) { subclassName in
                            Text(subclassName).tag(subclassName)
                        }
                    }
                }
                
                Stepper("Уровень: \(level)", value: $level, in: 1...20)
            }
        }
        .navigationTitle("Добавить новый класс")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            dataService.ensureClassesLoaded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                classesLoaded = !dataService.dndClasses.isEmpty
            if selectedClass.isEmpty && !dataService.dndClasses.isEmpty {
                selectedClass = dataService.dndClasses.first?.nameRu ?? ""
            }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
                .foregroundColor(.orange)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    addClass()
                }
                .disabled(selectedClass.isEmpty)
                .foregroundColor(.orange)
            }
        }
    }
    
    private func addClass() {
        print("DEBUG: addClass() called")
        guard !selectedClass.isEmpty else { 
            print("DEBUG: selectedClass is empty, returning")
            return 
        }
        print("DEBUG: Adding class \(selectedClass), level \(level), subclass \(selectedSubclass)")
        let subclass = selectedSubclass.isEmpty ? nil : selectedSubclass
        
        print("DEBUG: Calling character.addClass")
        character.addClass(selectedClass, level: level, subclass: subclass)
        print("DEBUG: character.addClass completed")
        
        print("DEBUG: Calling onCharacterUpdate")
        onCharacterUpdate?(character)
        print("DEBUG: onCharacterUpdate completed")
        
        print("DEBUG: Calling dismiss")
        dismiss()
        print("DEBUG: dismiss completed")
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
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .foregroundColor(.orange)
                }
            }
    }
    
    private func saveChanges() {
        character.updateClassLevel(classInfo.id, newLevel: level)
        onCharacterUpdate?(character)
        dismiss()
    }
}

struct EditMainClassView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataService: DataService
    @State private var selectedClass: String
    @State private var selectedSubclass: String
    @State private var level: Int
    
    init(character: Binding<Character>, onCharacterUpdate: ((Character) -> Void)?) {
        self._character = character
        self.onCharacterUpdate = onCharacterUpdate
        self._selectedClass = State(initialValue: character.wrappedValue.characterClass)
        self._selectedSubclass = State(initialValue: character.wrappedValue.subclass ?? "Нет подкласса")
        self._level = State(initialValue: character.wrappedValue.level)
    }
    
    private var availableClasses: [String] {
        return dataService.dndClasses.map { $0.nameRu }
    }
    
    private var availableSubclasses: [String] {
        var subclasses = ["Нет подкласса"]
        if let dndClass = dataService.dndClasses.first(where: { $0.nameRu == selectedClass }) {
            subclasses.append(contentsOf: dndClass.subclassNames)
        }
        return subclasses
    }
    
    var body: some View {
        Form {
            Section("Основной класс") {
                Picker("Класс", selection: $selectedClass) {
                    ForEach(availableClasses, id: \.self) { className in
                        Text(className).tag(className)
                    }
                }
                .onChange(of: selectedClass) { newClass in
                    selectedSubclass = "Нет подкласса"
                }
                
                Picker("Подкласс", selection: $selectedSubclass) {
                    ForEach(availableSubclasses, id: \.self) { subclassName in
                        Text(subclassName).tag(subclassName)
                    }
                }
                
                Stepper("Уровень: \(level)", value: $level, in: 1...20)
            }
        }
        .navigationTitle("Редактировать основной класс")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
                .foregroundColor(.orange)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    print("DEBUG: EditMainClassView Save button pressed")
                    character.characterClass = selectedClass
                    character.subclass = selectedSubclass == "Нет подкласса" ? nil : selectedSubclass
                    character.level = level
                    character.dateModified = Date()
                    
                    // Обновляем мультикласс если он инициализирован
                    if !character.classes.isEmpty {
                        let newSubclass = selectedSubclass == "Нет подкласса" ? nil : selectedSubclass
                        character.classes[0] = CharacterClass(name: selectedClass, level: level, subclass: newSubclass)
                    }
                    
                    print("DEBUG: Calling onCharacterUpdate")
                    onCharacterUpdate?(character)
                    print("DEBUG: onCharacterUpdate completed")
                    
                    print("DEBUG: Calling dismiss")
                    dismiss()
                    print("DEBUG: dismiss completed")
                }
                .foregroundColor(.orange)
            }
        }
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
