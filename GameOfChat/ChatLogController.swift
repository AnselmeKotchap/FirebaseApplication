//
//  ChatLogController.swift
//  GameOfChat
//
//  Created by Anselme Kotchap on 2017/01/23.
//  Copyright © 2017 MIND. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
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
    
    lazy var inputContainerView: UIView = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        

        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        //uploadImageView.tintColor = UIColor(r: 14, g: 122, b: 254)
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTapImage)))
        
        containerView.addSubview(uploadImageView)
        
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        
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
        containerView.addSubview(self.inputTextField)
        
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
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
        
        
        
        return containerView
    }()
    
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatmessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
//        setupInputComponents()
        setupKeyboardObservers()
    }
    
    
    override var inputAccessoryView: UIView? {
        
        get {
            
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        
        return true
    }
    
    func setupKeyboardObservers() {
        
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardDidShow(){
    
        if messages.count > 0 {
            
            //scroll to last index
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)//NSIndexPath(forItem: , inSection: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func handleUploadTapImage(){
    
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        self.present(imagePickerController, animated: true, completion: nil)

    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            //we selected an image
            
            
            handleVideoSlectedFor(url: videoUrl)
            

        } else {
            
            handleImageSelectedFor(info: info)
            
        }
        

        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSlectedFor(url: URL) {
        
        let filename = NSUUID().uuidString + ".mov"
        
        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(filename).putFile(url, metadata: nil, completion: { (metadata, error) in
            
            print("saving video to firebase \n")
            if error != nil {
                print("failed to upload video:", error!)
                return
            }
            
            if let storageUrl = metadata?.downloadURL()?.absoluteString {
                
                
                if let thumbnailImage = self.thumbnailImageFor(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        
                        let values: [String: Any] = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": storageUrl]
                        self.sendMessageWithProperties(properties: values)
                    })

                }
                
                
                
                
            }
        })
        
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount, let totalUniCount = snapshot.progress?.totalUnitCount {
                
                let uploadPercentage = Float64(completedUnitCount) * 100 / Float64(totalUniCount)
                self.navigationItem.title = String(format: "%.0f ", uploadPercentage) + "%"
                
            }
            
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageFor(fileUrl: URL) -> UIImage? {
        
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnail = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnail)
            
        } catch let err {
            
            print(err)
        }
        
        return nil
    }
    
    private func handleImageSelectedFor(info: [String: Any]) {
        //we selected an image
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWith(imageUrl: imageUrl, for: selectedImage)
            })
        }
        
    }
    
    func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
    
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print("Failer to upload image", error!)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    completion(imageUrl)
                    
                }
                
            })
            
        }
    }
    
    
    
    func handleKeyboardWillShow(notification: Notification){
        
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        
        let keyboardDuration = Double(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        
        UIView.animate(withDuration: keyboardDuration) {
            
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    func handleKeyboardWillHide(notification: Notification){
        
        let userInfo = notification.userInfo!
        
        containerViewBottomAnchor?.constant = 0
        
        let keyboardDuration = Double(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        UIView.animate(withDuration: keyboardDuration) {
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatmessageCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
        
        cell.textView.text = message.text
        
        if let text = message.text {
            
            cell.bubbleWidthAnchor?.constant = estimateFrame(for: text).width + 32
            cell.textView.isHidden = false
            
            
        }else if message.imageUrl != nil {
            //fall in here if it is image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoom)))
            cell.textView.isHidden = true
        }
        
        setup(cell: cell, with: message)
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setup(cell: ChatmessageCell, with message: Message){
        
        if let profileImageUrl = self.user?.profileImageUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatmessageCell.customBlue
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
           
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            
            //incomming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            
        }
        
        if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
//            cell.textView.isHidden = true
            
        } else {
            
            cell.messageImageView.isHidden = true
//            cell.textView.isHidden = false
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            
            height = estimateFrame(for: text).height + 20
            
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue  {
            
            height = CGFloat(imageHeight/imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    
    private func estimateFrame(for text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let frame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
        return frame
    }
    
    func observeMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observe(.value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
//                message.setValuesForKeys(dictionary)
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    
                    //scroll to last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)//NSIndexPath(forItem: , inSection: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            })
        })
        
    }
    
    
    func handleSend(){
        
        
        if let message = inputTextField.text {
            
           let  values = ["text": message]
        
           self.sendMessageWithProperties(properties: values)
        }
        
        
    }
    
    private func sendMessageWith(imageUrl: String, for image: UIImage) {
        
        let values: [String: Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]

        self.sendMessageWithProperties(properties: values)
        
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        if let toId = user?.id, let fromId = FIRAuth.auth()?.currentUser?.uid {
            
            let timeStamp = NSDate().timeIntervalSinceReferenceDate
            
            var values: [String: Any] = ["toId": toId, "fromId": fromId, "timeStamp": timeStamp]
            
            properties.forEach({values[$0] = $1})
            
            print("values sent is: \(values) \n")
            
            //            childRef.updateChildValues(values)
            childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    return
                }
                
                self.inputTextField.text = nil
                
                let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
                
                let messageId = childRef.key
                userMessageRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
            })
            
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    
    var backgroundView: UIView?
    var startingImageView: UIImageView?
    
    //custom zoom logic
    func performZoom(tapGesture: UITapGestureRecognizer){
        
        if let imageView = tapGesture.view as? UIImageView {
        
            startingImageView = imageView
            startingImageView?.isHidden = true
            
            startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
            
            guard let keyWindow = UIApplication.shared.keyWindow else {
                
                return
            }
            
            //add backgroundview
            backgroundView = UIView(frame: keyWindow.frame)
            backgroundView?.backgroundColor = UIColor.black
            backgroundView?.alpha = 0
            keyWindow.addSubview(backgroundView!)
            
            //add image view
            let zoomImageView = UIImageView(frame: startingFrame!)
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            zoomImageView.image = imageView.image
            
            keyWindow.addSubview(zoomImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

                
                let height = self.startingFrame!.height/self.startingFrame!.width * keyWindow.frame.width
                
                self.backgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomImageView.center = keyWindow.center
                
            }, completion: { (completed) in
//                zoomOutImageView.removeFromSuperview()
//                self.backgroundView?.removeFromSuperview()
            })
            
            
        }
        
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        print("zoom out")
        
        
        
        if let zoomOutImageView = tapGesture.view {
            

            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                
                self.backgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                

                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.backgroundView?.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
            
            
        }
    }
    
    @objc func playVideo(for url: String){
        
        print("paly video")
    }
}







