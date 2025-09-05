import SwiftUI

struct EditCombatStatPopupView: View {
    let stat: CombatStat
    @Binding var value: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text(stat.displayName)
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                TextField("", value: $value, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
            }
            
            if stat == .initiative {
                Text("Модификатор: \(initiativeModifier)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
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
    
    private var initiativeModifier: String {
        let modifier = (value - 10) / 2
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}

#Preview {
    EditCombatStatPopupView(stat: .armorClass, value: .constant(15))
}

