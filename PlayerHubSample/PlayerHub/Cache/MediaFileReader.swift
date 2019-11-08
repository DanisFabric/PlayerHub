//
//  FileReader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/8.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


class MediaFileReader {
    let videoURL: URL
    let contentInfoURL: URL
    
    let queue: DispatchQueue
    let requestRange: Range<Int64>
    
    init(sourceURL: URL, queue: DispatchQueue, requestRange: Range<Int64>) {
        self.videoURL = FileUtils.videoURL(of: sourceURL)
        self.contentInfoURL = FileUtils.contentInfoURL(of: sourceURL)
        self.queue = queue
        self.requestRange = requestRange
    }
    
    func isContentInfoValid() -> Bool {
        return contentInfoURL.isExists
    }
    
    func availableRange() -> Range<Int64> {
        return .init(uncheckedBounds: (0, 0))
    }
    
    func readDataAsync(in range: Range<Int64>, completion: ((Result<Data, Error>) -> Void)?) {
        queue.async {
             
        }
    }
    
    func readContentInfoAsync(completion: ((Result<MediaContentInfo, Error>) -> Void)?) {
        queue.async {
            
        }
    }
    
    func close() {
        
    }
}
