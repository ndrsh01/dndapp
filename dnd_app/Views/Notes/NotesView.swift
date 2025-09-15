import SwiftUI

struct NotesView: View {
    @EnvironmentObject private var viewModel: NotesViewModel
    @State private var showAddNote = false
    @State private var editingNote: Note?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Поиск заметок...")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                
                // Category Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            Button(action: {
                                viewModel.selectCategory(category)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .font(.caption)
                                .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedCategory == category ? Color.orange : Color(.systemGray6))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Notes List
                if viewModel.filteredNotes.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "note.text",
                        title: "Нет заметок",
                        description: "Добавьте свою первую заметку для отслеживания важной информации",
                        actionTitle: "Добавить заметку",
                        action: {
                            showAddNote = true
                        }
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            Spacer().frame(height: 12)
                            ForEach(viewModel.filteredNotes) { note in
                                NoteCardView(note: note)
                                    .contextMenu {
                                        Button(action: {
                                            editingNote = note
                                        }) {
                                            Label("Редактировать", systemImage: "pencil")
                                        }

                                        Button(action: {
                                            viewModel.duplicateNote(note)
                                        }) {
                                            Label("Дублировать", systemImage: "doc.on.doc")
                                        }

                                        Divider()

                                        Button(action: {
                                            viewModel.deleteNote(note)
                                        }) {
                                            Label("Удалить", systemImage: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
        }
        .background(adaptiveBackgroundColor)
        .navigationTitle("Заметки")
        .navigationBarTitleDisplayMode(.large)
        .ignoresSafeArea(.all, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddNote = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showAddNote) {
            AddNoteView(characterId: viewModel.selectedCharacterId) { note in
                viewModel.addNote(note)
            }
        }
        .sheet(item: $editingNote) { note in
            EditNoteView(note: note) { updatedNote in
                viewModel.updateNote(updatedNote)
            }
        }
        }
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.systemBackground)
        case .light:
            return Color(red: 0.98, green: 0.97, blue: 0.95)
        @unknown default:
            return Color(UIColor.systemBackground)
        }
    }
}

