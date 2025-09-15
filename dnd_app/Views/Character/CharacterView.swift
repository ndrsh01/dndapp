import SwiftUI

struct CharacterView: View {
    @StateObject private var viewModel: CharacterViewModel
    @State private var showingEditHitPoints = false
    @State private var showingEditAbility = false
    @State private var showingEditCombatStat = false
    @State private var selectedAbility: AbilityScore?
    @State private var selectedCombatStat: CombatStat?
    @State private var hitPointsType: EditHitPointsPopupView.HitPointsType = .current
    @State private var showingSkillsView = false
    @State private var showingSavingThrowsView = false
    @State private var showingClassFeaturesView = false
    @State private var showingEquipmentView = false
    @State private var showingTreasuresView = false
    @State private var showingFeaturesView = false
    @State private var showingPersonalityView = false
    
    let onCharacterUpdate: ((Character) -> Void)?
    let onCharacterContextMenu: (() -> Void)?
    
    init(character: Character, onCharacterUpdate: ((Character) -> Void)? = nil, onCharacterContextMenu: (() -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: CharacterViewModel(character: character))
        self.onCharacterUpdate = onCharacterUpdate
        self.onCharacterContextMenu = onCharacterContextMenu
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Заголовок персонажа
                EditableCharacterHeader(character: $viewModel.character, onCharacterContextMenu: onCharacterContextMenu)
                    .environmentObject(DataService.shared)
                
                // Хиты
                hitPointsSection
                
                // Основные характеристики
                abilityScoresSection
                
                // Боевые характеристики
                combatStatsSection

                // Детальная информация
                detailedInfoSection
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Персонаж")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
        }
        .overlay(
            ZStack {
                if showingEditHitPoints {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingEditHitPoints = false
                        }
                    
                    EditHitPointsPopupView(
                        currentHitPoints: $viewModel.character.hitPoints,
                        maxHitPoints: $viewModel.character.maxHitPoints,
                        hitPointsType: hitPointsType,
                        onDismiss: { showingEditHitPoints = false }
                    )
                    .onDisappear {
                        onCharacterUpdate?(viewModel.character)
                    }
                }
                
                if showingEditAbility, let ability = selectedAbility {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingEditAbility = false
                        }
                    
                    EditAbilityPopupView(
                        ability: ability,
                        value: Binding(
                            get: { viewModel.character.value(for: ability) },
                            set: { newValue in
                                viewModel.updateAbilityScore(ability: ability, newValue: newValue)
                            }
                        ),
                        onDismiss: { showingEditAbility = false }
                    )
                    .onDisappear {
                        onCharacterUpdate?(viewModel.character)
                    }
                }
                
                if showingEditCombatStat, let stat = selectedCombatStat {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingEditCombatStat = false
                        }
                    
