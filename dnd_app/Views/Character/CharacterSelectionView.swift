import SwiftUI

struct CharacterSelectionView: View {
    @EnvironmentObject private var characterManager: CharacterManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingCreateCharacter = false
    @State private var showingImportSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedCharacterForContext: Character?
    @State private var showingEditCharacter = false
    @State private var showingExportCharacter = false
    @State private var showingDeleteConfirmation = false
    @State private var characterToDelete: Character?
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var isExporting = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    headerSection
                    
                    // Список персонажей
                    charactersSection
                    
                    // Кнопка "Играть за X" (если есть выбранный персонаж)
                    if let selectedCharacter = characterManager.selectedCharacter {
                        playButton(for: selectedCharacter)
                    }
                    
                    // Кнопки действий
                    actionButtonsSection
                }
                .padding()
            }
            .navigationTitle("Персонажи")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCreateCharacter) {
                CharacterCreationView { newCharacter in
                    characterManager.addCharacter(newCharacter)
                    characterManager.selectCharacter(newCharacter)
                }
                .environmentObject(DataService.shared)
            }
            .sheet(isPresented: $showingImportSheet) {
                DocumentPicker { data in
                    // Сначала пробуем импортировать как расширенный формат с дополнительными данными
                    if let jsonString = String(data: data, encoding: .utf8),
                       let (character, relationships, notes, spells) = characterManager.importCharacterWithData(from: jsonString) {
                        characterManager.addCharacter(character)
                        
                        // Сохраняем дополнительные данные
                        let dataService = DataService.shared
                        for relationship in relationships {
                            dataService.addRelationship(relationship)
                        }
                        for note in notes {
                            dataService.addNote(note)
                        }
                        
                        // Сохраняем избранные заклинания
                        dataService.addFavoriteSpells(spells, for: character.id)
                        
                        alertMessage = "Персонаж успешно импортирован с дополнительными данными!"
                        showingAlert = true
                    } else if let character = characterManager.importExternalCharacterFromData(data) {
                        // Если не получилось, пробуем внешний формат
                        characterManager.addCharacter(character)
                        alertMessage = "Персонаж успешно импортирован из внешнего формата!"
                        showingAlert = true
                    } else if let character = characterManager.importCharacterFromData(data) {
                        // Если не получилось, пробуем внутренний формат
                        characterManager.addCharacter(character)
                        alertMessage = "Персонаж успешно импортирован!"
                        showingAlert = true
                    } else {
                        alertMessage = "Ошибка импорта персонажа. Проверьте формат файла."
                        showingAlert = true
                    }
                }
            }
            .sheet(isPresented: $showingEditCharacter) {
                if let character = selectedCharacterForContext {
                    CharacterEditView(character: character) { updatedCharacter in
                        characterManager.updateCharacter(updatedCharacter)
                    }
                }
            }
            .sheet(isPresented: $showingExportCharacter) {
                if let character = selectedCharacterForContext {
                    SimpleExportView(character: character)
                }
            }
            .alert("Импорт", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Удаление персонажа", isPresented: $showingDeleteConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    if let character = characterToDelete {
                        characterManager.deleteCharacter(character)
                    }
                }
            } message: {
                if let character = characterToDelete {
                    Text("Вы уверены, что хотите удалить персонажа \"\(character.name)\"? Это действие нельзя отменить.")
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                Group {
                    let _ = print("=== SHEET CONDITION CHECK ===")
                    let _ = print("isExporting: \(isExporting)")
                    let _ = print("exportURL != nil: \(exportURL != nil)")
                    let _ = print("exportURL: \(exportURL?.path ?? "nil")")
                    
                    if isExporting {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(2.0)
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            
                            Text("Экспорт персонажа...")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Создание файла с данными персонажа")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .onAppear {
                            print("=== SHARE SHEET SHEET TRIGGERED (LOADING) ===")
                            print("showingShareSheet: \(showingShareSheet)")
                            print("isExporting: \(isExporting)")
                        }
                    } else if let url = exportURL {
                        CharacterSelectionShareSheet(items: [url])
                            .onAppear {
                                print("=== SHARE SHEET SHEET TRIGGERED (SUCCESS) ===")
                                print("showingShareSheet: \(showingShareSheet)")
                                print("exportURL: \(url.path)")
                            }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Проблема с экспортом")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Не удалось создать файл для экспорта")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Закрыть") {
                                showingShareSheet = false
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                        }
                        .padding(40)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .onAppear {
                            print("=== SHARE SHEET SHEET TRIGGERED (ERROR) ===")
                            print("showingShareSheet: \(showingShareSheet)")
                            print("exportURL: nil")
                        }
                    }
                }
            }
        }
        .onAppear {
            print("=== CHARACTER SELECTION VIEW APPEARED ===")
            print("Total characters: \(characterManager.characters.count)")
            for (index, character) in characterManager.characters.enumerated() {
                print("Character \(index): '\(character.name)' with ID: \(character.id)")
            }
            print("Currently selected: '\(characterManager.selectedCharacter?.name ?? "nil")' with ID: \(characterManager.selectedCharacter?.id.uuidString ?? "nil")")
        }
    }
    
    private func playButton(for character: Character) -> some View {
        Button(action: {
            characterManager.selectCharacter(character)
            dismiss() // Закрываем экран выбора персонажа
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Играть за \(character.name)")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Управление персонажами")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Выберите персонажа или создайте нового")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Всего персонажей",
                    value: "\(characterManager.totalCharacters)",
                    icon: "person.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Классов",
                    value: "\(characterManager.charactersByClass.count)",
                    icon: "star.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "Рас",
                    value: "\(characterManager.charactersByRace.count)",
                    icon: "figure.walk",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var charactersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ваши персонажи")
                    .font(.headline)
                Spacer()
                if !characterManager.characters.isEmpty {
                    Text("\(characterManager.characters.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            if characterManager.characters.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(characterManager.characters) { character in
                        CharacterCard(
                            character: character,
                            isSelected: characterManager.selectedCharacter?.id == character.id,
                            onSelect: {
                                print("=== CHARACTER SELECTION VIEW ===")
                                print("User tapped on character: '\(character.name)' with ID: \(character.id)")
                                print("Current selected character: '\(characterManager.selectedCharacter?.name ?? "nil")' with ID: \(characterManager.selectedCharacter?.id.uuidString ?? "nil")")
                                characterManager.selectCharacter(character)
                                print("After selection: '\(characterManager.selectedCharacter?.name ?? "nil")' with ID: \(characterManager.selectedCharacter?.id.uuidString ?? "nil")")
                            },
                            onEdit: {
                                selectedCharacterForContext = character
                                showingEditCharacter = true
                            },
                            onExport: {
                                selectedCharacterForContext = character
                                showingExportCharacter = true
                            },
                            onDelete: {
                                characterToDelete = character
                                showingDeleteConfirmation = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("У вас пока нет персонажей")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Создайте своего первого персонажа или импортируйте существующего")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingCreateCharacter = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Создать персонажа")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    showingImportSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Импорт")
                    }
                    .font(.headline)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    if let selectedCharacter = characterManager.selectedCharacter {
                        exportCharacterDirectly(selectedCharacter)
                    } else {
                        alertMessage = "Выберите персонажа для экспорта"
                        showingAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text("Экспорт")
                    }
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .disabled(characterManager.selectedCharacter == nil)
                .opacity(characterManager.selectedCharacter == nil ? 0.6 : 1.0)
            }
        }
        .padding(.horizontal)
    }
    
    private func exportCharacterDirectly(_ character: Character) {
        print("=== DIRECT EXPORT ===")
        print("Character: \(character.name)")
        print("Current exportURL: \(exportURL?.path ?? "nil")")
        
        // Устанавливаем флаг экспорта и показываем Sheet
        isExporting = true
        showingShareSheet = true
        
        // Экспортируем полный формат
        print("Calling exportCharacterExtended...")
        guard let jsonString = characterManager.exportCharacterExtended(character) else {
            print("ERROR: exportCharacterExtended returned nil")
            DispatchQueue.main.async {
                self.isExporting = false
                self.alertMessage = "Ошибка создания файла экспорта"
                self.showingAlert = true
            }
            return
        }
        print("exportCharacterExtended succeeded, JSON length: \(jsonString.count)")
        
        print("JSON string length: \(jsonString.count)")
        
        // Создаем временный файл
        let fileName = "\(character.name)_экспорт.json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        print("Creating file at: \(tempURL)")
        
        do {
            try jsonString.write(to: tempURL, atomically: true, encoding: .utf8)
            print("File created successfully")
            
            // Обновляем UI на главном потоке
            DispatchQueue.main.async {
                print("=== UPDATING UI ON MAIN THREAD ===")
                print("Setting exportURL: \(tempURL)")
                self.exportURL = tempURL
                // Не сбрасываем isExporting сразу, чтобы Sheet не переключился на ошибку
                print("Export completed, ShareSheet should update automatically")
                print("Current showingShareSheet state: \(self.showingShareSheet)")
                print("Current exportURL: \(self.exportURL?.path ?? "nil")")
                
                // Сбрасываем isExporting через небольшую задержку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isExporting = false
                }
            }
            
        } catch {
            print("ERROR: \(error)")
            DispatchQueue.main.async {
                self.isExporting = false
                self.alertMessage = "Ошибка сохранения файла: \(error.localizedDescription)"
                self.showingAlert = true
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(adaptiveTextColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveTextColor: Color {
        switch colorScheme {
        case .dark:
            return .white
        case .light:
            return .black
        @unknown default:
            return .primary
        }
    }
    
    private var adaptiveCardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        case .light:
            return color.opacity(0.1)
        @unknown default:
            return Color(UIColor.secondarySystemBackground)
        }
    }
}

struct CharacterCard: View {
    let character: Character
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Аватар
            Circle()
                .fill(isSelected ? Color.orange : Color.secondary.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .secondary)
                )
            
            // Информация о персонаже
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack {
                    Text(character.race)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(character.characterClass)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Уровень \(character.level)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(6)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Индикатор выбора
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            CharacterContextMenu(
                character: character,
                onEdit: onEdit,
                onExport: onExport,
                onDelete: onDelete
            )
        }
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveCardBackgroundColor: Color {
        if isSelected {
            return Color.orange.opacity(0.1)
        } else {
            switch colorScheme {
            case .dark:
                return Color(UIColor.secondarySystemBackground)
            case .light:
                return Color.white
            @unknown default:
                return Color(UIColor.secondarySystemBackground)
            }
        }
    }
    
    private var adaptiveShadowColor: Color {
        switch colorScheme {
        case .dark:
            return .black.opacity(0.3)
        case .light:
            return .black.opacity(0.1)
        @unknown default:
            return .black.opacity(0.1)
        }
    }
}

struct CharacterContextMenu: View {
    let character: Character
    let onEdit: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            Label("Редактировать", systemImage: "pencil")
        }
        
        Button(action: onExport) {
            Label("Экспортировать", systemImage: "square.and.arrow.up")
        }
        
        Divider()
        
        Button(action: onDelete) {
            Label("Удалить", systemImage: "trash")
        }
    }
}

struct CharacterSelectionShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("=== CHARACTER SELECTION SHARE SHEET ===")
        print("Creating UIActivityViewController with items count: \(items.count)")
        
        for (index, item) in items.enumerated() {
            print("Item \(index): \(type(of: item))")
            if let url = item as? URL {
                print("  - URL: \(url)")
                print("  - Path: \(url.path)")
                print("  - File exists: \(FileManager.default.fileExists(atPath: url.path))")
            }
        }
        
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CharacterSelectionView()
        .environmentObject(CharacterManager.shared)
}
