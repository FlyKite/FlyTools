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
        set { iconView.image = newValue }
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
        fileNameLabel.font = UIFont.systemFont(ofSize: 16)
        
        contentView.addSubview(iconView)
        contentView.addSubview(fileNameLabel)
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        fileNameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
