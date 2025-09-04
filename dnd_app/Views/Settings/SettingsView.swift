import SwiftUI

struct SettingsView: View {
    @StateObject private var characterViewModel = CharacterViewModel()
    @State private var showCharacterSelection = false
    @State private var showExportAlert = false
    @State private var showImportAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Character Section
                Section("Персонаж") {
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Выбранный персонаж")
                                .font(.headline)
                            Text(characterViewModel.selectedCharacter?.name ?? "Нет персонажа")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Изменить") {
                            showCharacterSelection = true
                        }
                        .font(.caption)
                    }
                }
                
                // Data Management Section
                Section("Управление данными") {
                    SettingsRowView(
                        icon: "square.and.arrow.up",
                        title: "Экспорт данных",
                        subtitle: "Сохранить все данные в файл"
                    ) {
                        showExportAlert = true
                    }
                    
                    SettingsRowView(
                        icon: "square.and.arrow.down",
                        title: "Импорт данных",
                        subtitle: "Загрузить данные из файла"
                    ) {
                        showImportAlert = true
                    }
                    
                    SettingsRowView(
                        icon: "trash",
                        title: "Очистить кэш",
                        subtitle: "Удалить временные файлы"
                    ) {
                        // TODO: Implement cache clearing
                    }
                }
                
                // App Section
                Section("Приложение") {
                    SettingsRowView(
                        icon: "info.circle",
                        title: "О приложении",
                        subtitle: "Версия 1.0.0"
                    ) {
                        // TODO: Show about screen
                    }
                    
                    SettingsRowView(
                        icon: "star",
                        title: "Оценить приложение",
                        subtitle: "Оставить отзыв в App Store"
                    ) {
                        // TODO: Open App Store review
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showCharacterSelection) {
            CharacterSelectionView(
                characters: characterViewModel.characters,
                selectedCharacter: characterViewModel.selectedCharacter
            ) { character in
                characterViewModel.selectCharacter(character)
            }
        }
        .alert("Экспорт данных", isPresented: $showExportAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Экспорт") {
                // TODO: Implement data export
            }
        } message: {
            Text("Все ваши данные будут сохранены в файл для резервного копирования.")
        }
        .alert("Импорт данных", isPresented: $showImportAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Импорт") {
                // TODO: Implement data import
            }
        } message: {
            Text("Выберите файл с данными для импорта.")
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
