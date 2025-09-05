import SwiftUI

struct CharacterCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var character = Character(
        name: "",
        race: "Человек",
        characterClass: "Воин",
        background: "Солдат",
        alignment: "Законно-добрый",
        level: 1
    )
    
    let onSave: (Character) -> Void
    
    private let totalSteps = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Прогресс-бар
                progressBar
                
                // Контент шага
                TabView(selection: $currentStep) {
                    BasicInfoStep(character: $character)
                        .tag(0)
                    
                    RaceClassStep(character: $character)
                        .tag(1)
                    
                    AbilityScoresStep(character: $character)
                        .tag(2)
                    
                    BackgroundStep(character: $character)
                        .tag(3)
                    
                    ReviewStep(character: character)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Навигационные кнопки
                navigationButtons
            }
            .navigationTitle("Создание персонажа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Шаг \(currentStep + 1) из \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(stepTitle)
                    .font(.headline)
            }
            .padding(.horizontal)
            
            ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Основная информация"
        case 1: return "Раса и класс"
        case 2: return "Характеристики"
        case 3: return "Предыстория"
        case 4: return "Обзор"
        default: return ""
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Назад") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .foregroundColor(.orange)
            }
            
            Spacer()
            
            if currentStep < totalSteps - 1 {
                Button("Далее") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.orange)
                .cornerRadius(8)
            } else {
                Button("Создать") {
                    onSave(character)
                    dismiss()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(character.name.isEmpty ? Color.gray : Color.orange)
                .cornerRadius(8)
                .disabled(character.name.isEmpty)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Step Views

struct BasicInfoStep: View {
    @Binding var character: Character
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                Text("Основная информация")
                    .font(.title2)
                    .fontWeight(.bold)
                    
                    Text("Расскажите о вашем персонаже")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Форма
                VStack(spacing: 20) {
                    FormField(
                        title: "Имя персонажа",
                        placeholder: "Введите имя",
                        text: $character.name
                    )
                    
                    FormField(
                        title: "Уровень",
                        placeholder: "1",
                        text: Binding(
                            get: { String(character.level) },
                            set: { character.level = Int($0) ?? 1 }
                        )
                    )
                    
                    FormField(
                        title: "Мировоззрение",
                        placeholder: "Законно-добрый",
                        text: $character.alignment
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

struct RaceClassStep: View {
    @Binding var character: Character
    
    private let races = ["Человек", "Эльф", "Дварф", "Халфлинг", "Драконорожденный", "Гном", "Полуэльф", "Полуорк", "Тифлинг"]
    private let classes = ["Воин", "Маг", "Клирик", "Плут", "Бард", "Друид", "Паладин", "Следопыт", "Чернокнижник", "Монах", "Варвар", "Изобретатель"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                Text("Раса и класс")
                    .font(.title2)
                    .fontWeight(.bold)
                    
                    Text("Выберите расу и класс персонажа")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Выбор расы
                VStack(alignment: .leading, spacing: 12) {
                    Text("Раса")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(races, id: \.self) { race in
                            SelectionCard(
                                title: race,
                                isSelected: character.race == race,
                                action: { character.race = race }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Выбор класса
                VStack(alignment: .leading, spacing: 12) {
                    Text("Класс")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(classes, id: \.self) { characterClass in
                            SelectionCard(
                                title: characterClass,
                                isSelected: character.characterClass == characterClass,
                                action: { character.characterClass = characterClass }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct AbilityScoresStep: View {
    @Binding var character: Character
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                Text("Характеристики")
                    .font(.title2)
                    .fontWeight(.bold)
                    
                    Text("Распределите очки характеристик")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Характеристики
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    AbilityScoreField(
                        title: "Сила",
                        value: $character.strength,
                        color: .red
                    )
                    
                    AbilityScoreField(
                        title: "Ловкость",
                        value: $character.dexterity,
                        color: .green
                    )
                    
                    AbilityScoreField(
                        title: "Телосложение",
                        value: $character.constitution,
                        color: .orange
                    )
                    
                    AbilityScoreField(
                        title: "Интеллект",
                        value: $character.intelligence,
                        color: .blue
                    )
                    
                    AbilityScoreField(
                        title: "Мудрость",
                        value: $character.wisdom,
                        color: .purple
                    )
                    
                    AbilityScoreField(
                        title: "Харизма",
                        value: $character.charisma,
                        color: .pink
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

struct BackgroundStep: View {
    @Binding var character: Character
    
    private let backgrounds = ["Солдат", "Ученый", "Торговец", "Пират", "Следопыт", "Благородный", "Чужеземец", "Преступник", "Отшельник", "Артист"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                Text("Предыстория")
                    .font(.title2)
                    .fontWeight(.bold)
                    
                    Text("Выберите предысторию персонажа")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Выбор предыстории
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(backgrounds, id: \.self) { background in
                        SelectionCard(
                            title: background,
                            isSelected: character.background == background,
                            action: { character.background = background }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ReviewStep: View {
    let character: Character
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Обзор персонажа")
                    .font(.title2)
                    .fontWeight(.bold)
                    
                    Text("Проверьте информацию о персонаже")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Карточка персонажа
                VStack(spacing: 16) {
                    // Аватар и основная информация
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(character.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(character.race)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(character.characterClass)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Уровень \(character.level)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    
                    // Характеристики
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Характеристики")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            CharacteristicCard(title: "СИЛ", value: character.strength, modifier: character.strengthModifier)
                            CharacteristicCard(title: "ЛОВ", value: character.dexterity, modifier: character.dexterityModifier)
                            CharacteristicCard(title: "ТЕЛ", value: character.constitution, modifier: character.constitutionModifier)
                            CharacteristicCard(title: "ИНТ", value: character.intelligence, modifier: character.intelligenceModifier)
                            CharacteristicCard(title: "МДР", value: character.wisdom, modifier: character.wisdomModifier)
                            CharacteristicCard(title: "ХАР", value: character.charisma, modifier: character.charismaModifier)
                        }
                    }
                    
                    // Дополнительная информация
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дополнительная информация")
                            .font(.headline)
                        
                        CharacterInfoRow(label: "Предыстория", value: character.background)
                        CharacterInfoRow(label: "Мировоззрение", value: character.alignment)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Helper Views

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct SelectionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

struct AbilityScoreField: View {
    let title: String
    @Binding var value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack {
                Button("-") {
                    if value > 1 {
                        value -= 1
                    }
                }
                .foregroundColor(color)
                
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(minWidth: 40)
                
                Button("+") {
                    if value < 20 {
                        value += 1
                    }
                }
                .foregroundColor(color)
            }
            
            Text("(\(value >= 10 ? "+" : "")\((value - 10) / 2))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CharacteristicCard: View {
    let title: String
    let value: Int
    let modifier: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("(\(modifier >= 0 ? "+" : "")\(modifier))")
                .font(.caption)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct CharacterInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    CharacterCreationView { _ in }
}