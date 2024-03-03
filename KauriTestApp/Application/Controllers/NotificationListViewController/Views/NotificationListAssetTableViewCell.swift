import UIKit

final class NotificationListAssetTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String = "NotificationListAssetTableViewCell"
    
    // MARK: - Closures

    var onActivationSwitchToggle: ((Bool) -> Void)?
    
    // MARK: - Private Properties
    
    private let containerBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private let assetNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var activationSwitch: UISwitch = {
        let activationSwitch = UISwitch()
        activationSwitch.addTarget(self, action: #selector(activationSwitchToggle), for: .valueChanged)
        return activationSwitch
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
    
    func setupCell(model: CurrencyNotificationRealmModel) {
        assetNameLabel.text = model.name
        priceLabel.text = String(model.price) + " USDT"
        activationSwitch.isOn = model.isNotificationOn
    }
    
    // MARK: - Private methods
    
    @objc private func activationSwitchToggle() {
        onActivationSwitchToggle?(activationSwitch.isOn)
    }
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerBackgroundView)
        containerBackgroundView.addSubview(assetNameLabel)
        containerBackgroundView.addSubview(priceLabel)
        containerBackgroundView.addSubview(activationSwitch)
        
        containerBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.bottom.trailing.equalToSuperview().inset(16)
        }
        
        assetNameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(assetNameLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(16)
            make.trailing.equalTo(activationSwitch.snp.leading).offset(8)
        }
        
        activationSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(priceLabel)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetNameLabel.text = nil
        priceLabel.text = nil
    }
}
