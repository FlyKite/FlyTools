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
    private static let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.FlyTools")
    
    @available(iOS 13.0, *)
    public static func setup(windowScene: UIWindowScene, sandboxContainers: [SandboxContainer]? = nil) {
        queue.sync {
            guard window == nil else { return }
            let window = FlyToolsWindow(windowScene: windowScene)
            setup(window: window, sandboxContainers: sandboxContainers)
        }
    }
    
    @available(iOS, deprecated: 13.0, message: "Use another setup function to provide a UIWindowScene above iOS 13.0")
    public static func setup(sandboxContainers: [SandboxContainer]? = nil) {
        queue.sync {
            guard window == nil else { return }
            let window = UIWindow(frame: UIScreen.main.bounds)
            setup(window: window, sandboxContainers: sandboxContainers)
        }
    }
    
    private static func setup(window: UIWindow, sandboxContainers: [SandboxContainer]?) {
        _ = FlyNetworkCatcher.shared
        FlyURLProtocol.register()
        FlyURLProtocol.start()
        
        window.windowLevel = .alert
        window.rootViewController = FlyMonitorViewController(sandboxContainers: sandboxContainers)
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
