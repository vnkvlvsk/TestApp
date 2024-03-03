import Foundation
import RealmSwift

final class NotificationListViewModel {
    
    // MARK: - Public Properties
    
    var dataSource: [CurrencyNotificationRealmModel] = []
    
    // MARK: - Public Methods
    
    func setupDataSource() throws {
        let currencyNotificationRealmModels = try getCurrencyNotificationRealmModels()
        
        dataSource = currencyNotificationRealmModels
    }
    
    // MARK: - Private Methods
    
    private func getCurrencyNotificationRealmModels() throws -> [CurrencyNotificationRealmModel] {
        let realm = try Realm()
        return Array(realm.objects(CurrencyNotificationRealmModel.self))
    }
}
