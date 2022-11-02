//
//  FlyURLSessionDemux.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/2.
//

import Foundation

class FlyURLSessionDemux: NSObject {
    
    static let shared: FlyURLSessionDemux = FlyURLSessionDemux(configuration: .default)
    
    let configuration: URLSessionConfiguration
    private(set) lazy var session: URLSession = URLSession(configuration: configuration,
                                                           delegate: self,
                                                           delegateQueue: sessionDelegateQueue)
    
    private var taskInfoByTaskID: [Int: TaskInfo] = [:]
    private let taskInfoByTaskIDQueue: DispatchQueue = DispatchQueue(label: "com.FlyKite.FlyTools.FlyURLSessionDemux",
                                                                     attributes: .concurrent)
    private let sessionDelegateQueue: OperationQueue = OperationQueue()
    
    struct TaskInfo {
        let task: URLSessionDataTask
        let delegate: URLSessionDataDelegate
        let modes: [RunLoop.Mode]
    }
    
    private init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
        sessionDelegateQueue.maxConcurrentOperationCount = 1
        sessionDelegateQueue.name = "FlyURLSessionDemux"
        super.init()
        session.sessionDescription = "FlyURLSessionDemux"
    }
    
    func dataTask(_ request: URLRequest, delegate: URLSessionDataDelegate, modes: [RunLoop.Mode]) -> URLSessionDataTask {
        let modes = modes.isEmpty ? [.default] : modes
        let task = session.dataTask(with: request)
        let taskInfo = TaskInfo(task: task, delegate: delegate, modes: modes)
        taskInfoByTaskIDQueue.async(flags: .barrier) {
            self.taskInfoByTaskID[task.taskIdentifier] = taskInfo
        }
        return task
    }
    
    private func taskInfo(for task: URLSessionTask) -> TaskInfo? {
        return taskInfoByTaskIDQueue.sync {
            taskInfoByTaskID[task.taskIdentifier]
        }
    }
}

extension FlyURLSessionDemux: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        guard let taskInfo = taskInfo(for: task), taskInfo.delegate.responds(to: #selector(urlSession(_:task: willPerformHTTPRedirection:newRequest:completionHandler:))) else {
            completionHandler(request)
            return
        }
        taskInfo.delegate.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let taskInfo = taskInfo(for: task), taskInfo.delegate.responds(to: #selector(urlSession(_:task:didReceive:completionHandler:))) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        taskInfo.delegate.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        guard let taskInfo = taskInfo(for: task), taskInfo.delegate.responds(to: #selector(urlSession(_:task:needNewBodyStream:))) else {
            completionHandler(nil)
            return
        }
        taskInfo.delegate.urlSession?(session, task: task, needNewBodyStream: completionHandler)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let taskInfo = taskInfo(for: task) else { return }
        taskInfo.delegate.urlSession?(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let taskInfo = taskInfo(for: task) else { return }
        taskInfoByTaskIDQueue.async(flags: .barrier) {
            self.taskInfoByTaskID[task.taskIdentifier] = nil
        }
        guard taskInfo.delegate.responds(to: #selector(urlSession(_:task:didCompleteWithError:))) else { return }
        taskInfo.delegate.urlSession?(session, task: task, didCompleteWithError: error)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let taskInfo = taskInfo(for: dataTask), taskInfo.delegate.responds(to: #selector(urlSession(_:dataTask:didReceive:completionHandler:))) else {
            completionHandler(.allow)
            return
        }
        taskInfo.delegate.urlSession?(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        guard let taskInfo = taskInfo(for: dataTask) else { return }
        taskInfo.delegate.urlSession?(session, dataTask: dataTask, didBecome: downloadTask)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let taskInfo = taskInfo(for: dataTask) else { return }
        taskInfo.delegate.urlSession?(session, dataTask: dataTask, didReceive: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        guard let taskInfo = taskInfo(for: dataTask), taskInfo.delegate.responds(to: #selector(urlSession(_:dataTask:willCacheResponse:completionHandler:))) else {
            completionHandler(proposedResponse)
            return
        }
        taskInfo.delegate.urlSession?(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler)
    }
}
