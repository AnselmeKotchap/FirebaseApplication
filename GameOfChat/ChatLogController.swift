//
//  ChatLogController.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/23.
//  Copyright © 2017 MIND. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var user: User? {
        
        didSet {
            
            navigationItem.title = user?.name
        
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    lazy var inputTextField: UITextField = {
        
        let inputText  = UITextField()
        inputText.placeholder = "Enter message..."
        inputText.translatesAutoresizingMaskIntoConstraints = false
        inputText.delegate = self
        return inputText
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatmessageCell.self, forCellWithReuseIdentifier: cellId)
        setupInputComponents()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatmessageCell
        
        let message = messages[indexPath.row]
        
        cell.textView.text = message.text
        
        cell.bubbleWidthAnchor?.constant = estimateFrame(for: message.text!).width + 32
        
        setup(cell: cell, with: message)
        
        

        return cell
    }
    
    private func setup(cell: ChatmessageCell, with message: Message){
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatmessageCell.customBlue
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            
            
        } else {
            
            //incomming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            
            height = estimateFrame(for: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    private func estimateFrame(for text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let frame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
        return frame
    }
    
    func observeMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observe(.value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            })
        })
        
    }
    
    
    func setupInputComponents() {
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        //x,y,width and height constraint
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //adding send button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        //adding input textfield
        containerView.addSubview(inputTextField)
        
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        //Adding separator view
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        //x, y, w, h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
    }
    
    
    func handleSend(){
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        if let toId = user?.id, let message = inputTextField.text, let fromId = FIRAuth.auth()?.currentUser?.uid {
            
            let timeStamp = NSDate().timeIntervalSinceReferenceDate
            
            let values: [String: Any] = ["text": message, "toId": toId, "fromId": fromId, "timeStamp": timeStamp]
        
//            childRef.updateChildValues(values)
            childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    return
                }
                
                self.inputTextField.text = nil
                
                let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
                
                let messageId = childRef.key
                userMessageRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
            })
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        return true
    }
}







