import UIKit
import RealmSwift

final class NotificationAddingViewController: UIViewController {
    
    // MARK: - Closures

    var notificationDidAdded: (() -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.alwaysBounceVertical = true
        tableView.register(NotificationCurrencySelectTableViewCell.self, forCellReuseIdentifier: NotificationCurrencySelectTableViewCell.reuseIdentifier)
        tableView.register(NotificationCurrencyPriceEnteringTableViewCell.self, forCellReuseIdentifier: NotificationCurrencyPriceEnteringTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 12
        button.setTitle("Submit", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: NotificationAddingViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: NotificationAddingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        hideKeyboardOnTap()
        updateButtonState()
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Add notification"
        
        view.addSubview(tableView)
        view.addSubview(submitButton)
        tableView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(submitButton.snp.top)
        }
        
        submitButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    @objc private func submitButtonPressed() {
        do {
            guard let name = viewModel.storage.assetName, let price = viewModel.storage.price else {
                showAlertError(errorDescription: "Fail to get name or price")
                return
            }
            
            let realm = try Realm()
            try realm.write {
                let model = CurrencyNotificationRealmModel(
                    name: name,
                    price: price,
                    isNotificationOn: true, 
                    lastSentAt: nil
                )
                
                model.id = model.incrementID(specificRealmInstance: realm)
                realm.add(model)
            }
            
            notificationDidAdded?()
        } catch {
            showAlertError(errorDescription: error.localizedDescription)
        }
    }
    
    private func updateButtonState() {
        submitButton.isEnabled = viewModel.isSubmitButtonEnabled
        if viewModel.isSubmitButtonEnabled {
            submitButton.backgroundColor = .systemBlue
        } else {
            submitButton.backgroundColor = .systemGray4
        }
    }
    
    private func showNotificationAssetSelectingViewController() {
        let notificationAssetSelectingViewModel = NotificationAssetSelectingViewModel()
        let notificationAssetSelectingViewController = NotificationAssetSelectingViewController(viewModel: notificationAssetSelectingViewModel)
        
        notificationAssetSelectingViewController.didSelectAsset = { [weak self] assetName in
            guard let self else { return }
            viewModel.storage.assetName = assetName
            if let index = viewModel.tableTemplate.firstIndex(where: { $0 == .assetSelection }) {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                tableView.reloadData()
            }
            navigationController?.dismiss(animated: true)
            updateButtonState()
        }
        
        navigationController?.present(notificationAssetSelectingViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotificationAddingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableTemplate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableItem = viewModel.tableTemplate[indexPath.row]
        var cell = UITableViewCell()
        
        switch tableItem {
        case .assetSelection:
            guard let notificationCurrencySelectTableViewCell = tableView.dequeueReusableCell(withIdentifier: NotificationCurrencySelectTableViewCell.reuseIdentifier) as? NotificationCurrencySelectTableViewCell else {
                return UITableViewCell()
            }
            notificationCurrencySelectTableViewCell.setupCell(assetName: viewModel.storage.assetName)
            
            notificationCurrencySelectTableViewCell.didSelectCell = { [weak self] in
                guard let self else { return }
                showNotificationAssetSelectingViewController()
            }
            cell = notificationCurrencySelectTableViewCell
        case .priceEntering:
            guard let notificationCurrencyPriceEnteringTableViewCell = tableView.dequeueReusableCell(withIdentifier: NotificationCurrencyPriceEnteringTableViewCell.reuseIdentifier) as? NotificationCurrencyPriceEnteringTableViewCell else {
                return UITableViewCell()
            }
            
            notificationCurrencyPriceEnteringTableViewCell.didChangeText = { [weak self] text in
                guard let self else { return }
                self.viewModel.storage.price = Double(text)
                updateButtonState()
            }
            cell = notificationCurrencyPriceEnteringTableViewCell
        }
        
        return cell
    }
}

extension NotificationAddingViewController {
    private func hideKeyboardOnTap(_ specificView: UIView? = nil) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        (specificView ?? view).addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
