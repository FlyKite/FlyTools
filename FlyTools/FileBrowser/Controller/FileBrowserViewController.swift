//
//  FileBrowserViewController.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/24.
//

import UIKit
import SnapKit
import FlyUtils

public struct SandboxContainer {
    public let name: String
    public let path: String
    
    public init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}

public class FileBrowserViewController: UIViewController {
    
    private let provider: FileBrowserProvider
    
    private let tableView: UITableView = UITableView()
    
    public init(directory: Directory? = nil, showHiddenFiles: Bool = false) {
        if let directory = directory {
            provider = DirectoryBrowserManager(directory: directory,
                                               showHiddenFiles: showHiddenFiles)
        } else {
            let url = URL(fileURLWithPath: NSHomeDirectory())
            let directory = Directory(url: url, name: "Home")
            provider = DirectoryBrowserManager(directory: directory,
                                               showHiddenFiles: showHiddenFiles)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(containers: [SandboxContainer], showHiddenFiles: Bool = false) {
        provider = SandboxBrowserManager(containers: containers, showHiddenFiles: showHiddenFiles)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc private func close() {
        navigationController?.dismiss(animated: true)
    }
}

extension FileBrowserViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.ch.dequeueReusableCell(FileBrowserTableCell.self, for: indexPath)
        let item = provider.items[indexPath.row]
        if #available(iOS 13.0, *) {
            cell.icon = item.icon
            cell.fileName = item.name
        } else {
            cell.fileName = "\(item.iconEmoji) \(item.name)"
        }
        if case .directory = item {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension FileBrowserViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = provider.items[indexPath.row]
        switch item {
        case let .directory(directory):
            let controller = FileBrowserViewController(directory: directory,
                                                       showHiddenFiles: provider.showHiddenFiles)
            navigationController?.pushViewController(controller, animated: true)
        case let .file(file):
            let controller = UIActivityViewController(activityItems: [file.url], applicationActivities: nil)
            present(controller, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard provider.canDelete(at: indexPath.row) else { return nil }
        let actions: [UIContextualAction] = [
            UIContextualAction(style: .destructive, title: "删除", handler: { _, _, completion in
                let deleteSuccess = self.provider.delete(at: indexPath.row)
                if deleteSuccess {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                completion(deleteSuccess)
            })
        ]
        return UISwipeActionsConfiguration(actions: actions)
    }
}

extension FileBrowserViewController {
    private func setupViews() {
        title = provider.currentDirectoryName
        if navigationController?.viewControllers.count == 1 {
            if #available(iOS 13.0, *) {
                navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
            } else {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
            }
        }
        navigationItem.backButtonTitle = "返回"
        
        tableView.ch.register(FileBrowserTableCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.rowHeight = 52
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
