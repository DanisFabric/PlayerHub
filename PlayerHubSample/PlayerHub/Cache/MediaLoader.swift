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
    
    func write(response: URLResponse)
    func write(contentInfo: MediaContentInfo)
    func write(data: Data)
    func writeCompletion(error: Error?)
}

class MediaLoader {
    
    private(set) var requests = [MediaLoaderRequestable]()
    
    private var tasks = [DataDownloader.Task]()
    
    private let queue = DispatchQueue(label: "com.danis.MediaLoader.FileQueue")

    // 只有FullDataTask能够向文件写数据
    private var sourceURL: URL!
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
    }
}

extension MediaLoader {
    func add(request: MediaLoaderRequestable) {
        let task = DataDownloader.shared.download(from: sourceURL, offsetBytes: request.requestedOffset, contentBytes: request.requestedLength, didReceiveResponseHandler: { (response) in
            request.write(response: response)
        }, didReceiveDataHandler: {(data) in
            request.write(data: data)
        }, didCompleteHandler: { error in
            request.writeCompletion(error: error)
            
            self.remove(request: request)
        })
        task.requestHash = request.hash
        task.resume()
        tasks.append(task)
        
        print("tasks->\(tasks.count)")
    }
    
    func remove(request: MediaLoaderRequestable) {
        if let index = tasks.firstIndex(where: { (task) -> Bool in
            return task.requestHash == request.hash
        }) {
            tasks.remove(at: index).cancel()
        }
        print("tasks->\(tasks.count)")
    }
    
    func cancel() {
        tasks.forEach { (task) in
            task.cancel()
        }
        tasks.removeAll()
        requests.removeAll()
    }
}
