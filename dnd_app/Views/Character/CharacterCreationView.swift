import SwiftUI

struct CharacterCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CharacterCreationViewModel()
    @State private var currentStep = 0
    
    let onSave: (DnDCharacter) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Bar
                ProgressView(value: Double(currentStep), total: Double(viewModel.totalSteps))
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Step Content
                TabView(selection: $currentStep) {
                    BasicInfoStepView(character: $viewModel.character)
                        .tag(0)
                    
                    RaceClassStepView(character: $viewModel.character)
                        .tag(1)
                    
                    StatsStepView(character: $viewModel.character)
                        .tag(2)
                    
                    BackgroundStepView(character: $viewModel.character)
                        .tag(3)
                    
                    EquipmentStepView(character: $viewModel.character)
                        .tag(4)
                    
                    ReviewStepView(character: viewModel.character)
                        .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack {
                    if currentStep > 0 {
                        Button("Назад") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(DnDButtonStyle())
                    }
                    
                    Spacer()
                    
                    if currentStep < viewModel.totalSteps - 1 {
                        Button("Далее") {
                            if viewModel.validateCurrentStep(currentStep) {
                                withAnimation {
                                    currentStep += 1
                                }
                            }
                        }
                        .buttonStyle(DnDButtonStyle())
                    } else {
                        Button("Создать") {
                            let character = viewModel.createCharacter()
                            onSave(character)
                            dismiss()
                        }
                        .buttonStyle(DnDButtonStyle())
                        .disabled(!viewModel.isValid)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
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
}

// MARK: - Step 1: Basic Info
struct BasicInfoStepView: View {
    @Binding var character: DnDCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Основная информация")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    TextField("Имя персонажа", text: $character.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Имя игрока", text: $character.info.playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Раса", selection: $character.info.race) {
                        Text("Выберите расу").tag("")
                        Text("Человек").tag("Человек")
                        Text("Эльф").tag("Эльф")
                        Text("Дварф").tag("Дварф")
                        Text("Халфлинг").tag("Халфлинг")
                        Text("Драконорожденный").tag("Драконорожденный")
                        Text("Гном").tag("Гном")
                        Text("Полуэльф").tag("Полуэльф")
                        Text("Полуорк").tag("Полуорк")
                        Text("Табакси").tag("Табакси")
                        Text("Тифлинг").tag("Тифлинг")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Мировоззрение", selection: $character.info.alignment) {
                        Text("Выберите мировоззрение").tag("")
                        Text("Законно-добрый").tag("Законно-добрый")
                        Text("Нейтрально-добрый").tag("Нейтрально-добрый")
                        Text("Хаотично-добрый").tag("Хаотично-добрый")
                        Text("Законно-нейтральный").tag("Законно-нейтральный")
                        Text("Нейтральный").tag("Нейтральный")
                        Text("Хаотично-нейтральный").tag("Хаотично-нейтральный")
                        Text("Законно-злой").tag("Законно-злой")
                        Text("Нейтрально-злой").tag("Нейтрально-злой")
                        Text("Хаотично-злой").tag("Хаотично-злой")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Step 2: Race & Class
struct RaceClassStepView: View {
    @Binding var character: DnDCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Раса и класс")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    Picker("Класс", selection: $character.info.charClass) {
                        Text("Выберите класс").tag("")
                        Text("Варвар").tag("Варвар")
                        Text("Бард").tag("Бард")
                        Text("Жрец").tag("Жрец")
                        Text("Друид").tag("Друид")
                        Text("Воин").tag("Воин")
                        Text("Монах").tag("Монах")
                        Text("Паладин").tag("Паладин")
                        Text("Следопыт").tag("Следопыт")
                        Text("Плут").tag("Плут")
                        Text("Чародей").tag("Чародей")
                        Text("Колдун").tag("Колдун")
                        Text("Волшебник").tag("Волшебник")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Подкласс", text: $character.info.charSubclass)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Stepper("Уровень: \(character.info.level)", value: $character.info.level, in: 1...20)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Step 3: Stats
struct StatsStepView: View {
    @Binding var character: DnDCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Характеристики")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    StatStepperView(
                        title: "Сила",
                        value: $character.stats.str.score,
                        modifier: character.stats.str.modifier ?? 0
                    )
                    
                    StatStepperView(
                        title: "Ловкость",
                        value: $character.stats.dex.score,
                        modifier: character.stats.dex.modifier ?? 0
                    )
                    
                    StatStepperView(
                        title: "Телосложение",
                        value: $character.stats.con.score,
                        modifier: character.stats.con.modifier ?? 0
                    )
                    
                    StatStepperView(
                        title: "Интеллект",
                        value: $character.stats.int.score,
                        modifier: character.stats.int.modifier ?? 0
                    )
                    
                    StatStepperView(
                        title: "Мудрость",
                        value: $character.stats.wis.score,
                        modifier: character.stats.wis.modifier ?? 0
                    )
                    
                    StatStepperView(
                        title: "Харизма",
                        value: $character.stats.cha.score,
                        modifier: character.stats.cha.modifier ?? 0
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct StatStepperView: View {
    let title: String
    @Binding var value: Int
    let modifier: Int
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 80, alignment: .leading)
            
            Stepper(value: $value, in: 1...30) {
                HStack {
                    Text("\(value)")
                        .frame(width: 30)
                    
                    Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                        .foregroundColor(.orange)
                        .frame(width: 40)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Step 4: Background
struct BackgroundStepView: View {
    @Binding var character: DnDCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Предыстория")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    Picker("Предыстория", selection: $character.info.background) {
                        Text("Выберите предысторию").tag("")
                        Text("Аколит").tag("Аколит")
                        Text("Артист").tag("Артист")
                        Text("Благородный").tag("Благородный")
                        Text("Герой").tag("Герой")
                        Text("Гильдейский ремесленник").tag("Гильдейский ремесленник")
                        Text("Моряк").tag("Моряк")
                        Text("Мудрец").tag("Мудрец")
                        Text("Народный герой").tag("Народный герой")
                        Text("Отшельник").tag("Отшельник")
                        Text("Пират").tag("Пират")
                        Text("Преступник").tag("Преступник")
                        Text("Солдат").tag("Солдат")
                        Text("Странник").tag("Странник")
                        Text("Чужеземец").tag("Чужеземец")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Описание предыстории", text: $character.text.background, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Step 5: Equipment
struct EquipmentStepView: View {
    @Binding var character: DnDCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Снаряжение")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    TextField("Снаряжение", text: $character.text.equipment, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(5...10)
                    
                    TextField("Золото", value: $character.coins.gp, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Step 6: Review
struct ReviewStepView: View {
    let character: DnDCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Обзор персонажа")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(character.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("Уровень \(character.info.level)")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        
                        Text("\(character.info.race) - \(character.info.charClass)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(character.info.alignment)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                        
                        if !character.info.background.isEmpty {
                            Text("Предыстория: \(character.info.background)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - ViewModel
class CharacterCreationViewModel: ObservableObject {
    @Published var character = DnDCharacter()
    let totalSteps = 6
    
    var isValid: Bool {
        !character.name.isEmpty &&
        !character.info.race.isEmpty &&
        !character.info.charClass.isEmpty &&
        !character.info.alignment.isEmpty
    }
    
    func validateCurrentStep(_ step: Int) -> Bool {
        switch step {
        case 0: // Basic Info
            return !character.name.isEmpty && !character.info.race.isEmpty
        case 1: // Race & Class
            return !character.info.charClass.isEmpty
        case 2: // Stats
            return true // Stats are always valid
        case 3: // Background
            return true // Background is optional
        case 4: // Equipment
            return true // Equipment is optional
        default:
            return true
        }
    }
    
    func createCharacter() -> DnDCharacter {
        var newCharacter = character
        newCharacter.dateCreated = Date()
        newCharacter.dateModified = Date()
        
        // Calculate modifiers
        newCharacter.stats.str.modifier = (newCharacter.stats.str.score - 10) / 2
        newCharacter.stats.dex.modifier = (newCharacter.stats.dex.score - 10) / 2
        newCharacter.stats.con.modifier = (newCharacter.stats.con.score - 10) / 2
        newCharacter.stats.int.modifier = (newCharacter.stats.int.score - 10) / 2
        newCharacter.stats.wis.modifier = (newCharacter.stats.wis.score - 10) / 2
        newCharacter.stats.cha.modifier = (newCharacter.stats.cha.score - 10) / 2
        
        // Calculate HP based on class and level
        newCharacter.vitality.hpMax = calculateHP(for: newCharacter)
        newCharacter.vitality.hpDiceCurrent = newCharacter.info.level
        
        return newCharacter
    }
    
    private func calculateHP(for character: DnDCharacter) -> Int {
        let conModifier = character.stats.con.modifier ?? 0
        let baseHP = getBaseHP(for: character.info.charClass)
        return baseHP + (conModifier * character.info.level)
    }
    
    private func getBaseHP(for className: String) -> Int {
        switch className {
        case "Варвар": return 12
        case "Воин", "Паладин", "Следопыт": return 10
        case "Бард", "Жрец", "Друид", "Монах", "Плут", "Чародей", "Колдун", "Волшебник": return 8
        default: return 8
        }
    }
}

#Preview {
    CharacterCreationView { _ in }
}
