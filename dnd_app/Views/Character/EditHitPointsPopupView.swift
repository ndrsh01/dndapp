import SwiftUI

struct EditHitPointsPopupView: View {
    @Binding var currentHitPoints: Int
    @Binding var maxHitPoints: Int
    @State private var temporaryHitPoints: Int = 0
    @State private var localValue: Int
    let hitPointsType: HitPointsType
    @Environment(\.dismiss) private var dismiss
    
    init(currentHitPoints: Binding<Int>, maxHitPoints: Binding<Int>, hitPointsType: HitPointsType) {
        self._currentHitPoints = currentHitPoints
        self._maxHitPoints = maxHitPoints
        self.hitPointsType = hitPointsType
        
        switch hitPointsType {
        case .current:
            self._localValue = State(initialValue: currentHitPoints.wrappedValue)
        case .maximum:
            self._localValue = State(initialValue: maxHitPoints.wrappedValue)
        case .temporary:
            self._localValue = State(initialValue: 0)
        }
    }
    
    enum HitPointsType {
        case current
        case maximum
        case temporary
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                Button(action: {
                    if localValue > 0 {
                        localValue -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .disabled(localValue <= 0)
                
                Text("\(localValue)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(minWidth: 60)
                
                Button(action: {
                    localValue += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            
            if hitPointsType == .current {
                Text("Максимум: \(maxHitPoints)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                Button("Отмена") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                
                Button("Готово") {
                    saveValue()
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
    
    private var title: String {
        switch hitPointsType {
        case .current:
            return "Текущие хиты"
        case .maximum:
            return "Максимальные хиты"
        case .temporary:
            return "Временные хиты"
        }
    }
    
    private func saveValue() {
        switch hitPointsType {
        case .current:
            currentHitPoints = localValue
        case .maximum:
            maxHitPoints = localValue
        case .temporary:
            temporaryHitPoints = localValue
        }
    }
}

#Preview {
    EditHitPointsPopupView(
        currentHitPoints: .constant(15),
        maxHitPoints: .constant(20),
        hitPointsType: .current
    )
}
