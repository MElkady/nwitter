//
//  Tweets.swift
//  Nwitter
//
//  Created by MAK on 11/25/16.
//  Copyright © 2016 MAK. All rights reserved.
//

import Foundation
import ObjectMapper

class Tweets : Mappable {
    var statuses: [Tweet] = [Tweet]()
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        var s: [Tweet]?
        s <- map["statuses"]
        if let ss = s {
            self.statuses = ss
        }
        
    }
}
