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
    
    let rcDataCache = RetailChatData.sharedInstance
    
    @IBAction func addContact(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            (textField) -> Void in
            textField.placeholder = "email"
            textField.autocapitalizationType = .words
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            if let email = alert.textFields?.first?.text {
                self.rcDataCache.saveContact(email)
                self.tableView.reloadData()
            }
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rcDataCache.getData()
        tableView.reloadData()
    }
    
    // Function that gives the table view the number of rows to print, from the database containing the mails of each contact
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the number of Contacts we have in CoreData
        return rcDataCache.getContactsCount()
    }
    
    // Function that constructs the table view cells to display from the contact list fetched by CoreData
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        cell.textLabel?.text = rcDataCache.getContact(atIndex: indexPath.row).email
        return cell
    }
    
    // When the segue is triggered by pressing the mail of a contact in the tableview, we insert his mail address in the "To" field called destField in ComposeMailController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "newMailToContact"?:
            if let row = tableView.indexPathForSelectedRow?.row{
                let composeViewController = segue.destination as! ComposeMailController
                if composeViewController.view == nil{
                    composeViewController.loadView()
                }
                composeViewController.destField.text = rcDataCache.getContact(atIndex: row).email
                composeViewController.subjectField.text = ""
                composeViewController.bodyField.text = ""
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
