import SwiftUI

struct ModernEditHitPointsView: View {
    @Binding var currentHitPoints: Int
    @Binding var maxHitPoints: Int
    @Binding var temporaryHitPoints: Int
    let hitPointsType: HitPointsType
    let onDismiss: () -> Void
    
    @State private var inputValue: String
    
    enum HitPointsType {
        case current
        case maximum
        case temporary
    }
    
    init(currentHitPoints: Binding<Int>, maxHitPoints: Binding<Int>, 
         temporaryHitPoints: Binding<Int>, hitPointsType: HitPointsType, onDismiss: @escaping () -> Void) {
        self._currentHitPoints = currentHitPoints
        self._maxHitPoints = maxHitPoints
        self._temporaryHitPoints = temporaryHitPoints
        self.hitPointsType = hitPointsType
        self.onDismiss = onDismiss
        
        let initialValue: Int
        switch hitPointsType {
        case .current: initialValue = currentHitPoints.wrappedValue
        case .maximum: initialValue = maxHitPoints.wrappedValue
        case .temporary: initialValue = temporaryHitPoints.wrappedValue
        }
        self._inputValue = State(initialValue: String(initialValue))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // Поле ввода
            TextField("Введите значение", text: $inputValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Кнопки действий
            HStack(spacing: 16) {
                Button("Отмена") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                
                Button("Применить") {
                    applyValue()
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(iconColor)
                .disabled(inputValue.isEmpty || Int(inputValue) == nil)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .presentationDetents([.height(200)])
    }
    
    private var title: String {
        switch hitPointsType {
        case .current: return "Текущие хиты"
        case .maximum: return "Максимальные хиты"
        case .temporary: return "Временные хиты"
        }
    }
    
    private var iconName: String {
        switch hitPointsType {
        case .current: return "heart.fill"
        case .maximum: return "heart.circle.fill"
        case .temporary: return "shield.fill"
        }
    }
    
    private var iconColor: Color {
        switch hitPointsType {
        case .current: return .green
        case .maximum: return .red
        case .temporary: return .blue
        }
    }
    
    private func applyValue() {
        guard let value = Int(inputValue) else { return }
        
        switch hitPointsType {
        case .current: 
            currentHitPoints = max(0, value)
        case .maximum: 
            maxHitPoints = max(1, value)
            // Если текущие HP больше нового максимума, уменьшаем их
            if currentHitPoints > maxHitPoints {
                currentHitPoints = maxHitPoints
            }
        case .temporary: 
            temporaryHitPoints = max(0, value)
        }
    }
}

#Preview {
    ModernEditHitPointsView(
        currentHitPoints: .constant(15),
        maxHitPoints: .constant(20),
        temporaryHitPoints: .constant(5),
        hitPointsType: .current,
        onDismiss: {}
    )
}
