//
//  UIColor+hex.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/24.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit


extension UIColor {
    convenience init(hex: UInt) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
