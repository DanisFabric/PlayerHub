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
    
    var isExists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}


class FileUtils {
    static func fileSize(of fileURL: URL) -> Int64 {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
            if let size = attributes[.size] as? Int64 {
                return size
            }
        }
        return 0
    }
    
    static func createFileIfNeeded(of fileURL: URL) {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
    }
    
    static func createDirectoryIfNeeded(of directoryURL: URL) {
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    

}

/// MARK: - 构建缓存w目录
extension FileUtils {
    static func cacheDirectory() -> URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("video_cache")
    }
    
    static func videoURL(of sourceURL: URL) -> URL {
        return cacheDirectory().appendingPathComponent(sourceURL.absoluteString + ".cache")
    }
    
    static func contentInfoURL(of sourceURL: URL) -> URL {
        return cacheDirectory().appendingPathComponent(sourceURL.absoluteString + ".header")
    }
    
    
}

/// MARK: - 对缓存文件进行操作
extension FileUtils {
    static func clearCacheFiles() {
        try? FileManager.default.removeItem(at: cacheDirectory())
    }
}
