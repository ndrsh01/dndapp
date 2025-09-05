import SwiftUI

struct CharacterEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataService: DataService
    @State private var character: Character
    
    let onSave: (Character) -> Void
    
    init(character: Character, onSave: @escaping (Character) -> Void) {
        self._character = State(initialValue: character)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $character.name)
                    TextField("Раса", text: $character.race)
                    
                    Picker("Класс", selection: $character.characterClass) {
                        ForEach(dataService.dndClasses, id: \.nameRu) { dndClass in
                            Text(dndClass.nameRu).tag(dndClass.nameRu)
                        }
                    }
                    
                    Picker("Подкласс", selection: Binding(
                        get: { character.subclass ?? "Нет подкласса" },
                        set: { character.subclass = $0 == "Нет подкласса" ? nil : $0 }
                    )) {
                        ForEach(availableSubclasses, id: \.self) { subclass in
                            Text(subclass).tag(subclass)
                        }
                    }
                    
                    Picker("Предыстория", selection: $character.background) {
                        ForEach(dataService.backgrounds, id: \.название) { background in
                            Text(background.название).tag(background.название)
                        }
                    }
                    
                    Picker("Мировоззрение", selection: $character.alignment) {
                        ForEach(availableAlignments, id: \.self) { alignment in
                            Text(alignment).tag(alignment)
                        }
                    }
                    
                    Stepper("Уровень: \(character.level)", value: $character.level, in: 1...20)
                }
                
                Section("Основные характеристики") {
                    HStack {
                        Text("Сила")
                        Spacer()
                        Stepper("\(character.strength)", value: $character.strength, in: 1...30)
                    }
                    
                    HStack {
                        Text("Ловкость")
                        Spacer()
                        Stepper("\(character.dexterity)", value: $character.dexterity, in: 1...30)
                    }
                    
                    HStack {
                        Text("Телосложение")
                        Spacer()
                        Stepper("\(character.constitution)", value: $character.constitution, in: 1...30)
                    }
                    
                    HStack {
                        Text("Интеллект")
                        Spacer()
                        Stepper("\(character.intelligence)", value: $character.intelligence, in: 1...30)
                    }
                    
                    HStack {
                        Text("Мудрость")
                        Spacer()
                        Stepper("\(character.wisdom)", value: $character.wisdom, in: 1...30)
                    }
                    
                    HStack {
                        Text("Харизма")
                        Spacer()
                        Stepper("\(character.charisma)", value: $character.charisma, in: 1...30)
                    }
                }
                
                Section("Боевые характеристики") {
                    HStack {
                        Text("Класс брони")
                        Spacer()
                        Stepper("\(character.armorClass)", value: $character.armorClass, in: 0...50)
                    }
                    
                    HStack {
                        Text("Инициатива")
                        Spacer()
                        Stepper("\(character.initiative)", value: $character.initiative, in: -10...20)
                    }
                    
                    HStack {
                        Text("Скорость")
                        Spacer()
                        Stepper("\(character.speed) фт.", value: $character.speed, in: 0...200)
                    }
                    
                    HStack {
                        Text("Текущие хиты")
                        Spacer()
                        Stepper("\(character.hitPoints)", value: $character.hitPoints, in: 0...character.maxHitPoints)
                    }
                    
                    HStack {
                        Text("Максимальные хиты")
                        Spacer()
                        Stepper("\(character.maxHitPoints)", value: $character.maxHitPoints, in: 1...999)
                    }
                    
                    HStack {
                        Text("Бонус мастерства")
                        Spacer()
                        Stepper("\(character.proficiencyBonus)", value: $character.proficiencyBonus, in: 0...10)
                    }
                }
                
                Section("Дополнительная информация") {
                    TextField("Черты личности", text: $character.personalityTraits, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Идеалы", text: $character.ideals, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Привязанности", text: $character.bonds, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Слабости", text: $character.flaws, axis: .vertical)
                        .lineLimit(3...6)
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
                        character.dateModified = Date()
                        onSave(character)
                        dismiss()
                    }
                    .disabled(character.name.isEmpty)
                }
            }
        }
    }
    
    private var availableSubclasses: [String] {
        if let selectedClass = dataService.dndClasses.first(where: { $0.nameRu == character.characterClass }) {
            return selectedClass.subclassNames
        }
        return ["Нет подкласса"]
    }
    
    private var availableAlignments: [String] {
        return [
            "Законно-добрый",
            "Нейтрально-добрый",
            "Хаотично-добрый",
            "Законно-нейтральный",
            "Истинно-нейтральный",
            "Хаотично-нейтральный",
            "Законно-злой",
            "Нейтрально-злой",
            "Хаотично-злой"
        ]
    }
}

#Preview {
    CharacterEditView(character: Character(
        name: "Тестовый персонаж",
        race: "Человек",
        characterClass: "Воин",
        background: "Солдат",
        alignment: "Законно-добрый"
    )) { _ in }
}
