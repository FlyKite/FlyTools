//
//  FlyTools.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/27.
//

import UIKit

public class FlyTools {
    
    @available(iOS 13.0, *)
    private static var windowScene: UIWindowScene?
    private static var window: UIWindow?
    
    @available(iOS 13.0, *)
    public static func showFlyBall(windowScene: UIWindowScene) {
        guard windowScene != self.windowScene else { return }
        let window = FlyToolsWindow(windowScene: windowScene)
        window.windowLevel = .alert
        window.rootViewController = FlyBallViewController()
        window.makeKeyAndVisible()
        self.window = window
        self.windowScene = windowScene
    }
    
    @available(iOS, deprecated: 13.0, message: "Use showFlyBall(windowScene:) to provide a UIWindowScene above iOS 13.0")
    public static func showFlyBall() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert
        window.rootViewController = FlyBallViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}

class FlyToolsWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view != self ? view : nil
    }
}
