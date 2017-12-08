//
//  CustomMailComposeViewController.swift
//  RetailChat
//
//  Created by student on 12/7/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import Foundation
import MessageUI

class CustomMailComposeViewController : MFMailComposeViewController{
    
    var messageBody : String?
    
    override func setMessageBody(_ body: String, isHTML: Bool) {
        super.setMessageBody(body, isHTML: isHTML)
        messageBody = body
    }
}
