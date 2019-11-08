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
    
    init(sourceURL: URL) {
        self.videoURL = FileUtils.videoURL(of: sourceURL)
        self.contentInfoURL = FileUtils.contentInfoURL(of: sourceURL)
        
        if let contentInfoData = try? Data(contentsOf: contentInfoURL) {
            contentInfo = try? JSONDecoder().decode(MediaContentInfo.self, from: contentInfoData)
        }
        originalFileSize = FileUtils.fileSize(of: videoURL)
    }
    
    var contentInfo: MediaContentInfo?
    var originalFileSize: Int64
    
    func write(response: URLResponse) {
        
    }
    
    func write(data: Data) {
        
    }
    
    func openStream() {
        self.outputStream = OutputStream(url: self.videoURL, append: true)
        self.outputStream?.open()
    }
    
    func closeStream() {
        self.outputStream?.close()
        self.outputStream = nil
    }
}
