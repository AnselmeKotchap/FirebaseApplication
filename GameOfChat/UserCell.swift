//
//  UserCell.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/24.
//  Copyright © 2017 MIND. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        
        didSet {
            
            
                setupNameAndProfileImage()
            
                self.textLabel?.text = message?.toId
                self.detailTextLabel?.text = message?.text
                
                
                if let seconds = message?.timeStamp {
                    let time = NSDate(timeIntervalSinceReferenceDate: Double(seconds))
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "hh:mm:ss a"
                    timeLabel.text = dateFormatter.string(for: time)
                }
            
            
        }
    }
    
    private func setupNameAndProfileImage(){
        
        if let toId = message?.chatPartnerId(){
            
            let ref = FIRDatabase.database().reference().child("users").child(toId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            })
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 62, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 62, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "paris")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
//        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //iOS 9 constraint anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 9).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        //x,y,w,h constraint
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        //timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: (textLabel?.centerYAnchor)!).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

