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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func submitPressed(_ sender: UIButton) {
        if emailField.text != "" && pwField.text != "" {
            emptyLogin()
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let credentials = Credentials(context : context)
            
            credentials.email = emailField.text
            credentials.password = pwField.text
            
            // Code to add, the data source & table view must stay in sync
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            currentEmail.text = emailField.text
            
            clearFieldsAndResponder()
        }
    }
    
    func emptyLogin() {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Credentials")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
        } catch {
            print("Batch Delete Failed")
        }
        
        // Code to add, the data source & table view must stay in sync
        //(UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func clearFieldsAndResponder(){
        emailField.text = ""
        pwField.text = ""
        
        emailField.resignFirstResponder()
        pwField.resignFirstResponder()
    }
}
