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
    var filteredData = [(product: String, dc: String)]()
    var isSearching = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var productRequestArray = [ProductRequests]()
    var credentialsArray = [Credentials]()
    var contactsArray = [Contacts]()
    let smtpSession = MCOSMTPSession()
    
    
    func loadSmtpSession(){
        let cr = credentialsArray[0]
        
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
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let pr = ProductRequests(context : context)
                
                pr.product = product
                pr.dc = dc
                
                // Code to add, the data source & table view must stay in sync
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                self.getData()
                self.tableView.reloadData()
                // Sends an email to everyone except this person to notify him of the product request
                
                let userEmailAddress : String = self.smtpSession.username
                
                // Get the list of all mail addresses from CoreData + remove email of current user
                //var stringDestEmailAddresses = [String]()
                
                // Transform the destEmailAddresses array in an array of MCOAddress to send them the message
                var recipientsMCOAddressArray = [MCOAddress]()
                
                for contact in self.contactsArray{
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
                builder.textBody.append("\nProductRequest#\(productText)\nDC#\(dcText)\n")
                builder.textBody.append("Thank you for your attention.")
                
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
            
            // Check first that the combination product/dc doesn't already exist in the fetched data here before adding
            do{
                productRequestArray = try context.fetch(ProductRequests.fetchRequest())
            }
            catch {
                print("PR Fetching Failed")
            }
            
            // If the combination product/dc is already in the array, we exit the function
            
            for element in productRequestArray{
                if element.product == product && element.dc == dc{
                    return
                }
            }
            
            // Else we add the combination to the array
            let pr = ProductRequests(context : context)
            pr.product = product
            pr.dc = dc
            
            // Code to add, the data source & table view must stay in sync
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            getData()
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.returnKeyType = UIReturnKeyType.done
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        getData()
        
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
            cell.textLabel?.text = filteredData[indexPath.row].product
            cell.detailTextLabel?.text = filteredData[indexPath.row].dc
        }
        else{
            // If we are not searching, loads data from the database
            let productRequest = productRequestArray[indexPath.row]
            cell.textLabel?.text = productRequest.product
            cell.detailTextLabel?.text = "DC: " + productRequest.dc!
        }
        return cell
    }
    
    // Allows for deletion in Product Request List
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete from datasource
            let pr = productRequestArray[indexPath.row]
            context.delete(pr)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                productRequestArray = try context.fetch(ProductRequests.fetchRequest())
            } catch {
                print("PR Fetching Failed")
            }
            
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
            let textLength = searchText.characters.count
            if textLength <= getMaxStringLengthInPRArray(){
                let filteredPR = productRequestArray.filter({($0.product?.lowercased().contains(searchText.lowercased()))!})
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
        for element in productRequestArray{
            if (element.product?.characters.count)! > length{
                length = (element.product?.characters.count)!
            }
        }
        return length
    }
    
    func getData(){
        //Product Requests fetch
        do {
            productRequestArray = try context.fetch(ProductRequests.fetchRequest())
        } catch {
            print("PR Fetching Failed")
        }
        
        //Credentials fetch
        do {
            credentialsArray = try context.fetch(Credentials.fetchRequest())
        } catch {
            print("Credentials Fetching Failed")
        }
        
        //Contacts fetch
        do {
            contactsArray = try context.fetch(Contacts.fetchRequest())
        } catch {
            print("Contacts Fetching Failed")
        }
    }
}
