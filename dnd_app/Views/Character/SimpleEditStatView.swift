import SwiftUI

struct SimpleEditStatView: View {
    @Binding var value: Int
    let title: String
    let iconName: String
    let iconColor: Color
    let onDismiss: () -> Void
    
    @State private var inputValue: String
    
    init(value: Binding<Int>, title: String, iconName: String, iconColor: Color, onDismiss: @escaping () -> Void) {
        self._value = value
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
        self.onDismiss = onDismiss
        self._inputValue = State(initialValue: String(value.wrappedValue))
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
    
    private func applyValue() {
        guard let newValue = Int(inputValue) else { return }
        value = max(0, newValue)
    }
}

#Preview {
    SimpleEditStatView(
        value: .constant(15),
        title: "Сила",
        iconName: "figure.strengthtraining.traditional",
        iconColor: .red,
        onDismiss: {}
    )
}
