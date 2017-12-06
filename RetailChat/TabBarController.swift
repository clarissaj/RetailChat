//
//  TabBarController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController{
    
    var alertController = UIAlertController(title: "Invalid location", message: "You cannot use this application when not working, exiting.", preferredStyle: .alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Checks the location of the user relatively to the work location, exit if they don't match
        
        // If location != work location, alert and exit
        if false{
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in exit(0)}))
            present(alertController, animated: true)
        }
        
        // If we're here it means that we are at work, i.e. we can receive the emails
    }
}
