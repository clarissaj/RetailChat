//
//  MailsTableViewController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit
import MessageUI

class MailsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var searchField: UISearchBar!
    
    let db = database.sharedInstance
    var composeVC  : MFMailComposeViewController?
    
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
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    // Function called when we press on the button to compose a mail
    @IBAction func composeMail(_ sender: UIBarButtonItem) {
        if !MFMailComposeViewController.canSendMail(){
            present(mailAccountAlert, animated: true)
        }
        else{
            composeVC = MFMailComposeViewController()
            composeVC?.mailComposeDelegate = self
            print(composeVC.debugDescription)
            self.present(composeVC!, animated: true)
        }
    }
    
    // Function called when either the Cancel or Send button on the ComposeView is pressed
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        dismiss(animated: true, completion: nil)
    }
}

