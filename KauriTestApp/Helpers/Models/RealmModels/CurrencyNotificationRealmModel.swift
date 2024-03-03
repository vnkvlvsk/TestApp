import Foundation
import RealmSwift

@objcMembers
class CurrencyNotificationRealmModel: Object {
    
    dynamic var id: Int
    dynamic var name: String
    dynamic var price: Double
    dynamic var isNotificationOn: Bool
    dynamic var lastSentAt: Date?
    
    override class func primaryKey() -> String? { "id" }
    
    internal init(id: Int = Int(), name: String, price: Double, isNotificationOn: Bool, lastSentAt: Date?) {
        self.id = id
        self.name = name
        self.price = price
        self.isNotificationOn = isNotificationOn
        self.lastSentAt = lastSentAt
        super.init()
    }
    
    override init() {
        id = Int()
        name = String()
        price = Double()
        isNotificationOn = true
        lastSentAt = Date()
    }
}
