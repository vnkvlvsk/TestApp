import UIKit

final class NotificationCurrencySelectTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String = "NotificationCurrencySelectTableViewCell"
    
    // MARK: - Closures

    var didSelectCell: (() -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var containerBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.systemGray4.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCell(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.text = "Observing asset:"
        return label
    }()
    
    private let assetNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(systemName: "arrow.right")
        imageView.tintColor = .systemGray4
        return imageView
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
    
    func setupCell(assetName: String?) {
        assetNameLabel.text = assetName ?? "Tap to select"
    }
    
    // MARK: - Private methods
    
    @objc private func didSelectCell(_ sender: UITapGestureRecognizer) {
        didSelectCell?()
    }
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerBackgroundView)
        containerBackgroundView.addSubview(titleLabel)
        containerBackgroundView.addSubview(assetNameLabel)
        containerBackgroundView.addSubview(arrowImageView)
        
        containerBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.bottom.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        assetNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(16)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(8)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(assetNameLabel)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetNameLabel.text = nil
    }
}
