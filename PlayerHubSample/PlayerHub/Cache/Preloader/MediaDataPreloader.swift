//
//  MediasPreloaderDataDownloader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/11.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


class MediaDataPreloader {
    var didCompleteHandler: ((Error?) -> Void)?
    
    private let sourceURL: URL
    private let fileIO: MediaFileIO
    private var dataTask: DataDownloader.Task?
    
    var expectedSize: Int64 = 2 * 1024 * 1024
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.fileIO = MediaFileIO(sourceURL: sourceURL)
        
        if let contentInfo = fileIO.contentInfo {
            if fileIO.originalFileSize == contentInfo.contentLength {
                // 本地文件完整
            } else if fileIO.originalFileSize >= expectedSize {
                // 本地数据超过了预加载的数据
            } else {
                // 本地数据不足，下载剩余部分
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
    
}

extension MediaDataPreloader {
    private func onReceived(response: URLResponse) {
        
    }
    
    private func onReceived(data: Data) {
        
    }
    
    private func onCompleted(error: Error?) {
        
    }
}