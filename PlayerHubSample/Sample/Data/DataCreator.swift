//
//  DataCreator.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/10/22.
//  Copyright © 2019 Danis. All rights reserved.
//

import Foundation


struct Feed: Codable {
    let image: String
    let video: String
    let title: String?
    let authorName: String?
    
    enum CodingKeys: String, CodingKey {
        case image = "thumbnail_url"
        case video = "video_url"
        case title
        case authorName = "nick_name"
        
    }
    
    
    var imageURL: URL {
        return URL(string: image)!
    }
    
    var videoURL: URL {
        return URL(string: video)!
    }
    
}


struct DataCreator {
    static func createFeeds() -> [Feed] {
        let path = Bundle.main.url(forResource: "data", withExtension: "json")!
        let data = try! Data.init(contentsOf: path)
        
        return try! JSONDecoder().decode([Feed].self, from: data)
    }
}
