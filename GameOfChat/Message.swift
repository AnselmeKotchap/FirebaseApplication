//
//  Message.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/23.
//  Copyright © 2017 MIND. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    
    init(dictionary: [String: Any]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
    
    func chatPartnerId() -> String? {
        
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}
