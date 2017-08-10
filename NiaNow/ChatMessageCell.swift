//
//  ChatMessageCell.swift
//  NiaNow
//
//  Created by David Brownstone on 28/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?
    var message: Message?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
//        button.setTitle("Play Video", for: .normal)
        button.setImage(UIImage(named:"play"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)
        
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func handlePlayVideo() {
        if let videoUrlString = message?.videoUrl, let url = NSURL(string: videoUrlString) {
            player = AVPlayer(url: url as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView  = {
        let tv = UITextView()
//        tv.text = "asdkjfhlakjsdhf"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let dateView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.backgroundColor = UIColor.clear
        tv.textColor = .lightGray
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named:"david")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
    }()
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    static let blueColor = UIColor.themeBubbleBlueColor
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var dateViewLeftAnchor: NSLayoutConstraint?
    var dateViewRightAnchor: NSLayoutConstraint?
    var profileImageViewLeftAnchor: NSLayoutConstraint?
    var profileImageViewRightAnchor: NSLayoutConstraint?

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        addSubview(dateView)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        dateViewRightAnchor = dateView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -8)
        dateViewRightAnchor?.isActive = true
        dateViewLeftAnchor = dateView.leftAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 8)
        dateViewLeftAnchor?.isActive = false
        dateView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        dateView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        dateView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        //x, y, w, h
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant:50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant:50).isActive = true
        bubbleView.addSubview(activityIndicatorView)
        //x, y, w, h
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant:50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant:50).isActive = true
        
        //x,y,w,h
        profileImageViewLeftAnchor = profileImageView.leftAnchor.constraint(equalTo:self.leftAnchor, constant: 8)
        profileImageViewLeftAnchor?.isActive = true
        profileImageViewRightAnchor = profileImageView.rightAnchor.constraint(equalTo:self.rightAnchor, constant: -8)
        profileImageViewRightAnchor?.isActive = true
        profileImageView.centerYAnchor.constraint(equalTo:bubbleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        //x,y,w,h
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo:self.rightAnchor, constant: -32)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant:8)
        bubbleViewLeftAnchor?.isActive = false
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //x,y,w,h
        textView.leftAnchor.constraint(equalTo:bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        textView.rightAnchor.constraint(equalTo:bubbleView.rightAnchor).isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}
