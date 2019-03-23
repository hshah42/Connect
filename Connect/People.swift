//
//  People.swift
//  Connect
//
//  Created by Hem shah on 25/02/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class People
{
    var name: String;
    var email: String;
    var macAddress: Array<String>?;
    var ipAddress: String?;
    var username: String?;
    var photo: UIImage?;
    var friends: Array<String>?;
    var interests: Array<String>?;
    var peer: MCPeerID?;
    
    init(name: String, email: String, photo: UIImage?) {
        self.name = name;
        self.email = email;
        self.photo = photo;
        self.macAddress = [String]();
        self.interests = [String]();
    }

    func addMacAddress(macAddress: String)
    {
        self.macAddress?.append(macAddress);
    }
    
    func addInterest(interest: String)
    {
        self.interests?.append(interest);
    }
    
    func addUserName(username: String)
    {
        self.username = username;
    }
}
