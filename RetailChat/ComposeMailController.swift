//
//  ComposeMailController.swift
//  RetailChat
//
//  Created by student on 12/11/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

// Controller in charge of the view to compose and send a mail
class ComposeMailController: UIViewController{

    @IBOutlet weak var destField: UITextField!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var bodyField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanFields()
    }
    
    // Function triggered when the user press on the Send mail button
    @IBAction func sendMail(_ sender: UIBarButtonItem) {
        
    }
    
    // Function that cleans the fields of this view, activated when the user presses on the button to compose a message and when the view disappears
    func cleanFields(){
        destField.text = ""
        subjectField.text = ""
        bodyField.text = ""
    }
}
