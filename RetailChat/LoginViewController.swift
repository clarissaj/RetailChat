//
//  LoginViewController.swift
//  RetailChat
//
//  Created by Clarissa Jiminian on 12/13/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var currentEmail: UILabel!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var pwField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    let rcDataCache = RetailChatData.sharedInstance
    
    override func loadView() {
        super.loadView()
        
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rcDataCache.getData()
       // rcDataCache.emptyInitialLogin()
        if !rcDataCache.credentialsIsEmpty() {
            currentEmail.text = rcDataCache.getUserCredentials(index: 0).email
        } else {
            //if empty disable tabs that require user to be logged in
            if let arrayOfTabBarItems = tabBarController?.tabBar.items as AnyObject as? NSArray,
                let mailsList = arrayOfTabBarItems[0] as? UITabBarItem, let prList = arrayOfTabBarItems[1] as? UITabBarItem, let contactsList = arrayOfTabBarItems[2] as? UITabBarItem{
                mailsList.isEnabled = false
                prList.isEnabled = false
                contactsList.isEnabled = false
            }
        }
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        if emailField.text != "" && pwField.text != "" {
            rcDataCache.emptyInitialLogin()
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let credentials = Credentials(context : context)
            
            credentials.email = emailField.text
            credentials.password = pwField.text
            
            // Code to add, the data source & table view must stay in sync
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            currentEmail.text = emailField.text
            
            //enables tabs that require user to be logged in
            if let arrayOfTabBarItems = tabBarController?.tabBar.items as AnyObject as? NSArray,
                let mailsList = arrayOfTabBarItems[0] as? UITabBarItem, let prList = arrayOfTabBarItems[1] as? UITabBarItem, let contactsList = arrayOfTabBarItems[2] as? UITabBarItem{
                mailsList.isEnabled = true
                prList.isEnabled = true
                contactsList.isEnabled = true
            }
            
            self.tabBarController?.selectedIndex = 0
            clearFieldsAndResponder()
        }
    }
    
    func clearFieldsAndResponder(){
        emailField.text = ""
        pwField.text = ""
        
        emailField.resignFirstResponder()
        pwField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
