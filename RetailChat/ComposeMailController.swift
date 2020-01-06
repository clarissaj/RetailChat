//
//  ComposeMailController.swift
//  RetailChat
//
//  Created by student on 12/11/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

// Controller in charge of the view to compose and send a mail
class ComposeMailController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var destField: UITextField!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var bodyField: UITextField!
    
    let db = database.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.getData()
        db.loadSmtpSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanFields()
    }
    
    // Function triggered when the user press on the Send mail button
    @IBAction func sendMail(_ sender: UIBarButtonItem) {
        if destField.isFirstResponder{
            destField.resignFirstResponder()
        }
        else if subjectField.isFirstResponder{
            subjectField.resignFirstResponder()
        }
        else if bodyField.isFirstResponder{
            bodyField.resignFirstResponder()
        }
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: destField.text!, mailbox: destField.text!) as MCOAddress]
        builder.header.from = MCOAddress(displayName: db.getSmtpSession().username, mailbox: db.getSmtpSession().username)
        builder.header.subject = subjectField.text!
        builder.textBody = bodyField.text!
        
        let rfc822Data = builder.data()
        let sendOperation = db.getSmtpSession().sendOperation(with: rfc822Data!)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                print("Error sending email: \(String(describing: error))")
            } else {
                print("Successfully sent email!")
                let mailSentAlert = UIAlertController(title: "Success", message: "Mail successfully sent.", preferredStyle: .alert)
                mailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (_) in self.navigationController?.popViewController(animated: true)}))
                self.present(mailSentAlert, animated: true)
            }
        }
    }
    
    // Function that cleans the fields of this view, activated when the user presses on the button to compose a message and when the view disappears
    func cleanFields(){
        if destField != nil && subjectField != nil && bodyField != nil{
            destField.text = ""
            subjectField.text = ""
            bodyField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
