//
//  LogCell.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/7.
//

import UIKit

protocol LogCellDelegate: AnyObject {
    func logCellCopyLog(_ cell: LogCell)
}

class LogCell: UITableViewCell {
    
    weak var delegate: LogCellDelegate?
    
    var header: String? {
        get { headerLabel.text }
        set { headerLabel.text = newValue }
    }
    
    var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    var messageColor: UIColor? {
        get { messageLabel.textColor }
        set { messageLabel.textColor = newValue }
    }
    
    private let headerLabel: UILabel = UILabel()
    private let messageLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
        
        headerLabel.font = UIFont.systemFont(ofSize: 12)
        headerLabel.numberOfLines = 0
        if #available(iOS 13.0, *) {
            headerLabel.textColor = .secondaryLabel
        } else {
            headerLabel.textColor = .systemGray
        }
        
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(messageLabel)
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.right.equalTo(headerLabel)
            make.top.equalTo(headerLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    @objc private func handleLongPress() {
        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "Copy", action: #selector(copyLog))
        ]
        UIMenuController.shared.setTargetRect(messageLabel.bounds, in: messageLabel)
        UIMenuController.shared.isMenuVisible = true
    }
    
    @objc private func copyLog() {
        delegate?.logCellCopyLog(self)
    }
}
