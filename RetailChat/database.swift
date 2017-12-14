//
//  database.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class database {

    static let sharedInstance = database()
    
    private var productRequestArray = [ProductRequests]()
    private var credentialsArray = [Credentials]()
    private var mailsArray = [Mail]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init(){
        populateArrays()
    }
    
    // Function that gets data from CoreData and fills the arrays
    func populateArrays(){
        
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
            print(" Credentials Fetching Failed")
        }
        
        //Mails fetch
        do {
            mailsArray = try context.fetch(Mail.fetchRequest())
        } catch {
            print(" Mails Fetching Failed")
        }
    }
    
    func getPRArray() -> [ProductRequests]{
        return productRequestArray
    }
    
    func modifyPRArray(_ pr: [ProductRequests]) {
        productRequestArray = pr
    }
    
    func getPRCount() -> Int{
        return productRequestArray.count
    }
    
    func getMailsCount() -> Int{
        return mailsArray.count
    }
    
    func getPR(atIndex: Int) -> ProductRequests{
        return productRequestArray[atIndex]
    }
    
    func getMail(atIndex: Int) -> Mail{
        return mailsArray[atIndex]
    }
    
    func filterPR(_ searchText: String) -> [ProductRequests]{
        return productRequestArray.filter({($0.product?.lowercased())! == searchText.lowercased()})
    }
    
    func deleteMail(atIndex: Int){
         // Remove from CoreData
        let mail = mailsArray[atIndex]
        context.delete(mail)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        do {
            mailsArray = try context.fetch(Mail.fetchRequest())
        } catch {
            print("Mail Fetching Failed")
        }
    }
    
    func deletePR(atIndex: Int){
        // Remove from CoreData
        let pr = productRequestArray[atIndex]
        context.delete(pr)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        do {
            productRequestArray = try context.fetch(ProductRequests.fetchRequest())
        } catch {
            print("PR Fetching Failed")
        }
    }
    
    }
