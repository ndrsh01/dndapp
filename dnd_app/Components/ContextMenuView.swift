import SwiftUI
import UIKit

struct ContextMenuView: View {
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onEdit) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Редактировать")
                        .foregroundColor(.primary)
                        .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Button(action: onDuplicate) {
                HStack {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    Text("Дублировать")
                        .foregroundColor(.primary)
                        .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Button(action: onDelete) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                    Text("Удалить")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .frame(width: 220)
    }
}

// MARK: - Global Context Menu Manager
class GlobalContextMenuManager: ObservableObject {
    @Published var showContextMenu = false
    @Published var highlightedElementFrame: CGRect = .zero
    @Published var onEdit: (() -> Void)?
    @Published var onDelete: (() -> Void)?
    @Published var onDuplicate: (() -> Void)?
    
    static let shared = GlobalContextMenuManager()
    
    func showMenu(for elementFrame: CGRect, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void, onDuplicate: @escaping () -> Void) {
        self.highlightedElementFrame = elementFrame
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onDuplicate = onDuplicate
        self.showContextMenu = true
    }
    
    func hideMenu() {
        self.showContextMenu = false
        self.onEdit = nil
        self.onDelete = nil
        self.onDuplicate = nil
    }
}

// MARK: - Context Menu Modifier
struct ContextMenuModifier: ViewModifier {
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    @State private var showMenu = false
    @State private var scale: CGFloat = 1.0
    @State private var borderColor: Color = .clear
    @State private var borderWidth: CGFloat = 0

    func body(content: Content) -> some View {
        ZStack {
            content
                .scaleEffect(scale)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                scale = 1.05
                                borderColor = .orange.opacity(0.8)
                                borderWidth = 2
                            }
                            // Haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()

                            showMenu = true
                        }
                )
                .onTapGesture {
                    if showMenu {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            scale = 1.0
                            borderColor = .clear
                            borderWidth = 0
                        }
                        showMenu = false
                    }
                }

            if showMenu {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ContextMenuView(
                            onEdit: {
                                onEdit()
                                hideMenu()
                            },
                            onDelete: {
                                onDelete()
                                hideMenu()
                            },
                            onDuplicate: {
                                onDuplicate()
                                hideMenu()
                            }
                        )
                        .offset(y: 20) // Опускаем меню ниже элемента
                        Spacer()
                    }
                    Spacer()
                }
                .background(
                    Color.black.opacity(0.3) // Затемнение всей области
                        .onTapGesture {
                            hideMenu()
                        }
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
    }

    private func hideMenu() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            scale = 1.0
            borderColor = .clear
            borderWidth = 0
            showMenu = false
        }
    }
}

extension View {
    func contextMenu(
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onDuplicate: @escaping () -> Void
    ) -> some View {
        self.modifier(ContextMenuModifier(
            onEdit: onEdit,
            onDelete: onDelete,
            onDuplicate: onDuplicate
        ))
    }
}
