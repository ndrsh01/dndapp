import Foundation

struct Quote: Codable, Identifiable {
    let id: UUID
    let text: String
    let category: String
    
    init(text: String, category: String) {
        self.id = UUID()
        self.text = text
        self.category = category
    }
}

struct QuotesData: Codable {
    let categories: [String: [String]]
    
    var allQuotes: [Quote] {
        categories.flatMap { category, quotes in
            quotes.map { Quote(text: $0, category: category) }
        }
    }
    
    func quotes(for category: String) -> [Quote] {
        guard let categoryQuotes = categories[category] else { return [] }
        return categoryQuotes.map { Quote(text: $0, category: category) }
    }
    
    var categoryNames: [String] {
        Array(categories.keys).sorted()
    }
    
    func randomQuote(from category: String) -> Quote? {
        let categoryQuotes = quotes(for: category)
        return categoryQuotes.randomElement()
    }
}
