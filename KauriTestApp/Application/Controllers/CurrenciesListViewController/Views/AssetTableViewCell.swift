import UIKit
import SnapKit

final class AssetTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String = "AssetTableViewCell"
    
    // MARK: - Private Properties
    
    private let assetTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let assetPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func setupCell(model: AssetPriceModel) {
        assetTitleLabel.text = model.symbol
        
        if let lastUSDTPriceDouble = Double(model.price) {
            let formattedString = String(format: "%.2f", lastUSDTPriceDouble) + " USDT"
            assetPriceLabel.text = formattedString
        } else {
            assetPriceLabel.text = model.price + " USDT"
        }
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        addSubview(assetTitleLabel)
        addSubview(assetPriceLabel)
        
        assetTitleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(16)
            make.trailing.equalTo(assetPriceLabel.snp.leading).offset(8)
        }
        
        assetPriceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetTitleLabel.text = nil
        assetPriceLabel.text = nil
    }
}
