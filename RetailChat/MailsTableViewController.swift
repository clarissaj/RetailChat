//
//  MailsTableViewController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

class MailsTableViewController: UITableViewController{
    
    let db = database.sharedInstance
     let session = MCOIMAPSession()
    
    var locationAlert = UIAlertController(title: "Invalid location", message: "You cannot use this application when not working, exiting.", preferredStyle: .alert)
    var mailAccountAlert = UIAlertController(title: "Could Not access Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in exit(0)}))

        // Checks the location of the user relatively to the work location, exit if they don't match
        
        // If location != work location, alert and exit
        if false{
            present(locationAlert, animated: true)
        }
        
        // If we're here it means that we are at work, i.e. we can receive the emails
        mailAccountAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in }))
        
        setupMailConnection()
        getNewMails()
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            // Delete from datasource
            
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
                mailViewController.fromLabel.text = mail.from
                mailViewController.toLabel.text = mail.to
                mailViewController.objectLabel.text = mail.subject
                mailViewController.bodyLabel.text = mail.body
            }
        case "newMail"?:
            let newMailController = segue.destination as! ComposeMailController
            newMailController.cleanFields()
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    // Function that setups the connection the the mail server
    func setupMailConnection(){
        
        session.hostname = "imap.gmail.com"
        session.username = "cj13bestbuy@gmail.com"
        session.password = "bestbuytest"
        session.port = 993
        session.connectionType = MCOConnectionType.TLS
        session.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    //print("Connectionlogger: \(string)")
                }
            }
        }
    }
    
    // Function that fetches new mails
    func getNewMails(){
        print(UINT64_MAX)
        let uidSet = MCOIndexSet()
        
        let requestKind = MCOIMAPMessagesRequestKind.fullHeaders
        var operation = session.fetchMessagesOperation(withFolder: "INBOX", requestKind: requestKind, uids: uidSet)
        
        //let fetchOp = session.fetchMessagesByUIDOperation(withFolder: "INBOX", requestKind: MCOIMAPMessagesRequestKind.fullHeaders, uids: uidSet)
        
        let test = session.fetchAllFoldersOperation()
        test?.start({(error: Error?, data: [Any]?) in
            print(data!)
        })

        operation?.start { (err, msg, vanished) -> Void in
            print("error from server \(err)")
            print("fetched \(msg?.count) messages")
        }
    }
    
    // Function that adds automatically an item in the product request view table of the user, based on the body of the mails he receives
    func addProductRequestFromMail(_ body: String?){
        if body == nil{
            return
        }
        
        do{
            let regexProduct = try NSRegularExpression(pattern: "\\bProductRequest#(\\w+)\\b")
            let regexDC = try NSRegularExpression(pattern: "\\bDC#(\\d+)\\b")
            let nsString = body! as NSString
            let productsInMail = regexProduct.matches(in: body!, range: NSRange(location: 0, length: nsString.length))
            let dcInMails = regexDC.matches(in: body!, range: NSRange(location: 0, length: nsString.length))
            // Now need to get the results as strings and add them by pair of PR/DC in the product request list
        }
        catch let error{
            print("Invalid regex: \(error.localizedDescription)")
        }
    }
}

