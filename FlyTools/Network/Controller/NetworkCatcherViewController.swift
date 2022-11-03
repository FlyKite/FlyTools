//
//  NetworkCatcherViewController.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/3.
//

import UIKit
import FlyUtils

class NetworkCatcherViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    @ThreadSafe private var catchedRequestCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc private func close() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func clear() {
        FlyNetworkCatcher.shared.removeAllCatchedRequests()
        catchedRequestCount = 0
        tableView.reloadData()
    }
}

extension NetworkCatcherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catchedRequestCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.fl.dequeueReusableCell(NetworkRequestCell.self, for: indexPath)
        guard indexPath.row < FlyNetworkCatcher.shared.catchedRequests.count else { return cell }
        cell.requestInfo = FlyNetworkCatcher.shared.catchedRequests[indexPath.row]
        return cell
    }
}

extension NetworkCatcherViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < FlyNetworkCatcher.shared.catchedRequests.count else { return }
        let requestInfo = FlyNetworkCatcher.shared.catchedRequests[indexPath.row]
        let controller = NetworkRequestInfoViewController(requestInfo: requestInfo)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions: [UIContextualAction] = [
            UIContextualAction(style: .destructive, title: "删除", handler: { _, _, completion in
                FlyNetworkCatcher.shared.removeCatchedRequest(at: indexPath.row)
                self._catchedRequestCount.transformValue { $0 -= 1 }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            })
        ]
        return UISwipeActionsConfiguration(actions: actions)
    }
}

extension NetworkCatcherViewController: FlyNetworkCatcherDelegate {
    func networkCatcher(_ catcher: FlyNetworkCatcher, didCatchNewRequest: NetworkRequestInfo) {
        _catchedRequestCount.transformValue { $0 += 1 }
        tableView.insertRows(at: [IndexPath(row: catchedRequestCount - 1, section: 0)], with: .automatic)
    }
}

extension NetworkCatcherViewController {
    private func setupViews() {
        title = "网络"
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清空", style: .plain, target: self, action: #selector(clear))
        }
        navigationItem.backButtonTitle = "返回"
        
        FlyNetworkCatcher.shared.delegate = self
        catchedRequestCount = FlyNetworkCatcher.shared.catchedRequests.count
        
        tableView.fl.register(NetworkRequestCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.rowHeight = 88
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
