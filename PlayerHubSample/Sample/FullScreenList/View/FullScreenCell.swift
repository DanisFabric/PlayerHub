//
//  FullScreenCell.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/21.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit
import SnapKit

class FullScreenCell: UITableViewCell {
    let videoContainer = UIView()
    let videoImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        videoImageView.contentMode = .scaleAspectFit
        contentView.backgroundColor = UIColor.black
        
        contentView.addSubview(videoContainer)
        videoContainer.addSubview(videoImageView)
        
        videoContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        videoImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
