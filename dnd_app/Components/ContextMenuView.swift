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
    @State private var elementFrame: CGRect = .zero
    @StateObject private var globalManager = GlobalContextMenuManager.shared
    
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
                globalManager.showMenu(
                    for: elementFrame,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onDuplicate: onDuplicate
                )
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
