//
//  ContactListViewController.swift
//  RetailChat
//
//  Created by student on 12/12/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

// Class that accesses and displays to the list of all our contact's email address
class ContactListViewController: UITableViewController {
    
    let db = database.sharedInstance
    
    // Function that gives the table view the number of rows to print, from the database containing the mails of each contact
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the number of Contacts we have in the CoreData db
        return 0
    }
    
    // Function that constructs the table view cells to display from the contact list fetched by CoreData
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = db.getContactMail(index: indexPath.row)
        return cell
    }
 */
    
    // When the segue is triggered by pressing the mail of a contact in the tableview, we insert his mail address in the "To" field called destField in ComposeMailController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "newMailToContact"?:
            if let row = tableView.indexPathForSelectedRow?.row{
                let composeViewController = segue.destination as! ComposeMailController
                //let contactMail = db.getContactMail(index: indexPath.row)
                //composeViewController.destField.text = contactMail
                composeViewController.subjectField.text = ""
                composeViewController.bodyField.text = ""
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
