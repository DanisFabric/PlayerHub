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
    private let dataSource: MediaDataSource
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.dataSource = MediaDataSource(sourceURL: sourceURL)
    }
}

extension MediaLoader {
    func add(request: MediaLoaderRequestable) {
        queue.async {
            if self.dataSource.isReachable(output: request) {
                self.dataSource.resumeDataTask()
                self.dataSource.add(output: request)
            } else {
                print("不在文件中- \(request.requestedOffset)")
                self.dataSource.resumeDataTask()
                self.dataSource.add(output: request)
                
//                self.dataSource.suspendDataTask()
//
//                let task = DataDownloader.shared.download(from: self.sourceURL, offsetBytes: request.requestedOffset, contentBytes: request.requestedLength, didReceiveResponseHandler: { (response) in
//                    request.write(response: response)
//                }, didReceiveDataHandler: {(data) in
//                    request.write(data: data)
//                }, didCompleteHandler: { error in
//                    request.writeCompletion(error: error)
//
//                    self.remove(request: request)
//                })
//                task.requestHash = request.hash
//                task.resume()
//                self.tasks.append(task)
            }
        }
        
        
    }
    
    func remove(request: MediaLoaderRequestable) {
        queue.async {
            self.dataSource.remove(output: request)
            
//            if self.dataSource.contains(output: request) {
//                self.dataSource.remove(output: request)
//            } else {
//                if let index = self.tasks.firstIndex(where: { (task) -> Bool in
//                    return task.requestHash == request.hash
//                }) {
//                    self.tasks.remove(at: index).cancel()
//                }
//            }
            
        }
        
    }
    
    func cancel() {
        queue.async {
//            self.tasks.forEach { (task) in
//                task.cancel()
//            }
            self.tasks.removeAll()
            self.dataSource.cancel()
        }
    }
}
