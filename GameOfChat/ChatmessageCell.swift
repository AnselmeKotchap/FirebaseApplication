//
//  ChatmessageCell.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/25.
//  Copyright © 2017 MIND. All rights reserved.
//

import UIKit

class ChatmessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        
        let textV = UITextView()
        textV.text = "sample text for more text in the cell view of the collection view"
        textV.font = UIFont.systemFont(ofSize: 16)
        textV.backgroundColor = UIColor.clear
        textV.textColor = .white
        textV.translatesAutoresizingMaskIntoConstraints = false
        return textV
    }()
    
    static let customBlue = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = customBlue
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        return view
        
    }()
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "monia")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(bubbleView)
        addSubview(textView)

        
        //x,y,w,h constraint
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //x,y, w, h constraint for bubble
        bubbleViewRightAnchor?.identifier = "bubbleRight"
        
        bubbleViewRightAnchor =  bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.priority = 999
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchor?.priority = 999
        bubbleViewLeftAnchor?.identifier = "bubbleLeft"

        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.identifier = "bubblewidth"
        
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //x,y, w, h constraint for textview
//        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
