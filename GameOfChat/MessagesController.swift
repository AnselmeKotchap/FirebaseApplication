//
//  ViewController.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/15.
//  Copyright © 2017 MIND. All rights reserved.
//Uploading to remote repository plus new changes

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    var cellId = "cellId"
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Lougout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLoggedIn()
        
//        observeMessages()
//        observeUserMEssages()
    }
    
    func observeUserMEssages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    let message = Message()
                    
                    message.setValuesForKeys(dictionary)
                    
                    //                self.messages.append(message)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            
                            if let time1 = message1.timeStamp?.intValue, let time2 = message2.timeStamp?.intValue {
                                return  time1 > time2
                            }
                            
                            return false
                        })
                    }
                    
                    self.timer?.invalidate()
                    
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (time) in
                        
                        DispatchQueue.main.async {
                            print("tableView reloaded ....\n")
                            self.tableView.reloadData()
                        }
                        
                    })


                }
            })
            
        })
    }
    
    
    func reloadTable(){
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        
        cell.message =  messages[indexPath.row]
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatController(for: user)
        })

    }
    
    func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            

            fetchUserAndSetupNavBarTitle(uid: uid)
            
        }else {
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
    }
    
    func fetchUserAndSetupNavBarTitle(uid: String) {
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            //print(snapshot)
            if let downloadedUser = snapshot.value as? [String: AnyObject] {
                
//                self.navigationItem.title = user["name"] as? String
                
                let user = User()
                user.setValuesForKeys(downloadedUser)
                self.setupNavBar(with: user)
                
            }
            
            
        }, withCancel: nil)
    }
    
    func setupNavBar(with user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMEssages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        //x, y, width and height
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive  = true
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            
        }
        
        containerView.addSubview(profileImageView)
        
        //need x, y, width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //need x, y, width and height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
//        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
        
    }
    
    func showChatController(for user: User) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
            
        }catch let logoutError {
            print(logoutError)
        }
        let LoginView = LoginController()
        LoginView.messagesViewController = self
        present(LoginView, animated: true, completion: nil)
    }

}

