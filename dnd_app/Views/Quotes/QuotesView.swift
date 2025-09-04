import SwiftUI

struct QuotesView: View {
    @StateObject private var viewModel = QuotesViewModel()
    @State private var showCategoryManagement = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Selection - горизонтальный скролл вверху
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            Button(category) {
                                viewModel.selectCategory(category)
                            }
                            .font(.subheadline)
                            .foregroundColor(viewModel.selectedCategory == category ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedCategory == category ? Color.orange : Color.gray.opacity(0.3))
                            .cornerRadius(20)
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
        }
        .sheet(isPresented: $showCategoryManagement) {
            CategoryManagementView(viewModel: viewModel)
        }
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
                            .contextMenu(
                                onEdit: {
                                    editingCategoryName = category
                                    showEditCategory = true
                                },
                                onDelete: {
                                    viewModel.deleteCategory(category)
                                },
                                onDuplicate: {
                                    viewModel.duplicateCategory(category)
                                }
                            )
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
                    .zIndex(9998)
                
                // Вырезаем область элемента из затемнения
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: globalContextMenu.highlightedElementFrame.width, 
                           height: globalContextMenu.highlightedElementFrame.height)
                    .position(x: globalContextMenu.highlightedElementFrame.midX, 
                             y: globalContextMenu.highlightedElementFrame.midY)
                    .zIndex(9999)
                    .blendMode(.destinationOut)
                    
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
                        .zIndex(10000)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        showAddCategory = true
                    }) {
                        Image(systemName: "plus")
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
                originalName: editingCategoryName,
                onSave: { newName in
                    viewModel.renameCategory(from: editingCategoryName, to: newName)
                }
            )
        }
        .sheet(isPresented: $showQuotesList) {
            QuotesListView(
                category: selectedCategoryForQuotes,
                viewModel: viewModel
            )
        }
    }
}

struct CategoryCardView: View {
    let category: String
    let quoteCount: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка слева
            Image(systemName: "quote.bubble")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.orange)
                .clipShape(Circle())
            
            // Текст по центру
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(quoteCount) цитат")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Стрелка справа
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Add Category View
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

// MARK: - Edit Category View
struct EditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categoryName: String
    
    let originalName: String
    let onSave: (String) -> Void
    
    init(originalName: String, onSave: @escaping (String) -> Void) {
        self.originalName = originalName
        self.onSave = onSave
        self._categoryName = State(initialValue: originalName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Редактировать категорию") {
                    TextField("Название категории", text: $categoryName)
                }
            }
            .navigationTitle("Редактировать")
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
                    .disabled(categoryName.isEmpty || categoryName == originalName)
                }
            }
        }
    }
}

// MARK: - Quotes List View
struct QuotesListView: View {
    @Environment(\.dismiss) private var dismiss
    let category: String
    @ObservedObject var viewModel: QuotesViewModel
    @ObservedObject private var dataService = DataService.shared
    @State private var showAddQuote = false
    @State private var showEditQuote = false
    @State private var editingQuote: Quote?
    @StateObject private var globalContextMenu = GlobalContextMenuManager.shared
    
    var quotes: [Quote] {
        dataService.quotes?.quotes(for: category) ?? []
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if quotes.isEmpty {
                    EmptyStateView(
                        icon: "quote.bubble",
                        title: "Нет цитат",
                        description: "Добавьте первую цитату в эту категорию",
                        actionTitle: "Добавить цитату",
                        action: {
                            showAddQuote = true
                        }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(quotes) { quote in
                                QuoteCardView(quote: quote)
                                    .contextMenu(
                                        onEdit: {
                                            editingQuote = quote
                                            showEditQuote = true
                                        },
                                        onDelete: {
                                            viewModel.deleteQuote(quote)
                                        },
                                        onDuplicate: {
                                            viewModel.duplicateQuote(quote)
                                        }
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                }
                
                // Глобальное контекстное меню поверх всего
                if globalContextMenu.showContextMenu {
                                    // Затемненный фон
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        globalContextMenu.hideMenu()
                    }
                    .zIndex(9998)
                
                // Вырезаем область элемента из затемнения
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: globalContextMenu.highlightedElementFrame.width, 
                           height: globalContextMenu.highlightedElementFrame.height)
                    .position(x: globalContextMenu.highlightedElementFrame.midX, 
                             y: globalContextMenu.highlightedElementFrame.midY)
                    .zIndex(9999)
                    .blendMode(.destinationOut)
                    
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
                        .zIndex(10000)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle(category)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Назад") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddQuote = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear {
            // Инициализируем данные при открытии
            print("QuotesListView appeared for category: \(category)")
            Task {
                await dataService.loadQuotes()
                print("Quotes loaded, categories: \(dataService.quotes?.categoryNames ?? [])")
            }
        }
        .sheet(isPresented: $showAddQuote) {
            AddQuoteView(category: category) { quote in
                viewModel.addQuote(quote)
            }
        }
        .sheet(isPresented: $showEditQuote) {
            if let quote = editingQuote {
                EditQuoteView(quote: quote) { updatedQuote in
                    viewModel.updateQuote(from: quote, to: updatedQuote)
                }
            }
        }
    }
}

// MARK: - Quote Card View
struct QuoteCardView: View {
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Add Quote View
struct AddQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    let category: String
    @State private var quoteText = ""
    
    let onSave: (Quote) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Новая цитата") {
                    TextField("Текст цитаты", text: $quoteText, axis: .vertical)
                        .lineLimit(3...10)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let quote = Quote(text: quoteText, category: category)
                        onSave(quote)
                        dismiss()
                    }
                    .disabled(quoteText.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Quote View
struct EditQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quoteText: String
    
    let quote: Quote
    let onSave: (Quote) -> Void
    
    init(quote: Quote, onSave: @escaping (Quote) -> Void) {
        self.quote = quote
        self.onSave = onSave
        self._quoteText = State(initialValue: quote.text)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Редактировать цитату") {
                    TextField("Текст цитаты", text: $quoteText, axis: .vertical)
                        .lineLimit(3...10)
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let updatedQuote = Quote(text: quoteText, category: quote.category)
                        onSave(updatedQuote)
                        dismiss()
                    }
                    .disabled(quoteText.isEmpty || quoteText == quote.text)
                }
            }
        }
    }
}

#Preview {
    QuotesView()
}

