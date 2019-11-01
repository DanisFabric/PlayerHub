//
//  ResourceLoader.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/29.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import AVFoundation

class ResourceLoaderProxy: NSObject, AVAssetResourceLoaderDelegate {
    
    private var loader: MediaLoader?
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let originURL = loadingRequest.request.url else {
            return false
        }
        
        guard CacheURL.containsCacheScheme(url: originURL) else {
            return false
        }
        
        let sourceUrl = CacheURL.removeCacheScheme(from: originURL)
        
        if loader == nil {
            loader = MediaLoader(sourceURL: sourceUrl)
        }
        loader?.add(loadingRequest: loadingRequest)
        
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        loader?.remove(loadingRequest: loadingRequest)
    }
    
    func cancel() {
        loader?.cancel()
    }
}
