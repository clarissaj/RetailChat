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
    let composeVC  = MFMailComposeViewController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
        composeVC.mailComposeDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Function that gives the table view the number of rows to print, from the database containing mails
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // Function that constructs the table view cells to display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
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
                mailViewController.objectLabel.text = mail.object
                mailViewController.bodyLabel.text = mail.body
            }
        //case "createMail"?:
         //   break
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    
    @IBAction func composeMail(_ sender: UIBarButtonItem) {
        if !MFMailComposeViewController.canSendMail(){
            print("Mail services are not available.")
        }
        else{
            self.present(composeVC, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        dismiss(animated: true, completion: nil)
    }
}

