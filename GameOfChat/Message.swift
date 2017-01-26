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
    
    func chatPartnerId() -> String? {
        
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}
