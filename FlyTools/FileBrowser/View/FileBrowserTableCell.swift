//
//  FileBrowserTableCell.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/24.
//

import UIKit

class FileBrowserTableCell: UITableViewCell {
    
    var icon: UIImage? {
        get { iconView.image }
        set {
            iconView.image = newValue
            iconView.isHidden = newValue == nil
        }
    }
    var fileName: String? {
        get { fileNameLabel.text }
        set { fileNameLabel.text = newValue }
    }
    
    private let iconView: UIImageView = UIImageView()
    private let fileNameLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        
        iconView.isHidden = true
        
        fileNameLabel.font = UIFont.systemFont(ofSize: 16)
        
        contentView.addSubview(stack)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(fileNameLabel)
        
        stack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
