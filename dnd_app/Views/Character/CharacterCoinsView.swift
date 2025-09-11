import SwiftUI
import Foundation

struct CharacterCoinsView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок с общей информацией
                coinsHeader
                
                // Список монет
                coinsList
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Монеты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingExchange) {
            CoinExchangeView(character: $character, onCharacterUpdate: onCharacterUpdate)
        }
    }
    
    @State private var showingExchange = false
    
    private var coinsHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Общее богатство")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(totalWealthInGold) медных монет")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Эквивалент")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(totalWealthInCopper) медных")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Индикатор богатства и кнопка обмена
            HStack {
                Text("Богатство")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(wealthLevel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(wealthColor)

                Button(action: {
                    showingExchange = true
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var coinsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(CoinType.allCases, id: \.self) { coinType in
                    coinCard(coinType: coinType)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func coinCard(coinType: CoinType) -> some View {
        HStack(spacing: 12) {
            // Иконка монеты
            Image(systemName: coinType.icon)
                .font(.title2)
                .foregroundColor(coinType.color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coinType.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(coinType.valueInGold) медных за штуку")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // Поле ввода
                TextField("0", value: Binding(
                    get: { character.value(for: coinType) },
                    set: { setCoins(coinType: coinType, value: $0) }
                ), format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Готово") {
                            hideKeyboard()
                        }
                    }
                }
                
                // Кнопка увеличения
                Button(action: {
                    increaseCoins(coinType: coinType)
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    
    private var totalWealthInGold: Int {
        let copper = character.copperPieces * CoinType.copper.valueInGold
        let silver = character.silverPieces * CoinType.silver.valueInGold
        let electrum = character.electrumPieces * CoinType.electrum.valueInGold
        let gold = character.goldPieces * CoinType.gold.valueInGold
        let platinum = character.platinumPieces * CoinType.platinum.valueInGold
        
        return copper + silver + electrum + gold + platinum
    }
    
    private var totalWealthInCopper: Int {
        let copper = character.copperPieces
        let silver = character.silverPieces * 10
        let electrum = character.electrumPieces * 50
        let gold = character.goldPieces * 100
        let platinum = character.platinumPieces * 1000
        
        return copper + silver + electrum + gold + platinum
    }
    
    private var wealthLevel: String {
        let copper = totalWealthInGold
        
        switch copper {
        case 0..<1000:
            return "Бедняк"
        case 1000..<10000:
            return "Скромный"
        case 10000..<100000:
            return "Зажиточный"
        case 100000..<1000000:
            return "Богатый"
        default:
            return "Очень богатый"
        }
    }
    
    private var wealthColor: Color {
        let copper = totalWealthInGold
        
        switch copper {
        case 0..<1000:
            return .red
        case 1000..<10000:
            return .orange
        case 10000..<100000:
            return .yellow
        case 100000..<1000000:
            return .green
        default:
            return .purple
        }
    }
    
    // MARK: - Helper Functions
    
    private func increaseCoins(coinType: CoinType) {
        switch coinType {
        case .copper:
            character.copperPieces += 1
        case .silver:
            character.silverPieces += 1
        case .electrum:
            character.electrumPieces += 1
        case .gold:
            character.goldPieces += 1
        case .platinum:
            character.platinumPieces += 1
        }
        
        character.dateModified = Date()
        onCharacterUpdate?(character)
    }
    
    private func decreaseCoins(coinType: CoinType) {
        switch coinType {
        case .copper:
            character.copperPieces = max(0, character.copperPieces - 1)
        case .silver:
            character.silverPieces = max(0, character.silverPieces - 1)
        case .electrum:
            character.electrumPieces = max(0, character.electrumPieces - 1)
        case .gold:
            character.goldPieces = max(0, character.goldPieces - 1)
        case .platinum:
            character.platinumPieces = max(0, character.platinumPieces - 1)
        }
        
        character.dateModified = Date()
        onCharacterUpdate?(character)
    }
    
    private func setCoins(coinType: CoinType, value: Int) {
        let clampedValue = max(0, value)
        
        switch coinType {
        case .copper:
            character.copperPieces = clampedValue
        case .silver:
            character.silverPieces = clampedValue
        case .electrum:
            character.electrumPieces = clampedValue
        case .gold:
            character.goldPieces = clampedValue
        case .platinum:
            character.platinumPieces = clampedValue
        }
        
        character.dateModified = Date()
        onCharacterUpdate?(character)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

enum CoinType: String, CaseIterable {
    case copper = "Медные монеты"
    case silver = "Серебряные монеты"
    case electrum = "Электрумовые монеты"
    case gold = "Золотые монеты"
    case platinum = "Платиновые монеты"
    
    var icon: String {
        switch self {
        case .copper:
            return "circle.fill"
        case .silver:
            return "circle.fill"
        case .electrum:
            return "circle.fill"
        case .gold:
            return "circle.fill"
        case .platinum:
            return "circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .copper:
            return .orange
        case .silver:
            return .gray
        case .electrum:
            return .yellow
        case .gold:
            return .yellow
        case .platinum:
            return .blue
        }
    }
    
    var valueInGold: Int {
        switch self {
        case .copper:
            return 1 // 100 медных = 1 золотая
        case .silver:
            return 10 // 10 серебряных = 1 золотая
        case .electrum:
            return 2 // 2 электрумовые = 1 золотая
        case .gold:
            return 100 // 1 золотая = 100 медных
        case .platinum:
            return 1000 // 1 платиновая = 1000 медных
        }
    }
}

extension Character {
    func value(for coinType: CoinType) -> Int {
        switch coinType {
        case .copper:
            return copperPieces
        case .silver:
            return silverPieces
        case .electrum:
            return electrumPieces
        case .gold:
            return goldPieces
        case .platinum:
            return platinumPieces
        }
    }
}

struct CoinExchangeView: View {
    @Binding var character: Character
    let onCharacterUpdate: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    @State private var fromCoinType: CoinType = .gold
    @State private var toCoinType: CoinType = .silver
    @State private var amount: Int = 1
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Обмен монет")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Откуда
                VStack(alignment: .leading, spacing: 8) {
                    Text("Отдаете")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Откуда", selection: $fromCoinType) {
                        ForEach(CoinType.allCases, id: \.self) { coinType in
                            HStack {
                                Image(systemName: coinType.icon)
                                    .foregroundColor(coinType.color)
                                Text(coinType.rawValue)
                            }
                            .tag(coinType)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Количество
                VStack(alignment: .leading, spacing: 8) {
                    Text("Количество")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Stepper("\(amount)", value: $amount, in: 1...max(1, character.value(for: fromCoinType)))
                }
                
                // Куда
                VStack(alignment: .leading, spacing: 8) {
                    Text("Получаете")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Куда", selection: $toCoinType) {
                        ForEach(CoinType.allCases, id: \.self) { coinType in
                            HStack {
                                Image(systemName: coinType.icon)
                                    .foregroundColor(coinType.color)
                                Text(coinType.rawValue)
                            }
                            .tag(coinType)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Результат обмена
                if fromCoinType != toCoinType && amount > 0 {
                    VStack(spacing: 8) {
                        Text("Результат обмена")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(amount) \(fromCoinType.rawValue) = \(exchangeResult) \(toCoinType.rawValue)")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Обменять") {
                        performExchange()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(amount <= 0 || amount > character.value(for: fromCoinType) || fromCoinType == toCoinType)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Обмен")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var exchangeResult: Int {
        let fromValue = fromCoinType.valueInGold
        let toValue = toCoinType.valueInGold
        let totalValue = amount * fromValue
        return totalValue / toValue
    }
    
    private func performExchange() {
        // Проверяем, что у нас достаточно монет
        guard amount > 0 && amount <= character.value(for: fromCoinType) else {
            return
        }
        
        let resultAmount = exchangeResult
        guard resultAmount > 0 else {
            return
        }
        
        // Уменьшаем исходные монеты
        switch fromCoinType {
        case .copper:
            character.copperPieces = max(0, character.copperPieces - amount)
        case .silver:
            character.silverPieces = max(0, character.silverPieces - amount)
        case .electrum:
            character.electrumPieces = max(0, character.electrumPieces - amount)
        case .gold:
            character.goldPieces = max(0, character.goldPieces - amount)
        case .platinum:
            character.platinumPieces = max(0, character.platinumPieces - amount)
        }
        
        // Увеличиваем целевые монеты
        switch toCoinType {
        case .copper:
            character.copperPieces += resultAmount
        case .silver:
            character.silverPieces += resultAmount
        case .electrum:
            character.electrumPieces += resultAmount
        case .gold:
            character.goldPieces += resultAmount
        case .platinum:
            character.platinumPieces += resultAmount
        }
        
        character.dateModified = Date()
        onCharacterUpdate?(character)
        dismiss()
    }
}

#Preview {
    CharacterCoinsView(
        character: .constant(Character(
            name: "Тестовый персонаж",
            race: "Человек",
            characterClass: "Волшебник",
            background: "Ученый",
            alignment: "Нейтральный"
        )),
        onCharacterUpdate: nil
    )
}
