//
//  SnapshotViewController.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/7.
//

import UIKit
import FlyUtils

class SnapshotViewController: UIViewController {
    
    let snapshot: UIImage
    
    private let whiteMaskView: UIView = UIView()
    private let container: UIView = UIView()
    private let imageView: UIImageView = UIImageView()
    private let toolbox: UIStackView = UIStackView()
    
    init(snapshot: UIImage) {
        self.snapshot = snapshot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension SnapshotViewController: CustomPresentableViewController {
    func presentationAnimationConfigs() -> AnimationConfig {
        var config = AnimationConfig()
        config.duration = 0.35
        config.durationForDismissing = 0.25
        return config
    }

    func presentationUpdateViewsForTransition(type: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            switch type {
            case .presenting:
                self.container.snp.remakeConstraints { make in
                    make.top.left.equalTo(self.view.safeAreaLayoutGuide).offset(16)
                    make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
                    make.bottom.equalTo(self.toolbox.snp.top).offset(-6)
                }
                self.view.layoutIfNeeded()
            case .dismissing:
                self.view.alpha = 0
            }
        } completion: { finished in
            if finished {
                completeCallback()
            }
        }
    }
}

extension SnapshotViewController {
    private func setupViews() {
        toolbox.backgroundColor = UIColor(white: 0, alpha: 0.8)
        toolbox.layer.cornerRadius = 4
        
        whiteMaskView.backgroundColor = .white
        
        imageView.image = snapshot
        
        view.addSubview(toolbox)
        view.addSubview(container)
        container.addSubview(whiteMaskView)
        container.addSubview(imageView)
        
        toolbox.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        whiteMaskView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.height.equalTo(imageView).offset(4)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.left.greaterThanOrEqualToSuperview()
            make.bottom.right.lessThanOrEqualToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(snapshot.size.height / snapshot.size.width)
        }
    }
}
