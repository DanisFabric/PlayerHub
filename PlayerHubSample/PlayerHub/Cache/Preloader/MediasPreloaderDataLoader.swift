//
//  MediasPreloaderDataDownloader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/11.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


class MediasPreloaderDataLoader {
    var didCompleteHandler: ((Error?) -> Void)?
    
    let sourceURL: URL
    private let fileIO: MediaFileIO
    private var dataTask: DataDownloader.Task?
    
    var expectedSize: Int64 = 2 * 1024 * 1024
    
    private let networkLock = NSLock()
    
    private(set) var isDataEnoughWhenInit = false
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.fileIO = MediaFileIO(sourceURL: sourceURL)
        
        if let contentInfo = fileIO.contentInfo {
            if fileIO.originalFileSize == contentInfo.contentLength {
                // 本地文件完整
                isDataEnoughWhenInit = true
            } else if fileIO.originalFileSize >= expectedSize {
                // 本地数据超过了预加载的数据
                isDataEnoughWhenInit = true
            } else {
                // 本地数据不足，下载剩余部分
                fileIO.openStream()
                dataTask = DataDownloader.shared.download(from: sourceURL, offsetBytes: fileIO.originalFileSize, contentBytes: expectedSize - fileIO.originalFileSize, didReceiveResponseHandler: { (response) in
                    self.onReceived(response: response)
                }, didReceiveDataHandler: { (data) in
                    self.onReceived(data: data)
                }, didCompleteHandler: { (error) in
                    self.onCompleted(error: error)
                })
            }
        } else {
            // 本地无数据，从0开始下载数据
            assert(fileIO.originalFileSize == 0, "无contentInfo的情况下，不可能下载了文件数据")
            
            fileIO.openStream()
            dataTask = DataDownloader.shared.download(from: sourceURL, offsetBytes: 0, contentBytes: expectedSize, didReceiveResponseHandler: { (response) in
                self.onReceived(response: response)
            }, didReceiveDataHandler: { (data) in
                self.onReceived(data: data)
            }, didCompleteHandler: { (error) in
                self.onCompleted(error: error)
            })
        }
    }
    
    func resume() {
        dataTask?.resume()
    }
    
    func suspend() {
        dataTask?.suspend()
    }
    
    func cancel() {
        dataTask?.cancel()
    }
    
    var isRunning: Bool {
        return dataTask?.dataTask.state == URLSessionTask.State.running
    }
    
    var isSuspended: Bool {
        return dataTask?.dataTask.state == URLSessionTask.State.suspended
    }
    
}

extension MediasPreloaderDataLoader {
    private func onReceived(response: URLResponse) {
        networkLock.lock()
        defer {
            networkLock.unlock()
        }
        
        if self.fileIO.contentInfo == nil {
            self.fileIO.write(response: response)
        }
    }
    
    private func onReceived(data: Data) {
        networkLock.lock()
        defer {
            networkLock.unlock()
        }
        
        self.fileIO.write(data: data)
    }
    
    private func onCompleted(error: Error?) {
        networkLock.lock()
        defer {
            networkLock.unlock()
        }
        self.fileIO.closeStream()
        
        didCompleteHandler?(error)
    }
}
