//
//  User.swift
//  Nwitter
//
//  Created by MAK on 11/25/16.
//  Copyright © 2016 MAK. All rights reserved.
//

import Foundation
import ObjectMapper

class User : Mappable {
    var id: String?
    var screen_name: String?
    var name: String?
    var description: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        id <- map["id_str"]
        screen_name <- map["screen_name"]
        name <- map["name"]
        description <- map["description"]
    }
}
