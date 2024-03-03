enum BlockchainType: String {
    case ethereum
    case binanceSmartChain
    case bitcoin
    
    var name: String {
        switch self {
        case .ethereum:
            return "Ethereum"
        case .binanceSmartChain:
            return "BNB Smart Chain"
        case .bitcoin:
            return "Bitcoin"
        }
    }
    
    var symbol: String {
        switch self {
        case .ethereum:
            return "ETH"
        case .binanceSmartChain:
            return "BNB"
        case .bitcoin:
            return "BTC"
        }
    }
}
