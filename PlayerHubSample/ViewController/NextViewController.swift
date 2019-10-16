//
//  NextViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/14.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {
    
    let container = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        container.backgroundColor = UIColor.red

        view.addSubview(container)
        
        container.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(container.snp.width).multipliedBy(9.0 / 16.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PlayerHub.shared.move(to: container)
    }
}
