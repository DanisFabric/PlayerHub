//
//  MediasPreloader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/11.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


class MediasPreloader {
    static let shared = MediasPreloader()
    
    private var dataLoader: MediasPreloaderDataLoader?
    
    var loadingURL: URL? {
        return dataLoader?.sourceURL
    }
    
    private(set) var pendingURLs = [URL]()
    
    private init() {}
}

extension MediasPreloader {
    func resume() {
        if let dataLoader = dataLoader, dataLoader.isSuspended {
            dataLoader.resume()
        } else {
            preloadNextURL()
        }
    }
    
    func suspend() {
        dataLoader?.suspend()
    }
    
    func cancel() {
        dataLoader?.cancel()
        dataLoader = nil
        pendingURLs.removeAll()
    }
    
    
    func add(urls: [URL]) {
        pendingURLs.append(contentsOf: urls)
        pendingURLs = pendingURLs.unique        //  删除重复元素
    }
    
    func cancel(url: URL) {
        if loadingURL == url {
            // 当前正在下载，取消当前的下载，直接开始下一个
            dataLoader?.cancel()
            dataLoader = nil
        } else {
            pendingURLs.removeAll { (temp) -> Bool in
                return temp == url
            }
        }
    }
    
}

extension MediasPreloader {
    private func preloadNextURL() {
        guard pendingURLs.count > 0 else {
            return
        }
        let nextURL = pendingURLs.removeFirst()
        
        dataLoader = MediasPreloaderDataLoader(sourceURL: nextURL)
        if dataLoader!.isDataEnoughWhenInit {
            preloadNextURL()
        } else {
            dataLoader?.resume()
            
            dataLoader?.didCompleteHandler = { [weak self] error in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    if (error as NSError).code == NSURLErrorCancelled {
                        // 如果是取消，则不做任何事情,
                    } else {
                        strongSelf.preloadNextURL()
                    }
                } else {
                    strongSelf.preloadNextURL()
                }
            }
        }
    }
    private func suspendCurrent() {
        
    }
    
    private func resumeCurrent() {
        
    }
    
    private func cancelCurrent() {
        
    }
}
