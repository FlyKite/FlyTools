//
//  ScreenshotViewController.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/7.
//

import UIKit
import FlyUtils

class ScreenshotViewController: UIViewController {
    
    let screenshot: UIImage
    
    private let container: UIView = UIView()
    private let imageView: UIImageView = UIImageView()
    private let toolbox: UIStackView = UIStackView()
    
    enum ToolType: CaseIterable {
        case addRect
        case close
        case save
        
        var icon: UIImage? {
            switch self {
            case .addRect: return Images.addRect
            case .close: return Images.close
            case .save: return Images.confirm
            }
        }
        
        var tintColor: UIColor {
            switch self {
            case .addRect: return .systemGray
            case .close: return .systemRed
            case .save: return .systemGreen
            }
        }
    }
    
    init(screenshot: UIImage) {
        self.screenshot = screenshot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc private func toolButtonClicked(_ button: UIButton) {
        let type = ToolType.allCases[button.tag]
        switch type {
        case .close: dismiss(animated: true)
        default: break
        }
    }
}

extension ScreenshotViewController: CustomPresentableViewController {
    func presentationAnimationConfigs() -> AnimationConfig {
        var config = AnimationConfig()
        config.duration = 0.5
        config.durationForDismissing = 0.25
        return config
    }
    
    func presentationWillBeginTransition(type: TransitionType) {
        if type == .presenting {
            imageView.alpha = 0
        }
    }

    func presentationUpdateViewsForTransition(type: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: duration, delay: 0) {
            switch type {
            case .presenting:
                self.imageView.alpha = 1
                self.container.snp.remakeConstraints { make in
                    make.top.left.equalTo(self.view.safeAreaLayoutGuide).offset(16)
                    make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
                    make.bottom.equalTo(self.toolbox.snp.top).offset(-10)
                }
                self.view.layoutIfNeeded()
            case .dismissing:
                self.view.alpha = 0
                self.container.snp.updateConstraints { make in
                    make.top.equalTo(self.view.safeAreaLayoutGuide).offset(66)
                }
                self.toolbox.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(34)
                }
                self.view.layoutIfNeeded()
            }
        } completion: { finished in
            completeCallback()
        }
    }
}

extension ScreenshotViewController {
    private func setupViews() {
        toolbox.backgroundColor = UIColor(white: 0, alpha: 0.65)
        toolbox.layer.cornerRadius = 4
        
        let whiteBg = UIView()
        whiteBg.backgroundColor = .white
        
        imageView.image = screenshot
        
        for (index, type) in ToolType.allCases.enumerated() {
            let button = UIButton()
            if #available(iOS 13.0, *) {
                button.setImage(type.icon, for: .normal)
            }
            button.tag = index
            button.tintColor = type.tintColor
            button.addTarget(self, action: #selector(toolButtonClicked), for: .touchUpInside)
            toolbox.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalTo(36)
            }
        }
        
        view.addSubview(toolbox)
        view.addSubview(container)
        container.addSubview(whiteBg)
        container.addSubview(imageView)
        
        toolbox.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        whiteBg.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.height.equalTo(imageView).offset(4)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.left.greaterThanOrEqualToSuperview()
            make.bottom.right.lessThanOrEqualToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(screenshot.size.height / screenshot.size.width)
        }
    }
}
