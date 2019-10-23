//
//  PlayerControlable.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/23.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

protocol PlayerControlable {
    var gravity: Player.Gravity { get set }
    var playerView: PlayerView { get }
    var contentView: UIView { get }
    
    func replace(with url: URL, coverUrl: URL?, placeholder: UIImage?)
}
