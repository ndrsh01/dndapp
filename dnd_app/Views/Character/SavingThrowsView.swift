import SwiftUI

struct SavingThrowsView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Спасброски")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Управляйте спасбросками вашего персонажа. Владение добавляет бонус мастерства к базовому модификатору характеристики.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(AbilityScore.allCases, id: \.self) { ability in
                            savingThrowRow(ability: ability)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(adaptiveBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func savingThrowRow(ability: AbilityScore) -> some View {
        let hasProficiency = character.hasSavingThrowProficiency(for: ability)
        let abilityModifier = character.modifier(for: ability)
        let proficiencyBonus = character.proficiencyBonus
        
        let savingThrowBonus = abilityModifier + (hasProficiency ? proficiencyBonus : 0)
        
        return HStack(spacing: 12) {
            // Название характеристики и иконка
            HStack(spacing: 8) {
                Image(systemName: ability.icon)
                    .foregroundColor(ability.color)
                    .font(.title3)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(ability.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text("Спасбросок")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Индикатор владения и бонус
            HStack(spacing: 8) {
                // Владение
                Button(action: {
                    toggleProficiency(for: ability)
                }) {
                    Image(systemName: hasProficiency ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(hasProficiency ? .orange : .gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Бонус спасброска
                Text(character.formatModifier(savingThrowBonus))
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
    
    private func toggleProficiency(for ability: AbilityScore) {
        character.toggleSavingThrow(for: ability)
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

#Preview {
    SavingThrowsView(
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
