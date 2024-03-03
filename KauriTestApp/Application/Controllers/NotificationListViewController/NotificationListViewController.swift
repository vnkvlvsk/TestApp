import UIKit
import RealmSwift

final class NotificationListViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.alwaysBounceVertical = true
        tableView.register(NotificationListAssetTableViewCell.self, forCellReuseIdentifier: NotificationListAssetTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private let viewModel: NotificationListViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: NotificationListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupDataSource()
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Notifications"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonPressed))
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupDataSource() {
        do {
            activityIndicator.startAnimating()
            try viewModel.setupDataSource()
            activityIndicator.stopAnimating()
            tableView.reloadData()
        } catch {
            activityIndicator.stopAnimating()
            showAlertError(errorDescription: error.localizedDescription)
        }
    }
    
    private func notificationActivationSwitchAction(model: CurrencyNotificationRealmModel, isOn: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                model.isNotificationOn = isOn
            }
        } catch {
            showAlertError(errorDescription: error.localizedDescription)
        }
    }
    
    @objc private func onAddButtonPressed() {
        let notificationSettingsViewModel = NotificationAddingViewModel()
        let notificationSettingsViewController = NotificationAddingViewController(viewModel: notificationSettingsViewModel)
        
        notificationSettingsViewController.notificationDidAdded = { [weak self] in
            guard let self else { return }
            setupDataSource()
            navigationController?.popViewController(animated: true)
        }
        
        navigationController?.pushViewController(notificationSettingsViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotificationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationListAssetTableViewCell.reuseIdentifier) as? NotificationListAssetTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setupCell(model: viewModel.dataSource[indexPath.row])
        
        cell.onActivationSwitchToggle = { [weak self] isOn in
            guard let self else { return }
            notificationActivationSwitchAction(model: viewModel.dataSource[indexPath.row], isOn: isOn)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(viewModel.dataSource[indexPath.row])
                }
                viewModel.dataSource.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                showAlertError(errorDescription: error.localizedDescription)
            }
        }
    }
}
