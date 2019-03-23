//
//  PeopleDAO.swift
//  Connect
//
//  Created by Hem shah on 11/03/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import Foundation
import Firebase

class PeopleDAO
{
    let db: Firestore!;
    let dbName: String = "UserDetails";

    init() {
        db = Firestore.firestore();
        print("Inside contructor")
    }
    
    func getPersonDetails(email: String) -> People
    {
        var person: People = People(name: "", email: email, photo: UIImage(named: "profile_default"));
        
        db.collection(dbName).whereField("email", isEqualTo: email).getDocuments(){ (querySnapshot, err) in
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
            }
            };}
        
        return person;
    }
}
