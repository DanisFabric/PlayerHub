//
//  MediaLoader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/31.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation

class MediaLoader {
    private let sourceURL: URL
    
    private var requests = [AVAssetResourceLoadingRequest]()
    
    private var tasks = [DataDownloader.Task]()
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
    }
}

extension MediaLoader {
    func add(loadingRequest: AVAssetResourceLoadingRequest) {
        let task = DataDownloader.shared.download(from: sourceURL,
                                       offsetBytes: loadingRequest.dataRequest!.requestedOffset,
                                       contentBytes: Int64(loadingRequest.dataRequest!.requestedLength),
                                       didReceiveResponseHandler: { (response) in
                                        
                                        loadingRequest.write(response: response)
                                        
        }, didReceiveDataHandler: { (data) in
            loadingRequest.write(data: data)
        }) { (error) in
            loadingRequest.writeCompletion(error: error)
        }
        task.loadingRequest = loadingRequest
        task.resume()
        
        tasks.append(task)
    }
    
    func remove(loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = tasks.lastIndex(where: { (task) -> Bool in
            return task.loadingRequest == loadingRequest
        }) {
            tasks.remove(at: index).cancel()
        }
    }
    
    func cancel() {
        tasks.forEach { (task) in
            task.cancel()
        }
        tasks.removeAll()
    }
}
