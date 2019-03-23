//
//  UserProfileViewController.swift
//  Connect
//
//  Created by Hem shah on 21/03/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserProfileViewController: UIViewController
{
    var db: Firestore!;
    var email: String!;
    let dbName: String = "UserDetails";
    
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userProfileEmail: UITextField!
    @IBOutlet weak var userProfileUsername: UITextField!
    @IBOutlet weak var userProfileInterests: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        db = Firestore.firestore();
        userProfileEmail.isEnabled = false;
        
        db.collection(dbName).whereField("email", isEqualTo: email!).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data: Dictionary = document.data();
                    let email = data["email"];
                    let userName = data["username"];
                    
                    let interests = data["interests"] as? Array ?? [""];
                    
                    self.userProfileEmail.text = (email as! String);
                    self.userProfileUsername.text = (userName as! String);
                    self.userProfileInterests.text = interests.joined(separator: ",");
                }
            };
        }
    }
    
    @IBAction func save(_ sender: Any) {
        let userProfile = db.collection(dbName).document(email);
        
        let updatedUserName = userProfileUsername.text;
        let interests = userProfileInterests.text;
        
        let interestsArray = interests?.split(separator: ",");
        
        if(updatedUserName?.count ?? 0 > 0)
        {
            userProfile.updateData(["username": userProfileUsername.text!]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        
        userProfile.updateData(["interests": interestsArray ?? []]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
}
