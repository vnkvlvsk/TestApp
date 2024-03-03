import Foundation

final class NetworkService {
    
    static let shared: NetworkService = NetworkService.init()
    
    private init() {}
    
    func getCurrenciesToUSDTPrice() async throws -> [AssetPriceModel] {
        let apiUrl = "https://api.binance.com/api/v3/ticker/price"
        
        guard let url = URL(string: apiUrl) else {
            throw NetworkServiceError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw NetworkServiceError.badID }
        let models: [AssetPriceModel] = try JSONDecoder().decode([AssetPriceModel].self, from: data)
        let filteredModels = models.filter({ String($0.symbol.suffix(4)) == "USDT" })
        for model in filteredModels {
            model.symbol = String(model.symbol.dropLast(4))
            if let doublePrice = Double(model.price) {
                let formattedNumber = String(format: "%.2f", doublePrice)
                model.price = formattedNumber
            }
        }
        return filteredModels
    }
}

extension NetworkService {
    enum NetworkServiceError: Error {
        case badURL
        case badID
    }
}
