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
    private var contactsArray = [Contacts]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init(){
        getData()
    }
    
    // Function that gets data from CoreData and fills the arrays
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
        
        //Mails fetch
        do {
            mailsArray = try context.fetch(Mail.fetchRequest())
        } catch {
            print("Mails Fetching Failed")
        }
        
        //Contacts fetch
        do {
            contactsArray = try context.fetch(Contacts.fetchRequest())
        } catch {
            print("Contacts Fetching Failed")
        }
    }
    
    func getPRArray() -> [ProductRequests]{
        return productRequestArray
    }
    
    func getContacts() -> [Contacts]{
        return contactsArray
    }
    
    /*
    func modifyPRArray(_ pr: [ProductRequests]) {
        productRequestArray = pr
    }*/
    
    func getPRCount() -> Int{
        return productRequestArray.count
    }
    
    func getMailsCount() -> Int{
        return mailsArray.count
    }
    
    func getContactsCount() -> Int{
        return contactsArray.count
    }
    
    func getPR(atIndex: Int) -> ProductRequests{
        return productRequestArray[atIndex]
    }
    
    func getMail(atIndex: Int) -> Mail{
        return mailsArray[atIndex]
    }
    
    func getContact(atIndex: Int) -> Contacts{
        return contactsArray[atIndex]
    }
    
    func filterPR(_ searchText: String) -> [ProductRequests]{
        getData()
        return productRequestArray.filter({($0.product?.lowercased().contains(searchText.lowercased()))!})
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
        
        // Code to delete, the data source & table view must stay in sync
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
        
        // Code to delete, the data source & table view must stay in sync
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func savePR(_ product: String?, _ dc: String?) {
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
    }
    
    func saveContact(_ email: String){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contact = Contacts(context : context)
        
        contact.email = email
        
        // Code to add, the data source & table view must stay in sync
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
    }
    
    func saveMail(_ header: MCOMessageHeader, _ body: String){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Check first that the mail doesn't already exist in the fetched data here before adding
        do{
            mailsArray = try context.fetch(Mail.fetchRequest())
        }
        catch {
            print("Mail Fetching Failed")
        }
        
        // If the mail is already in the array, we exit the function
        for element in mailsArray{
            if element.messageID == header.messageID{
                return
            }
        }
        
        //save
        var headerFrom = header.from.description
        let headerFromArray = headerFrom.characters.split{$0 == " "}.map(String.init)
        var headerTo = header.to.description
        let headerToArray = headerTo.characters.split{$0 == " "}.map(String.init)
        
        let mail = Mail(context : context)
        
        mail.to = headerToArray.last!
        mail.from = headerFromArray.last!
        mail.subject = header.subject
        mail.messageID = header.messageID
        mail.body = body
        
        // Code to add, the data source & table view must stay in sync
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
    }
    
    func emptyMails() {
        for mail in mailsArray
        {
            context.delete(mail)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        do {
            mailsArray = try context.fetch(Mail.fetchRequest())
        } catch {
            print("Credentials Fetching Failed")
        }
        
        // Code to delete, the data source & table view must stay in sync
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func getUserCredentials(index: Int) -> Credentials{
        getData()
        return credentialsArray[index]
    }
    
    func credentialsIsEmpty() -> Bool {
        getData()
        return credentialsArray.isEmpty
    }
    
    func emptyInitialLogin() {
        for cr in credentialsArray
        {
            context.delete(cr)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        do {
            credentialsArray = try context.fetch(Credentials.fetchRequest())
        } catch {
            print("Credentials Fetching Failed")
        }
        
        // Code to delete, the data source & table view must stay in sync
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}
