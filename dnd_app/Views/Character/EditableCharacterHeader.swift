import SwiftUI

struct EditableCharacterHeader: View {
    @Binding var character: Character
    @State private var showingEditSheet = false
    @EnvironmentObject private var dataService: DataService
    @Environment(\.colorScheme) private var colorScheme
    let onCharacterContextMenu: (() -> Void)?
    let onCharacterUpdate: ((Character) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Аватар
                Circle()
                    .fill(Color.orange)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                        Text(character.race)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Уровень \(character.level)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Кнопка редактирования
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            
            // Информация о классе и предыстории
            HStack(spacing: 12) {
                infoCard(
                    title: "Класс",
                    value: character.characterClass,
                    icon: "star.fill",
                    color: .green
                )
                
                infoCard(
                    title: "Подкласс",
                    value: character.subclass ?? "Нет подкласса",
                    icon: "star.fill",
                    color: .orange
                )
                
                infoCard(
                    title: "Предыстория",
                    value: character.background,
                    icon: "book.fill",
                    color: .purple
                )
                
                infoCard(
                    title: "Мировоззрение",
                    value: character.alignmentShort,
                    icon: "person.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(adaptiveBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingEditSheet) {
            EditCharacterHeaderView(character: $character, onCharacterUpdate: onCharacterUpdate)
                .environmentObject(dataService)
        }
    }
    
    private func infoCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        case .light:
            return Color.white
        @unknown default:
            return Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var adaptiveShadowColor: Color {
        switch colorScheme {
        case .dark:
            return .black.opacity(0.3)
        case .light:
            return .black.opacity(0.1)
        @unknown default:
            return .black.opacity(0.1)
        }
    }
}

struct EditCharacterHeaderView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var character: Character
    @EnvironmentObject private var dataService: DataService
    let onCharacterUpdate: ((Character) -> Void)?
    
    @State private var name: String
    @State private var race: String
    @State private var characterClass: String
    @State private var subclass: String
    @State private var background: String
    @State private var alignment: String
    @State private var level: Int
    
    init(character: Binding<Character>, onCharacterUpdate: ((Character) -> Void)? = nil) {
        self._character = character
        self.onCharacterUpdate = onCharacterUpdate
        self._name = State(initialValue: character.wrappedValue.name)
        self._race = State(initialValue: character.wrappedValue.race)
        self._characterClass = State(initialValue: character.wrappedValue.characterClass)
        self._subclass = State(initialValue: character.wrappedValue.subclass ?? "")
        self._background = State(initialValue: character.wrappedValue.background)
        self._alignment = State(initialValue: character.wrappedValue.alignment)
        self._level = State(initialValue: character.wrappedValue.level)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя персонажа", text: $name)
                    
                    TextField("Раса", text: $race)
                    
                    Stepper("Уровень: \(level)", value: $level, in: 1...20)
                }
                
                Section("Класс и подкласс") {
                    Picker("Класс", selection: $characterClass) {
                        ForEach(availableClasses, id: \.self) { className in
                            Text(className).tag(className)
                        }
                    }
                    
                    Picker("Подкласс", selection: $subclass) {
                        ForEach(availableSubclasses, id: \.self) { subclassName in
                            Text(subclassName).tag(subclassName)
                        }
                    }
                }
                
                Section("Предыстория и мировоззрение") {
                    Picker("Предыстория", selection: $background) {
                        ForEach(availableBackgrounds, id: \.self) { backgroundName in
                            Text(backgroundName).tag(backgroundName)
                        }
                    }
                    
                    Picker("Мировоззрение", selection: $alignment) {
                        ForEach(availableAlignments, id: \.self) { alignment in
                            Text(alignment).tag(alignment)
                        }
                    }
                }
            }
            .navigationTitle("Редактировать персонажа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        character.name = name
                        character.race = race
                        character.characterClass = characterClass
                        character.subclass = subclass.isEmpty ? nil : subclass
                        character.background = background
                        character.alignment = alignment
                        character.level = level
                        character.dateModified = Date()
                        onCharacterUpdate?(character)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private var availableClasses: [String] {
        return dataService.dndClasses.map { $0.nameRu }
    }
    
    private var availableSubclasses: [String] {
        if let selectedClass = dataService.dndClasses.first(where: { $0.nameRu == characterClass }) {
            return selectedClass.subclassNames
        }
        return ["Нет подкласса"]
    }
    
    private var availableBackgrounds: [String] {
        return dataService.backgrounds.map { $0.название }
    }
    
    private var availableAlignments: [String] {
        return [
            "Законно-добрый",
            "Нейтрально-добрый", 
            "Хаотично-добрый",
            "Законно-нейтральный",
            "Нейтральный",
            "Хаотично-нейтральный",
            "Законно-злой",
            "Нейтрально-злой",
            "Хаотично-злой"
        ]
    }
}

#Preview {
    EditableCharacterHeader(
        character: .constant(Character(
            name: "Абоба",
            race: "Человек",
            characterClass: "Монах",
            background: "Чужеземец",
            alignment: "Хаотично-нейтральный",
            level: 8
        )),
        onCharacterContextMenu: nil,
        onCharacterUpdate: nil
    )
    .environmentObject(DataService.shared)
}
