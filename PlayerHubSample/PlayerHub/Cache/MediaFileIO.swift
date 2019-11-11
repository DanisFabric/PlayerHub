//
//  FileWritter.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/8.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation

/*
 * Writter 会同时进行写文件和读文件，以及文件大小等判断，所以使用互斥锁
 * 防止写数据同时读取数据
 * 防止多个线程同时写数据
 */

class MediaFileIO {
    var didAppendDataHandler: ((Int64, Data) -> Void)?
    
    let videoURL: URL
    let contentInfoURL: URL
    
    private var outputStream: OutputStream?
    
    var contentInfo: MediaContentInfo?
    var originalFileSize: Int64
    var currentFileSize: Int64
    
    private let dataLock = NSLock()
    
    init(sourceURL: URL) {
        dataLock.lock()
        defer {
            dataLock.unlock()
        }
        FileUtils.createDirectoryIfNeeded(of: FileUtils.cacheDirectory())
        
        self.videoURL = FileUtils.videoURL(of: sourceURL)
        FileUtils.createFileIfNeeded(of: self.videoURL)
        
        self.contentInfoURL = FileUtils.contentInfoURL(of: sourceURL)
        if let contentInfoData = try? Data(contentsOf: contentInfoURL) {
            contentInfo = try? JSONDecoder().decode(MediaContentInfo.self, from: contentInfoData)
        }
        
        originalFileSize = FileUtils.fileSize(of: videoURL)
        currentFileSize = originalFileSize
    }
    
    
    func write(response: URLResponse) {
        dataLock.lock()
        defer {
            dataLock.unlock()
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        guard let contentInfo = MediaContentInfo(response: httpResponse) else {
            return
        }
        
        guard let data = try? JSONEncoder().encode(contentInfo) else {
            return
        }
        
        self.contentInfo = contentInfo
        
        try? data.write(to: contentInfoURL)
    }
    
    func write(data: Data) {
        dataLock.lock()
        defer {
            dataLock.unlock()
        }
        let bytes = [UInt8](data)
        self.outputStream?.write(bytes, maxLength: bytes.count)
        currentFileSize += Int64(bytes.count)
    }
    
    func openStream() {
        dataLock.lock()
        defer {
            dataLock.unlock()
        }
        
        self.outputStream = OutputStream(url: self.videoURL, append: true)
        self.outputStream?.open()
    }
    
    func closeStream() {
        dataLock.lock()
        defer {
            dataLock.unlock()
        }
        
        self.outputStream?.close()
        self.outputStream = nil
    }
    
    func readData(in range: Range<Int64>) -> Data? {
        dataLock.lock()
        defer {
            dataLock.unlock()
        }
        
        if range.isEmpty {
            return nil
        }
        if range.lowerBound >= currentFileSize {
            return nil
        }
        guard let handle = try? FileHandle(forReadingFrom: videoURL) else {
            return nil
        }

        do {
            try handle.seek(toOffset: UInt64(range.lowerBound))
            if currentFileSize >= range.upperBound {
                let data = handle.readData(ofLength: Int(range.count))
                
                return data
            } else {
                return handle.readDataToEndOfFile()
            }
        } catch {
            print(error)
            
            return nil
        }
        
    }
}
