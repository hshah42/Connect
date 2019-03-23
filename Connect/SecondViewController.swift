//
//  SecondViewController.swift
//  Connect
//
//  Created by Hem shah on 25/02/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var businesses = [Business]();
    let cellIdentifier = "BusinessTableViewCell"
    
    @IBOutlet weak var businessesTable: UITableView!
    
    private func loadSampleData()
    {
        let businessOne = Business(name: "McDonalds", photo: UIImage(named: "mcdonalds")!, description: "This is a fast food changes where you can get burgers and fries. Also Unhealthy!");
        
        businesses += [businessOne];
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleData();
        // Do any additional setup after loading the view, typically from a nib.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath) as! BusinessTableViewCell;
        
        let businessRow = businesses[indexPath.row]
        
        
        cell.businessNameLabel.text = businessRow.name;
        cell.businessPhotoLabel.image = businessRow.photo;
        cell.businessDescriptionLabel.text = businessRow.description;
        
        cell.businessDescriptionLabel.numberOfLines = 0;
        cell.businessDescriptionLabel.lineBreakMode = .byWordWrapping;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0;//Choose your custom row height
    }

}

