import UIKit

final class NotificationCurrencyPriceEnteringTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String = "NotificationCurrencyPriceEnteringTableViewCell"
    
    // MARK: - Closures

    var didChangeText: ((String) -> Void)?
    
    // MARK: - Private Properties
    
    private let containerBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.text = "Observing price(USDT):"
        return label
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter price"
        textField.keyboardType = .decimalPad
        textField.delegate = self
        return textField
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
    
    func setupCell(assetName: String) {
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerBackgroundView)
        containerBackgroundView.addSubview(titleLabel)
        containerBackgroundView.addSubview(priceTextField)
        
        containerBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.bottom.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        priceTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.trailing.equalToSuperview().inset(16)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        priceTextField.text = nil
    }
}

extension NotificationCurrencyPriceEnteringTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        didChangeText?(newText)
        return true
    }
}
