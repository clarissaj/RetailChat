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
    
    // Adds a new product to the product request list, modally
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Product", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            (textField) -> Void in
            textField.placeholder = "product and DC amount"
            textField.autocapitalizationType = .words
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) -> Void in
            
            if let product = alert.textFields?.first?.text {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let pr = ProductRequests(context : context)
                
                pr.product = product
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.returnKeyType = UIReturnKeyType.done
        tableView.delegate = self
        tableView.dataSource = self
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
