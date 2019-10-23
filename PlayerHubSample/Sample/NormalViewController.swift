//
//  NormalViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/12.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class NormalViewController: UIViewController {
    
    let shortVideo = "http://flv3.bn.netease.com/tvmrepo/2018/6/9/R/EDJTRAD9R/SD/EDJTRAD9R-mobile.mp4"
    let longVideo = "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"
    
    let container = UIView()
    
    let playButton: UIButton = {
        let temp = UIButton(type: .system)
        temp.setTitle("播放", for: .normal)
        
        return temp
    }()
    
    deinit {
        print("deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.backgroundColor = UIColor.red

        view.addSubview(container)
        view.addSubview(playButton)
        
        container.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(container.snp.width).multipliedBy(9.0 / 16.0)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .plain, target: self, action: #selector(onTouch(nextButton:)))
        playButton.addTarget(self, action: #selector(onTouch(playButton:)), for: .touchUpInside)
    }

    @objc private func onTouch(playButton: UIButton) {
        PlayerHub.shared.addPlayer(to: container)
//        PlayerHub.shared.replace(with: URL(string: longVideo)!, )
    }
    
    @objc private func onTouch(nextButton: AnyObject) {
        let nextVC = NextViewController()
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
