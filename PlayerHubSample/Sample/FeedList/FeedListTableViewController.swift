//
//  FeedListTableViewController.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/24.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

class FeedListTableViewController: UITableViewController {

    var feeds = DataCreator.createFeeds()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PlayerHub.shared.register(controller: NormalPlayerController())
        
        tableView.backgroundColor = UIColor.black
        tableView.register(FeedCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.contentInsetAdjustmentBehavior = .never
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
            
        }
        
        return cell
    }
}
