import SwiftUI
import UniformTypeIdentifiers

struct CharacterExportView: View {
    let character: Character
    @EnvironmentObject private var characterManager: CharacterManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var exportType: ExportType = .extended
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingCopyAlert = false
    @State private var exportText = ""
    
    enum ExportType: String, CaseIterable {
        case extended = "Полный экспорт"
        case basic = "Только персонаж"
        case external = "Внешний формат"
        
        var description: String {
            switch self {
            case .extended:
                return "Персонаж + отношения + заметки + избранные заклинания"
            case .basic:
                return "Только основные данные персонажа"
            case .external:
                return "Формат внешнего приложения (Long Story Short)"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Информация о персонаже
                characterInfoSection
                
                // Выбор типа экспорта
                exportTypeSection
                
                // Предварительный просмотр
                previewSection
                
                Spacer()
                
                // Кнопки действий
                actionButtonsSection
            }
            .padding()
            .navigationTitle("Экспорт персонажа")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                        .onAppear {
                            print("ShareSheet appeared with URL: \(url)")
                        }
                } else {
                    VStack {
                        Text("Ошибка экспорта")
                            .foregroundColor(.red)
                            .font(.headline)
                        Text("Не удалось создать файл для экспорта")
                        .foregroundColor(.secondary)
                        Button("Закрыть") {
                            showingShareSheet = false
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .alert("Экспорт", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Экспорт в буфер обмена", isPresented: $showingCopyAlert) {
                Button("Копировать") {
                    UIPasteboard.general.string = exportText
                }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text("JSON скопирован в буфер обмена")
            }
        }
    }
    
    private var characterInfoSection: some View {
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "person.fill")
                            .font(.title2)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(character.name)
                        .font(.title2)
                        .fontWeight(.bold)
                            
                    Text("\(character.race) \(character.characterClass)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Уровень \(character.level)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                                .background(Color.orange)
                        .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
    }
                
    private var exportTypeSection: some View {
                VStack(alignment: .leading, spacing: 12) {
            Text("Тип экспорта")
                .font(.headline)
            
            ForEach(ExportType.allCases, id: \.self) { type in
                Button(action: {
                    exportType = type
                }) {
                    HStack {
                        Image(systemName: exportType == type ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(exportType == type ? .orange : .gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(type.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(exportType == type ? Color.orange.opacity(0.1) : Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Что будет экспортировано")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.orange)
                        .frame(width: 20)
                    Text("Персонаж: \(character.name)")
                        .font(.subheadline)
                }
                
                if exportType == .extended {
                    let dataService = DataService.shared
                    let relationshipsCount = dataService.getRelationships(for: character.id).count
                    let notesCount = dataService.getNotes(for: character.id).count
                    let spellsCount = dataService.getFavoriteSpells(for: character.id).count
                    
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("Отношения: \(relationshipsCount)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        Text("Заметки: \(notesCount)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        Text("Избранные заклинания: \(spellsCount)")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var actionButtonsSection: some View {
                VStack(spacing: 12) {
                    Button(action: {
                print("Export button tapped")
                exportCharacter()
                    }) {
                        HStack {
                    Image(systemName: "square.and.arrow.up.fill")
                    Text("Экспортировать")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                print("Copy to clipboard button tapped")
                copyToClipboard()
                    }) {
                        HStack {
                    Image(systemName: "doc.on.clipboard")
                    Text("Копировать в буфер обмена")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
    }
    
    private func exportCharacter() {
        print("=== CHARACTER EXPORT VIEW ===")
        print("Starting export for character: \(character.name)")
        print("Character ID: \(character.id)")
        print("Export type: \(exportType.rawValue)")
        
        let jsonString: String?
        let fileName: String

        switch exportType {
        case .extended:
            print("Calling exportCharacterExtended...")
            jsonString = characterManager.exportCharacterExtended(character)
            fileName = "\(character.name)_полный_экспорт.json"
        case .basic:
            print("Calling exportCharacter...")
            jsonString = characterManager.exportCharacter(character)
            fileName = "\(character.name)_персонаж.json"
        case .external:
            print("Calling exportCharacterExternal...")
            jsonString = characterManager.exportCharacterExternal(character)
            fileName = "\(character.name)_внешний_формат.json"
        }
        
        guard let jsonString = jsonString else {
            print("ERROR: jsonString is nil from characterManager")
            alertMessage = "Ошибка создания файла экспорта - jsonString is nil"
            showingAlert = true
            return
        }

        print("JSON string received, length: \(jsonString.count) characters")
        print("First 100 characters: \(String(jsonString.prefix(100)))")

        // Создаем временный файл
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        print("Creating temp file at: \(tempURL)")
        print("File name: \(fileName)")

        do {
            print("Writing JSON string to file...")
            try jsonString.write(to: tempURL, atomically: true, encoding: .utf8)
            print("File written successfully")
            
            // Проверяем, что файл действительно создался
            let fileExists = FileManager.default.fileExists(atPath: tempURL.path)
            print("File exists check: \(fileExists)")
            
            if fileExists {
                let fileSize = try FileManager.default.attributesOfItem(atPath: tempURL.path)[.size] as? Int64 ?? 0
                print("File size: \(fileSize) bytes")
            }
            
            exportURL = tempURL
            print("Setting exportURL and showing share sheet")
            showingShareSheet = true
            
        } catch {
            print("ERROR writing file: \(error)")
            print("Error type: \(type(of: error))")
            print("Error localized description: \(error.localizedDescription)")
            alertMessage = "Ошибка сохранения файла: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func copyToClipboard() {
        print("=== COPY TO CLIPBOARD ===")
        print("Starting copy to clipboard for character: \(character.name)")
        print("Character ID: \(character.id)")
        print("Export type: \(exportType.rawValue)")
        
        let jsonString: String?

        switch exportType {
        case .extended:
            print("Copy type: extended - calling exportCharacterExtended...")
            jsonString = characterManager.exportCharacterExtended(character)
        case .basic:
            print("Copy type: basic - calling exportCharacter...")
            jsonString = characterManager.exportCharacter(character)
        case .external:
            print("Copy type: external - calling exportCharacterExternal...")
            jsonString = characterManager.exportCharacterExternal(character)
        }
        
        guard let jsonString = jsonString else {
            print("ERROR: jsonString is nil for clipboard from characterManager")
            alertMessage = "Ошибка создания JSON для буфера обмена - jsonString is nil"
            showingAlert = true
            return
        }

        print("JSON string received for clipboard, length: \(jsonString.count) characters")
        print("First 100 characters: \(String(jsonString.prefix(100)))")
        
        exportText = jsonString
        print("Setting exportText and showing copy alert")
        showingCopyAlert = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("=== SHARE SHEET ===")
        print("Creating UIActivityViewController with items count: \(items.count)")
        
        for (index, item) in items.enumerated() {
            print("Item \(index): \(type(of: item))")
            if let url = item as? URL {
                print("  - URL: \(url)")
                print("  - Path: \(url.path)")
                print("  - File exists: \(FileManager.default.fileExists(atPath: url.path))")
            } else {
                print("  - Value: \(item)")
            }
        }
        
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        print("UIActivityViewController created successfully")

        // Настройки для iPad
        if let popover = controller.popoverPresentationController {
            print("Configuring popover for iPad...")
            popover.sourceView = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
            print("Popover configured")
        } else {
            print("No popover presentation controller (iPhone)")
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        print("Updating UIActivityViewController")
    }
}

#Preview {
    CharacterExportView(character: Character(
        name: "Тестовый персонаж",
        race: "Человек",
        characterClass: "Воин",
        background: "Солдат",
        alignment: "Законно-добрый"
    ))
    .environmentObject(CharacterManager.shared)
}