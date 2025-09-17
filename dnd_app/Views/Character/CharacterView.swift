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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var dataService: DataService
    
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
                EditableCharacterHeader(character: $viewModel.character, onCharacterContextMenu: onCharacterContextMenu, onCharacterUpdate: onCharacterUpdate)
                
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
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
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
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
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
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
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
                    .background(adaptiveCardBackgroundColor)
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

struct CharacterSkillsView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
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
                        ForEach(Skill.allCases.sorted(by: { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }), id: \.self) { skill in
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
        let proficiencyBonus = character.updatedProficiencyBonus
        
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
        .background(adaptiveCardBackgroundColor)
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
                    
                    if character.isMulticlass {
                        Text("Умения всех классов (общий уровень: \(character.totalLevel))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        Text("Умения класса \(character.characterClass) до \(character.level) уровня")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // Все классовые умения
                    LazyVStack(spacing: 12) {
                        ForEach(Array(availableFeatures.enumerated()), id: \.offset) { index, feature in
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
        if character.isMulticlass {
            return getAllMulticlassFeatures()
        } else {
            guard let dndClass = dataService.dndClasses.first(where: { $0.nameRu == character.characterClass }) else {
                return []
            }
            
        
        var features: [ClassFeatureWithLevel] = []
        
        // Получаем умения до текущего уровня
        if let levelFeatures = dndClass.levelFeatures {
            for levelData in levelFeatures {
                if levelData.level <= character.level {
                    if let featuresAtLevel = levelData.features {
                        for feature in featuresAtLevel {
                            features.append(ClassFeatureWithLevel(
                                name: feature.name,
                                description: feature.description,
                                level: levelData.level
                            ))
                        }
                    } else if let name = levelData.name, let description = levelData.description {
                        features.append(ClassFeatureWithLevel(
                            name: name,
                            description: description,
                            level: levelData.level
                        ))
                    }
                }
            }
        }
        
        // Добавляем умения подкласса если есть
        if let subclass = character.subclass, !subclass.isEmpty {
            if let subclasses = dndClass.subclasses,
               let selectedSubclass = subclasses.first(where: { $0.nameRu == subclass }) {
                if let subclassFeatures = selectedSubclass.features {
                    for subclassFeature in subclassFeatures {
                        if subclassFeature.level <= character.level {
                            features.append(ClassFeatureWithLevel(
                                name: subclassFeature.name,
                                description: subclassFeature.description,
                                level: subclassFeature.level
                            ))
                        }
                    }
                }
            }
        }
        
        // Сортируем по уровню получения
        features.sort { $0.level < $1.level }
        
        
        return features
        }
    }
    
    private func getAllMulticlassFeatures() -> [ClassFeatureWithLevel] {
        var allFeatures: [ClassFeatureWithLevel] = []
        
        for classInfo in character.classes {
            guard let dndClass = dataService.dndClasses.first(where: { $0.nameRu == classInfo.name }) else {
                continue
            }
            
            // Получаем умения до уровня этого класса
            if let levelFeatures = dndClass.levelFeatures {
                for levelData in levelFeatures {
                    if levelData.level <= classInfo.level {
                        if let featuresAtLevel = levelData.features {
                            for feature in featuresAtLevel {
                                allFeatures.append(ClassFeatureWithLevel(
                                    name: "[\(classInfo.name)] \(feature.name)",
                                    description: feature.description,
                                    level: levelData.level
                                ))
                            }
                        } else if let name = levelData.name, let description = levelData.description {
                            allFeatures.append(ClassFeatureWithLevel(
                                name: "[\(classInfo.name)] \(name)",
                                description: description,
                                level: levelData.level
                            ))
                        }
                    }
                }
            }
            
            // Добавляем умения подкласса если есть
            if let subclass = classInfo.subclass, !subclass.isEmpty {
                if let subclasses = dndClass.subclasses,
                   let selectedSubclass = subclasses.first(where: { $0.nameRu == subclass }) {
                    if let subclassFeatures = selectedSubclass.features {
                        for subclassFeature in subclassFeatures {
                            if subclassFeature.level <= classInfo.level {
                                allFeatures.append(ClassFeatureWithLevel(
                                    name: "[\(classInfo.name)] \(subclassFeature.name)",
                                    description: subclassFeature.description,
                                    level: subclassFeature.level
                                ))
                            }
                        }
                    }
                }
            }
        }
        
        // Сортируем по уровню получения, затем по названию класса
        return allFeatures.sorted { 
            if $0.level != $1.level {
                return $0.level < $1.level
            }
            return $0.name < $1.name
        }
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
        if character.isMulticlass {
            return getAllMulticlassResources()
        } else {
            guard let dndClass = dataService.dndClasses.first(where: { $0.nameRu == character.characterClass }) else {
                return []
            }


        var resources: [ClassResourceInfo] = []

        // Получаем ресурсы со всех уровней до текущего
        if let levelFeatures = dndClass.levelFeatures {
            for levelData in levelFeatures {
                if levelData.level <= character.level {
                    // Обрабатываем все возможные ресурсы универсально
                    let levelResources = extractResourcesFromLevelData(levelData, className: character.characterClass)
                    resources.append(contentsOf: levelResources)
                }
            }
        }
        
        // Добавляем ресурсы подкласса если есть
        if let subclass = character.subclass, !subclass.isEmpty {
            if let subclasses = dndClass.subclasses,
               let selectedSubclass = subclasses.first(where: { $0.nameRu == subclass }) {
                if let subclassFeatures = selectedSubclass.features {
                    for subclassFeature in subclassFeatures {
                        if subclassFeature.level <= character.level {
                            // Проверяем, является ли умение подкласса ресурсом
                            if isResourceFeature(ClassFeatureWithLevel(
                                name: subclassFeature.name,
                                description: subclassFeature.description,
                                level: subclassFeature.level
                            )) {
                                // Создаем ресурс для умения подкласса
                                let resourceInfo = ClassResourceInfo(
                                    name: subclassFeature.name,
                                    icon: getIconForResource(columnName: subclassFeature.name),
                                    maxValue: 1, // По умолчанию 1, можно настроить
                                    description: subclassFeature.description
                                )
                                resources.append(resourceInfo)
                            }
                        }
                    }
                }
            }
        }

        return resources
        }
    }
    
    private func getAllMulticlassResources() -> [ClassResourceInfo] {
        var allResources: [ClassResourceInfo] = []
        
        for classInfo in character.classes {
            guard let dndClass = dataService.dndClasses.first(where: { $0.nameRu == classInfo.name }) else {
                continue
            }
            
            // Получаем ресурсы со всех уровней до текущего уровня этого класса
            if let levelFeatures = dndClass.levelFeatures {
                for levelData in levelFeatures {
                    if levelData.level <= classInfo.level {
                        // Обрабатываем все возможные ресурсы универсально
                        let levelResources = extractResourcesFromLevelData(levelData, className: classInfo.name, isMulticlass: true)
                        allResources.append(contentsOf: levelResources)
                    }
                }
            }
            
            // Добавляем ресурсы подкласса если есть
            if let subclass = classInfo.subclass, !subclass.isEmpty {
                if let subclasses = dndClass.subclasses,
                   let selectedSubclass = subclasses.first(where: { $0.nameRu == subclass }) {
                    if let subclassFeatures = selectedSubclass.features {
                        for subclassFeature in subclassFeatures {
                            if subclassFeature.level <= classInfo.level {
                                // Проверяем, является ли умение подкласса ресурсом
                                if isResourceFeature(ClassFeatureWithLevel(
                                    name: subclassFeature.name,
                                    description: subclassFeature.description,
                                    level: subclassFeature.level
                                )) {
                                    // Создаем ресурс для умения подкласса
                                    let resourceInfo = ClassResourceInfo(
                                        name: "[\(classInfo.name)] \(subclassFeature.name)",
                                        icon: getIconForResource(columnName: subclassFeature.name),
                                        maxValue: 1, // По умолчанию 1, можно настроить
                                        description: subclassFeature.description
                                    )
                                    allResources.append(resourceInfo)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return allResources
    }
    
    private func extractResourcesFromLevelData(_ levelData: LevelFeature, className: String, isMulticlass: Bool = false) -> [ClassResourceInfo] {
        var resources: [ClassResourceInfo] = []
        let prefix = isMulticlass ? "[\(className)] " : ""
        
        // Ярость (Варвар)
        if let rages = levelData.rages {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Ярость",
                icon: "flame.fill",
                maxValue: rages,
                description: "Использований ярости на \(levelData.level) уровне"
            )
            resources.append(resourceInfo)
        }
        
        // Урон ярости (Варвар)
        if let rageDamage = levelData.rageDamage {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Урон ярости",
                icon: "bolt.fill",
                maxValue: rageDamage,
                description: "Дополнительный урон от ярости: +\(rageDamage)"
            )
            resources.append(resourceInfo)
        }
        
        // Оружейное мастерство (Варвар)
        if let weaponMastery = levelData.weaponMastery {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Оружейное мастерство",
                icon: "sword.fill",
                maxValue: weaponMastery,
                description: "Видов оружия с мастерством: \(weaponMastery)"
            )
            resources.append(resourceInfo)
        }
        
        // Заговоры (Бард, Чародей, Колдун, Волшебник)
        if let cantripsKnown = levelData.cantripsKnown {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Заговоры",
                icon: "sparkles",
                maxValue: cantripsKnown,
                description: "Известных заговоров: \(cantripsKnown)"
            )
            resources.append(resourceInfo)
        }
        
        // Подготовленные заклинания (Бард, Жрец, Друид, Паладин, Следопыт)
        if let spellsKnown = levelData.spellsKnown {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Подготовленные заклинания",
                icon: "book.fill",
                maxValue: spellsKnown,
                description: "Подготовленных заклинаний: \(spellsKnown)"
            )
            resources.append(resourceInfo)
        }
        
        // Ячейки заклинаний (все заклинатели)
        if let spellSlots = levelData.spellSlots {
            for (index, slots) in spellSlots.enumerated() {
                if slots > 0 {
                    let level = index + 1
                    let resourceInfo = ClassResourceInfo(
                        name: "\(prefix)Ячейки \(level)-го уровня",
                        icon: "\(level).circle.fill",
                        maxValue: slots,
                        description: "Ячеек заклинаний \(level)-го уровня: \(slots)"
                    )
                    resources.append(resourceInfo)
                }
            }
        }
        
        // Кость вдохновения (Бард)
        if let bardicInspirationDie = levelData.bardicInspirationDie {
            let dieValue = extractDieValue(from: bardicInspirationDie)
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Кость вдохновения",
                icon: "dice.fill",
                maxValue: dieValue,
                description: "Кость вдохновения барда: \(bardicInspirationDie)"
            )
            resources.append(resourceInfo)
        }
        
        // Очки ки (Монах)
        if let kiPoints = levelData.kiPoints {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Очки ки",
                icon: "circle.dotted",
                maxValue: kiPoints,
                description: "Очков ки: \(kiPoints)"
            )
            resources.append(resourceInfo)
        }
        
        // Боевые искусства (Монах)
        if let martialArtsDie = levelData.martialArtsDie {
            let dieValue = extractDieValue(from: martialArtsDie)
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Боевые искусства",
                icon: "figure.martial.arts",
                maxValue: dieValue,
                description: "Урон боевых искусств: \(martialArtsDie)"
            )
            resources.append(resourceInfo)
        }
        
        // Божественное вмешательство (Жрец)
        if let channelDivinity = levelData.channelDivinity {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Божественное вмешательство",
                icon: "sparkles",
                maxValue: channelDivinity,
                description: "Использований божественного вмешательства: \(channelDivinity)"
            )
            resources.append(resourceInfo)
        }
        
        // Пул исцеления (Паладин)
        if let layOnHandsPool = levelData.layOnHandsPool {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Пул исцеления",
                icon: "heart.fill",
                maxValue: layOnHandsPool,
                description: "Пул исцеления: \(layOnHandsPool)"
            )
            resources.append(resourceInfo)
        }
        
        // Дикий облик (Друид)
        if let wildShapeUses = levelData.wildShapeUses {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Дикий облик",
                icon: "leaf.fill",
                maxValue: wildShapeUses,
                description: "Использований дикого облика: \(wildShapeUses)"
            )
            resources.append(resourceInfo)
        }
        
        // Очки чародейства (Чародей)
        if let sorceryPoints = levelData.sorceryPoints {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Очки чародейства",
                icon: "sparkles",
                maxValue: sorceryPoints,
                description: "Очков чародейства: \(sorceryPoints)"
            )
            resources.append(resourceInfo)
        }
        
        // Ячейки заклинаний колдуна (Колдун)
        if let warlockSpellSlots = levelData.warlockSpellSlots {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Ячейки заклинаний",
                icon: "hexagon.fill",
                maxValue: warlockSpellSlots,
                description: "Ячеек заклинаний колдуна: \(warlockSpellSlots)"
            )
            resources.append(resourceInfo)
        }
        
        // Известные заклинания волшебника (Волшебник)
        if let wizardSpellsKnown = levelData.wizardSpellsKnown {
            let resourceInfo = ClassResourceInfo(
                name: "\(prefix)Известные заклинания",
                icon: "book.fill",
                maxValue: wizardSpellsKnown,
                description: "Известных заклинаний: \(wizardSpellsKnown)"
            )
            resources.append(resourceInfo)
        }
        
        return resources
    }
    
    private func extractDieValue(from dieString: String) -> Int {
        // Извлекаем число из строки типа "к6", "к8", "к10", "к12"
        let numbers = dieString.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
        return numbers.first ?? 6
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
    @Environment(\.colorScheme) private var colorScheme
    
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
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
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
}

struct ClassResourceView: View {
    let resource: ClassResource
    let onUse: () -> Void
    let onReset: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
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
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
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
}

struct ClassResourceInfoCard: View {
    let resource: ClassResourceInfo
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.colorScheme) private var colorScheme

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
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: adaptiveShadowColor, radius: 6, x: 0, y: 3)
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
    
    // MARK: - Adaptive Colors
    
    private var adaptiveCardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        case .light:
            return Color(.systemBackground)
        @unknown default:
            return Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var adaptiveShadowColor: Color {
        switch colorScheme {
        case .dark:
            return .black.opacity(0.3)
        case .light:
            return .black.opacity(0.08)
        @unknown default:
            return .black.opacity(0.1)
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