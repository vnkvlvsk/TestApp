import UIKit
import UserNotifications
import RealmSwift

final class CurrenciesListViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.alwaysBounceVertical = true
        tableView.register(AssetTableViewCell.self, forCellReuseIdentifier: AssetTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private let viewModel: CurrenciesListViewModel
    
    private var timer: Timer?
    
    // MARK: - Lifecycle
    
    init(viewModel: CurrenciesListViewModel) {
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
        
        setupTimer()
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onAddButtonPressed))
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(setupDataSource), userInfo: nil, repeats: true)
    }
    
    @objc private func onAddButtonPressed() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    let notificationSettingsViewModel = NotificationListViewModel()
                    let notificationSettingsViewController = NotificationListViewController(viewModel: notificationSettingsViewModel)
                    
                    self.navigationController?.pushViewController(notificationSettingsViewController, animated: true)
                } else {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        DispatchQueue.main.async {
                            if granted {
                                let notificationSettingsViewModel = NotificationListViewModel()
                                let notificationSettingsViewController = NotificationListViewController(viewModel: notificationSettingsViewModel)
                                
                                self.navigationController?.pushViewController(notificationSettingsViewController, animated: true)
                            } else {
                                self.showAlertError(errorDescription: "You must give permission to send notifications in settings")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func setupDataSource() {
        guard !viewModel.isCurrenciesPriceDownloading else { return }
        activityIndicator.startAnimating()
        viewModel.isCurrenciesPriceDownloading = true
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.setupDataSource()
                let modelsToSendNotification = try await viewModel.sendNotifications()
                DispatchQueue.main.async {
                    self.sendNotifications(to: modelsToSendNotification)
                    self.activityIndicator.stopAnimating()
                    self.viewModel.isCurrenciesPriceDownloading = false
                    self.tableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.viewModel.isCurrenciesPriceDownloading = false
                    self.showAlertError(errorDescription: error.localizedDescription)
                }
            }
        }
    }
    
    private func sendNotifications(to modelsId: [Int]) {
        let realm = try! Realm()

        let allCurrencyNotificationRealmModel = Array(realm.objects(CurrencyNotificationRealmModel.self))
        let filteredCurrencyNotificationRealmModel = allCurrencyNotificationRealmModel.filter { currencyNotificationRealmModel in
            modelsId.contains(where: { $0 == currencyNotificationRealmModel.id })
        }
        
        for model in filteredCurrencyNotificationRealmModel {
            let content = UNMutableNotificationContent()
            content.title = "Price of \(model.name)"
            content.body = "\(model.name.uppercased()) price reached \(model.price) USDT!"
            content.sound = UNNotificationSound.default
            
            try! realm.write {
                model.lastSentAt = .now
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(model.price)PriceNotification", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CurrenciesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AssetTableViewCell.reuseIdentifier) as? AssetTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setupCell(model: viewModel.dataSource[indexPath.row])
        
        return cell
    }
}

