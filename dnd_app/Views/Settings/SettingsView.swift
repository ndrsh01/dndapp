import SwiftUI

struct SettingsView: View {
    @ObservedObject private var characterManager = CharacterManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showCharacterSelection = false
    @State private var showCacheClearedAlert = false
    
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
                            Text(characterManager.selectedCharacter?.name ?? "Нет персонажа")
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
                
                // Cache Management Section
                Section("Управление данными") {
                    SettingsRowView(
                        icon: "trash",
                        title: "Очистить кэш",
                        subtitle: "Удалить временные файлы"
                    ) {
                        clearCache()
                    }
                }
                
                // Appearance Section
                Section("Внешний вид") {
                    HStack {
                        Image(systemName: "moon")
                            .foregroundColor(.orange)
                            .frame(width: 24)

                        VStack(alignment: .leading) {
                            Text("Темная тема")
                                .font(.headline)
                            Text("Включить темную цветовую схему")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { 
                                return settingsManager.settings.selectedTheme == .dark 
                            },
                            set: { isOn in
                                settingsManager.settings.selectedTheme = isOn ? .dark : .light
                            }
                        ))
                        .labelsHidden()
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
            CharacterSelectionView()
                .environmentObject(characterManager)
        }
        .alert("Кэш очищен", isPresented: $showCacheClearedAlert) {
            Button("OK") { }
        } message: {
            Text("Временные файлы успешно удалены.")
        }
    }
    
    private func clearCache() {
        // Очищаем временные файлы
        let tempDirectory = FileManager.default.temporaryDirectory
        
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
            
            for file in tempFiles {
                try FileManager.default.removeItem(at: file)
            }
            
            print("Cache cleared: \(tempFiles.count) files removed")
            showCacheClearedAlert = true
            
        } catch {
            print("Error clearing cache: \(error)")
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
