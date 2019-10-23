//
//  FullScreenListTableViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/21.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit
import Kingfisher

class DouyinListTableViewController: UITableViewController {
    
    
    var feeds = DataCreator.createFeeds()
    
    private var playingIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlayerHub.shared.register(controller: NormalPlayerController())

        tableView.backgroundColor = UIColor.black
        tableView.register(DouyinCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.isPagingEnabled = true
        tableView.contentInsetAdjustmentBehavior = .never

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let current = feeds[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! DouyinCell
        cell.videoImageView.kf.setImage(with: URL(string: current.image))
        
        
        cell.didTouchToPlayHandler = { [unowned self] in
            self.autoPlayIfNeeded()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height
    }

    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        autoPlayIfNeeded()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
        
        PlayerHub.shared.stop()
        PlayerHub.shared.addPlayer(to: cell.videoContainer)
        PlayerHub.shared.replace(with: feed.videoURL, coverUrl: feed.imageURL, placeholder: nil)
        PlayerHub.shared.play()
    }
}
