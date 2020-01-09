//
//  MailsTableViewController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit
import CoreLocation

// Main class that shows received mails
class MailsTableViewController: UITableViewController{
    
    let db = database.sharedInstance
    // object that checks the location of the user to see if he's at work or not
    var locationManager : LocationManager?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var locationAlert = UIAlertController(title: "Invalid location", message: "You cannot use this application when not working, exiting.", preferredStyle: .alert)
    var mailAccountAlert = UIAlertController(title: "Could Not access Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = LocationManager()
        locationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in exit(0)}))

        // Checks the location of the user relatively to the work location, exit if they don't match
        
        guard let locationManager = locationManager else { return }
        let currentLocation = locationManager.getCoordinates()
        print("***** coordinates: \(currentLocation)\n")
        
        // If location != work location, alert and exit
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            if !locationManager.locationInBounds(currentLocation){
                present(locationAlert, animated: true)
            }
        }
        
        locationManager.stopUpdates()
        // If we're here it means that we are at work, i.e. we can receive the emails
        mailAccountAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in }))


        db.loadImapConnection()
        db.loadSmtpSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNewMails()
        db.getData()
        tableView.reloadData()
    }
    
    // Function that gives the table view the number of rows to print, from the database containing mails
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return db.getMailsCount()
    }
    
    // Function that constructs the table view cells to display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = db.getMail(atIndex: indexPath.row).subject
        return cell
    }
    
    // Function that will delete a row from the table view and the datasource when in editing mode
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            // Delete from datasource
            db.deleteMail(atIndex: indexPath.row)
            
            // Delete from table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Function that resigns the keyboard when the return key is pressed
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showMail"?:
            if let row = tableView.indexPathForSelectedRow?.row{
                let mailViewController = segue.destination as! MailViewController
                let mail = db.getMail(atIndex: row)
                mailViewController.from = mail.from
                mailViewController.to = mail.to
                mailViewController.subject = mail.subject
                mailViewController.body = mail.body
            }
        case "newMail"?:
            let newMailController = segue.destination as! ComposeMailController
            newMailController.cleanFields()
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    // Function that fetches mails, gets the header and the body
    func getNewMails(){
        let uidSet = MCOIndexSet()
        uidSet.add(MCORange(location: 1, length: UINT64_MAX))
        
        let requestKind = MCOIMAPMessagesRequestKind.headers
        let operation = db.getImapSession().fetchMessagesOperation(withFolder: "INBOX", requestKind: requestKind, uids: uidSet)
        
        operation?.start { (err, msg, vanished) -> Void in
            print("errors from server \(String(describing: err ?? nil))")
            print("fetched \(msg!.count) messages")
            let arrayOfMessages = msg as! [MCOIMAPMessage]
            var messageParser : MCOMessageParser?
            for message in arrayOfMessages{
                let fetchBody = self.db.getImapSession().fetchMessageOperation(withFolder: "INBOX", uid: message.uid)
                fetchBody?.start({(error: Error?, data: Data?) in
                    messageParser = MCOMessageParser(data: data!)
                    let saved = self.db.saveMail(String(message.uid), message.header, messageParser!.plainTextBodyRendering()) // the header object contains all the fields in the header you need, next to it is the body
                    self.tableView.reloadData()
                    //print((messageParser!.plainTextBodyRendering())!) // plain body text
                    
                    
                    
                    // Check if the body of the mail contains a Product request mention and if so add it to the Product request list
                    self.addProductRequestFromMail(messageParser!.plainTextBodyRendering())
                    
                    // For every incoming mail we also want to send an automatic delievery response, but we shouldn't answer if the mail was already auto-generated (i.e a we don't want to do an infinite loop of confirmation messages confirming each other)
                    // The solution is to set a fixed Subject for automatic answers and to not reply if the incoming message has that subject header
                    // Should do that only for the last, New messages tho and only once (else we will spam for one confirmation for each message received ever..)
                    
                    // To do that, we could fetch the existing mails received from Core Data, and make sure that if there is a match we don't do anything
                    
                    if saved && message.header.subject != "AUTO-GENERATED: Delivery confirmation"{
                        let builder = MCOMessageBuilder()
                        builder.header.to = [message.header.from as MCOAddress]
                        builder.header.from = MCOAddress(displayName: self.db.getSmtpSession().username, mailbox: self.db.getSmtpSession().username)
                        builder.header.subject = "AUTO-GENERATED: Delivery confirmation"
                        builder.textBody = "This message has been generated automatically, please do not answer.\n\nYour mail has successfully been delivered to this recipient.\n\nThank you for your attention."
                        
                        let rfc822Data = builder.data()
                        
                        // Sends the mail
                        let sendOperation = self.db.getSmtpSession().sendOperation(with: rfc822Data!)
                        
                        sendOperation?.start { (error) -> Void in
                            if (error != nil) {
                                print("Error sending email: \(String(describing: error))")
                            } else {
                                print("Successfully sent email!")
                            }
                        }
                    }
                })
            }
        }
    }
    
    // Function that adds automatically an item in the product request tableview of the user, based on the body of the mails he receives
    func addProductRequestFromMail(_ body: String?){
        if body == nil{
            return
        }
        
        do{
            // The body must contain ProductRequest#SomeNameHere\nDC#SomeNumberHere
            let regex = try NSRegularExpression(pattern: "\\bProductRequest#([a-zA-Z0-9\\s]+)_DC#(\\d+)\\b")
            let nsString = body! as NSString
            let matches = regex.matches(in: body!, range: NSRange(location: 0, length: nsString.length))
            // Now need to get the results as strings and add them by pair of PR/DC in the product request list
            
            var product : String? = nil
            var dc : String? = nil
            
            // Gets the strings from the mail corresponding to the product and dc, stock them in the corresponding variables
            for match in matches {
                for n in 0..<match.numberOfRanges {
                    let range = match.range(at: n)
                    let r = body!.index(body!.startIndex, offsetBy: range.location)..<body!.index(body!.startIndex, offsetBy: range.location+range.length)
                    print(String(body![r]))
                    if n == 1{
                        product = String(body![r])
                    }
                    else if n == 2{
                        dc = String(body![r])
                    }
                }
            }
            
            // By now we can use the previous variables and add an item to the list of the product requests tableview
            if product != nil && dc != nil{
                //let productRequestTab = self.tabBarController!.viewControllers![1] as! PRTableViewController
                //productRequestTab.addNewItemFromMail(product,dc)
                db.savePR(product, dc)
            }
        }
        catch let error{
            print("Invalid regex: \(error.localizedDescription)")
        }
    }
}

