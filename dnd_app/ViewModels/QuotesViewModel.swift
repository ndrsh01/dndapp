import Foundation
import Combine

class QuotesViewModel: ObservableObject {
    @Published var selectedCategory: String = "общение"
    @Published var currentQuote: Quote?
    @Published var currentImage: String = "tabaxi_pose1"
    @Published var showCategoryManagement = false
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSelectedCategory()

        // Подписываемся на изменения данных
        dataService.$quotes
            .sink { [weak self] quotes in
                if let quotes = quotes, !quotes.categories.isEmpty {
                    self?.generateRandomQuote()
                }
            }
            .store(in: &cancellables)

        // Генерируем цитату сразу, если данные уже доступны
        if dataService.quotes != nil && !availableCategories.isEmpty {
            generateRandomQuote()
        }

        // Отладочная информация
        print("QuotesViewModel init - selectedCategory: \(selectedCategory)")
        print("QuotesViewModel init - availableCategories: \(availableCategories)")
        print("QuotesViewModel init - currentQuote: \(currentQuote?.text ?? "nil")")
    }
    
    var availableCategories: [String] {
        return dataService.quotes?.categoryNames ?? []
    }
    
    func quotesCount(for category: String) -> Int {
        return dataService.quotes?.quotes(for: category).count ?? 0
    }
    
    func selectCategory(_ category: String) {
        print("QuotesViewModel selectCategory - category: \(category)")
        selectedCategory = category
        dataService.setSelectedQuoteCategory(category)
        generateRandomQuote()
        print("QuotesViewModel selectCategory - new quote: \(currentQuote?.text ?? "nil")")
    }
    
    func generateRandomQuote() {
        currentQuote = dataService.getRandomQuote(from: selectedCategory)
        currentImage = dataService.getRandomTabaxiImage()
    }
    
    private func loadSelectedCategory() {
        selectedCategory = dataService.getSelectedQuoteCategory()
    }
    
    func showCategoryManagementView() {
        showCategoryManagement = true
    }
    
    // MARK: - Category Management
    func addCategory(_ name: String) {
        dataService.addQuoteCategory(name)
    }
    
    func deleteCategory(_ name: String) {
        dataService.deleteQuoteCategory(name)
        // Если удаляемая категория была выбрана, переключаемся на первую доступную
        if selectedCategory == name {
            if let firstCategory = availableCategories.first {
                selectCategory(firstCategory)
            }
        }
    }
    
    func renameCategory(from oldName: String, to newName: String) {
        dataService.renameQuoteCategory(from: oldName, to: newName)
        // Если переименованная категория была выбрана, обновляем выбор
        if selectedCategory == oldName {
            selectedCategory = newName
        }
    }
    
    func duplicateCategory(_ name: String) {
        let newName = "\(name) (копия)"
        dataService.duplicateQuoteCategory(from: name, to: newName)
    }
    
    // MARK: - Quote Management
    func addQuote(_ quote: Quote) {
        dataService.addQuote(quote)
    }
    
    func updateQuote(_ quote: Quote) {
        dataService.updateQuote(quote)
    }
    
    func updateQuote(from oldQuote: Quote, to newQuote: Quote) {
        dataService.updateQuote(from: oldQuote, to: newQuote)
    }
    
    func deleteQuote(_ quote: Quote) {
        dataService.deleteQuote(quote)
    }
    
    func duplicateQuote(_ quote: Quote) {
        dataService.duplicateQuote(quote)
    }
}