                    EditCombatStatPopupView(
                        stat: stat,
                        value: Binding(
                            get: { viewModel.character.value(for: stat) },
                            set: { newValue in
                                viewModel.updateCombatStat(stat: stat, newValue: newValue)
                            }
                        ),
                        onDismiss: { showingEditCombatStat = false }
                    )
                    .onDisappear {
                        onCharacterUpdate?(viewModel.character)
                    }
                }
            }
        )
        .sheet(isPresented: $showingSkillsView) {
            CharacterSkillsView(
                character: $viewModel.character,
                onCharacterUpdate: onCharacterUpdate
            )
        }
        .sheet(isPresented: $showingSavingThrowsView) {
            SavingThrowsView(
                character: $viewModel.character,
                onCharacterUpdate: onCharacterUpdate
            )
        }
        .sheet(isPresented: $showingClassFeaturesView) {
            CharacterClassFeaturesView(
                character: $viewModel.character,
                onCharacterUpdate: onCharacterUpdate
            )
            .environmentObject(DataService.shared)
        }
        .sheet(isPresented: $showingEquipmentView) {
            CharacterEquipmentView(
                character: $viewModel.character,
                onCharacterUpdate: onCharacterUpdate
            )
        }
        .sheet(isPresented: $showingTreasuresView) {
            CharacterTreasuresView(
                character: $viewModel.character,
                onCharacterUpdate: onCharacterUpdate
            )
        }
        .sheet(isPresented: $showingFeaturesView) {
            CharacterFeaturesView(
                character: $viewModel.character,
                onCharacterUpdate: onCharacterUpdate
            )
        }
        .sheet(isPresented: $showingPersonalityView) {
            CharacterPersonalityView(
                character: $viewModel.character,
                onCharacterUpdate: onCharacterUpdate
            )
        }
    }
    
    
    private var healthBarColor: Color {
        let percentage = viewModel.character.healthPercentage
        if percentage <= 0.25 {
            return .red
        } else if percentage <= 0.7 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private var hitPointsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.green)
                Text("Хиты")
                    .font(.headline)
                Spacer()
                }
                
                HStack {
                Text("\(viewModel.character.hitPoints) / \(viewModel.character.maxHitPoints)")
                        .font(.title2)
                        .fontWeight(.bold)
                    .foregroundColor(.green)
                    
                    Spacer()
                    
                Text("\(Int(viewModel.character.healthPercentage * 100))% здоровья")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            ProgressView(value: viewModel.character.healthPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: healthBarColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            hitPointsType = .current
            showingEditHitPoints = true
        }
        .contextMenu {
            Button(action: {
                hitPointsType = .current
                showingEditHitPoints = true
            }) {
                Label("Текущие хиты", systemImage: "heart")
            }
            
            Button(action: {
                hitPointsType = .maximum
                showingEditHitPoints = true
            }) {
                Label("Максимальные хиты", systemImage: "heart.fill")
            }
            
            Button(action: {
                hitPointsType = .temporary
                showingEditHitPoints = true
            }) {
                Label("Временные хиты", systemImage: "plus.circle")
            }
        }
    }
    
    
    private var abilityScoresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("Основные характеристики")
                        .font(.headline)
                Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(AbilityScore.allCases, id: \.self) { ability in
                    abilityCard(ability: ability)
                }
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var combatStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(.blue)
                Text("Боевые характеристики")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(CombatStat.allCases, id: \.self) { stat in
                    combatStatCard(stat: stat)
                }
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var detailedInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Детальная информация")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                detailCard(title: "Навыки", icon: "brain.head.profile", color: .green)
                detailCard(title: "Спасброски", icon: "shield.checkered", color: .blue)
                detailCard(title: "Классовые умения", icon: "star.fill", color: .purple)
                detailCard(title: "Снаряжение", icon: "bag.fill", color: .orange)
                detailCard(title: "Сокровища", icon: "diamond.fill", color: .yellow)
                detailCard(title: "Личность", icon: "person.crop.square.fill", color: .pink)
                detailCard(title: "Особенности", icon: "star.fill", color: .blue)
            }
        }
    }
    
    private var classResourcesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ресурсы")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.character.classResources.isEmpty {
                Text("Нет доступных ресурсов")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(Array(viewModel.character.classResources.keys.sorted()), id: \.self) { resourceKey in
                        if let resource = viewModel.character.classResources[resourceKey] {
                            ClassResourceView(
                                resource: resource,
                                onUse: {
                                    useResource(resourceKey)
                                },
                                onReset: {
                                    resetResource(resourceKey)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func useResource(_ resourceKey: String) {
        if var resource = viewModel.character.classResources[resourceKey], resource.currentValue > 0 {
            resource.currentValue -= 1
            viewModel.character.classResources[resourceKey] = resource
            onCharacterUpdate?(viewModel.character)
        }
    }
    
    private func resetResource(_ resourceKey: String) {
        if var resource = viewModel.character.classResources[resourceKey] {
            resource.currentValue = resource.maxValue
            viewModel.character.classResources[resourceKey] = resource
            onCharacterUpdate?(viewModel.character)
        }
    }
    
    private func detailCard(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            if title == "Навыки" {
                showingSkillsView = true
            } else if title == "Спасброски" {
                showingSavingThrowsView = true
            } else if title == "Классовые умения" {
                showingClassFeaturesView = true
            } else if title == "Снаряжение" {
                showingEquipmentView = true
            } else if title == "Сокровища" {
                showingTreasuresView = true
            } else if title == "Личность" {
                showingPersonalityView = true
            } else if title == "Особенности" {
                showingFeaturesView = true
            }
        }
    }
    
    private func abilityCard(ability: AbilityScore) -> some View {
        let value = viewModel.character.value(for: ability)
        let modifier = viewModel.character.modifier(for: ability)
        
        return VStack(spacing: 4) {
            Image(systemName: ability.icon)
                .font(.title3)
                .foregroundColor(ability.color)
            
            Text(ability.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(viewModel.character.formatModifier(modifier))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("\(value)")
                    .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(ability.color.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            selectedAbility = ability
            showingEditAbility = true
        }
    }
    
    private func combatStatCard(stat: CombatStat) -> some View {
        let value = viewModel.character.value(for: stat)
        
        return VStack(spacing: 4) {
            Image(systemName: stat.icon)
                .font(.title3)
                .foregroundColor(stat.color)
            
            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(stat.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(stat.color.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            selectedCombatStat = stat
            showingEditCombatStat = true
        }
    }
}

struct CharacterSkillsView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Навыки")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Управляйте навыками вашего персонажа. Владение добавляет бонус владения, компетенция удваивает его.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(Skill.allCases, id: \.self) { skill in
                            skillRow(skill: skill)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func skillRow(skill: Skill) -> some View {
        let isProficient = character.skills[skill.rawValue] ?? false
        let hasExpertise = character.skillsExpertise[skill.rawValue] ?? false
        let abilityModifier = character.modifier(for: skill.ability)
        let proficiencyBonus = character.proficiencyBonus
        
        let skillBonus = abilityModifier + (isProficient ? (hasExpertise ? proficiencyBonus * 2 : proficiencyBonus) : 0)
        
        return HStack(spacing: 12) {
            // Название навыка и базовая характеристика
            VStack(alignment: .leading, spacing: 2) {
                Text(skill.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(skill.ability.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Индикаторы владения и компетенции
            HStack(spacing: 8) {
                // Владение
                Button(action: {
                    toggleProficiency(for: skill)
                }) {
                    Image(systemName: isProficient ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isProficient ? .orange : .gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Компетенция (только если есть владение)
                if isProficient {
                    Button(action: {
                        toggleExpertise(for: skill)
                    }) {
                        Image(systemName: hasExpertise ? "star.circle.fill" : "star.circle")
                            .foregroundColor(hasExpertise ? .orange : .gray)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Бонус навыка
                Text(character.formatModifier(skillBonus))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(8)
    }
    
    private func toggleProficiency(for skill: Skill) {
        character.skills[skill.rawValue] = !(character.skills[skill.rawValue] ?? false)
        // Если убираем владение, убираем и компетенцию
        if !(character.skills[skill.rawValue] ?? false) {
            character.skillsExpertise[skill.rawValue] = false
        }
        onCharacterUpdate?(character)
    }
    
    private func toggleExpertise(for skill: Skill) {
        character.skillsExpertise[skill.rawValue] = !(character.skillsExpertise[skill.rawValue] ?? false)
        onCharacterUpdate?(character)
    }
}

struct CharacterClassFeaturesView: View {
    @Binding var character: Character
    @EnvironmentObject private var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    let onCharacterUpdate: ((Character) -> Void)?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Классовые умения")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Умения класса \(character.characterClass) до \(character.level) уровня")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // Все классовые умения
                    LazyVStack(spacing: 12) {
                        ForEach(availableFeatures, id: \.name) { feature in
                            // Проверяем, является ли это умение ресурсом
                            if isResourceFeature(feature) {
                                // Показываем как редактируемый ресурс
                                if let resource = availableResources.first(where: { $0.name == feature.name }) {
                                    ClassResourceInfoCard(
                                        resource: resource,
                                        character: $character,
                                        onCharacterUpdate: onCharacterUpdate
                                    )
                                } else {
                                    // Если ресурс не найден, показываем как обычное умение
                                    ClassFeatureCard(feature: feature)
                                }
                            } else {
                                // Показываем как обычное умение (только для чтения)
                                ClassFeatureCard(feature: feature)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Отладочная информация
                    if availableResources.isEmpty {
                        VStack {
                            Text("Отладка: Ресурсы не найдены")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text("Класс: \(character.characterClass), Уровень: \(character.level)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Найдено умений: \(availableFeatures.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var availableFeatures: [ClassFeatureWithLevel] {
        guard let dndClass = dataService.dndClasses.first(where: { $0.nameRu == character.characterClass }) else {
            return []
        }
        
        var features: [ClassFeatureWithLevel] = []
        
        // Получаем умения до текущего уровня
        for levelData in dndClass.levelProgression {
            if levelData.level <= character.level {
                if let levelFeatures = levelData.features {
                    for feature in levelFeatures {
                        features.append(ClassFeatureWithLevel(
                            name: feature.name,
                            description: feature.description,
                            level: levelData.level
                        ))
                    }
                }
            }
        }
        
        // Фильтруем по подклассу если есть
        if let subclass = character.subclass, !subclass.isEmpty {
            // Здесь можно добавить фильтрацию по подклассу
            // Пока что показываем все умения
        }
        
        return features
    }
    
    private func isResourceFeature(_ feature: ClassFeatureWithLevel) -> Bool {
        // Используем ту же логику, что и в isImportantResource
        let importantResources = [
            "Ярость",
            "Урон ярости",
            "Кость вдохновения",
            "Заговоры",
            "Подготовленные заклинания",
            "Очки сосредоточенности",
            "Кубы превосходства",
            "Божественное вмешательство",
            "Дикий облик",
            "Кость превосходства",
            "Ячейки заклинаний",
            "Боевые искусства",
            "Оружейное мастерство",
            "Движение без доспехов"
        ]
        
        return importantResources.contains { feature.name.contains($0) } ||
               feature.name.lowercased().contains("сосредоточен") ||
               feature.name.lowercased().contains("превосходств") ||
               feature.name.lowercased().contains("вдохновен")
    }
    
    private var availableResources: [ClassResourceInfo] {
        // Получаем данные из class_tables.json
        guard let classTable = getClassTableForCharacter(),
              let levelRow = classTable.rows.first(where: { $0.level == String(character.level) }) else {
            print("DEBUG: Class table not found for \(character.characterClass) level \(character.level)")
            return []
        }

        print("DEBUG: Found class table for \(character.characterClass), level \(character.level)")
        print("DEBUG: Additional data keys: \(levelRow.additionalData.keys)")

        var resources: [ClassResourceInfo] = []

        // Обрабатываем все дополнительные данные из таблицы класса
        for (columnName, value) in levelRow.additionalData {
            // Пропускаем пустые значения и прочерки
            if value == "-" || value == "—" || value.isEmpty {
                continue
            }

            // Фильтруем только важные ресурсы
            if isImportantResource(columnName: columnName) {
                print("DEBUG: Found important resource: \(columnName) = \(value)")
                let resourceInfo = createResourceInfo(columnName: columnName, value: value)
                resources.append(resourceInfo)
            }
        }

        print("DEBUG: Total resources found: \(resources.count)")
        return resources
    }

    private func isImportantResource(columnName: String) -> Bool {
        let importantResources = [
            "Ярость",
            "Урон ярости",
            "Кость вдохновения",
            "Заговоры",
            "Подготовленные заклинания",
            "Очки сосредоточенности",
            "Кубы превосходства",
            "Божественное вмешательство",
            "Дикий облик",
            "Кость превосходства"
        ]

        return importantResources.contains { columnName.contains($0) } ||
               columnName.lowercased().contains("сосредоточен") ||
               columnName.lowercased().contains("превосходств") ||
               columnName.lowercased().contains("вдохновен")
    }
    
    private func getClassTableForCharacter() -> ClassTable? {
        // Мапим русские названия классов на slug'и
        let classSlugMapping: [String: String] = [
            "Варвар": "barbarian",
            "Бард": "bard",
            "Жрец": "cleric",
            "Друид": "druid",
            "Воин": "fighter",
            "Монах": "monk",
            "Паладин": "paladin",
            "Следопыт": "ranger",
            "Плут": "rogue",
            "Чародей": "sorcerer",
            "Колдун": "warlock",
            "Волшебник": "wizard"
        ]
        
        guard let slug = classSlugMapping[character.characterClass] else {
            return nil
        }
        
        return dataService.classTables.first(where: { $0.slug == slug })
    }
    
    private func createResourceInfo(columnName: String, value: String) -> ClassResourceInfo {
        let icon = getIconForResource(columnName: columnName)
        let maxValue = extractNumericValue(from: value)
        let description = getDescriptionForResource(columnName: columnName, value: value)
        
        return ClassResourceInfo(
            name: columnName,
            icon: icon,
            maxValue: maxValue,
            description: description
        )
    }
    
    private func getIconForResource(columnName: String) -> String {
        switch columnName {
        case "Ярость":
            return "flame.fill"
        case "Урон ярости":
            return "bolt.fill"
        case "Оружейное мастерство":
            return "sword.fill"
        case "Кость вдохновения":
            return "dice.fill"
        case "Заговоры":
            return "sparkles"
        case "Подготовленные заклинания":
            return "book.fill"
        case let name where name.contains("Ячейки"):
            return "\(extractSpellLevel(from: name)).circle.fill"
        case "Боевые искусства":
            return "figure.martial.arts"
        case "Очки сосредоточенности":
            return "circle.dotted"
        case "Движение без доспехов":
            return "figure.run"
        case let name where name.contains("Кубы превосходства") || name.contains("Кость превосходства"):
            return "dice.fill"
        case let name where name.contains("Божественное вмешательство"):
            return "sparkles"
        case let name where name.contains("Дикий облик"):
            return "leaf.fill"
        default:
            return "star.fill"
        }
    }
    
    private func extractSpellLevel(from columnName: String) -> String {
        if columnName.contains("1") { return "1" }
        if columnName.contains("2") { return "2" }
        if columnName.contains("3") { return "3" }
        if columnName.contains("4") { return "4" }
        if columnName.contains("5") { return "5" }
        if columnName.contains("6") { return "6" }
        if columnName.contains("7") { return "7" }
        if columnName.contains("8") { return "8" }
        if columnName.contains("9") { return "9" }
        return "star"
    }
    
    private func extractNumericValue(from value: String) -> Int {
        // Извлекаем число из строки (например, "2", "+2", "1к6", "К6")
        let numbers = value.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
        return numbers.first ?? 1
    }
    
    private func getDescriptionForResource(columnName: String, value: String) -> String {
        switch columnName {
        case "Ярость":
            return "Использований ярости на \(character.level) уровне"
        case "Урон ярости":
            return "Дополнительный урон от ярости: \(value)"
        case "Оружейное мастерство":
            return "Видов оружия с мастерством: \(value)"
        case "Кость вдохновения":
            return "Кость вдохновения барда: \(value)"
        case "Заговоры":
            return "Известных заговоров: \(value)"
        case "Подготовленные заклинания":
            return "Подготовленных заклинаний: \(value)"
        case let name where name.contains("Ячейки"):
            return "Ячеек заклинаний: \(value)"
        case "Боевые искусства":
            return "Урон боевых искусств: \(value)"
        case "Очки сосредоточенности":
            return "Очков сосредоточенности: \(value)"
        case "Движение без доспехов":
            return "Дополнительная скорость: \(value)"
        case let name where name.contains("Кубы превосходства") || name.contains("Кость превосходства"):
            return "Кубов превосходства: \(value)"
        case let name where name.contains("Божественное вмешательство"):
            return "Использований божественного вмешательства: \(value)"
        case let name where name.contains("Дикий облик"):
            return "Использований дикого облика: \(value)"
        default:
            return "\(columnName): \(value)"
        }
    }
}

struct ClassFeatureWithLevel {
    let name: String
    let description: String
    let level: Int
}

struct ClassResourceInfo {
    let name: String
    let icon: String
    let maxValue: Int
    let description: String
}

struct ClassFeatureCard: View {
    let feature: ClassFeatureWithLevel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(feature.level) уровень")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }
}

struct ClassResourceView: View {
    let resource: ClassResource
    let onUse: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка ресурса
            Button(action: onUse) {
                Image(systemName: resource.icon)
                    .font(.title2)
                    .foregroundColor(resource.currentValue > 0 ? .orange : .gray)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(resource.currentValue > 0 ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                    )
            }
            .disabled(resource.currentValue == 0)
            
            // Название ресурса
            Text(resource.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Счетчик использований
            HStack(spacing: 2) {
                ForEach(0..<resource.maxValue, id: \.self) { index in
                    Circle()
                        .fill(index < resource.currentValue ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Кнопка сброса (долгий тап)
            Text("\(resource.currentValue)/\(resource.maxValue)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .onLongPressGesture {
                    onReset()
                }
        }
        .padding(8)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}

struct ClassResourceInfoCard: View {
    let resource: ClassResourceInfo
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?

    // Найдем соответствующий ресурс в персонаже
    private var characterResource: ClassResource? {
        character.classResources.values.first { $0.name == resource.name }
    }

    private var currentValue: Int {
        characterResource?.currentValue ?? resource.maxValue
    }

    private var maxValue: Int {
        characterResource?.maxValue ?? resource.maxValue
    }

    var body: some View {
        VStack(spacing: 12) {
            // Иконка ресурса
            Image(systemName: resource.icon)
                .font(.title)
                .foregroundColor(.orange)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                )

            // Название ресурса
            Text(resource.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Управление значением
            VStack(spacing: 8) {
                // Текущее значение
                HStack(spacing: 4) {
                    Text("\(currentValue)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("/")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(maxValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Кнопки управления
                HStack(spacing: 12) {
                    // Кнопка уменьшения
                    Button(action: {
                        useResource()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundColor(currentValue > 0 ? .red : .gray.opacity(0.3))
                    }
                    .disabled(currentValue <= 0)

                    // Кнопка сброса
                    Button(action: {
                        resetResource()
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .disabled(currentValue == maxValue)

                    // Кнопка увеличения (если нужно)
                    Button(action: {
                        restoreResource()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(currentValue < maxValue ? .green : .gray.opacity(0.3))
                    }
                    .disabled(currentValue >= maxValue)
                }
            }

            // Описание
            Text(resource.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .frame(maxWidth: .infinity)
    }

    private func useResource() {
        if var resource = characterResource, resource.currentValue > 0 {
            resource.currentValue -= 1
            updateResource(resource)
        }
    }

    private func restoreResource() {
        if var resource = characterResource, resource.currentValue < resource.maxValue {
            resource.currentValue += 1
            updateResource(resource)
        }
    }

    private func resetResource() {
        if var resource = characterResource {
            resource.currentValue = resource.maxValue
            updateResource(resource)
        }
    }

    private func updateResource(_ updatedResource: ClassResource) {
        // Найдем ключ ресурса в словаре
        if let key = character.classResources.first(where: { $0.value.name == resource.name })?.key {
            character.classResources[key] = updatedResource
            onCharacterUpdate?(character)
        }
    }
}



#Preview {
    NavigationView {
        CharacterView(character: Character(
            name: "Абоба",
            race: "Человек",
            characterClass: "Монах",
            background: "Чужеземец",
            alignment: "Хаотично-нейтральный",
            level: 8
        ))
    }
}