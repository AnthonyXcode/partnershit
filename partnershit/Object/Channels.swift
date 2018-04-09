//
//  Channel.swift
//  partnershit
//
//  Created by user on 15/1/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import Foundation

class ChannelsObject: NSObject, NSCoding {
    var name = ""
    var id = ""
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
    }
}
