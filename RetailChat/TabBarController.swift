//
//  TabBarController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController{
    
    let rcDataCache = RetailChatData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if rcDataCache.credentialsIsEmpty() {
            self.selectedIndex = 3
        }
    }
}
