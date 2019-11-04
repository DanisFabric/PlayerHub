//
//  MediaLoader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/31.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation

protocol MediaLoaderOutputable: NSObject {
    func write(response: URLResponse)
    func write(contentInfo: MediaContentInfo)
    func write(data: Data)
    func writeCompletion(error: Error?)
}

protocol MediaLoaderRequestable: NSObject {
    var requestedOffset: Int64 { get }
    var requestedLength: Int64 { get }
}

class MediaLoader {
    private let sourceURL: URL
    
    private(set) var requests = [MediaLoaderRequestable]()
    private(set) var outputs = [MediaLoaderOutputable]()
    
    private var tasks = [DataDownloader.Task]()
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
    }
}

extension MediaLoader {
    func add(request: MediaLoaderRequestable, to output: MediaLoaderOutputable) {
        let task = DataDownloader.shared.download(from: sourceURL,
                                                  offsetBytes: request.requestedOffset,
                                                  contentBytes: request.requestedLength,
                                                  didReceiveResponseHandler: { (response) in output.write(response: response) },
                                                  didReceiveDataHandler: { (data) in output.write(data: data) })
        { (error) in
            output.writeCompletion(error: error)
        }
        task.requestHash = request.hash
        task.resume()
        tasks.append(task)
    }
    
    func remove(request: MediaLoaderRequestable) {
        if let index = tasks.firstIndex(where: { (task) -> Bool in
            return task.requestHash == request.hash
        }) {
            tasks.remove(at: index).cancel()
        }
    }
    
    func remove(output: MediaLoaderOutputable) {
        outputs.removeAll { (temp) -> Bool in
            return temp == output
        }
    }
    
    func cancel() {
        tasks.forEach { (task) in
            task.cancel()
        }
        tasks.removeAll()
        requests.removeAll()
        outputs.removeAll()
    }
}
