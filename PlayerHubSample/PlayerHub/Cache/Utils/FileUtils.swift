//
//  FileUtils.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/1.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation

extension URL {
    private var modificationDate: Date? {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: self.path) {
            if let date = attributes[.modificationDate] as? Date {
                return date
            }
        }
        return nil
    }
}


class FileUtils {
    static func fileSize(of fileURL: URL) -> Int64 {
        return 0
    }
    
    
    
}

/// MARK: - 构建缓存w目录
extension FileUtils {
    static func cacheDirectory() -> URL {
        let dir = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("video_cache")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
        return dir
    }
    
    static func destinationURL(of sourceURL: URL) -> URL {
        
    }
    
    static func contentInfoURL(of sourceURL: URL) -> URL {
        
    }
    
}

/// MARK: - 对缓存文件进行操作
extension FileUtils {
    static func clearCacheFiles() {
        
    }
    
    static func clearOldCacheFiles() {
        
    }
    
    
}
