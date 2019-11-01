//
//  MediaDownloader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/1.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation

class DataDownloader: NSObject {
    class Task {
        var didCompleteHandler: ((Error?) -> Void)?
        var didReceiveDataHandler: ((Data) -> Void)?
        var didReceiveResponseHandler: ((URLResponse) -> Void)?
        
        let dataTask: URLSessionDataTask

        var loadingRequest: AVAssetResourceLoadingRequest?
        
        init(sourceURL: URL, offsetBytes: Int64, contentBytes: Int64?, session: URLSession) {
            var request = URLRequest(url: sourceURL)
            if let contentBytes = contentBytes, contentBytes > 0 {
                request.setValue("bytes=\(offsetBytes)-\(offsetBytes + contentBytes - 1)", forHTTPHeaderField: "Range")
            } else {
                request.setValue("bytes=\(offsetBytes)-", forHTTPHeaderField: "Range")
            }
            request.cachePolicy = .reloadIgnoringLocalCacheData
            
            dataTask = session.dataTask(with: request)
        }
        
        func resume() {
            dataTask.resume()
        }
        
        func cancel() {
            dataTask.cancel()
        }
    }
    
    static let shared = DataDownloader()
    
    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    
    private var tasks = [Task]()
    
    func download(from sourceURL: URL,
                  offsetBytes: Int64,
                  contentBytes: Int64?,
                  didReceiveResponseHandler: ((URLResponse) -> Void)?,
                  didReceiveDataHandler: ((Data) -> Void)?,
                  didCompleteHandler: ((Error?) -> Void)?) -> Task {
        
        let task = Task(sourceURL: sourceURL, offsetBytes: offsetBytes, contentBytes: contentBytes, session: session)
        task.didReceiveResponseHandler = didReceiveResponseHandler
        task.didReceiveDataHandler = didReceiveDataHandler
        task.didCompleteHandler = didCompleteHandler
        
        tasks.append(task)
        
        return task
    }
}

extension DataDownloader: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        guard let currentTask = tasks.first(where: { $0.dataTask == dataTask }) else {
            completionHandler(.cancel)
            
            return
        }
        
        currentTask.didReceiveResponseHandler?(response)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let currentTask = tasks.first(where: { $0.dataTask == dataTask }) else {
            return
        }
        
        currentTask.didReceiveDataHandler?(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let currentTask = tasks.first(where: { $0.dataTask == task }) else {
            return
        }
        
        currentTask.didCompleteHandler?(error)
    }
}
