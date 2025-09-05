import SwiftUI

struct QuotesView: View {
    @StateObject private var viewModel = QuotesViewModel()
    @State private var showCategoryManagement = false
    @ObservedObject private var dataService = DataService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and category management
            HStack {
                Text("Цитаты")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showCategoryManagement = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
            
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
            
            // Main Content Area
            if viewModel.availableCategories.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "quote.bubble",
                    title: "Нет цитат",
                    description: "Добавьте цитаты для вдохновения и мотивации",
                    actionTitle: "Добавить цитату",
                    action: {
                        // TODO: Add quote functionality
                    }
                )
                Spacer()
            } else {
                // Quote Card - большая карточка по центру
                if let quote = viewModel.currentQuote {
                    VStack(spacing: 16) {
                        // Цитата НАД изображением - на всю ширину
                        Text(quote.text)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        
                        // Tabaxi Image без фона - максимальный размер
                        RandomTabaxiImageView()
                            .frame(width: 200, height: 200)
                            .clipped()
                        
                        // Navigation buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.generateRandomQuote()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                    .frame(width: 44, height: 44)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                viewModel.generateRandomQuote()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                    .frame(width: 44, height: 44)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        
                        // Quote counter
                        Text("\(viewModel.quotesCount(for: viewModel.selectedCategory)) цитат в категории")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                }
            }
<<<<<<< Updated upstream
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        .onAppear {
            Task {
                await dataService.loadQuotes();
=======
            .onAppear {
                // Данные должны быть уже загружены синхронно при старте приложения
                // Если нужно, обновляем асинхронно
                Task {
                    await DataService.shared.loadQuotes();
                }
>>>>>>> Stashed changes
            }
        .sheet(isPresented: $showCategoryManagement) {
            CategoryManagementView()
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
    @StateObject private var viewModel = QuotesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("Категории цитат") {
                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        HStack {
                            Text(category)
                            Spacer()
                            Text("\(viewModel.quotesCount(for: category))")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Управление категориями")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
<<<<<<< Updated upstream
                    Button("Готово") {
=======
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
                .fontWeight(.semibold)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        }
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
>>>>>>> Stashed changes
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