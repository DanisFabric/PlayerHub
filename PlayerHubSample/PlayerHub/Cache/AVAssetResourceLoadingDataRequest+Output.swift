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
}

extension AVAssetResourceLoadingRequest: MediaLoaderOutputable {
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
        receivedBytesCount += Int64(data.count)
        
        dataRequest?.respond(with: data)
    }
    
    
    func writeCompletion(error: Error?) {
        if isFinished {
            return
        }
        if let error = error {
            finishLoading(with: error)
        } else {
            finishLoading()
        }
    }
}

extension AVAssetResourceLoadingRequest {
    var receivedBytesCount: Int64 {
        get {
            return (objc_getAssociatedObject(self, &RuntimeKeyReceivedBytesCount) as? Int64) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &RuntimeKeyReceivedBytesCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var totalBytesExpectedToWrite: Int {
        return dataRequest!.requestedLength
    }
}
