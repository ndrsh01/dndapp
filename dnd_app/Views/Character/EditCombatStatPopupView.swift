import SwiftUI

struct EditCombatStatPopupView: View {
    let stat: CombatStat
    @Binding var value: Int
    let onDismiss: () -> Void
    
    init(stat: CombatStat, value: Binding<Int>, onDismiss: @escaping () -> Void) {
        self.stat = stat
        self._value = value
        self.onDismiss = onDismiss
    }
    
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
    EditCombatStatPopupView(stat: .armorClass, value: .constant(15), onDismiss: {})
}

