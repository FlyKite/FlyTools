//
//  FlyMonitor.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/25.
//

import UIKit

enum ActionType: CaseIterable {
    case fileBrowser
    case network
    case log
    case location
    case snapshot
    case ruler
    case info
    case toggleMonitor
}

protocol FlyMonitorDelegate: AnyObject {
    func flyMonitor(_ monitor: FlyMonitor, actionButtonClick actionType: ActionType)
}

class FlyMonitor: UIView {
    
    weak var delegate: FlyMonitorDelegate?
    
    enum State {
        case monitor
        case expanded
        
        var next: State {
            switch self {
            case .monitor: return .expanded
            case .expanded: return .monitor
            }
        }
    }
    
    var state: State = .monitor {
        didSet {
            updateState(state)
        }
    }
    
    var deviceUsage: DeviceUsage? {
        didSet {
            guard let usage = deviceUsage else { return }
            monitorTextLabel.text = " \(usage.formattedCPUUsage)\n\(usage.formattedMemoryUsage)"
            if state == .monitor {
                layer.borderColor = usage.monitorBorderColor.cgColor
            }
        }
    }
    
    private let monitorContainer: UIView = UIView()
    private let monitorTextLabel: UILabel = UILabel()
    private let expandedContainer: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        updateState(state)
        clipsToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        addSubview(monitorContainer)
        addSubview(expandedContainer)
        setupMonitorContainer()
        setupExpandedContainer()
    }
    
    private func setupMonitorContainer() {
        monitorTextLabel.font = UIFont.systemFont(ofSize: 12)
        monitorTextLabel.textColor = .white
        monitorTextLabel.textAlignment = .center
        monitorTextLabel.numberOfLines = 2
        
        monitorContainer.addSubview(monitorTextLabel)
        
        monitorContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Constant.size)
        }
        
        monitorTextLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupExpandedContainer() {
        let actionStack = UIStackView()
        actionStack.axis = .vertical
        actionStack.distribution = .fillEqually
        actionStack.alignment = .fill
        
        var row: UIStackView?
        for (index, type) in ActionType.allCases.enumerated() {
            if index % 4 == 0 {
                let stack = UIStackView()
                stack.axis = .horizontal
                stack.alignment = .fill
                stack.distribution = .fillEqually
                actionStack.addArrangedSubview(stack)
                row = stack
            }
            let button = actionButton(type)
            button.onTap = { [weak self] in
                guard let self = self else { return }
                self.delegate?.flyMonitor(self, actionButtonClick: type)
            }
            row?.addArrangedSubview(button)
        }
        
        let secondRow = UIStackView()
        secondRow.axis = .horizontal
        secondRow.distribution = .fillEqually
        secondRow.alignment = .fill
        
        expandedContainer.addSubview(actionStack)
        
        expandedContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Constant.expandedSize)
        }
        
        actionStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func updateState(_ state: State) {
        backgroundColor = state.backgroundColor
        layer.cornerRadius = state.cornerRadius
        if state == .monitor, let usage = deviceUsage {
            layer.borderColor = usage.monitorBorderColor.cgColor
        } else {
            layer.borderColor = state.borderColor.cgColor
        }
        layer.borderWidth = state.borderWidth
        monitorContainer.alpha = state == .monitor ? 1 : 0
        expandedContainer.alpha = state == .monitor ? 0 : 1
    }
    
    @objc private func handleTap() {
        guard state == .monitor else { return }
        delegate?.flyMonitor(self, actionButtonClick: .toggleMonitor)
    }
    
    private func actionButton(_ type: ActionType) -> ActionButton {
        let icon: UIImage?
        if #available(iOS 13.0, *) {
            icon = type.icon
        } else {
            icon = nil
        }
        let title: String = type.title
        return ActionButton(icon: icon, title: title)
    }
}

extension FlyMonitor {
    private struct Constant {
        static let size: CGSize = CGSize(width: 56, height: 56)
        static let cornerRadius: CGFloat = 28
        static let borderColor: UIColor = UIColor.white
        static let borderWidth: CGFloat = 2.5
        static let backgroundColor: UIColor = UIColor(white: 0, alpha: 0.5)
        
        static let expandedSize: CGSize = CGSize(width: 64 * 4, height: 128)
        static let expandedCornerRadius: CGFloat = 4
        static let expandedBorderColor: UIColor = UIColor.clear
        static let expandedBorderWidth: CGFloat = 0
        static let expandedBackgroundColor: UIColor = UIColor(white: 0, alpha: 0.9)
    }
}

extension FlyMonitor.State {
    var size: CGSize {
        switch self {
        case .monitor: return FlyMonitor.Constant.size
        case .expanded: return FlyMonitor.Constant.expandedSize
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .monitor: return FlyMonitor.Constant.backgroundColor
        case .expanded: return FlyMonitor.Constant.expandedBackgroundColor
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .monitor: return FlyMonitor.Constant.cornerRadius
        case .expanded: return FlyMonitor.Constant.expandedCornerRadius
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .monitor: return FlyMonitor.Constant.borderColor
        case .expanded: return FlyMonitor.Constant.expandedBorderColor
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .monitor: return FlyMonitor.Constant.borderWidth
        case .expanded: return FlyMonitor.Constant.expandedBorderWidth
        }
    }
}

private class ActionButton: UIView {
    
    var onTap: (() -> Void)?
    
    var icon: UIImage? {
        get { iconView.image }
        set { iconView.image = newValue }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private let iconView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    
    init(icon: UIImage?, title: String?) {
        super.init(frame: .zero)
        setupViews()
        self.icon = icon
        self.title = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        
        addSubview(stack)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}

extension ActionType {
    @available(iOS 13.0, *)
    var icon: UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        switch self {
        case .fileBrowser: return UIImage(systemName: "shippingbox.fill", withConfiguration: config)
        case .network: return UIImage(systemName: "network", withConfiguration: config)
        case .log: return UIImage(systemName: "doc.plaintext.fill", withConfiguration: config)
        case .location: return UIImage(systemName: "location.circle.fill", withConfiguration: config)
        case .snapshot: return UIImage(systemName: "camera.fill", withConfiguration: config)
        case .ruler: return UIImage(systemName: "ruler.fill", withConfiguration: config)
        case .info: return UIImage(systemName: "info.circle.fill", withConfiguration: config)
        case .toggleMonitor: return UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        }
    }
    
    var title: String {
        switch self {
        case .fileBrowser: return "文件"
        case .network: return "网络"
        case .log: return "日志"
        case .location: return "定位"
        case .snapshot: return "截屏"
        case .ruler: return "测量"
        case .info: return "信息"
        case .toggleMonitor: return "折叠"
        }
    }
}

private extension DeviceUsage {
    var monitorBorderColor: UIColor {
        if cpuUsage < 0.5 {
            return .white
        } else if cpuUsage < 0.8 {
            return .systemYellow
        } else {
            return .systemRed
        }
    }
}
