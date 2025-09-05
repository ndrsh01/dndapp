import SwiftUI

struct EditCombatStatPopupView: View {
    let stat: CombatStat
    @Binding var value: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(stat.displayName)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                Button(action: {
                    value -= 1
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                
                Text("\(value)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(minWidth: 60)
                
                Button(action: {
                    value += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            
            if stat == .initiative {
                Text("Модификатор: \(initiativeModifier)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
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
    
    private var initiativeModifier: String {
        let modifier = (value - 10) / 2
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}

#Preview {
    EditCombatStatPopupView(stat: .armorClass, value: .constant(15))
}

