//
//  MediaContentInfo.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/31.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import MobileCoreServices

struct MediaContentInfo: Codable {
    let isByteRangeAccessSupported: Bool
    let contentLength: Int64
    let contentType: String
    
    init?(response: HTTPURLResponse) {
        // 将headers的key都转换为小写
        var headers = [String: Any]()
        for key in response.allHeaderFields.keys {
            let lowercased = (key as! String).lowercased()
            
            headers[lowercased] = response.allHeaderFields[key]
        }
        isByteRangeAccessSupported = (headers["accept-ranges"] as? String) == "bytes"
        if let contentLengthText = headers["content-length"] as? String, let contentLength = Int64(contentLengthText) {
            self.contentLength = contentLength
        } else {
            return nil
        }

        if let mimeType = response.mimeType,
            let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() {
            self.contentType = contentType as String
        } else {
            return nil
        }
    }
}
