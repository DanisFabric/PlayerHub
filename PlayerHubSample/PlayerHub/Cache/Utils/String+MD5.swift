//
//  String+MD5.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/9.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation
import CommonCrypto


extension String {
    var md5: String {
        let strData = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_MD5_DIGEST_LENGTH))
        
        /// CC_MD5 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
        /// Calls the given closure with a pointer to the underlying unsafe bytes of the strData’s contiguous storage.
        strData.withUnsafeBytes {
            CC_MD5($0.baseAddress, UInt32(strData.count), &digest)
        }
        
        var md5String = ""
        for byte in digest {
            md5String += String(format:"%02x", UInt8(byte))
        }
        
        return md5String
    }
}
