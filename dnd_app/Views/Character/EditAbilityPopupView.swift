import SwiftUI

struct EditAbilityPopupView: View {
    let ability: AbilityScore
    @Binding var value: Int
    let onDismiss: () -> Void

    init(ability: AbilityScore, value: Binding<Int>, onDismiss: @escaping () -> Void) {
        self.ability = ability
        self._value = value
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(ability.displayName)
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                TextField("", value: $value, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(.systemBackground).opacity(0.8))
                    .frame(width: 80)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
            }
            
            Text("Модификатор: \(abilityModifier)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Button("Отмена") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Сохранить") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
        .padding(20)
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8)
    }
    
    private var abilityModifier: String {
        let modifier = (value - 10) / 2
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}

#Preview {
    EditAbilityPopupView(ability: .strength, value: .constant(15), onDismiss: {})
}

