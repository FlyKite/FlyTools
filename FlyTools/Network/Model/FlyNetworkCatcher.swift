//
//  FlyNetworkCatcher.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/27.
//

import Foundation
import FlyUtils

protocol FlyNetworkCatcherDelegate: AnyObject {
    func networkCatcher(_ catcher: FlyNetworkCatcher, didCatchNewRequest: NetworkRequestInfo)
}

public class NetworkRequestInfo {
    public let request: URLRequest
    public let beginDate: Date
    public internal(set) var cost: TimeInterval?
    
    @Listenable
    public internal(set) var response: HTTPURLResponse?
    
    public var responseListenable: Listenable<HTTPURLResponse?> { _response }
    
    init(request: URLRequest, beginDate: Date) {
        self.request = request
        self.beginDate = beginDate
    }
}

public class FlyNetworkCatcher {
    
    public static let shared: FlyNetworkCatcher = FlyNetworkCatcher()
    
    @ThreadSafe
    public private(set) var catchedRequests: [NetworkRequestInfo] = []
    @ThreadSafe
    private var requestMap: [Int: NetworkRequestInfo] = [:]
    
    weak var delegate: FlyNetworkCatcherDelegate?
    
    private init() {
        FlyURLProtocol.delegate = self
    }
}

extension FlyNetworkCatcher: FlyURLProtocolDelegate {
    func urlProtocol(_ urlProtocol: FlyURLProtocol, didStartLoading task: URLSessionTask) {
        let requestInfo = NetworkRequestInfo(request: urlProtocol.request, beginDate: Date())
        _catchedRequests.transformValue { list in
            var list = list
            list.append(requestInfo)
            return list
        }
        _requestMap.transformValue { map in
            var map = map
            map[task.taskIdentifier] = requestInfo
            return map
        }
        delegate?.networkCatcher(self, didCatchNewRequest: requestInfo)
    }
    
    func urlProtocol(_ urlProtocol: FlyURLProtocol, task: URLSessionTask, didReceiveResponse response: HTTPURLResponse) {
        guard let requestInfo = requestMap[task.taskIdentifier] else { return }
        requestInfo.cost = Date().timeIntervalSince(requestInfo.beginDate)
        requestInfo.response = response
    }
}
