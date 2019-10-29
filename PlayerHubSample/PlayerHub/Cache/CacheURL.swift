//
//  CacheURL.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/29.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation

private let CacheURLPrefix = "PlayerCachable"

struct CacheURL {
    static func isCachable(url: URL) -> Bool {
        return url.absoluteString.hasPrefix(CacheURLPrefix)
    }
    
    static func cachableURL(from url: URL) -> URL {
        return URL(string: CacheURLPrefix + url.absoluteString)!
    }
    
    static func normalURL(from url: URL) -> URL {
        if isCachable(url: url) {
            return URL(string: url.absoluteString.replacingOccurrences(of: CacheURLPrefix, with: ""))!
        } else {
            return url
        }
    }
    
}
