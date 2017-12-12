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
    
    //let db = database.sharedInstance
    var filteredData = [String]()
    var isSearching = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var productRequestArray = [ProductRequests]()
    let smtpSession = MCOSMTPSession()
    
    
    func loadSmtpSession(){
        // To change with values retrieved from CoreData, same thing in ComposeMail and MailsTableView
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "cj13bestbuy@gmail.com"
        smtpSession.password = "bestbuytest"
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
    
    
    // Adds a new product to the product request list, modally from the Product Request tab
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Product", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            (textField) -> Void in
            textField.placeholder = "product and DC amount" // "Product name"
            textField.autocapitalizationType = .words
        }
        
        /* Maybe have a text field just for product and another one just for DC amount, would simplify to send the mail to all users 
         // In the same fashion maybe should we have one attribute for DC and one for product in the Entity list
         
        alert.addTextField {
            (textField) -> Void in
            textField.placeholder = "DC amount"
            textField.autocapitalizationType = .words
        }
         
         // You can access the text fields one by one with the alert.textFields array
        */

        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            if let product = alert.textFields?.first?.text {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let pr = ProductRequests(context : context)
                
                pr.product = product
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                // Code to add, the data source & table view must stay in sync
                
                
                // Sends an email to everyone except this person to notify him of the product request
                
                let userEmailAddress : String = self.smtpSession.username
                
                // Get the list of all mail addresses from CoreData + remove email of current user
                var stringDestEmailAddresses = [String]()
                
                // Transform the destEmailAddresses array in an array of MCOAddress to send them the message
                var recipientsMCOAddressArray = [MCOAddress]()
                
                for address in stringDestEmailAddresses{
                    recipientsMCOAddressArray.append(MCOAddress(displayName: address, mailbox: address))
                }
                
                // Build the message
                let builder = MCOMessageBuilder()
                builder.header.to = recipientsMCOAddressArray
                builder.header.from = MCOAddress(displayName: userEmailAddress, mailbox: userEmailAddress)
                builder.header.subject = "AUTO-GENERATED: Product Request"
                
                // Case where we have two textFields, otherwise more complicated:
                //builder.textBody = "This message has been generated automatically, please do not answer.\n\nProductRequest#\(alert.textFields?.first?.text)\nDC#\(alert.textFields?[1].text)\n\nThank you for your attention."
                
                let rfc822Data = builder.data()
                
                // Send the mails
                let sendOperation = self.smtpSession.sendOperation(with: rfc822Data!, from: MCOAddress(displayName: userEmailAddress, mailbox: userEmailAddress), recipients: recipientsMCOAddressArray)
                
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
    
    // Function that adds a product to the product request list programmatically from information in a mail
    func addNewItemFromMail(_ product: String?, _ dc: String?){
        if product != nil && dc != nil{
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            // Should check first that the combination product/dc doesn't already exist in the fetched data here before adding
            let pr = ProductRequests(context : context)
            pr.product = product
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            // Code to add, the data source & table view must stay in sync
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.returnKeyType = UIReturnKeyType.done
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        
        // Loads the SMTP session
        self.loadSmtpSession()
    }
    
    // Function that gives the table view the number of rows to print, from the database containing mails
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return filteredData.count
        }
        return productRequestArray.count
    }
    
    // Function that constructs the table view cells to display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        if isSearching{
            // If we are searching, loads data from the data that matches the search
            cell.textLabel?.text = filteredData[indexPath.row]
        }
        else{
            // If we are not searching, loads data from the database
            cell.textLabel?.text = productRequestArray[indexPath.row].product
        }
        return cell
    }
    
    // Allows for deletion in Product Request List
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let product = productRequestArray[indexPath.row]
            context.delete(product)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                productRequestArray = try context.fetch(ProductRequests.fetchRequest())
            } catch {
                print("Fetching Failed")
            }
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
            let filteredPR = productRequestArray.filter({($0.product?.lowercased())! == searchText.lowercased()})
            for pr in filteredPR{
                filteredData.append(pr.product!)
            }
            tableView.reloadData()
        }
    }
    
    // Method to fill in data
    func getData() {
        do {
            productRequestArray = try context.fetch(ProductRequests.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
    }
    
}
