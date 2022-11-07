//
//  SnapshotUtil.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/7.
//

import UIKit

class SnapshotUtil {
    static func takeSnapshot() -> UIImage? {
        var scale: CGFloat = 3.0
        var windows: [UIWindow]?
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes where scene.session.role == .windowApplication {
                guard let windowScene = scene as? UIWindowScene else { continue }
                scale = windowScene.screen.scale
                windows = windowScene.windows
                break
            }
        } else {
            scale = UIScreen.main.scale
            windows = UIApplication.shared.windows
        }
        guard var windows = windows else { return nil }
        windows.sort { windowA, windowB in
            return windowA.windowLevel < windowB.windowLevel
        }
        var width: CGFloat = 0
        var height: CGFloat = 0
        for window in windows {
            width = max(width, window.frame.maxX)
            height = max(height, window.frame.maxY)
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        for window in windows {
//            if window is FlyToolsWindow {
//                continue
//            }
            window.drawHierarchy(in: window.frame, afterScreenUpdates: true)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
