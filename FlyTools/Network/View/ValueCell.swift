//
//  ValueCell.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/3.
//

import UIKit

class ValueCell: UITableViewCell {
    
    var value: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
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
        valueLabel.font = UIFont.systemFont(ofSize: 15)
        valueLabel.numberOfLines = 0
        
        contentView.addSubview(valueLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
