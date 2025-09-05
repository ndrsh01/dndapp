import SwiftUI

struct EditAbilityPopupView: View {
    let ability: AbilityScore
    @Binding var value: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(ability.displayName)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                Button(action: {
                    if value > 1 {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .disabled(value <= 1)
                
                Text("\(value)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(minWidth: 60)
                
                Button(action: {
                    if value < 30 {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
                .disabled(value >= 30)
            }
            
            Text("Модификатор: \(abilityModifier)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                Button("Отмена") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                
                Button("Готово") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private var abilityModifier: String {
        let modifier = (value - 10) / 2
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}

#Preview {
    EditAbilityPopupView(ability: .strength, value: .constant(15))
}

