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
    
    let db = database.sharedInstance
    var filteredData = [String]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.returnKeyType = UIReturnKeyType.done
    }
    
    // Function that gives the table view the number of rows to print, from the database containing mails
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return filteredData.count
        }
        return 0
    }
    
    // Function that constructs the table view cells to display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        if isSearching{
            // If we are searching, loads data from the data that matches the search
            cell.textLabel?.text = filteredData[indexPath.row]
        }
        else{
            // If we are not searching, loads data from the database
            cell.textLabel?.text = db.getMail(atIndex: indexPath.row).object
        }
        return cell
    }
    
    // More functions are needed for the search bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""{
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else{
            filteredData.removeAll()
            isSearching = true
            let filteredPR = db.getPRArray().filter({($0.product?.lowercased())! == searchText.lowercased()})
            for pr in filteredPR{
                filteredData.append(pr.product!)
            }
            tableView.reloadData()
        }
    }
}
