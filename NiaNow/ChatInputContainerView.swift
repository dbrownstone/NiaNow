//
//  ChatInputContainerView.swift
//  NiaNow
//
//  Created by David Brownstone on 28/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatLogController: ChatLogController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUpLoadTap)))
        }
    }
    
    var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.white
        textField.delegate = self as? UITextFieldDelegate
        return textField
    }()

    let uploadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"upload_image_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let sendButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = UIColor.white
        
        
        addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo:leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant:44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant:44).isActive = true
        
        sendButton.setTitle("Send", for:.normal)
        sendButton.backgroundColor = UIColor.white
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo:rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant:80).isActive = true
        sendButton.heightAnchor.constraint(equalTo:heightAnchor, multiplier:0.95).isActive = true
        
        addSubview(self.inputTextField)
        self.inputTextField.delegate = self
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo:uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo:sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo:heightAnchor, multiplier:0.95).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor.lightGray
        addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo:leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
}
