import SwiftUI

struct CharacterSelectionView: View {
    @EnvironmentObject private var characterManager: CharacterManager
    @State private var showingCreateCharacter = false
    @State private var showingImportSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedCharacterForContext: Character?
    @State private var showingEditCharacter = false
    @State private var showingExportCharacter = false
    @State private var showingDeleteConfirmation = false
    @State private var characterToDelete: Character?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    headerSection
                    
                    // Статистика
                    statisticsSection
                    
                    // Список персонажей
                    charactersSection
                    
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
            }
            .sheet(isPresented: $showingImportSheet) {
                DocumentPicker { data in
                    // Сначала пробуем импортировать как внешний формат
                    if let character = characterManager.importExternalCharacter(from: data) {
                        characterManager.addCharacter(character)
                        alertMessage = "Персонаж успешно импортирован из внешнего формата!"
                        showingAlert = true
                    } else if let character = characterManager.importCharacter(from: data) {
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
                    CharacterExportView(character: character)
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
        }
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
                                characterManager.selectCharacter(character)
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
            
            Button(action: {
                showingImportSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Импортировать из JSON")
                }
                .font(.headline)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CharacterCard: View {
    let character: Character
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void
    
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
                    
                    Text(character.dateModified, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        .background(isSelected ? Color.orange.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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

#Preview {
    CharacterSelectionView()
        .environmentObject(CharacterManager())
}
