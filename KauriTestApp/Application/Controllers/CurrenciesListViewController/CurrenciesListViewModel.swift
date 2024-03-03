import Foundation
import RealmSwift

final class CurrenciesListViewModel {
    
    // MARK: - Public Properties
    
    var dataSource: [AssetPriceModel] = []
    var isCurrenciesPriceDownloading = false
    
    // MARK: - Public Methods
    
    func setupDataSource() async throws {
        let currenciesPriceModels = try await getCurrenciesPriceModels()
        
        dataSource = currenciesPriceModels
    }
    
    func sendNotifications() async throws -> [Int] {
        return try await checkIfNeedToSendNotification()
    }
    
    // MARK: - Private Methods
    
    private func checkIfNeedToSendNotification() async throws -> [Int] {
        let models = try await getCurrencyNotificationRealmModels()
        
        return models.filter({ notificationModel in
            guard notificationModel.isNotificationOn else { return false }
            guard let dataSourceModel = self.dataSource.first(where: { $0.symbol == notificationModel.name }) else { return false }
            guard let doublePrice = Double(dataSourceModel.price) else { return false }
            guard let oneMinutesAgo = Calendar.current.date(byAdding: .minute, value: -1, to: Date()) else { return false }
            if let lastSentAt = notificationModel.lastSentAt {
                guard lastSentAt <= oneMinutesAgo else { return false }
            }
            return doublePrice > notificationModel.price
        }).map { $0.id }
    }
    
    private func getCurrenciesPriceModels() async throws -> [AssetPriceModel] {
        return try await NetworkService.shared.getCurrenciesToUSDTPrice()
    }
    
    private func getCurrencyNotificationRealmModels() async throws -> [CurrencyNotificationRealmModel] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let realm = try Realm()
                let objects = Array(realm.objects(CurrencyNotificationRealmModel.self))
                continuation.resume(returning: objects)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
