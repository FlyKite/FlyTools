//
//  TitleValueCell.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/3.
//

import UIKit

class TitleValueCell: UITableViewCell {
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var value: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
    private let titleLabel: UILabel = UILabel()
    private let valueLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        valueLabel.font = UIFont.systemFont(ofSize: 15)
        valueLabel.numberOfLines = 0
        
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .secondaryLabel
        } else {
            titleLabel.textColor = .systemGray
        }
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
