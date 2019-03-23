//
//  MPCManager.swift
//  Connect
//
//  Created by Hem shah on 22/03/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity
import Firebase;

protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}

protocol MPCReceive{
    func receive(dictionary: Dictionary<String, AnyObject>);
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate
{
    var session: MCSession!;
    var peer: MCPeerID!;
    var browser: MCNearbyServiceBrowser!;
    var advertiser: MCNearbyServiceAdvertiser!;
    
    var db: Firestore?;
    let dbName: String = "UserDetails";
    
    var delegate: MPCManagerDelegate?;
    var recieveDelegate: MPCReceive?;
    
    var foundPeers = [MCPeerID]();
    var people = [People]();
    //var invitationHandler: ((Bool, MCSession?)->Void)!;
    var invitationHandler: (Bool, MCSession) -> Void = { status, session in }

    override init() {
        super.init()
        db =  Firestore.firestore();
    }
    
    func start(name: String)
    {
        peer = MCPeerID(displayName: name);
        session = MCSession(peer: peer);
        session.delegate = self;
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc");
        browser.delegate = self;
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc");
        advertiser.delegate = self;
        print("Done");
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        print("found:", peerID.displayName)
        
        db!.collection(dbName).whereField("username", isEqualTo: peerID.displayName).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data: Dictionary = document.data();
                    let email = data["email"];
                    let ipAddress = data["ip_address"];
                    let userName = data["username"];
                    
                    let person = People(name: userName as! String, email: email as! String, photo: UIImage(named: "profile_default"));
                    person.ipAddress = ipAddress as? String;
                    person.peer = peerID;
                    
                    self.people.append(person);
                    self.delegate?.foundPeer();
                }
            };
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in people.enumerated(){
            if aPeer.username == peerID.displayName {
                people.remove(at: index)
                break
            }
        }
        delegate?.lostPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(fromPeer: peerID.displayName);
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID: peerID)
            
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary);
        let peersArray = NSArray(object: targetPeer)
        var _: NSError?
        
        do {
            try session.send(dataToSend, toPeers: peersArray as! [MCPeerID], with: MCSessionSendDataMode.reliable);
        } catch {
            print(error)
        }
        
        return true
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary: [String: AnyObject] = ["data": data as AnyObject, "fromPeer": peerID];
        print("data recieved: ", dictionary , "from", peerID.displayName);
        recieveDelegate?.receive(dictionary: dictionary);
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: //dictionary);
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    

}
