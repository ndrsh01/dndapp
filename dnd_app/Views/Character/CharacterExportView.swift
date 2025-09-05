import SwiftUI

struct CharacterExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var jsonString: String
    @State private var showingShareSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let character: Character
    
    init(character: Character) {
        self.character = character
        
        // Генерируем JSON при инициализации
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(character),
           let json = String(data: data, encoding: .utf8) {
            self._jsonString = State(initialValue: json)
        } else {
            self._jsonString = State(initialValue: "Ошибка генерации JSON")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Экспорт персонажа")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Экспортируйте \(character.name) в JSON файл")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Информация о персонаже
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(character.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("\(character.race) • \(character.characterClass)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Уровень \(character.level)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(6)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // JSON предварительный просмотр
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("JSON данные")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Копировать") {
                            UIPasteboard.general.string = jsonString
                            alertMessage = "JSON скопирован в буфер обмена!"
                            showingAlert = true
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        Text(jsonString)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Кнопки действий
                VStack(spacing: 12) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Поделиться файлом")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = jsonString
                        alertMessage = "JSON скопирован в буфер обмена!"
                        showingAlert = true
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Копировать JSON")
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
            .navigationTitle("Экспорт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [createJSONFile()])
            }
            .alert("Экспорт", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createJSONFile() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(character.name.replacingOccurrences(of: " ", with: "_"))_character.json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try? jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CharacterExportView(character: Character(
        name: "Тестовый персонаж",
        race: "Человек",
        characterClass: "Воин",
        background: "Солдат",
        alignment: "Законно-добрый"
    ))
}

