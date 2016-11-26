//
//  Tweet.swift
//  Nwitter
//
//  Created by MAK on 11/25/16.
//  Copyright © 2016 MAK. All rights reserved.
//

import Foundation
import ObjectMapper

class Tweet : Mappable {
    var text: String?
    var created_at: String?
    var id: String?
    var user: User?
    var retweetCount: NSNumber = 0
    var favoriteCount: NSNumber = 0
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        text <- map["text"]
        created_at <- map["created_at"]
        id <- map["id_str"]
        user <- map["user"]
        retweetCount <- map["retweet_count"]
        favoriteCount <- map["favorite_count"]
    }
}
