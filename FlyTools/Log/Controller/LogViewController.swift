//
//  LogViewController.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/4.
//

import UIKit

class LogViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.FlyTools.LogViewController")
    
    private var logs: [Log] = []
    private var logCellHeight: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logs = Logger.shared.logs
        setupViews()
    }
    
    @objc private func close() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func clear() {
        Logger.shared.clear()
    }
}

extension LogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.fl.dequeueReusableCell(LogCell.self, for: indexPath)
        let log = logs[indexPath.row]
        cell.header = log.formattedHeader
        cell.message = log.message
        cell.messageColor = log.level.logColor
        cell.delegate = self
        return cell
    }
}

extension LogViewController: LogCellDelegate {
    func logCellCopyLog(_ cell: LogCell) {
        UIPasteboard.general.string = cell.message
    }
}

extension LogViewController: LoggerDelegate {
    func logger(_ logger: Logger, didAddLog log: Log) {
        queue.async {
            self.logs.append(log)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loggerDidClear(_ logger: Logger) {
        queue.async {
            self.logs = []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension LogViewController {
    private func setupViews() {
        title = "日志"
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清空", style: .plain, target: self, action: #selector(clear))
        }
        
        Logger.shared.delegate = self
        
        tableView.fl.register(LogCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
