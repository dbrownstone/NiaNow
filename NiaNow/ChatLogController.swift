//
//  ChatLogController.swift
//  NiaNow
//
//  Created by David Brownstone on 28/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
 UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //differentiate between a group chat and individual chat
    var messages = [Message]()
    var groupChat = false
    var classMembers:[User] = []
    
    /**
     When a notification arrives, this function determines how to handle it i.e. which screen to display
     
     - Parameter notificationInfo: dictionary of data from the push notification
     1. notificationInfo["chat"] could have value of "class" if Class Chat is requested or "one-on-one" if individual chat is required
     2. notificationInfo["toId"] specifies the UDID string of the sender
     3. notificationInfo?["fromId"] specifies the UDID string of the receiving user
     4. notificationInfo?["alert"] speifies the content of the message
     */
    var notificationInfo:[String: AnyObject]? {
        didSet {
            let message = notificationInfo?["alert"]
            let fromId = notificationInfo?["fromId"]
            let toId = notificationInfo?["toId"]
            
            self.groupChat = notificationInfo?["chat"] as! String == "class" ? true : false
            let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
            
            let values = ["text": message as Any, "toId": toId as Any, "fromId": fromId as Any, "timeStamp":timeStamp] as [String : Any]
            
            updateTheMessages(values)
        }
    }
    
    var thisClass:NiaClass? {
        didSet {
            navigationItem.title = (thisClass?.name)! + " Chat"
            
            groupChat = true
            
            getAllMembersOfTheClass()
            observeGroupMessages()
        }
    }
    
    func getAllMembersOfTheClass() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.value, with: { snapshot in
            var newMembersList:[User] = []
            for aUser in snapshot.children {
                let member = User(snapshot: aUser as! DataSnapshot)
                let name = member.name
                let email = member.email
                let phone = member.phoneNo
                let uid = member.uid
                let profileImageUrl = member.profileImageUrl
                for memberId in (self.thisClass?.members)! {
                    // if the user is in the selected class, add to members list
                    if uid == memberId {
                        let attendee = User(name: name!, phoneNo: phone!, email: email!, profileImageUrl: profileImageUrl!)
                        attendee.uid = uid
                        newMembersList.append(attendee)
                        break
                    }
                }
            }
            self.classMembers = newMembersList
        })
    }
    
    func observeGroupMessages() {
        Database.database().reference().child("messages").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                if message.toId == self.thisClass?.uid {
                    self.messages.append(message)
                    self.messages.sort(by: {(message1, message2) -> Bool in
                        return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                    })
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }
            }
        })
    }
    
    func getFromIdImageUrl(_ id: String) -> String {
        var result = ""
        for member in self.classMembers {
            if member.uid == id {
                result = member.profileImageUrl!
                break
            }
        }
        return result
    }
    
    var user:User? {
        didSet {
            navigationItem.title = "Chat with \((user?.name)!)"
            observeUserMessages()
        }
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem(image: UIImage(named:"backButton"), style: .plain, target: self, action: #selector(closeView))
        self.navigationItem.leftBarButtonItem = leftButton
    
        //self.title = "Chat"
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
    }
    
    func closeView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    func handleUpLoadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            handleVideoSelectedForUrl(url:videoUrl as URL)
        } else {
            handleImageSelectedForInfo(info:info as [String : AnyObject])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url:URL) {
        let filename = UUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error ?? "unable to upload video")
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageFor(fileUrl: url as NSURL) {
                    
                    self.uploadImageToFirebaseStorage(image:thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                        
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func thumbnailImageFor(fileUrl: NSURL) ->UIImage? {
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [String: AnyObject]) {
        var selectedImageFromPicker:UIImage?
    
        if let editedImage = info[UIImagePickerControllerEditedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] {
            selectedImageFromPicker = originalImage as? UIImage
        }
    
        if let selectedImage = selectedImageFromPicker {
            uploadImageToFirebaseStorage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image:selectedImage)
            })
//            uploadImageToFirebaseStorage(image:selectedImage)
        }
    }
    
    private func uploadImageToFirebaseStorage(image:UIImage, completion: @escaping (_ imageUrl: String) ->()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: {(metadata,error) in
                
                if error != nil {
                    print(error ?? "Unable to load into Firebase Storage")
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
        
    }
    
    private func sendMessageWithImageUrl(imageUrl:String, image: UIImage) {
        let properties:[String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth":image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        sendMessageWithProperties(properties: properties)
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardDidShow(notification:NSNotification) {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    func handleKeyboardWillShow(notification:NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification:NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
// MARK: - Collection view data source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 100
        var width: CGFloat = UIScreen.main.bounds.width
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
                height = CGFloat(imageHeight/imageWidth * 200)
        }
        
        return CGSize(width: width + 20, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        
        let message = messages[indexPath.row]
        cell.message = message
        
        cell.textView.text = message.text
        if let seconds = message.timeStamp?.doubleValue {
            let timeStampDate = Date(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E d, h:mm"
            dateFormatter.timeZone = NSTimeZone.local
            cell.dateView.text = dateFormatter.string(from: timeStampDate)
        }
        setUpCell(cell:cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setUpCell(cell:ChatMessageCell, message:Message) {
        if groupChat {
            let profileImageUrl = self.getFromIdImageUrl(message.fromId!)
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        } else {
            let profileImageUrl = self.user?.profileImageUrl
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.dateViewLeftAnchor?.isActive = false
            cell.dateViewRightAnchor?.isActive = true
            cell.profileImageViewLeftAnchor?.isActive = false
            cell.profileImageViewRightAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.dateView.textAlignment = .right
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.profileImageViewLeftAnchor?.isActive = true
            cell.profileImageViewRightAnchor?.isActive = false
            cell.dateViewLeftAnchor?.isActive = true
            cell.dateViewRightAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.dateView.textAlignment = .left

        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    var containerViewBottomAnchor:NSLayoutConstraint?
    
    
    func handleSend() {
        inputContainerView.inputTextField.resignFirstResponder()
        let properties:[String: AnyObject] = ["text": inputContainerView.inputTextField.text! as AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        var toId: String?
        if groupChat {
            toId = (thisClass?.uid)!
        } else {
            toId = user!.uid!
        }
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        var values = ["toId": toId as Any, "fromId": fromId, "timeStamp":timeStamp] as [String : Any]
        properties.forEach {
            values.updateValue($1, forKey: $0)
        }
        
        self.inputContainerView.inputTextField.text = nil
        updateTheMessages(values)
    }
    
    func updateTheMessages(_ values: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = values["toId"] as! String
        let fromId = values["fromId"] as! String
        childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error ?? "Send error")
                return
            }
            
            var userMessagesRef: DatabaseReference?
            
            if self.groupChat {
                userMessagesRef = Database.database().reference().child("classes").child((self.thisClass?.uid)!).child("messages").child(fromId)
            } else {
                userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            }
            
            let messageId = childRef.key
            userMessagesRef?.updateChildValues([messageId: 1])
            
            if !self.groupChat {
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
            }
        })
    }
    
    //custom zooming logic
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingFrame!)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                let height = CGFloat((self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width)
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            
            }, completion: nil)
            
            zoomingImageView.center = keyWindow.center
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
        }
        
    }
}
