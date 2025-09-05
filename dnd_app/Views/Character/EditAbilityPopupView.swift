import SwiftUI

struct EditAbilityPopupView: View {
    let ability: AbilityScore
    @Binding var value: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text(ability.displayName)
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                TextField("", value: $value, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
            }
            
            Text("Модификатор: \(abilityModifier)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Button("Отмена") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Сохранить") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8)
    }
    
    private var abilityModifier: String {
        let modifier = (value - 10) / 2
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}

#Preview {
    EditAbilityPopupView(ability: .strength, value: .constant(15))
}

