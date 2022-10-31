//
//  FlyURLProtocol.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/27.
//

import Foundation

public class FlyNetworkPatcher: URLProtocol {
    
    static var fetchDomains: [String] = []
    
    static let supportedSchemes: [String] = ["http", "https"]
    
    private struct Constant {
        static let recursiveRequestKey: String = "com.apple.dts.CustomHTTPProtocol"
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        guard
            let url = request.url,
            let scheme = url.scheme,
            supportedSchemes.contains(scheme.lowercased()),
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
//        NSURLRequest *      result;
//
//        assert(request != nil);
//        // can be called on any thread
//
//        // Canonicalising a request is quite complex, so all the heavy lifting has
//        // been shuffled off to a separate module.
//
//        result = CanonicalRequestForRequest(request);
//
//        [self customHTTPProtocol:nil logWithFormat:@"canonicalized %@ to %@", [request URL], [result URL]];
//
//        return result;
    }
    
    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
//        self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
//        if (self != nil) {
//            // All we do here is log the call.
//            [[self class] customHTTPProtocol:self logWithFormat:@"init for %@ from <%@ %p>", [request URL], [client class], client];
//        }
//        return self;
    }
    
    public override func startLoading() {
//        var calculatedModes: [RunLoop.Mode] = [.default]
//        let currentMode = RunLoop.current.currentMode
//        if let currentMode = currentMode, currentMode != .default {
//            calculatedModes.append(currentMode)
//        }
////        self.modes = calculatedModes
//        guard let recursiveRequest = (request as NSURLRequest).copy() as? NSMutableURLRequest else { return }
//        FlyNetworkPatcher.setProperty(true, forKey: Constant.recursiveRequestKey, in: recursiveRequest)
//        startTime = Date.timeIntervalSinceReferenceDate
//        clientThread = Thread.current
//
//
//        NSMutableURLRequest *   recursiveRequest;
//        NSMutableArray *        calculatedModes;
//        NSString *              currentMode;
//
//        // At this point we kick off the process of loading the URL via NSURLSession.
//        // The thread that calls this method becomes the client thread.
//
//        assert(self.clientThread == nil);           // you can't call -startLoading twice
//        assert(self.task == nil);
//
//        // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at
//        // you UIWebView!) we can be called from a non-standard thread which then runs a
//        // non-standard run loop mode waiting for the request to finish.  We detect this
//        // non-standard mode and add it to the list of run loop modes we use when scheduling
//        // our callbacks.  Exciting huh?
//        //
//        // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode"
//        // but it's better not to hard-code that here.
//
//        assert(self.modes == nil);
//        calculatedModes = [NSMutableArray array];
//        [calculatedModes addObject:NSDefaultRunLoopMode];
//        currentMode = [[NSRunLoop currentRunLoop] currentMode];
//        if ( (currentMode != nil) && ! [currentMode isEqual:NSDefaultRunLoopMode] ) {
//            [calculatedModes addObject:currentMode];
//        }
//        self.modes = calculatedModes;
//        assert([self.modes count] > 0);
//
//        // Create new request that's a clone of the request we were initialised with,
//        // except that it has our 'recursive request flag' property set on it.
//
//        recursiveRequest = [[self request] mutableCopy];
//        assert(recursiveRequest != nil);
//
//        [[self class] setProperty:@YES forKey:kOurRecursiveRequestFlagProperty inRequest:recursiveRequest];
//
//        self.startTime = [NSDate timeIntervalSinceReferenceDate];
//        if (currentMode == nil) {
//            [[self class] customHTTPProtocol:self logWithFormat:@"start %@", [recursiveRequest URL]];
//        } else {
//            [[self class] customHTTPProtocol:self logWithFormat:@"start %@ (mode %@)", [recursiveRequest URL], currentMode];
//        }
//
//        // Latch the thread we were called on, primarily for debugging purposes.
//
//        self.clientThread = [NSThread currentThread];
//
//        // Once everything is ready to go, create a data task with the new request.
//
//        self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];
//        assert(self.task != nil);
//
//        [self.task resume];
    }
}
