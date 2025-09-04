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
                    Text("Редактировать")
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
            
            Button(action: onDuplicate) {
                HStack {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.green)
                    Text("Дублировать")
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
            
            Button(action: onDelete) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("Удалить")
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}

// MARK: - Context Menu Modifier
struct ContextMenuModifier: ViewModifier {
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    @State private var showContextMenu = false
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
                showContextMenu = true
            }
            .confirmationDialog("Действия", isPresented: $showContextMenu) {
                Button("Редактировать", role: .none) {
                    onEdit()
                }
                
                Button("Дублировать", role: .none) {
                    onDuplicate()
                }
                
                Button("Удалить", role: .destructive) {
                    onDelete()
                }
                
                Button("Отмена", role: .cancel) { }
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
