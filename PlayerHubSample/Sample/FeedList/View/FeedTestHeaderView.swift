//
//  FeedTestHeaderView.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/25.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class FeedTestHeaderView: UIView {

    let titleLabel: UILabel = {
        let temp = UILabel()
        temp.textColor = UIColor.black
        temp.font = UIFont.systemFont(ofSize: 16)
        temp.numberOfLines = 0
        
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.blue
        titleLabel.backgroundColor = UIColor.green
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
