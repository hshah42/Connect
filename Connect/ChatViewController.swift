//
//  ChatViewController.swift
//  Connect
//
//  Created by Hem shah on 22/03/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MPCReceive
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatText: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var endChatButton: UIButton!
    
    var messagesArray: [Dictionary<String, String>] = [];
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    var mpcManager: MPCManager?;
    var name: String?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        nameLabel.text = name;
       
        chatTable.delegate = self;
        chatTable.dataSource = self;
        
        chatTable.estimatedRowHeight = 60.0;
        chatTable.rowHeight = UITableView.automaticDimension;
    
        chatText.delegate = self;
        mpcManager?.recieveDelegate = self;
        
       // NotificationCenter.default.addObserver(self, selector: "handleMPCReceivedDataWithNotification", name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "idCell") as! UITableViewCell;
        
        let currentMessage = messagesArray[indexPath.row] as Dictionary<String, String>;
        
        if let sender = currentMessage["sender"] {
            var senderLabelText: String;
            var senderColor: UIColor;
            
            if sender == "self"{
                senderLabelText = "I said:"
                senderColor = UIColor.cyan;
            }
            else{
                senderLabelText = sender + " said:"
                senderColor = UIColor.darkGray;
            }
            
            cell.detailTextLabel?.text = senderLabelText
            cell.detailTextLabel?.textColor = senderColor
        }
        
        if let message = currentMessage["message"] {
            cell.textLabel?.text = message
        }
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        let messageDictionary: [String: String] = ["message": textField.text ?? ""];
        
        if self.mpcManager!.sendData(dictionaryWithData: messageDictionary, toPeer: self.mpcManager!.session.connectedPeers[0] as MCPeerID){
            
            let dictionary: [String: String] = ["sender": "self", "message": textField.text ?? ""];
            messagesArray.append(dictionary);
            
            self.updateTableview();
        }
        else{
            print("Could not send data")
        }
        
        textField.text = "";
        
        return true
    }
    
    func updateTableview(){
        self.chatTable.reloadData();
        
        if self.chatTable.contentSize.height > self.chatTable.frame.size.height {
            chatTable.scrollToRow(at: NSIndexPath(row: messagesArray.count - 1, section: 0) as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true);
        }
    }
    
    @IBAction func send(_ sender: Any) {
        chatText.resignFirstResponder();
        
        let messageDictionary: [String: String] = ["message": chatText.text ?? ""];
        
        if self.mpcManager!.sendData(dictionaryWithData: messageDictionary, toPeer: self.mpcManager!.session.connectedPeers[0] as MCPeerID){
            
            let dictionary: [String: String] = ["sender": "self", "message": chatText.text ?? ""];
            messagesArray.append(dictionary);
            
            self.updateTableview();
        }
        else{
            print("Could not send data")
        }
        
        chatText.text = "";        
    }
    
    @IBAction func endChat(_ sender: Any) {
        let messageDictionary: [String: String] = ["message": "_end_chat_"]
        if self.mpcManager!.sendData(dictionaryWithData: messageDictionary, toPeer: self.mpcManager!.session.connectedPeers[0] as MCPeerID){
            self.mpcManager!.session.disconnect();
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    func receive(dictionary: Dictionary<String, AnyObject>) {
        let data = dictionary["data"] as? NSData
        let fromPeer = dictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        // Check if there's an entry with the "message" key.
        if let message = dataDictionary["message"] {
            // Make sure that the message is other than "_end_chat_".
            if message != "_end_chat_"{
                // Create a new dictionary and set the sender and the received message to it.
                let messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message]
                
                // Add this dictionary to the messagesArray array.
                messagesArray.append(messageDictionary)
                
                // Reload the tableview data and scroll to the bottom using the main thread.
                OperationQueue.main.addOperation({ () -> Void in
                    self.updateTableview()
                })
            }
            else{
                let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) ended this chat.", preferredStyle: UIAlertController.Style.alert)
                
                let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) { (alertAction) -> Void in
                    self.mpcManager!.session.disconnect()
                    self.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(doneAction)
                
                OperationQueue.main.addOperation({ () -> Void in
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        // Check if there's an entry with the "message" key.
        if let message = dataDictionary["message"] {
            // Make sure that the message is other than "_end_chat_".
            if message != "_end_chat_"{
                // Create a new dictionary and set the sender and the received message to it.
                let messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message]
                
                // Add this dictionary to the messagesArray array.
                messagesArray.append(messageDictionary)
                
                // Reload the tableview data and scroll to the bottom using the main thread.
                OperationQueue.main.addOperation({ () -> Void in
                    self.updateTableview()
                })
            }
            else{
                let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) ended this chat.", preferredStyle: UIAlertController.Style.alert)
                
                let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) { (alertAction) -> Void in
                    self.mpcManager!.session.disconnect()
                    self.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(doneAction)
                
                OperationQueue.main.addOperation({ () -> Void in
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
}
