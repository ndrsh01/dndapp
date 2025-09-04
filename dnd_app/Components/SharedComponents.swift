import SwiftUI

// MARK: - Custom Button Style
struct DnDButtonStyle: ButtonStyle {
    let color: Color
    let isSelected: Bool
    
    init(color: Color = .orange, isSelected: Bool = false) {
        self.color = color
        self.isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

// MARK: - Relationship Indicator
struct RelationshipIndicator: View {
    let level: Int
    let onTap: (Int) -> Void
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    let onDuplicate: (() -> Void)?
    
    init(level: Int, onTap: @escaping (Int) -> Void, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil, onDuplicate: (() -> Void)? = nil) {
        self.level = level
        self.onTap = onTap
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onDuplicate = onDuplicate
    }
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<11, id: \.self) { index in
                Button(action: {
                    onTap(index + 1)
                }) {
                    Image(systemName: iconForLevel(index))
                        .foregroundColor(colorForLevel(index))
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 20, height: 20)
                        .background(backgroundColorForLevel(index))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(borderColorForLevel(index), lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .contextMenu(
            onEdit: onEdit ?? {},
            onDelete: onDelete ?? {},
            onDuplicate: onDuplicate ?? {}
        )
    }
    
    private func iconForLevel(_ index: Int) -> String {
        if index < 5 {
            return "xmark.circle.fill"
        } else if index == 5 {
            return "circle.fill"
        } else {
            return "heart.fill"
        }
    }
    
    private func colorForLevel(_ index: Int) -> Color {
        if index < level {
            if index < 5 {
                return .white
            } else if index == 5 {
                return .white
            } else {
                return .white
            }
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func backgroundColorForLevel(_ index: Int) -> Color {
        if index < level {
            if index < 5 {
                return .black
            } else if index == 5 {
                return .gray
            } else {
                return .red
            }
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private func borderColorForLevel(_ index: Int) -> Color {
        if index < level {
            if index < 5 {
                return .black
            } else if index == 5 {
                return .gray
            } else {
                return .red
            }
        } else {
            return .gray.opacity(0.3)
        }
    }
}

// MARK: - Importance Indicator
struct ImportanceIndicator: View {
    let importance: Int
    let onTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { level in
                Button(action: {
                    onTap(level)
                }) {
                    Image(systemName: importance >= level ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                }
            }
        }
    }
}

// MARK: - Tabaxi Image Component
struct TabaxiImageView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: 200)
    }
}

// MARK: - Random Tabaxi Image
struct RandomTabaxiImageView: View {
    @State private var currentImageName: String = "tabaxi_pose1"
    
    var body: some View {
        TabaxiImageView(imageName: currentImageName)
            .onAppear {
                generateRandomImage()
            }
    }
    
    private func generateRandomImage() {
        currentImageName = TabaxiImages.getRandomImageName()
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
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 40)
    }
}
