import Foundation

final class NotificationAddingViewModel {
    
    // MARK: - Public properties
    
    let storage = Storage()
    
    lazy var tableTemplate: [TableItem] = {
        return [.assetSelection, .priceEntering]
    }()
    
    var isSubmitButtonEnabled: Bool {
        (storage.assetName != nil && storage.price != nil) ? true : false
    }
}

extension NotificationAddingViewModel {
    enum TableItem {
        case assetSelection
        case priceEntering
    }
    
    class Storage {
        var assetName: String?
        var price: Double?
    }
}
