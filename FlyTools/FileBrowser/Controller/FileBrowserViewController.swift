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
    
    private let manager: FileBrowserDataSource
    
    private let tableView: UITableView = UITableView()
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.FlyTools.FBVC", attributes: .concurrent)
    
    public init(directoryUrl: URL? = nil, showHiddenFiles: Bool = false) {
        manager = FileBrowserManager(directoryUrl: directoryUrl, showHiddenFiles: showHiddenFiles)
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(containers: [SandboxContainer], showHiddenFiles: Bool = false) {
        manager = SandboxContainerManager(containers: containers, showHiddenFiles: showHiddenFiles)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension FileBrowserViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.contents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.ch.dequeueReusableCell(FileBrowserTableCell.self, for: indexPath)
        let contentName = manager.contents[indexPath.row]
        let contentType = manager.contentType(for: contentName)
        cell.icon = contentType.icon
        cell.fileName = contentName
        cell.accessoryType = contentType == .directory ? .disclosureIndicator : .none
        return cell
    }
}

extension FileBrowserViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contentName = manager.contents[indexPath.row]
        let contentType = manager.contentType(for: contentName)
        switch contentType {
        case .directory:
            let controller = FileBrowserViewController(directoryUrl: manager.url(for: contentName),
                                                       showHiddenFiles: manager.showHiddenFiles)
            navigationController?.pushViewController(controller, animated: true)
        default:
            let url = manager.url(for: contentName)
            let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(controller, animated: true)
        }
    }
}

extension FileBrowserViewController {
    private func setupViews() {
        title = manager.currentDirectoryName
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
