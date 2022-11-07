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
    public static func setup(windowScene: UIWindowScene,
                             sandboxContainers: [SandboxContainer]? = nil,
                             logLevel: LogLevel = .info) {
        queue.sync {
            guard window == nil else { return }
            let window = FlyToolsWindow(windowScene: windowScene)
            setup(window: window, sandboxContainers: sandboxContainers, logLevel: logLevel)
        }
    }
    
    @available(iOS, deprecated: 13.0, message: "Use another setup function to provide a UIWindowScene above iOS 13.0")
    public static func setup(sandboxContainers: [SandboxContainer]? = nil,
                             logLevel: LogLevel = .info) {
        queue.sync {
            guard window == nil else { return }
            let window = UIWindow(frame: UIScreen.main.bounds)
            setup(window: window, sandboxContainers: sandboxContainers, logLevel: logLevel)
        }
    }
    
    private static func setup(window: UIWindow, sandboxContainers: [SandboxContainer]?, logLevel: LogLevel) {
        _ = FlyNetworkCatcher.shared
        FlyURLProtocol.register()
        FlyURLProtocol.start()
        
        Logger.shared.level = logLevel
        
        window.windowLevel = .alert
        window.rootViewController = FlyMonitorViewController(sandboxContainers: sandboxContainers)
        window.makeKeyAndVisible()
        self.window = window
    }
    
    public static func log(_ level: LogLevel, message: String, file: String = #file, line: Int = #line, function: String = #function) {
        Logger.shared.addLog(level: level, message: message, file: file, line: line, function: function)
    }
}

class FlyToolsWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view != self ? view : nil
    }
}
