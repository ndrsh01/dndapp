import SwiftUI

struct EditHitPointsPopupView: View {
    @Binding var currentHitPoints: Int
    @Binding var maxHitPoints: Int
    @State private var temporaryHitPoints: Int = 0
    @State private var localValue: Int
    let hitPointsType: HitPointsType
    let onDismiss: () -> Void
    
    init(currentHitPoints: Binding<Int>, maxHitPoints: Binding<Int>, hitPointsType: HitPointsType, onDismiss: @escaping () -> Void) {
        self._currentHitPoints = currentHitPoints
        self._maxHitPoints = maxHitPoints
        self.hitPointsType = hitPointsType
        self.onDismiss = onDismiss

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
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                TextField("", value: $localValue, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(.systemBackground).opacity(0.8))
                    .frame(width: 80)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
            }
            
            if hitPointsType == .current {
                Text("Максимум: \(maxHitPoints)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                Button("Отмена") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Сохранить") {
                    saveValue()
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
        hitPointsType: .current,
        onDismiss: {}
    )
}
