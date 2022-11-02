//
//  FlySessionConfigurationHook.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/2.
//

import Foundation

class FlySessionConfigurationHook {
    
    static let shared: FlySessionConfigurationHook = FlySessionConfigurationHook()
    
    private var exchanged: Bool = false
    
    func exchangeSessionConfigurationImplementations() {
        guard !exchanged else { return }
        guard
            let flyMethod = class_getClassMethod(URLSessionConfiguration.self,
                                                 NSSelectorFromString("flyDefaultConfiguration")),
            let originalMethod = class_getClassMethod(URLSessionConfiguration.self,
                                                      NSSelectorFromString("defaultSessionConfiguration")),
            let flyEphemeralMethod = class_getClassMethod(URLSessionConfiguration.self,
                                                          NSSelectorFromString("flyEphemeralConfiguration")),
            let originalEphemeralMethod = class_getClassMethod(URLSessionConfiguration.self,
                                                               NSSelectorFromString("ephemeralSessionConfiguration"))
        else { return }
        exchanged = true
        method_exchangeImplementations(flyMethod, originalMethod)
        method_exchangeImplementations(flyEphemeralMethod, originalEphemeralMethod)
    }
}

extension URLSessionConfiguration {
    @objc(flyDefaultConfiguration)
    private static func flyDefaultConfiguration() -> URLSessionConfiguration {
        let config = perform(#selector(flyDefaultConfiguration))!.takeUnretainedValue() as! URLSessionConfiguration
        if var classes = config.protocolClasses, classes.contains(where: { $0 == FlyNetworkCatcher.self }) {
            classes.insert(FlyNetworkCatcher.self, at: 0)
            config.protocolClasses = classes
        } else {
            config.protocolClasses = [FlyNetworkCatcher.self]
        }
        return config
    }
    
    @objc(flyEphemeralConfiguration)
    private static func flyEphemeralConfiguration() -> URLSessionConfiguration {
        let config = perform(#selector(flyEphemeralConfiguration))!.takeUnretainedValue() as! URLSessionConfiguration
        if var classes = config.protocolClasses, classes.contains(where: { $0 == FlyNetworkCatcher.self }) {
            classes.insert(FlyNetworkCatcher.self, at: 0)
            config.protocolClasses = classes
        } else {
            config.protocolClasses = [FlyNetworkCatcher.self]
        }
        return config
    }
}
