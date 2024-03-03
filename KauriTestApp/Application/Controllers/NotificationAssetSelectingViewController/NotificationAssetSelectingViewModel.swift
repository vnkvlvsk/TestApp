import Foundation

final class NotificationAssetSelectingViewModel {
    
    // MARK: - Public Properties
    
    var dataSource: [AssetPriceModel] = []
    
    // MARK: - Public Methods
    
    func setupDataSource() async throws {
        let currenciesPriceModels = try await getCurrenciesPriceModels()
        
        dataSource = currenciesPriceModels
    }
    
    // MARK: - Private Methods
    
    private func getCurrenciesPriceModels() async throws -> [AssetPriceModel] {
        return try await NetworkService.shared.getCurrenciesToUSDTPrice()
    }
}
