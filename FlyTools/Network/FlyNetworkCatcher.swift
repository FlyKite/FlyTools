//
//  FlyNetworkCatcher.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/27.
//

import Foundation

public protocol FlyNetworkCatcherDelegate: AnyObject {
    func networkCatcher(_ catcher: FlyNetworkCatcher, canAuthenticateAgainstProtectionSpace: URLProtectionSpace) -> Bool
    func networkCatcher(_ catcher: FlyNetworkCatcher, didReceiveAuthenticationChallenge: URLAuthenticationChallenge)
    func networkCatcher(_ catcher: FlyNetworkCatcher, didCancelAuthenticationChallenge: URLAuthenticationChallenge)
}

extension FlyNetworkCatcherDelegate {
    func networkCatcher(_ catcher: FlyNetworkCatcher, canAuthenticateAgainstProtectionSpace: URLProtectionSpace) -> Bool {
        return false
    }
    func networkCatcher(_ catcher: FlyNetworkCatcher, didReceiveAuthenticationChallenge: URLAuthenticationChallenge) { }
    func networkCatcher(_ catcher: FlyNetworkCatcher, didCancelAuthenticationChallenge: URLAuthenticationChallenge) { }
}

public class FlyNetworkCatcher: URLProtocol {
    
    public static weak var delegate: FlyNetworkCatcherDelegate?
    
    public static var fetchDomains: [String] = []
    
    public static var catchingSchemes: [String] = ["http", "https"]
    
    public static func start() {
        URLProtocol.registerClass(self)
        FlySessionConfigurationHook.shared.exchangeSessionConfigurationImplementations()
    }
    
    public static func stop() {
        URLProtocol.unregisterClass(self)
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        guard
            let url = request.url,
            let scheme = url.scheme,
            catchingSchemes.contains(where: { $0.lowercased() == scheme.lowercased() }),
            URLProtocol.property(forKey: Constant.recursiveRequestKey, in: request) == nil
        else { return false }
        
        if fetchDomains.isEmpty {
            return true
        } else if let host = url.host {
            return fetchDomains.contains(host.lowercased())
        }
        return false
    }
    
    public override class func canInit(with task: URLSessionTask) -> Bool {
        if let request = task.currentRequest {
            return canInit(with: request)
        }
        return false
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    private struct Constant {
        static let recursiveRequestKey: String = "com.FlyKite.FlyTools.FlyNetworkCatcher"
    }
    
    private var modes: [RunLoop.Mode] = []
    private var startTime: TimeInterval = 0
    private var clientThread: Thread = .main
    private var dataTask: URLSessionDataTask?
    
    private var delegate: FlyNetworkCatcherDelegate? { FlyNetworkCatcher.delegate }
    
    public private(set) var pendingChallenge: URLAuthenticationChallenge?
    private var pendingChallengeCompletionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)?
    
    public override var task: URLSessionTask? {
        return dataTask
    }
    
    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    public override func startLoading() {
        var calculatedModes: [RunLoop.Mode] = [.default]
        let currentMode = RunLoop.current.currentMode
        if let currentMode = currentMode, currentMode != .default {
            calculatedModes.append(currentMode)
        }
        modes = calculatedModes
        var recursiveRequest = request
        if let request = (recursiveRequest as NSURLRequest).copy() as? NSMutableURLRequest {
            FlyNetworkCatcher.setProperty(true, forKey: Constant.recursiveRequestKey, in: request)
            recursiveRequest = request as URLRequest
        }
        startTime = Date.timeIntervalSinceReferenceDate
        clientThread = Thread.current
        
        let task = FlyURLSessionDemux.shared.dataTask(recursiveRequest, delegate: self, modes: modes)
        dataTask = task
        task.resume()
    }
    
    public override func stopLoading() {
        cancelPendingChallenge()
        if let task = dataTask {
            task.cancel()
            dataTask = nil
        }
    }
    
    private func cancelPendingChallenge() {
        DispatchQueue.main.async {
            guard let challenge = self.pendingChallenge else { return }
            self.pendingChallenge = nil
            self.pendingChallengeCompletionHandler = nil
            self.delegate?.networkCatcher(self, didCancelAuthenticationChallenge: challenge)
        }
    }
    
    private func didReceive(challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        DispatchQueue.main.async {
            if self.pendingChallenge != nil {
                completionHandler(.cancelAuthenticationChallenge, nil)
            } else {
                if let delegate = self.delegate {
                    self.pendingChallenge = challenge
                    self.pendingChallengeCompletionHandler = completionHandler
                    delegate.networkCatcher(self, didReceiveAuthenticationChallenge: challenge)
                } else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
        }
    }
}

extension FlyNetworkCatcher: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        var redirectRequest = request
        if let request = (redirectRequest as NSURLRequest).copy() as? NSMutableURLRequest {
            FlyNetworkCatcher.removeProperty(forKey: Constant.recursiveRequestKey, in: request)
            redirectRequest = request as URLRequest
        }
        client?.urlProtocol(self, wasRedirectedTo: redirectRequest, redirectResponse: response)
        task.cancel()
        client?.urlProtocol(self, didFailWithError: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError))
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let result = delegate?.networkCatcher(self, canAuthenticateAgainstProtectionSpace: challenge.protectionSpace) ?? false
        
        if result {
            didReceive(challenge: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil);
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        let policy: URLCache.StoragePolicy
        if let response = response as? HTTPURLResponse {
            policy = cacheStoragePolicy(for: dataTask.originalRequest, response: response)
        } else {
            policy = .notAllowed
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? NSError {
            if error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled {
                client?.urlProtocol(self, didFailWithError: error)
            }
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}

extension FlyNetworkCatcher {
    private func cacheStoragePolicy(for request: URLRequest?, response: HTTPURLResponse) -> URLCache.StoragePolicy {
        var cacheable: Bool
        let result: URLCache.StoragePolicy
        
        switch response.statusCode {
        case 200, 203, 206, 301, 304, 404, 410:
            cacheable = true
        default:
            cacheable = false
        }
        
        if cacheable, let responseHeader = (response.allHeaderFields["Cache-Control"] as? String)?.lowercased() {
            cacheable = responseHeader.range(of: "no-store") == nil
        }
        
        if cacheable, let requestHeader = request?.allHTTPHeaderFields?["Cache-Control"]?.lowercased() {
            cacheable = requestHeader.range(of: "no-store") == nil || requestHeader.range(of: "no-cache") == nil
        }
        
        if cacheable {
            if request?.url?.scheme?.lowercased() == "https" {
                result = .allowedInMemoryOnly
            } else {
                result = .allowed
            }
        } else {
            result = .notAllowed
        }
        
        return result
    }
}
