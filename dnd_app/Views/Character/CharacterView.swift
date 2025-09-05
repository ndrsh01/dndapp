import SwiftUI

struct CharacterView: View {
    @StateObject private var viewModel: CharacterViewModel
    @State private var showingEditHitPoints = false
    @State private var showingEditAbility = false
    @State private var showingEditCombatStat = false
    @State private var selectedAbility: AbilityScore?
    @State private var selectedCombatStat: CombatStat?
    @State private var hitPointsType: EditHitPointsPopupView.HitPointsType = .current
    
    let onCharacterUpdate: ((Character) -> Void)?
    
    init(character: Character, onCharacterUpdate: ((Character) -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: CharacterViewModel(character: character))
        self.onCharacterUpdate = onCharacterUpdate
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Заголовок персонажа
                EditableCharacterHeader(character: $viewModel.character)
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
        .navigationTitle("Персонаж")
        .navigationBarTitleDisplayMode(.inline)
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
                        hitPointsType: hitPointsType
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
                        )
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
                        )
                    )
                    .onDisappear {
                        onCharacterUpdate?(viewModel.character)
                    }
                }
            }
        )
    }
    
    private func showHitPointsContextMenu() {
        let alert = UIAlertController(title: "Хиты", message: "Выберите тип хитов для редактирования", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Текущие хиты", style: .default) { _ in
            hitPointsType = .current
            showingEditHitPoints = true
        })
        
        alert.addAction(UIAlertAction(title: "Максимальные хиты", style: .default) { _ in
            hitPointsType = .maximum
            showingEditHitPoints = true
        })
        
        alert.addAction(UIAlertAction(title: "Временные хиты", style: .default) { _ in
            hitPointsType = .temporary
            showingEditHitPoints = true
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
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
        .onLongPressGesture {
            showHitPointsContextMenu()
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var detailedInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Детальная информация")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                detailCard(title: "Характеристики", icon: "person.2.fill", color: .blue)
                detailCard(title: "Боевые характеристики", icon: "shield.fill", color: .red)
                detailCard(title: "Навыки", icon: "brain.head.profile", color: .green)
                detailCard(title: "Классовые умения", icon: "star.fill", color: .purple)
                detailCard(title: "Снаряжение", icon: "bag.fill", color: .orange)
                detailCard(title: "Сокровища", icon: "diamond.fill", color: .yellow)
                detailCard(title: "Личность", icon: "person.crop.square.fill", color: .pink)
                detailCard(title: "Особенности", icon: "star.fill", color: .blue)
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
            
            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
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