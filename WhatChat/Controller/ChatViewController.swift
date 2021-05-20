//
//  ChatViewController.swift
//  WhatChat
//
//  Created by Joseph Meyrick on 20/05/2021.
//
//

import UIKit
import Firebase
import ChameleonFramework



class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var messageArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        
        configureTableView()
        retrieveMessages()

        
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "Egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            
            //Set background to blue if message is from logged in user.
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        } else {
            
            //Set background to grey if message is from another user.
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    func configureTableView() {
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 1300
        
    }

    //MARK:- TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
 
    //MARK: - Send & Recieve from Firebase
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary =  ["sender": Auth.auth().currentUser?.email,
                                  "messageBody": messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error , reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully")
            
            }
            
            self.messageTextfield.isEnabled = false
            self.sendButton.isEnabled = false
            self.messageTextfield.text = ""
        }
       
        


    }
    
    func retrieveMessages () {
        
            let messagesDB = Database.database().reference().child("Messages")
        
        messagesDB.observe(.childAdded) { (Snapshot) in
            
            let snapshotValue = Snapshot.value as! Dictionary<String, String>
            
            let message = Message()
            message.sender = snapshotValue["sender"]!
            message.messageBody = snapshotValue["messageBody"]!
            
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error, there was a problem signing out")
        }
    }
}

