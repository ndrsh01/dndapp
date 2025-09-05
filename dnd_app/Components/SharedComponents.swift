import SwiftUI

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(Color(red: 0.95, green: 0.94, blue: 0.92))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Tag View
struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .cornerRadius(8)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - DnD Button Style
struct DnDButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Relationship Indicator
struct RelationshipIndicator: View {
    let relationshipLevel: Int
    let maxLevel: Int = 10
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxLevel, id: \.self) { index in
                Image(systemName: iconForLevel(index))
                    .foregroundColor(colorForLevel(index))
                    .font(.caption)
            }
        }
    }
    
    private func iconForLevel(_ index: Int) -> String {
        if index < 2 {
            return "xmark.circle.fill"
        } else if index == 2 {
            return "heart.fill" // Neutral icon is now a friend icon
        } else {
            return "heart.fill"
        }
    }
    
    private func colorForLevel(_ index: Int) -> Color {
        if index < 2 {
            return .red
        } else if index == 2 {
            return .red
        } else {
            return .red
        }
    }
    
    private func backgroundColorForLevel(_ index: Int) -> Color {
        if index < 2 {
            return .red.opacity(0.1)
        } else if index == 2 {
            return .red.opacity(0.1)
        } else {
            return .red.opacity(0.1)
        }
    }
    
    private func borderColorForLevel(_ index: Int) -> Color {
        if index < 2 {
            return .red
        } else if index == 2 {
            return .red
        } else {
            return .red
        }
    }
}

// MARK: - Tabaxi Image View
struct TabaxiImageView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            VStack(spacing: 8) {
                Text("Ошибка")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let retryAction = retryAction {
                Button("Повторить", action: retryAction)
                    .buttonStyle(DnDButtonStyle())
            }
        }
        .padding(.horizontal, 32)
    }
}