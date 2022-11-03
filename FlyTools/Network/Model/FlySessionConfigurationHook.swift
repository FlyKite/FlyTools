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
        exchanged = true
        exchangeImplementations(#selector(getter: URLSessionConfiguration.default),
                                #selector(URLSessionConfiguration.flyDefaultConfiguration))
        exchangeImplementations(#selector(getter: URLSessionConfiguration.ephemeral),
                                #selector(URLSessionConfiguration.flyEphemeralConfiguration))
    }
    
    private func exchangeImplementations(_ selector1: Selector, _ selector2: Selector) {
        guard
            let method1 = class_getClassMethod(URLSessionConfiguration.self, selector1),
            let method2 = class_getClassMethod(URLSessionConfiguration.self, selector2)
        else { return }
        method_exchangeImplementations(method1, method2)
    }
}

extension URLSessionConfiguration {
    @objc(flyDefaultConfiguration)
    fileprivate static func flyDefaultConfiguration() -> URLSessionConfiguration {
        let config = perform(#selector(flyDefaultConfiguration))!.takeUnretainedValue() as! URLSessionConfiguration
        if var classes = config.protocolClasses, classes.contains(where: { $0 == FlyURLProtocol.self }) {
            classes.insert(FlyURLProtocol.self, at: 0)
            config.protocolClasses = classes
        } else {
            config.protocolClasses = [FlyURLProtocol.self]
        }
        return config
    }
    
    @objc(flyEphemeralConfiguration)
    fileprivate static func flyEphemeralConfiguration() -> URLSessionConfiguration {
        let config = perform(#selector(flyEphemeralConfiguration))!.takeUnretainedValue() as! URLSessionConfiguration
        if var classes = config.protocolClasses, classes.contains(where: { $0 == FlyURLProtocol.self }) {
            classes.insert(FlyURLProtocol.self, at: 0)
            config.protocolClasses = classes
        } else {
            config.protocolClasses = [FlyURLProtocol.self]
        }
        return config
    }
}
