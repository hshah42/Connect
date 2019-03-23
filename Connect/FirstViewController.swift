//
//  FirstViewController.swift
//  Connect
//
//  Created by Hem shah on 25/02/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import SocketIO
import MultipeerConnectivity

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MMLANScannerDelegate, GCDAsyncSocketDelegate, MPCManagerDelegate {
    
    var people = [People]();
    let cellIdentifier = "PersonTableViewCell";
    var lanScanner : MMLANScanner!;
    var timer : Timer!;
    var profile: People!;
    var db: Firestore!;
    var hasProfileLoaded: Bool = false;
    let dbName: String = "UserDetails";
    let manager = SocketManager(socketURL: URL(string: "http://localhost:80")!, config: [.log(true), .compress]);
    var socket: SocketIOClient?;
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    var mpcManager: MPCManager!

    @IBOutlet weak var profileButton: UIButton!
    
    var userEmail: String?;

    @IBOutlet weak var peopleTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore();
        //mpcManager = MPCManager(name: userEmail ?? UIDevice.current.name);
        //socket = manager.defaultSocket;
        //listener = SocketListener(host: "localhost", port: 9080);
        //addHandlers();
        //mpcManager.delegate = self;
        //mpcManager.browser.startBrowsingForPeers();
       
        var person: People = People(name: "", email: userEmail!, photo: UIImage(named: "profile_default"));
        
        self.mpcManager = MPCManager();
        
        db.collection(dbName).whereField("email", isEqualTo: userEmail!).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data: Dictionary = document.data();
                    let email = data["email"];
                    let ipAddress = data["ip_address"];
                    let userName = data["username"];
                    
                    person = People(name: userName as! String, email: email as! String, photo: UIImage(named: "profile_default"));
                    person.ipAddress = ipAddress as? String;
                    
                    self.profile = person;
                    
                    self.mpcManager.start(name: userName as! String);
                    self.mpcManager.delegate = self;
                    self.mpcManager.advertiser.startAdvertisingPeer();
                    self.mpcManager.browser.startBrowsingForPeers();
                }
                
                self.hasProfileLoaded = true;
            };
        }
        
        //loadSampleData();
        self.peopleTable.addSubview(self.refreshControl);
        
    }
    
    func foundPeer() {
        //refresh();
    }
    
    func lostPeer() {
        //refresh();
    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertController.Style.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertAction.Style.default) { (alertAction) -> Void in
            self.mpcManager.invitationHandler(true, self.mpcManager.session)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alertAction) -> Void in
            self.mpcManager.invitationHandler(false, self.mpcManager.session);
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Chat") as! ChatViewController;
        vc.mpcManager = self.mpcManager;
        vc.name = peerID.displayName;
        self.present(vc, animated: true, completion: nil);
    }
    
    func addHandlers()
    {
        socket?.on("app_user") {data, ack in
            ack.with(self.userEmail!, self.profile.username ?? self.userEmail!);
        }
        
        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.socket?.emit("ping", "data")
        }
        
        socket?.on("ping") { _, _ in
            print("ping received")
        }
        
        socket?.connect();
    }
    
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        let personOne = People(name: "Hem Shah", email: "hemshah.nmims@gmail.com", photo: UIImage(named: "profile_default"));
        personOne.ipAddress = device.ipAddress;
        print(device.ipAddress)
        print(device.macAddress)
    
        //getSocketData(ip: device.ipAddress);
    
        if(device.macAddress != nil)
        {
            personOne.addMacAddress(macAddress: device.macAddress);
        }
        
        people.append(personOne);
    }
    
    func getSocketData(ip: String)
    {
        let socketSendManager = SocketManager(socketURL: URL(string: "http://192.168.1.161:8080")!, config: [.log(true), .compress]);
        let socketSend = socketSendManager.defaultSocket;
        socketSend.connect();
        socketSend.on(clientEvent: .connect) {data, ack in
            print("socket connected", data)
        }
        socketSend.disconnect();
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        
    }
    
    func lanScanDidFailedToScan() {
        
    }
    
    private func loadSampleData()
    {
        self.lanScanner = MMLANScanner(delegate:self)
        self.lanScanner.start()
    }
    
    func refresh()
    {
        peopleTable.beginUpdates();
        peopleTable.reloadData();
        peopleTable.endUpdates();
    }
    
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(FirstViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.peopleTable.reloadData()
        refreshControl.endRefreshing()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mpcManager.people.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeer = self.mpcManager.people[indexPath.row] as People;
        
        self.mpcManager.browser.invitePeer(selectedPeer.peer!, to: self.mpcManager.session, withContext: nil, timeout: 20)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath) as! PersonTableViewCell;
        
        let peopleRow = self.mpcManager.people[indexPath.row]

        
        cell.nameLabel.text = peopleRow.name;
        cell.profileImageView.image = peopleRow.photo;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;//Choose your custom row height
    }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    @IBAction func profile(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! UserProfileViewController;
        vc.email = userEmail;
        self.present(vc, animated: true, completion: nil)
    }
    
}

