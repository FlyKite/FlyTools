//
//  FlyBall.swift
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
    case toggleFlyBall
}

protocol FlyBallDelegate: AnyObject {
    func flyBall(_ flyBall: FlyBall, actionButtonClick actionType: ActionType)
}

class FlyBall: UIView {
    
    weak var delegate: FlyBallDelegate?
    
    enum State {
        case ball
        case expanded
    }
    
    var state: State = .ball {
        didSet {
            updateState(state)
        }
    }
    
    var textForBallState: String = "" {
        didSet {
            ballTextLabel.text = textForBallState
        }
    }
    
    private let ballContainer: UIView = UIView()
    private let ballTextLabel: UILabel = UILabel()
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
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        
        addSubview(ballContainer)
        addSubview(expandedContainer)
        setupBallContainer()
        setupExpandedContainer()
    }
    
    private func setupBallContainer() {
        ballTextLabel.font = UIFont.systemFont(ofSize: 12)
        ballTextLabel.textColor = .white
        ballTextLabel.textAlignment = .center
        ballTextLabel.numberOfLines = 2
        
        ballContainer.addSubview(ballTextLabel)
        
        ballContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Constant.size)
        }
        
        ballTextLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupExpandedContainer() {
        var actionStack = UIStackView()
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
                self.delegate?.flyBall(self, actionButtonClick: type)
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
        ballContainer.alpha = state == .ball ? 1 : 0
        expandedContainer.alpha = state == .ball ? 0 : 1
    }
    
    @objc private func onTap() {
        guard state == .ball else { return }
        delegate?.flyBall(self, actionButtonClick: .toggleFlyBall)
    }
    
    private func actionButton(_ type: ActionType) -> ActionButton {
        let icon: UIImage?
        let title: String
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        switch type {
        case .fileBrowser:
            icon = UIImage(systemName: "shippingbox.fill", withConfiguration: config)
            title = "文件"
        case .network:
            icon = UIImage(systemName: "network", withConfiguration: config)
            title = "网络"
        case .log:
            icon = UIImage(systemName: "doc.plaintext.fill", withConfiguration: config)
            title = "日志"
        case .location:
            icon = UIImage(systemName: "location.circle.fill", withConfiguration: config)
            title = "定位"
        case .snapshot:
            icon = UIImage(systemName: "camera.fill", withConfiguration: config)
            title = "截屏"
        case .ruler:
            icon = UIImage(systemName: "ruler.fill", withConfiguration: config)
            title = "测量"
        case .info:
            icon = UIImage(systemName: "info.circle.fill", withConfiguration: config)
            title = "信息"
        case .toggleFlyBall:
            icon = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
            title = "折叠"
        }
        return ActionButton(icon: icon, title: title)
    }
}

extension FlyBall {
    private struct Constant {
        static let size: CGSize = CGSize(width: 56, height: 56)
        static let cornerRadius: CGFloat = 28
        static let backgroundColor: UIColor = UIColor(white: 0, alpha: 0.5)
        
        static let expandedSize: CGSize = CGSize(width: 64 * 4, height: 128)
        static let expandedCornerRadius: CGFloat = 4
        static let expandedBackgroundColor: UIColor = UIColor(white: 0, alpha: 0.9)
    }
}

extension FlyBall.State {
    var size: CGSize {
        switch self {
        case .ball: return FlyBall.Constant.size
        case .expanded: return FlyBall.Constant.expandedSize
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .ball: return FlyBall.Constant.backgroundColor
        case .expanded: return FlyBall.Constant.expandedBackgroundColor
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .ball: return FlyBall.Constant.cornerRadius
        case .expanded: return FlyBall.Constant.expandedCornerRadius
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
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onButtonTap)))
        
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
    
    @objc private func onButtonTap() {
        onTap?()
    }
}
