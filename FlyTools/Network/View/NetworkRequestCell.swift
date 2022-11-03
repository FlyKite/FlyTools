//
//  NetworkRequestCell.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/3.
//

import UIKit
import FlyUtils

class NetworkRequestCell: UITableViewCell {
    
    var requestInfo: NetworkRequestInfo? {
        didSet {
            updateCell(requestInfo)
        }
    }
    
    private let statusTagView: TagView = TagView()
    private let methodTagView: TagView = TagView()
    private let startTimeTagView: TagView = TagView()
    private let costTagView: TagView = TagView()
    private let pathLabel: UILabel = UILabel()
    private let hostLabel: UILabel = UILabel()
    
    private var responseListener: Listener<HTTPURLResponse?>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        accessoryType = .disclosureIndicator
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.alignment = .fill
        
        statusTagView.textLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        pathLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        hostLabel.font = UIFont.systemFont(ofSize: 13)
        
        if #available(iOS 13.0, *) {
            hostLabel.textColor = .secondaryLabel
        } else {
            hostLabel.textColor = .systemGray
        }
        
        contentView.addSubview(statusTagView)
        contentView.addSubview(stack)
        row.addArrangedSubview(methodTagView)
        row.addArrangedSubview(startTimeTagView)
        row.addArrangedSubview(costTagView)
        stack.addArrangedSubview(row)
        stack.addArrangedSubview(pathLabel)
        stack.addArrangedSubview(hostLabel)
        
        statusTagView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(24)
        }
        
        stack.snp.makeConstraints { make in
            make.left.equalTo(statusTagView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        row.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }
    
    private func updateCell(_ requestInfo: NetworkRequestInfo?) {
        methodTagView.textLabel.text = requestInfo?.request.httpMethod
        pathLabel.text = requestInfo?.request.url?.path
        hostLabel.text = "host: \(requestInfo?.request.url?.host ?? "")"
        if let beginData = requestInfo?.beginDate {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm"
            startTimeTagView.textLabel.text = fmt.string(from: beginData)
        } else {
            startTimeTagView.textLabel.text = "--:--"
        }
        responseListener = requestInfo?.responseListenable.listen(onChange: { [weak self] response in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateStatusCode(response?.statusCode)
                self.updateCost(requestInfo?.cost)
            }
        })
    }
    
    private func updateStatusCode(_ statusCode: Int?) {
        if let statusCode = statusCode {
            statusTagView.textLabel.text = "\(statusCode)"
            switch statusCode / 100 {
            case 1: statusTagView.backgroundColor = .systemGray
            case 2: statusTagView.backgroundColor = .systemGreen
            case 3: statusTagView.backgroundColor = .systemOrange
            case 4: statusTagView.backgroundColor = .systemPink
            case 5: statusTagView.backgroundColor = .systemPink
            default: statusTagView.backgroundColor = .systemGray
            }
        } else {
            statusTagView.textLabel.text = "..."
            statusTagView.backgroundColor = .systemGray
        }
    }
    
    private func updateCost(_ cost: TimeInterval?) {
        guard let cost = cost else {
            costTagView.textLabel.text = "-"
            costTagView.backgroundColor = .systemGray
            return
        }
        let ms = Int((cost ?? 0) * 1000)
        costTagView.textLabel.text = "\(ms)ms"
        if ms < 2000 {
            costTagView.backgroundColor = .systemGreen
        } else if ms < 5000 {
            costTagView.backgroundColor = .systemOrange
        } else {
            costTagView.backgroundColor = .systemPink
        }
    }
}

private class TagView: UIView {
    
    let textLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemGray
        layer.cornerRadius = 4
        
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        
        addSubview(textLabel)
        
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
        }
    }
}
