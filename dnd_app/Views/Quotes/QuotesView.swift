import SwiftUI

struct QuotesView: View {
    @StateObject private var viewModel = QuotesViewModel()
    @State private var showCategoryManagement = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Selection - как кнопка Случайная цитата
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            Button(action: {
                                viewModel.selectCategory(category)
                            }) {
                                Text(category)
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(viewModel.selectedCategory == category ? Color.orange.opacity(0.8) : Color.gray.opacity(0.4))
                                    .cornerRadius(20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                
                Spacer()
                
                // Quote Card - большая карточка по центру
                if let quote = viewModel.currentQuote {
                    VStack(spacing: 16) {
                        // Цитата НАД изображением - меньше ширина
                        Text(quote.text)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .frame(width: 280)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        
                        // Tabaxi Image без фона - максимальный размер
                        RandomTabaxiImageView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .id(viewModel.currentImage)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Нет цитат")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("Выберите категорию для отображения цитат")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }
                
                Spacer()
                
                // Random Quote Button - кнопка снизу, больше и выше
                Button(action: {
                    viewModel.generateRandomQuote()
                }) {
                    Text("Случайная цитата")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(30)
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Цитаты")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCategoryManagement = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.orange)
                    }
                }
            }
            .onAppear {
                Task {
                    await DataService.shared.loadQuotes();
            }
        }
        .sheet(isPresented: $showCategoryManagement) {
            CategoryManagementView(viewModel: viewModel)
        }
        }
    }
}

struct RandomTabaxiImageView: View {
    @State private var currentImageName: String = "tabaxi_pose1"
    
    var body: some View {
        TabaxiImageView(imageName: currentImageName)
            .onAppear {
                generateRandomImage()
            }
    }
    
    private func generateRandomImage() {
        currentImageName = TabaxiImages.getRandomImageName()
    }
}

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuotesViewModel
    @State private var showAddCategory = false
    @State private var showEditCategory = false
    @State private var editingCategoryName = ""
    @State private var showQuotesList = false
    @State private var selectedCategoryForQuotes = ""
    @StateObject private var globalContextMenu = GlobalContextMenuManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Список категорий как на изображении
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            CategoryCardView(
                                category: category,
                                quoteCount: viewModel.quotesCount(for: category),
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                // По клику на категорию - открываем список цитат этой категории
                                selectedCategoryForQuotes = category
                                showQuotesList = true
                            }
                            .contextMenu {
                                Button(action: {
                                    editingCategoryName = category
                                    showEditCategory = true
                                }) {
                                    Label("Редактировать", systemImage: "pencil")
                                }

                                Button(action: {
                                    viewModel.deleteCategory(category)
                                }) {
                                    Label("Удалить", systemImage: "trash")
                                        .foregroundColor(.red)
                                }

                                Button(action: {
                                    viewModel.duplicateCategory(category)
                                }) {
                                    Label("Дублировать", systemImage: "doc.on.doc")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // Глобальное контекстное меню поверх всего
                if globalContextMenu.showContextMenu {
                                    // Затемненный фон
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        globalContextMenu.hideMenu()
                    }
                    .zIndex(999998)
                
                    // Подсветка элемента
                Rectangle()
                        .fill(Color.blue.opacity(0.3))
                    .frame(width: globalContextMenu.highlightedElementFrame.width,
                           height: globalContextMenu.highlightedElementFrame.height)
                    .position(x: globalContextMenu.highlightedElementFrame.midX,
                             y: globalContextMenu.highlightedElementFrame.midY)
                    .zIndex(999999)
                    
                    // Само меню под элементом
                    if let onEdit = globalContextMenu.onEdit,
                       let onDelete = globalContextMenu.onDelete,
                       let onDuplicate = globalContextMenu.onDuplicate {
                        ContextMenuView(
                            onEdit: {
                                onEdit()
                                globalContextMenu.hideMenu()
                            },
                            onDelete: {
                                onDelete()
                                globalContextMenu.hideMenu()
                            },
                            onDuplicate: {
                                onDuplicate()
                                globalContextMenu.hideMenu()
                            }
                        )
                        .position(
                            x: globalContextMenu.highlightedElementFrame.midX,
                            y: globalContextMenu.highlightedElementFrame.maxY + 10
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: globalContextMenu.showContextMenu)
                        .zIndex(1000000)
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Категории цитат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Plus button tapped for adding category")
                        showAddCategory = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView { categoryName in
                viewModel.addCategory(categoryName)
            }
        }
        .sheet(isPresented: $showEditCategory) {
            EditCategoryView(
                oldName: editingCategoryName,
                onSave: { newName in
                    viewModel.renameCategory(from: editingCategoryName, to: newName)
                }
            )
        }
        .sheet(isPresented: $showQuotesList) {
            if !selectedCategoryForQuotes.isEmpty {
            QuotesListView(
                category: selectedCategoryForQuotes,
                viewModel: viewModel
            )
            }
        }
    }
}

