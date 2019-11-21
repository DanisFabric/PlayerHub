//
//  MediaLoader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/31.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation

protocol MediaLoaderRequestable: NSObject {
    var requestedOffset: Int64 { get }
    var requestedLength: Int64 { get }
    var currentOffset: Int64 { get }
    var isFinished: Bool { get }
    var isContentInfoReuqest: Bool { get }
    
    func write(response: URLResponse)
    func write(contentInfo: MediaContentInfo)
    func write(data: Data)
    func writeCompletion(error: Error?)
}

class MediaLoader {
    private(set) var requests = [MediaLoaderRequestable]()
    
    private var tasks = [DataDownloader.Task]()
    
    private let queue = DispatchQueue(label: "com.danis.medialoader.queue")

    private let sourceURL: URL
    private let dataLoader: MediaDataLoader
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.dataLoader = MediaDataLoader(sourceURL: sourceURL)
        
    }
}

extension MediaLoader {
    func add(request: MediaLoaderRequestable) {
        queue.async {
            
            if self.dataLoader.isReachable(output: request) {
                self.dataLoader.resumeDataTask()
                self.dataLoader.add(output: request)
            } else {
                print("不在文件中- \(request.requestedOffset)")
                
                self.dataLoader.suspendDataTask()
                
                let task = DataDownloader.shared.download(from: self.sourceURL, offsetBytes: request.requestedOffset, contentBytes: request.requestedLength, priority: URLSessionTask.highPriority, didReceiveResponseHandler: { (response) in
                    request.write(response: response)
                }, didReceiveDataHandler: { (data) in
                    request.write(data: data)
                }) { (error) in
                    request.writeCompletion(error: error)
                }
                task.requestHash = request.hash
                task.resume()
                self.tasks.append(task)
            }
        }
        
        
    }
    
    func remove(request: MediaLoaderRequestable) {
        queue.async {
            self.dataLoader.remove(output: request)
            
            if self.dataLoader.contains(output: request) {
                self.dataLoader.remove(output: request)
            } else {
                if let index = self.tasks.firstIndex(where: { (task) -> Bool in
                    return task.requestHash == request.hash
                }) {
                    self.tasks.remove(at: index).cancel()
                }
            }
        }
        
    }
    
    func cancel() {
        queue.async {
            self.tasks.forEach { (task) in
                task.cancel()
            }
            self.tasks.removeAll()
            self.dataLoader.cancel()
        }
    }
}
