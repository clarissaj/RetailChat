//
//  TabBarController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController{
    
    let db = database.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if db.credentialsIsEmpty() {
            self.selectedIndex = 3
        }
    }
}
