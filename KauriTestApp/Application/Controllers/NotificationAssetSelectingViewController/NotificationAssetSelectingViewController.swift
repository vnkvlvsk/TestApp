import UIKit

final class NotificationAssetSelectingViewController: UIViewController {
    
    // MARK: - Closures

    var didSelectAsset: ((String) -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.alwaysBounceVertical = true
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private let viewModel: NotificationAssetSelectingViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: NotificationAssetSelectingViewModel) {
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
        activityIndicator.startAnimating()
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.setupDataSource()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showAlertError(errorDescription: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NotificationAssetSelectingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.dataSource[indexPath.row].symbol
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectAsset?(viewModel.dataSource[indexPath.row].symbol)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Select asset"
    }
}
