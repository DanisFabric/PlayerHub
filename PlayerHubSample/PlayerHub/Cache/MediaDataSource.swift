//
//  MediaDataProvider.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/8.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


class MediaDataSource {
    let queue = DispatchQueue(label: "test")
    
    private var writter: MediaFileWritter
    private var dataTask: DataDownloader.Task?
    
    private let sourceURL: URL
    
    private var isFileCompleted = false
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.writter = MediaFileWritter(sourceURL: sourceURL)
        
        if let contentInfo = writter.contentInfo {
            if writter.originalFileSize == contentInfo.contentLength {
                // 本地文件完整，直接返回给播放器播放
                self.isFileCompleted = true
            } else {
                // 本地文件未下载完成，断点续传
                dataTask = DataDownloader.shared.download(from: sourceURL, offsetBytes: writter.originalFileSize, contentBytes: contentInfo.contentLength - writter.originalFileSize, didReceiveResponseHandler: { (response) in
                    self.onReceived(response: response)
                }, didReceiveDataHandler: { (data) in
                    self.onReceived(data: data)
                }, didCompleteHandler: { (error) in
                    self.onCompleted(error: error)
                })
            }
        } else {
            // 没有下载过
            assert(writter.originalFileSize == 0, "无contentInfo的情况下，不可能下载了文件数据")
            
            dataTask = DataDownloader.shared.download(from: sourceURL, offsetBytes: 0, contentBytes: nil, didReceiveResponseHandler: { (response) in
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

extension MediaDataSource {
    private func onReceived(response: URLResponse) {
        if writter.contentInfo == nil {
            writter.write(response: response)
        }
    }
    
    private func onReceived(data: Data) {
        writter.write(data: data)
    }
    
    private func onCompleted(error: Error?) {
        writter.closeStream()
        
        if error == nil {
            self.isFileCompleted = true
        }
    }
}
