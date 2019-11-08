//
//  AVAssetResourceLoadingDataRequest+Output.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/1.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation

private var RuntimeKeyReceivedBytesCount = "RuntimeKeyReceivedBytesCount"

extension AVAssetResourceLoadingRequest: MediaLoaderRequestable {
    var requestedOffset: Int64 {
        return dataRequest?.requestedOffset ?? 0
    }
    
    var requestedLength: Int64 {
        return Int64(dataRequest?.requestedLength ?? 0)
    }
    
    var currentOffset: Int64 {
        return dataRequest?.currentOffset ?? 0
    }
    
    func write(contentInfo: MediaContentInfo) {
        contentInformationRequest?.isByteRangeAccessSupported = contentInfo.isByteRangeAccessSupported
        contentInformationRequest?.contentLength = contentInfo.contentLength
        contentInformationRequest?.contentType = contentInfo.contentType
    }
    
    func write(response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        guard let contentInfo = MediaContentInfo(response: httpResponse) else {
            return
        }
        
        write(contentInfo: contentInfo)
    }
    
    func write(data: Data) {
        print(Thread.current)
        dataRequest?.respond(with: data)
    }
    
    
    func writeCompletion(error: Error?) {
        if isFinished {
            return
        }
        if let error = error, (error as NSError).code != NSURLErrorCancelled {
            finishLoading(with: error)
        } else {
            finishLoading()
        }
    }
}

