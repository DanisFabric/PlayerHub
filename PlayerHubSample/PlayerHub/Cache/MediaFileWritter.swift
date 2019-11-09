//
//  FileWritter.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/8.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation

class MediaFileWritter {
    var didAppendDataHandler: ((Int64, Data) -> Void)?
    
    let videoURL: URL
    let contentInfoURL: URL
    
    private var outputStream: OutputStream?
    
    var contentInfo: MediaContentInfo?
    var originalFileSize: Int64
    var currentFileSize: Int64
    
    init(sourceURL: URL) {
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
        let bytes = [UInt8](data)
        self.outputStream?.write(bytes, maxLength: bytes.count)
        currentFileSize += Int64(bytes.count)
        
        print("写文件 -> \(currentFileSize)-\(FileUtils.fileSize(of: videoURL))")
    }
    
    func openStream() {
        self.outputStream = OutputStream(url: self.videoURL, append: true)
        self.outputStream?.open()
    }
    
    func closeStream() {
        self.outputStream?.close()
        self.outputStream = nil
    }
    
    func readData(in range: Range<Int64>) -> Data? {
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
                print("读文件 -> \(range.lowerBound)-\(range.upperBound)")
                
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
