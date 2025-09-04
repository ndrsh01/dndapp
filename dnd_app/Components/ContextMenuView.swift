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

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Элемент (без затемнения)
                content
                    .scaleEffect(scale)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    scale = 1.02
                                }
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()

                                showMenu = true
                            }
                    )
                    .onTapGesture {
                        if showMenu {
                            hideMenu()
                        }
                    }
                    .zIndex(2)

                // Затемнение всего экрана (кроме элемента)
                if showMenu {
                    Color.black.opacity(0.4)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideMenu()
                        }
                        .transition(.opacity)
                        .zIndex(1)
                }

                // Меню значительно ниже элемента
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
                            .offset(y: 80) // Опускаем меню еще ниже
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .transition(.opacity)
                    .zIndex(3)
                }
            }
        }
    }

    private func hideMenu() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            scale = 1.0
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
