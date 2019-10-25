//
//  FeedDetailViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/24.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class FeedDetailViewController: UITableViewController {

    var headerView: FeedDetailHeaderView!
    
    private let feed: Feed
    init(feed: Feed) {
        self.feed = feed
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "详情"
        
        view.backgroundColor = UIColor.white
        
        headerView = FeedDetailHeaderView()
        headerView.configure(with: feed, preferedWidth: view.bounds.width)
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let size = headerView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 1200))
        headerView.frame = CGRect(origin: .zero, size: size)
        
        tableView.tableHeaderView = headerView
        
        headerView.didTouchToPlayHandler = { [unowned self] in
            self.playCurrentFeed()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playCurrentFeed()
    }
    
    private func playCurrentFeed() {
        PlayerHub.shared.addPlayer(to: self.headerView.videoContainer)
        PlayerHub.shared.replace(with: self.feed.videoURL, coverUrl: self.feed.imageURL, placeholder: nil)
        PlayerHub.shared.play()
        
//        PlayerHub.shared.movePlayer(to: <#T##UIView#>)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
