//
//  NetworkRequestInfoViewController.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/3.
//

import UIKit
import FlyUtils

class NetworkRequestInfoViewController: UIViewController {
    
    let requestInfo: NetworkRequestInfo
    
    init(requestInfo: NetworkRequestInfo) {
        self.requestInfo = requestInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = UITableView()
    
    private var sections: [Section] = []
    private var responseListener: Listener<HTTPURLResponse?>?
    
    private struct Section {
        let title: String
        let items: [Item]
        
        struct Item {
            let title: String
            let value: String
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
        setupViews()
        if requestInfo.response == nil {
            responseListener = requestInfo.responseListenable.listen(onChange: { [weak self] response in
                guard let self = self else { return }
                self.responseListener = nil
                self.updateData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    private func updateData() {
        sections = []
        sections.append(Section(title: "Request",
                                items: [
                                    Section.Item(title: "URL", value: requestInfo.request.url?.absoluteString ?? ""),
                                    Section.Item(title: "Parameters", value: getRequestParameters()),
                                    Section.Item(title: "Headers", value: getRequestHeaderString())
                                ]))
        if let response = requestInfo.response {
            sections.append(Section(title: "Response",
                                    items: [
                                        Section.Item(title: "Headers", value: getResponseHeaderString(response))
                                    ]))
        }
    }
    
    private func getRequestParameters() -> String {
        return ""
    }
    
    private func getRequestHeaderString() -> String {
        guard let headers = requestInfo.request.allHTTPHeaderFields else { return "" }
        return headers.map({ "\($0.key): \($0.value)"}).joined(separator: "\n")
    }
    
    private func getResponseHeaderString(_ response: HTTPURLResponse) -> String {
        return response.allHeaderFields.map({ "\($0.key): \($0.value)"}).joined(separator: "\n")
    }
}

extension NetworkRequestInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.fl.dequeueReusableCell(TitleValueCell.self, for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.title = item.title
        cell.value = item.value
        return cell
    }
}

extension NetworkRequestInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.fl.dequeueReusableView(HeaderTitleView.self)
        view?.title = sections[section].title
        return view
    }
}

extension NetworkRequestInfoViewController {
    private func setupViews() {
        title = "网络"
        
        tableView.fl.register(TitleValueCell.self)
        tableView.fl.register(HeaderTitleView.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 48
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
