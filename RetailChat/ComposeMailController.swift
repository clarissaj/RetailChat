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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var credentials = [Credentials]()
    let smtpSession = MCOSMTPSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        loadSmtpSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanFields()
    }
    
    // Function triggered when the user press on the Send mail button
    @IBAction func sendMail(_ sender: UIBarButtonItem) {
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: destField.text!, mailbox: destField.text!)]
        builder.header.from = MCOAddress(displayName: smtpSession.username, mailbox: smtpSession.username)
        builder.header.subject = subjectField.text!
        builder.textBody = bodyField.text!
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data!)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                print("Error sending email: \(String(describing: error))")
            } else {
                print("Successfully sent email!")
            }
        }
    }
    
    func loadSmtpSession(){
        let cr = credentials[0]
        
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = cr.email
        smtpSession.password = cr.password
        smtpSession.port = 465
        
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data == nil {
                print("Connection error while setting SMTP session")
                //if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                //    print("Connectionlogger: \(string)")
                //}
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
    
    func getData() {
        do {
            credentials = try context.fetch(Credentials.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
    }
    
}
