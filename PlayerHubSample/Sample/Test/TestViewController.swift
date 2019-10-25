//
//  TestViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/25.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    let loadingView = DouyinLoadingView()
    
    private let startButton: UIButton = {
        let temp = UIButton(type: .system)
        temp.setTitle("开始", for: .normal)
        
        return temp
    }()
    
    private let stopButton: UIButton = {
        let temp = UIButton(type: .system)
        temp.setTitle("停止", for: .normal)
        
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        
        view.addSubview(loadingView)
        view.addSubview(startButton)
        view.addSubview(stopButton)
        
        loadingView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(2)
        }
        
        startButton.snp.makeConstraints { (make) in
            make.top.equalTo(loadingView.snp.bottom).offset(24)
            make.right.equalTo(view.snp.centerX).offset(-12)
        }

        stopButton.snp.makeConstraints { (make) in
            make.top.equalTo(loadingView.snp.bottom).offset(24)
            make.left.equalTo(view.snp.centerX).offset(12)
        }
        
        startButton.addTarget(self, action: #selector(onTouch(startButton:)), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(onTouch(stopButton:)), for: .touchUpInside)
    }
    
    
    @objc private func onTouch(startButton: UIButton) {
        loadingView.startAnimating()
    }
    
    @objc private func onTouch(stopButton: UIButton) {
        loadingView.stopAnimating()
    }
    

}
