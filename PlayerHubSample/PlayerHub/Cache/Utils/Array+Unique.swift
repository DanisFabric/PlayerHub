//
//  Array+Unique.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/12.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


extension Array where Element:Hashable {
    var unique:[Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
}
