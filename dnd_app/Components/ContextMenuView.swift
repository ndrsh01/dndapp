import SwiftUI

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
    }
}

// MARK: - Context Menu Modifier
struct ContextMenuModifier: ViewModifier {
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    @State private var showContextMenu = false
    @State private var menuPosition: CGPoint = .zero
    @State private var elementFrame: CGRect = .zero
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            elementFrame = geometry.frame(in: .global)
                        }
                        .onChange(of: geometry.frame(in: .global)) { newFrame in
                            elementFrame = newFrame
                        }
                }
            )
            .onLongPressGesture {
                // Вычисляем позицию меню под элементом
                menuPosition = CGPoint(
                    x: elementFrame.midX,
                    y: elementFrame.maxY + 10
                )
                showContextMenu = true
            }
            .overlay(
                Group {
                    if showContextMenu {
                        // Фон для закрытия меню
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showContextMenu = false
                            }
                            .zIndex(9998)
                        
                        // Само меню
                        ContextMenuView(
                            onEdit: {
                                onEdit()
                                showContextMenu = false
                            },
                            onDelete: {
                                onDelete()
                                showContextMenu = false
                            },
                            onDuplicate: {
                                onDuplicate()
                                showContextMenu = false
                            }
                        )
                        .frame(width: 200) // Фиксированная ширина
                        .position(menuPosition)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showContextMenu)
                        .zIndex(9999)
                    }
                }
            )
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