struct CategoryCardView: View {
    let category: String
    let quoteCount: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(quoteCount) цитат")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categoryName = ""
    
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Новая категория") {
                    TextField("Название категории", text: $categoryName)
                }
            }
            .navigationTitle("Добавить категорию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave(categoryName)
                        dismiss()
                    }
                    .disabled(categoryName.isEmpty)
                }
            }
        }
    }
}

struct EditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categoryName: String
    
    let oldName: String
    let onSave: (String) -> Void
    
    init(oldName: String, onSave: @escaping (String) -> Void) {
        self.oldName = oldName
        self.onSave = onSave
        self._categoryName = State(initialValue: oldName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Редактировать категорию") {
                    TextField("Название категории", text: $categoryName)
                }
            }
            .navigationTitle("Редактировать категорию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave(categoryName)
                        dismiss()
                    }
                    .disabled(categoryName.isEmpty)
                }
            }
        }
    }
}

struct QuotesListView: View {
    @Environment(\.dismiss) private var dismiss
    let category: String
    @ObservedObject var viewModel: QuotesViewModel
    @State private var isLoading = true
    @State private var showAddQuote = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        let quotes = viewModel.quotes(for: category)
                        if !quotes.isEmpty {
                            ForEach(quotes, id: \.id) { quote in
                                QuoteCardView(quote: quote)
                                    .contextMenu {
                                        Button(action: {
                                            // TODO: Реализовать редактирование цитаты
                                            print("Edit quote: \(quote.text)")
                                        }) {
                                            Label("Редактировать", systemImage: "pencil")
                                        }

                                        Button(action: {
                                            viewModel.deleteQuote(quote)
                                        }) {
                                            Label("Удалить", systemImage: "trash")
                                                .foregroundColor(.red)
                                        }

                                        Button(action: {
                                            viewModel.duplicateQuote(quote)
                                        }) {
                                            Label("Дублировать", systemImage: "doc.on.doc")
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .background(Color(red: 0.98, green: 0.97, blue: 0.95))
                .allowsHitTesting(true)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { _ in }
                        .onEnded { _ in }
                )
                
                // Анимация загрузки
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))

                        Text("Загрузка цитат...")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.9))
                }

                // Пустое состояние на весь экран
                if viewModel.quotes(for: category).isEmpty && !isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("Нет цитат в категории")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)

                        Text("В категории \"\(category)\" пока нет цитат")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.98, green: 0.97, blue: 0.95))
                    .onAppear {
                        print("Showing empty state for category: \(category)")
                    }
                }
                
            }
            .navigationTitle(category)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Plus button tapped for category: \(category)")
                        showAddQuote = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showAddQuote) {
                AddQuoteView(category: category, viewModel: viewModel)
            }
            .onAppear {
                // Принудительно обновляем данные при появлении экрана
                print("QuotesListView appeared for category: \(category)")
                let quotesCount = viewModel.quotes(for: category).count
                print("Quotes count: \(quotesCount)")
                print("isLoading before: \(isLoading)")

                // Если цитат нет, показываем сразу
                if quotesCount == 0 {
                    isLoading = false
                    print("No quotes found, showing empty state immediately")
                } else {
                    // Имитируем загрузку только если есть цитаты
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isLoading = false
                        print("Loading completed, showing quotes")
                    }
                }
            }
        }
    }
}

struct QuoteCardView: View {
    let quote: Quote
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    let onDuplicate: (() -> Void)?
    
    init(quote: Quote, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil, onDuplicate: (() -> Void)? = nil) {
        self.quote = quote
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onDuplicate = onDuplicate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quote.text)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .contextMenu(
            onEdit: onEdit ?? {},
            onDelete: onDelete ?? {},
            onDuplicate: onDuplicate ?? {}
        )
    }
}

struct AddQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    let category: String
    @ObservedObject var viewModel: QuotesViewModel

    @State private var quoteText = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Новая цитата") {
                    ZStack(alignment: .topLeading) {
                        if quoteText.isEmpty {
                            Text("Введите текст цитаты...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }

                        TextEditor(text: $quoteText)
                            .frame(minHeight: 150)
                            .foregroundColor(.primary)
                    }
                }

                Section {
                    Button(action: {
                        if !quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let newQuote = Quote(
                                text: quoteText.trimmingCharacters(in: .whitespacesAndNewlines),
                                category: category
                            )
                            viewModel.addQuote(newQuote)
                            dismiss()
                        }
                    }) {
                        Text("Добавить цитату")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .disabled(quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .listRowBackground(
                        quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                        Color.gray : Color.orange
                    )
                }
            }
            .navigationTitle("Добавить цитату")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    QuotesView()
}
