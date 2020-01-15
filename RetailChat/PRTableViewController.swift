//
//  PRTableViewController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

class PRTableViewController: UITableViewController, UISearchBarDelegate{
    
    @IBOutlet weak var searchField: UISearchBar!
    
    let rcDataCache = RetailChatData.sharedInstance
    var filteredData = [(product: String, dc: String)]()
    var isSearching = false
    
    // Adds a new product to the product request list, modally from the Product Request tab
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Product", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            (textField) -> Void in
            textField.placeholder = "Product"
            textField.autocapitalizationType = .words
        }
        
         
        alert.addTextField {
            (textField) -> Void in
            textField.placeholder = "DC amount"
            textField.autocapitalizationType = .words
        }
         
         // You can access the text fields one by one with the alert.textFields array

        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            if let product = alert.textFields?[0].text, let dc = alert.textFields?[1].text {
                self.rcDataCache.saveProductRequest(product, dc)
                self.tableView.reloadData()
                // Sends an email to everyone except this person to notify him of the product request
                
                let userEmailAddress : String = self.rcDataCache.getSmtpSession().username
                
                // Get the list of all mail addresses from CoreData + remove email of current user
                //var stringDestEmailAddresses = [String]()
                
                // Transform the destEmailAddresses array in an array of MCOAddress to send them the message
                var recipientsMCOAddressArray = [MCOAddress]()
                
                for contact in self.rcDataCache.getContacts(){
                    recipientsMCOAddressArray.append(MCOAddress(displayName: contact.email, mailbox: contact.email))
                }
                
                // Build the message
                let builder = MCOMessageBuilder()
                builder.header.to = recipientsMCOAddressArray
                builder.header.from = MCOAddress(displayName: userEmailAddress, mailbox: userEmailAddress)
                builder.header.subject = "AUTO-GENERATED: Product Request"
                
                let productText : String = (alert.textFields?[0].text)!
                let dcText : String = (alert.textFields?[1].text)!
                // Case where we have two textFields, otherwise more complicated:
                builder.textBody = "This message has been generated automatically, please do not answer."
                builder.textBody.append("\nProductRequest#\(productText)_DC#\(dcText)\n")
                builder.textBody.append("Thank you for your attention.")
                
                let rfc822Data = builder.data()
                
                // Send the mails
                let sendOperation = self.rcDataCache.getSmtpSession().sendOperation(with: rfc822Data!, from: MCOAddress(displayName: userEmailAddress, mailbox: userEmailAddress), recipients: recipientsMCOAddressArray)
                
                sendOperation?.start { (error) -> Void in
                    if (error != nil) {
                        print("Error sending email: \(String(describing: error))")
                    } else {
                        print("Successfully sent emails!")
                    }
                }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.returnKeyType = UIReturnKeyType.done
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        rcDataCache.getData()
        
        // Loads the SMTP session
        rcDataCache.loadSmtpSession()
    }
    
    // Function that gives the table view the number of rows to print, from the database containing mails
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return filteredData.count
        }
        return rcDataCache.getPRCount()
    }
    
    // Function that constructs the table view cells to display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        if isSearching{
            // If we are searching, loads data from the data that matches the search
            cell.textLabel?.text = filteredData[indexPath.row].product
            cell.detailTextLabel?.text = filteredData[indexPath.row].dc
        }
        else{
            // If we are not searching, loads data from the database
            let productRequest = rcDataCache.getPR(atIndex: indexPath.row)
            cell.textLabel?.text = productRequest.product
            cell.detailTextLabel?.text = "DC: " + productRequest.dc!
        }
        return cell
    }
    
    // Allows for deletion in Product Request List
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete from datasource
            rcDataCache.deleteProductRequest(atIndex: indexPath.row)
            
            // Delete from table view
            tableView.deleteRows(at: [indexPath], with: .automatic)

        }
        
        tableView.reloadData()
    }
    
    // Main delegate function for the search bar, filters the data in the table view using the entered string
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""{
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else{
            filteredData.removeAll()
            isSearching = true
            let textLength = searchText.count
            if textLength <= getMaxStringLengthInPRArray(){
                let filteredPR = rcDataCache.filterProductRequests(searchText)
                for pr in filteredPR{
                    filteredData.append((product: pr.product!, dc: pr.dc!))
                }
            }
            else{
                filteredData.removeAll()
            }
            tableView.reloadData()
        }
    }
    
    func getMaxStringLengthInPRArray() -> Int{
        var length = 0
        for element in rcDataCache.getProductRequests(){
            if (element.product?.count)! > length{
                length = (element.product?.count)!
            }
        }
        return length
    }
}
