//
//  FeedListTableViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/24.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class FeedListTableViewController: UITableViewController, PlayerMovingTransitionVideoContainer {
    var feeds = DataCreator.createFeeds()
    
    var videoContainer: UIView?
    
    deinit {
        PlayerHub.shared.clearRegistration()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PlayerHub.shared.register(controller: NormalPlayerController())
        
        tableView.backgroundColor = UIColor(hex: 0xeeeeee)
        tableView.register(FeedCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let current = feeds[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! FeedCell
        cell.configure(with: current)
        
        cell.didTouchToPlayHandler = { [unowned self] in
            PlayerHub.shared.stop()
            PlayerHub.shared.removePlayer()
            PlayerHub.shared.addPlayer(to: cell.videoContainer)
            PlayerHub.shared.replace(with: current.videoURL, next: nil, coverUrl: current.imageURL, placeholder: nil)
            PlayerHub.shared.play()
            
            self.videoContainer = cell.videoContainer
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let videoContainer = (cell as! FeedCell).videoContainer
        if PlayerHub.shared.isPlayer(in: videoContainer) {
            PlayerHub.shared.stop()
            PlayerHub.shared.removePlayer()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = feeds[indexPath.row]
        let detailVC = FeedDetailViewController(feed: feed)
        
        let videoContainer = (tableView.cellForRow(at: indexPath) as! FeedCell).videoContainer
        if PlayerHub.shared.isPlayer(in: videoContainer) {
            detailVC.isContinued = true
        } else {
            detailVC.isContinued = false
            
            PlayerHub.shared.stop()
            PlayerHub.shared.removePlayer()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
