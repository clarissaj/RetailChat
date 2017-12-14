//
//  LoginViewController.swift
//  RetailChat
//
//  Created by Clarissa Jiminian on 12/13/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    @IBOutlet var currentEmail: UILabel!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var pwField: UITextField!
    
    var credentials = [Credentials]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        currentEmail.text = credentials[0].email
        
        //if empty disable tabs that require user to be logged in
        if credentials.isEmpty {
            if let arrayOfTabBarItems = tabBarController?.tabBar.items as AnyObject as? NSArray,
                let mailsList = arrayOfTabBarItems[1] as? UITabBarItem, let prList = arrayOfTabBarItems[2] as? UITabBarItem{
                mailsList.isEnabled = false
                prList.isEnabled = false
            }
        }
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        if emailField.text != "" && pwField.text != "" {
            emptyInitialLogin()
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let credentials = Credentials(context : context)
            
            credentials.email = emailField.text
            credentials.password = pwField.text
            
            // Code to add, the data source & table view must stay in sync
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            currentEmail.text = emailField.text
            
            //enables tabs that require user to be logged in
            if let arrayOfTabBarItems = tabBarController?.tabBar.items as AnyObject as? NSArray,
                let mailsList = arrayOfTabBarItems[1] as? UITabBarItem, let prList = arrayOfTabBarItems[2] as? UITabBarItem{
                mailsList.isEnabled = true
                prList.isEnabled = true
            }
            
            self.tabBarController?.selectedIndex = 1
            clearFieldsAndResponder()
        }
    }
    
    func emptyInitialLogin() {
        
        //let count = credentials.count
        for cr in credentials
        {
            context.delete(cr)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        do {
            credentials = try context.fetch(Credentials.fetchRequest())
        } catch {
            print("Credentials Fetching Failed")
        }
        
        // Code to delete, the data source & table view must stay in sync
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func clearFieldsAndResponder(){
        emailField.text = ""
        pwField.text = ""
        
        emailField.resignFirstResponder()
        pwField.resignFirstResponder()
    }
    
    func getData() {
        do {
            credentials = try context.fetch(Credentials.fetchRequest())
        } catch {
            print("CR Fetching Failed")
        }
    }
}
