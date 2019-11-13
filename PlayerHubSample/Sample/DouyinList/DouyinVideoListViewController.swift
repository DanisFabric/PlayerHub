//
//  FullScreenListTableViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/21.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit
import Kingfisher

class DouyinVideoListViewController: UIViewController {
    
    
    var feeds = DataCreator.createFeeds()
    
    private var playingIndexPath: IndexPath?
    
    private lazy var tableView: UITableView = {
        let temp = UITableView()
        temp.backgroundColor = UIColor.black
        temp.register(DouyinCell.self, forCellReuseIdentifier: "ItemCell")
        temp.isPagingEnabled = true
        temp.contentInsetAdjustmentBehavior = .never
        temp.dataSource = self
        temp.delegate = self
        
        return temp
    }()
    
    private let backButton: UIButton = {
        let temp = UIButton(type: .system)
        temp.setImage(UIImage(named: "navigation_back"), for: .normal)
        temp.tintColor = UIColor.white
        
        return temp
    }()
    
    deinit {
        PlayerHub.shared.clearRegistration()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlayerHub.shared.register(controller: DouyinPlayerController())

        view.addSubview(tableView)
        view.addSubview(backButton)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(44)
        }
        
        backButton.addTarget(self, action: #selector(onTouch(backButton:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc private func onTouch(backButton: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension DouyinVideoListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let current = feeds[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! DouyinCell
        cell.videoImageView.kf.setImage(with: URL(string: current.image))
        
        cell.didTouchToPlayHandler = { [unowned self] in
            self.autoPlayIfNeeded()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        autoPlayIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        autoPlayIfNeeded()
    }
    
    private func autoPlayIfNeeded() {
        let pointX = view.bounds.width / 2
        let pointY = tableView.contentOffset.y + tableView.bounds.height / 2
        
        guard let currentIndexPath = tableView.indexPathForRow(at: CGPoint(x: pointX, y: pointY)) else {
            return
        }
        guard let cell = tableView.cellForRow(at: currentIndexPath) as? DouyinCell else {
            return
        }
        
        if currentIndexPath == playingIndexPath {
            return
        }
        playingIndexPath = currentIndexPath
        
        let feed = feeds[currentIndexPath.row]
        
        var nextFeed: Feed?
        if currentIndexPath.row + 1 < feeds.count {
            nextFeed = feeds[currentIndexPath.row + 1]
        }
        
        PlayerHub.shared.stop()
        PlayerHub.shared.addPlayer(to: cell.videoContainer)
        PlayerHub.shared.replace(with: feed.videoURL, next: nextFeed?.videoURL, coverUrl: feed.imageURL, placeholder: nil)
        PlayerHub.shared.play()
    }
}
