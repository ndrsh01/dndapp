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
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        .onAppear {
            Task {
                await dataService.loadQuotes();
            }
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
                    Button("Готово") {
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