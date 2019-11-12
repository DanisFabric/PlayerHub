//
//  MediaDataProvider.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/8.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


class MediaDataLoader {
    private let sourceURL: URL
    private let fileIO: MediaFileIO
    
    private var isFileCompleted = false
    private var dataTask: DataDownloader.Task?
    
    
    var outputs = [MediaLoaderRequestable]()
    
    private let networkLock = NSLock()
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.fileIO = MediaFileIO(sourceURL: sourceURL)
        
        if let contentInfo = fileIO.contentInfo {
            if fileIO.originalFileSize == contentInfo.contentLength {
                // 本地文件完整，直接返回给播放器播放
                self.isFileCompleted = true
            } else {
                // 本地文件未下载完成，断点续传
                fileIO.openStream()
                dataTask = DataDownloader.shared.download(from: sourceURL, offsetBytes: fileIO.originalFileSize, contentBytes: contentInfo.contentLength - fileIO.originalFileSize, priority: URLSessionTask.highPriority, didReceiveResponseHandler: { (response) in
                    self.onReceived(response: response)
                }, didReceiveDataHandler: { (data) in
                    self.onReceived(data: data)
                }, didCompleteHandler: { (error) in
                    self.onCompleted(error: error)
                })
            }
        } else {
            // 没有下载过
            assert(fileIO.originalFileSize == 0, "无contentInfo的情况下，不可能下载了文件数据")
            
            fileIO.openStream()
            dataTask = DataDownloader.shared.download(from: sourceURL, offsetBytes: 0, contentBytes: nil, priority: URLSessionTask.highPriority, didReceiveResponseHandler: { (response) in
                self.onReceived(response: response)
            }, didReceiveDataHandler: { (data) in
                self.onReceived(data: data)
            }, didCompleteHandler: { (error) in
                self.onCompleted(error: error)
            })
        }
    }
    
    func resumeDataTask() {
        dataTask?.resume()
    }
    
    func suspendDataTask() {
        dataTask?.suspend()
    }
    
    func cancelDataTask() {
        dataTask?.cancel()
    }
    
    
}

extension MediaDataLoader {
    func isReachable(output: MediaLoaderRequestable) -> Bool {
        return output.requestedOffset <= fileIO.currentFileSize
    }
    func add(output: MediaLoaderRequestable) {
        if let contentInfo = fileIO.contentInfo {
            output.write(contentInfo: contentInfo)
        }
        // 从fileIO读取数据
        let range = Range(uncheckedBounds: (output.currentOffset, output.requestedLength))
        if let data = fileIO.readData(in: range) {
            output.write(data: data)
            if data.count == range.count {
                output.writeCompletion(error: nil)
            } else {
                outputs.append(output)
            }
        } else {
            outputs.append(output)
        }
    }
    
    func remove(output: MediaLoaderRequestable) {
        outputs.removeAll { (temp) -> Bool in
            return temp == output
        }
    }
    
    func contains(output: MediaLoaderRequestable) -> Bool {
        return outputs.contains { (temp) -> Bool in
            return output == temp
        }
    }
    
    func cancel() {
        cancelDataTask()
        fileIO.closeStream()
        outputs.removeAll()
    }
}

extension MediaDataLoader {
    private func onReceived(response: URLResponse) {
        networkLock.lock()
        defer {
            networkLock.unlock()
        }
        
        if self.fileIO.contentInfo == nil {
            self.fileIO.write(response: response)
        }
        self.outputs.filter({ (output) -> Bool in
            return !output.isFinished
        }).forEach { (output) in
            output.write(response: response)
        }
    }
    
    private func onReceived(data: Data) {
        networkLock.lock()
        defer {
            networkLock.unlock()
        }
        self.fileIO.write(data: data)
        
        self.outputs.filter({ (output) -> Bool in
            return !output.isFinished
        }).forEach { (output) in
            let range = Range(uncheckedBounds: (output.currentOffset, output.requestedLength))
            if let data = self.fileIO.readData(in: range) {
                output.write(data: data)
                if output.currentOffset == output.requestedOffset + output.requestedLength {
                    output.writeCompletion(error: nil)
                }
            }
        }
    }
    
    private func onCompleted(error: Error?) {
        networkLock.lock()
        defer {
            networkLock.unlock()
        }
        self.fileIO.closeStream()
        
        if error == nil {
            self.isFileCompleted = true
        }
        
        self.outputs.filter { (output) -> Bool in
            return !output.isFinished
        }.forEach { (output) in
            output.writeCompletion(error: error)
        }
        self.outputs.removeAll()
    }
}
