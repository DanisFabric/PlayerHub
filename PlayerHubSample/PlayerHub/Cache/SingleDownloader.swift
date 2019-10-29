//
//  SingleDownloader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/29.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation

let queue = OperationQueue()

class SingleDownloader: NSObject {
    var didReceiveResponseHandler: ((URLResponse) -> Void)?
    var didReceiveDataHandler: ((Data) -> Void)?
    var didFinishWithErrorHandler: ((Error?) -> Void)?
    
    private var session: URLSession!
    private var task: URLSessionDataTask!
    
    init(url: URL, offset: UInt64, length: UInt64, isToEnd: Bool) {
        super.init()
        
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: queue)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
//        request.setValue(String(format: "bytes=%lld-%lld", offset, offset + length - 1), forHTTPHeaderField: "Range")
        task = session.dataTask(with: request)
    }
    
    func start() {
        task.resume()
    }
    
}


extension SingleDownloader: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        didReceiveResponseHandler?(response)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        didReceiveDataHandler?(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        didFinishWithErrorHandler?(error)
    }
}
