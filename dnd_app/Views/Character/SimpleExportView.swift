import SwiftUI
import UniformTypeIdentifiers

struct SimpleExportView: View {
    let character: Character
    @EnvironmentObject private var characterManager: CharacterManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Информация о персонаже
                VStack(spacing: 12) {
                    Text("Экспорт персонажа")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(character.name)
                        .font(.title3)
                        .foregroundColor(.orange)
                    
                    Text("Уровень \(character.level) \(character.characterClass)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Кнопки экспорта
                VStack(spacing: 16) {
                    Button(action: {
                        exportCharacter(.extended)
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Полный экспорт")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        exportCharacter(.basic)
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Только персонаж")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Экспорт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                } else {
                    VStack {
                        Text("Ошибка экспорта")
                            .foregroundColor(.red)
                            .font(.headline)
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
        }
    }
    
    private func exportCharacter(_ type: ExportType) {
        print("=== SIMPLE EXPORT ===")
        print("Character: \(character.name)")
        print("Type: \(type)")
        
        let jsonString: String?
        let fileName: String
        
        switch type {
        case .extended:
            jsonString = characterManager.exportCharacterExtended(character)
            fileName = "\(character.name)_полный_экспорт.json"
        case .basic:
            jsonString = characterManager.exportCharacter(character)
            fileName = "\(character.name)_персонаж.json"
        }
        
        guard let jsonString = jsonString else {
            print("ERROR: jsonString is nil")
            alertMessage = "Ошибка создания файла экспорта"
            showingAlert = true
            return
        }
        
        print("JSON string length: \(jsonString.count)")
        
        // Создаем временный файл
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        print("Creating file at: \(tempURL)")
        
        do {
            try jsonString.write(to: tempURL, atomically: true, encoding: .utf8)
            print("File created successfully")
            
            exportURL = tempURL
            showingShareSheet = true
            
        } catch {
            print("ERROR: \(error)")
            alertMessage = "Ошибка сохранения файла: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    enum ExportType {
        case extended
        case basic
    }
}

#Preview {
    SimpleExportView(character: Character(
        name: "Тестовый персонаж",
        race: "Человек",
        characterClass: "Воин",
        background: "Солдат",
        alignment: "Законно-добрый"
    ))
    .environmentObject(CharacterManager.shared)
}
