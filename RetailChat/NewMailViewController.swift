//
//  NewMailViewController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

// Class that handles writing a new email
class NewMailViewController: UIViewController, UITextViewDelegate{
    
    @IBOutlet weak var destMailField: UITextField!
    @IBOutlet weak var objectMailField: UITextField!
    @IBOutlet weak var bodyMailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Function called to resign the keyboard when the Return key is pressed
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // Function called when we press the Send Button
    @IBAction func sendMail(_ sender: UIBarButtonItem) {
        
        // After the mail has been sent, go back to the Mails table view
        self.navigationController?.popViewController(animated: true)
    }
}