struct NoteCardView: View {
    let note: Note
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !note.description.isEmpty {
                        Text(note.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }

                    // Отображение дополнительных полей
                    additionalInfoView
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(note.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor.opacity(0.8))
                        .cornerRadius(6)
                    
                }
            }
        }
        .padding(16)
        .background(adaptiveCardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: adaptiveShadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var categoryColor: Color {
        switch note.category {
        case .all:
            return .gray
        case .campaign:
            return .purple
        case .characters:
            return .blue
        case .locations:
            return .green
        case .quests:
            return .orange
        case .lore:
            return .red
        case .items:
            return .indigo
        }
    }

    private var additionalInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            switch note.category {
            case .characters:
                characterInfo
            case .locations:
                locationInfo
            case .items:
                itemInfo
            case .quests:
                questInfo
            case .lore:
                loreInfo
            default:
                EmptyView()
            }
        }
    }

    private var characterInfo: some View {
        Group {
            if let race = note.race {
                infoRow(label: "Раса", value: race)
            }
            if let occupation = note.occupation {
                infoRow(label: "Должность", value: occupation)
            }
            if let organization = note.organization {
                infoRow(label: "Организация", value: organization)
            }
            if let age = note.age {
                infoRow(label: "Возраст", value: age)
            }
        }
    }

    private var locationInfo: some View {
        Group {
            if let locationType = note.locationType {
                infoRow(label: "Тип", value: locationType)
            }
            if let population = note.population {
                infoRow(label: "Население", value: population)
            }
            if let government = note.government {
                infoRow(label: "Правительство", value: government)
            }
            if let climate = note.climate {
                infoRow(label: "Климат", value: climate)
            }
        }
    }

    private var itemInfo: some View {
        Group {
            if let itemType = note.itemType {
                infoRow(label: "Тип", value: itemType)
            }
            if let rarity = note.rarity {
                infoRow(label: "Редкость", value: rarity)
            }
            if let value = note.value {
                infoRow(label: "Стоимость", value: value)
            }
        }
    }

    private var questInfo: some View {
        Group {
            if let questType = note.questType {
                infoRow(label: "Тип", value: questType)
            }
            if let status = note.status {
                infoRow(label: "Статус", value: status)
            }
            if let reward = note.reward {
                infoRow(label: "Награда", value: reward)
            }
        }
    }

    private var loreInfo: some View {
        Group {
            if let loreType = note.loreType {
                infoRow(label: "Тип", value: loreType)
            }
            if let era = note.era {
                infoRow(label: "Эпоха", value: era)
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text("\(label):")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Adaptive Colors
    
    private var adaptiveCardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        case .light:
            return Color(red: 0.95, green: 0.94, blue: 0.92)
        @unknown default:
            return Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var adaptiveShadowColor: Color {
        switch colorScheme {
        case .dark:
            return .black.opacity(0.3)
        case .light:
            return .black.opacity(0.05)
        @unknown default:
            return .black.opacity(0.1)
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var category: NoteCategory = .items

    // Дополнительные поля для персонажей
    @State private var race = ""
    @State private var occupation = ""
    @State private var organization = ""
    @State private var age = ""
    @State private var appearance = ""

    // Дополнительные поля для локаций
    @State private var locationType = ""
    @State private var population = ""
    @State private var government = ""
    @State private var climate = ""

    // Дополнительные поля для предметов
    @State private var itemType = ""
    @State private var rarity = ""
    @State private var value = ""

    // Дополнительные поля для квестов
    @State private var questType = ""
    @State private var status = ""
    @State private var reward = ""

    // Дополнительные поля для лора
    @State private var loreType = ""
    @State private var era = ""

    let characterId: UUID?
    let onSave: (Note) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Заголовок", text: $title)
                    ZStack(alignment: .bottomTrailing) {
                        TextField("Содержание", text: $content, axis: .vertical)
                            .lineLimit(5...10)

                        // Галочка в правом нижнем углу (серая если текст пустой, оранжевая если есть текст)
                        Button(action: {
                            // Скрываем клавиатуру
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(content.isEmpty ? .gray : .orange)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                        }
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                    }
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $category) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }

                // Дополнительные поля в зависимости от категории
                switch category {
                case .characters:
                    Section("Информация о персонаже") {
                        TextField("Раса", text: $race)
                        TextField("Должность", text: $occupation)
                        TextField("Организация", text: $organization)
                        TextField("Возраст", text: $age)
                        ZStack(alignment: .bottomTrailing) {
                            TextField("Внешность", text: $appearance, axis: .vertical)
                                .lineLimit(2...4)

                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Image(systemName: "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(appearance.isEmpty ? .gray : .orange)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                            }
                            .padding(.trailing, 8)
                            .padding(.bottom, 8)
                        }
                    }

                case .locations:
                    Section("Информация о локации") {
                        TextField("Тип локации", text: $locationType)
                        TextField("Население", text: $population)
                        TextField("Правительство", text: $government)
                        TextField("Климат", text: $climate)
                    }

                case .items:
                    Section("Информация о предмете") {
                        TextField("Тип предмета", text: $itemType)
                        TextField("Редкость", text: $rarity)
                        TextField("Стоимость", text: $value)
                    }

                case .quests:
                    Section("Информация о квесте") {
                        TextField("Тип квеста", text: $questType)
                        TextField("Статус", text: $status)
                        TextField("Награда", text: $reward)
                    }

                case .lore:
                    Section("Информация о лоре") {
                        TextField("Тип лора", text: $loreType)
                        TextField("Эпоха", text: $era)
                    }

                default:
                    EmptyView()
                }
            }
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let note = Note(
                            title: title,
                            description: content,
                            category: category,
                            characterId: characterId,
                            race: race.isEmpty ? nil : race,
                            occupation: occupation.isEmpty ? nil : occupation,
                            organization: organization.isEmpty ? nil : organization,
                            age: age.isEmpty ? nil : age,
                            appearance: appearance.isEmpty ? nil : appearance,
                            locationType: locationType.isEmpty ? nil : locationType,
                            population: population.isEmpty ? nil : population,
                            government: government.isEmpty ? nil : government,
                            climate: climate.isEmpty ? nil : climate,
                            itemType: itemType.isEmpty ? nil : itemType,
                            rarity: rarity.isEmpty ? nil : rarity,
                            value: value.isEmpty ? nil : value,
                            questType: questType.isEmpty ? nil : questType,
                            status: status.isEmpty ? nil : status,
                            reward: reward.isEmpty ? nil : reward,
                            loreType: loreType.isEmpty ? nil : loreType,
                            era: era.isEmpty ? nil : era
                        )
                        onSave(note)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var content: String
    @State private var category: NoteCategory

    // Дополнительные поля для персонажей
    @State private var race: String
    @State private var occupation: String
    @State private var organization: String
    @State private var age: String
    @State private var appearance: String

    // Дополнительные поля для локаций
    @State private var locationType: String
    @State private var population: String
    @State private var government: String
    @State private var climate: String

    // Дополнительные поля для предметов
    @State private var itemType: String
    @State private var rarity: String
    @State private var value: String

    // Дополнительные поля для квестов
    @State private var questType: String
    @State private var status: String
    @State private var reward: String

    // Дополнительные поля для лора
    @State private var loreType: String
    @State private var era: String

    let note: Note
    let onSave: (Note) -> Void

    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.description)
        self._category = State(initialValue: note.category)
        self._race = State(initialValue: note.race ?? "")
        self._occupation = State(initialValue: note.occupation ?? "")
        self._organization = State(initialValue: note.organization ?? "")
        self._age = State(initialValue: note.age ?? "")
        self._appearance = State(initialValue: note.appearance ?? "")
        self._locationType = State(initialValue: note.locationType ?? "")
        self._population = State(initialValue: note.population ?? "")
        self._government = State(initialValue: note.government ?? "")
        self._climate = State(initialValue: note.climate ?? "")
        self._itemType = State(initialValue: note.itemType ?? "")
        self._rarity = State(initialValue: note.rarity ?? "")
        self._value = State(initialValue: note.value ?? "")
        self._questType = State(initialValue: note.questType ?? "")
        self._status = State(initialValue: note.status ?? "")
        self._reward = State(initialValue: note.reward ?? "")
        self._loreType = State(initialValue: note.loreType ?? "")
        self._era = State(initialValue: note.era ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Заголовок", text: $title)
                    ZStack(alignment: .bottomTrailing) {
                        TextField("Содержание", text: $content, axis: .vertical)
                            .lineLimit(5...10)

                        // Галочка в правом нижнем углу (серая если текст пустой, оранжевая если есть текст)
                        Button(action: {
                            // Скрываем клавиатуру
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(content.isEmpty ? .gray : .orange)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                        }
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                    }
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $category) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }

                // Дополнительные поля в зависимости от категории
                switch category {
                case .characters:
                    Section("Информация о персонаже") {
                        TextField("Раса", text: $race)
                        TextField("Должность", text: $occupation)
                        TextField("Организация", text: $organization)
                        TextField("Возраст", text: $age)
                        ZStack(alignment: .bottomTrailing) {
                            TextField("Внешность", text: $appearance, axis: .vertical)
                                .lineLimit(2...4)

                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Image(systemName: "checkmark.circle")
                                    .font(.title2)
                                    .foregroundColor(appearance.isEmpty ? .gray : .orange)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                            }
                            .padding(.trailing, 8)
                            .padding(.bottom, 8)
                        }
                    }

                case .locations:
                    Section("Информация о локации") {
                        TextField("Тип локации", text: $locationType)
                        TextField("Население", text: $population)
                        TextField("Правительство", text: $government)
                        TextField("Климат", text: $climate)
                    }

                case .items:
                    Section("Информация о предмете") {
                        TextField("Тип предмета", text: $itemType)
                        TextField("Редкость", text: $rarity)
                        TextField("Стоимость", text: $value)
                    }

                case .quests:
                    Section("Информация о квесте") {
                        TextField("Тип квеста", text: $questType)
                        TextField("Статус", text: $status)
                        TextField("Награда", text: $reward)
                    }

                case .lore:
                    Section("Информация о лоре") {
                        TextField("Тип лора", text: $loreType)
                        TextField("Эпоха", text: $era)
                    }

                default:
                    EmptyView()
                }
            }
            .navigationTitle("Редактировать заметку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        var updatedNote = note
                        updatedNote.title = title
                        updatedNote.description = content
                        updatedNote.category = category
                        updatedNote.dateModified = Date()

                        // Обновление дополнительных полей
                        updatedNote.race = race.isEmpty ? nil : race
                        updatedNote.occupation = occupation.isEmpty ? nil : occupation
                        updatedNote.organization = organization.isEmpty ? nil : organization
                        updatedNote.age = age.isEmpty ? nil : age
                        updatedNote.appearance = appearance.isEmpty ? nil : appearance
                        updatedNote.locationType = locationType.isEmpty ? nil : locationType
                        updatedNote.population = population.isEmpty ? nil : population
                        updatedNote.government = government.isEmpty ? nil : government
                        updatedNote.climate = climate.isEmpty ? nil : climate
                        updatedNote.itemType = itemType.isEmpty ? nil : itemType
                        updatedNote.rarity = rarity.isEmpty ? nil : rarity
                        updatedNote.value = value.isEmpty ? nil : value
                        updatedNote.questType = questType.isEmpty ? nil : questType
                        updatedNote.status = status.isEmpty ? nil : status
                        updatedNote.reward = reward.isEmpty ? nil : reward
                        updatedNote.loreType = loreType.isEmpty ? nil : loreType
                        updatedNote.era = era.isEmpty ? nil : era

                        onSave(updatedNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NotesView()
}