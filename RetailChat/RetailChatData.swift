//
//  RetailChatData.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit
import CoreData

final class RetailChatData {

    static let sharedInstance = RetailChatData()
    
    private var productRequests = [ProductRequests]()
    private var loginCredentials = [Credentials]()
    private var mails = [MailMO]()
    private var contacts = [Contacts]()
    let persitentContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    let imapSession = MCOIMAPSession() // Imap session to fetch messages
    let smtpSession = MCOSMTPSession() // Smtp session to send back automatically confirmation of delivery messages
    var smtpLoaded = false
    var imapLoaded = false
    
    private init(){
        getData()
    }
    
    func getData() {
        guard let persitentContainer = persitentContainer else { return }
        
        do {
            productRequests = try persitentContainer.viewContext.fetch(ProductRequests.fetchRequest())
            loginCredentials = try persitentContainer.viewContext.fetch(Credentials.fetchRequest())
            mails = try persitentContainer.viewContext.fetch(MailMO.fetchRequest())
            contacts = try persitentContainer.viewContext.fetch(Contacts.fetchRequest())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getProductRequests() -> [ProductRequests] {
        return productRequests
    }
    
    func getContacts() -> [Contacts] {
        return contacts
    }
    
    /*
    func modifyPRArray(_ pr: [ProductRequests]) {
        productRequestArray = pr
    }*/
    
    func getPRCount() -> Int {
        return productRequests.count
    }
    
    func getMailsCount() -> Int {
        return mails.count
    }
    
    func getContactsCount() -> Int {
        return contacts.count
    }
    
    func getPR(atIndex: Int) -> ProductRequests {
        return productRequests[atIndex]
    }
    
    func getMail(atIndex: Int) -> MailMO {
        return mails[atIndex]
    }
    
    func getContact(atIndex: Int) -> Contacts {
        return contacts[atIndex]
    }
    
    func filterProductRequests(_ searchText: String) -> [ProductRequests] {
        getData()
        return productRequests.filter { productRequest -> Bool in
            guard let product = productRequest.product else { return false }
            return product.lowercased().contains(searchText.lowercased())
        }
    }
    
    func deleteMail(atIndex: Int){
        guard let persitentContainer = persitentContainer else { return }
        
         // Remove from CoreData
        let mail = mails[atIndex]
        
        persitentContainer.performBackgroundTask { backgroundContext in
            backgroundContext.delete(mail)
            
            do {
                try backgroundContext.save()
                self.mails = try persitentContainer.viewContext.fetch(MailMO.fetchRequest())
            } catch {
                print("Mail Delete Saving/Fetching Failed: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteProductRequest(atIndex: Int){
        guard let persitentContainer = persitentContainer else { return }
        
        persitentContainer.performBackgroundTask { backgroundContext in
            // Remove from CoreData
            let pr = self.productRequests[atIndex]
            backgroundContext.delete(pr)
            
            do {
                try backgroundContext.save()
                self.productRequests = try persitentContainer.viewContext.fetch(ProductRequests.fetchRequest())
            } catch {
                print("PR Delete Saving/Fetching Failed: \(error.localizedDescription)")
            }
        }
    }
    
    func saveProductRequest(_ product: String?, _ dc: String?) {
        guard let persitentContainer = persitentContainer else { return }
        
        // Check first that the combination product/dc doesn't already exist in the fetched data here before adding
        do{
            productRequests = try persitentContainer.viewContext.fetch(ProductRequests.fetchRequest())
        }
        catch {
            print("PR Fetching Failed: \(error.localizedDescription)")
        }
        
        // If the combination product/dc is already in the array, we exit the function
        for element in productRequests{
            if element.product == product && element.dc == dc{
                return
            }
        }
        
        // Else we add the combination to the array
        persitentContainer.performBackgroundTask { backgroundContext in
            let pr = ProductRequests(context : backgroundContext)
            pr.product = product
            pr.dc = dc
            
            // Code to add, the data source & table view must stay in sync
            do {
                try backgroundContext.save()
                self.getData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveContact(_ email: String){
        guard let persitentContainer = persitentContainer else { return }
        
        persitentContainer.performBackgroundTask { backgroundContext in
            let contact = Contacts(context : backgroundContext)
            
            contact.email = email
            
            // Code to add, the data source & table view must stay in sync
            do {
                try backgroundContext.save()
            } catch {
                print("Contact save error: \(error.localizedDescription)")
            }
            
            self.getData()
        }
    }
    
    func saveMail(_ uid: String, _ header: MCOMessageHeader, _ body: String) -> Bool{
        var saved = false
        guard let persitentContainer = persitentContainer else { return saved }
        
        // Check first that the mail doesn't already exist in the fetched data here before adding
        do{
            mails = try persitentContainer.viewContext.fetch(MailMO.fetchRequest())
        }
        catch {
            print("Mail Fetching Failed: \(error.localizedDescription)")
        }
        
        // If the mail is already in the array, we exit the function
        for element in mails {
            if element.messageID == uid {
                return false
            }
        }
        
        //save
        let headerFrom = header.from.description
        let headerFromArray = headerFrom.components(separatedBy: " ")
        let headerTo = header.to.description
        let headerToArray = headerTo.components(separatedBy: " ")
        
        let backgroundContext = persitentContainer.newBackgroundContext()

        let mail = MailMO(context : backgroundContext)
        
        mail.to = headerToArray.last
        if let mailTo = mail.to {
            mail.to = String(mailTo.dropLast())
        }
        mail.to = mail.to?.replacingOccurrences(of: "<", with: "")
        mail.to = mail.to?.replacingOccurrences(of: ">", with: "")
        mail.from = headerFromArray.last
        if let mailFrom = mail.from {
            mail.from = String(mailFrom.dropLast())
            mail.from = String(mailFrom.dropFirst())
        }
        mail.subject = header.subject
        mail.messageID = uid
        mail.body = body
        
        // Code to add, the data source & table view must stay in sync
        do {
            try backgroundContext.save()
            saved = true
            self.getData()
        } catch {
            print("Mail save error: \(error.localizedDescription)")
        }
        
        return saved
    }
    
    func emptyMails() {
        guard let persitentContainer = persitentContainer else { return }
        
        persitentContainer.performBackgroundTask { backgroundContext in
            for mail in self.mails
            {
                backgroundContext.delete(mail)
            }
            
            do {
                try backgroundContext.save()
                self.mails = try persitentContainer.viewContext.fetch(MailMO.fetchRequest())
            } catch {
                print("Credentials Saving/Fetching Failed: \(error.localizedDescription)")
            }
        }
    }
    
    func getUserCredentials(index: Int) -> Credentials{
        getData()
        return loginCredentials[index]
    }
    
    func credentialsIsEmpty() -> Bool {
        getData()
        return loginCredentials.isEmpty
    }
    
    func emptyInitialLogin() {
        guard let persitentContainer = persitentContainer else { return }
        
        persitentContainer.performBackgroundTask { backgroundContext in
            for cr in self.loginCredentials
            {
                backgroundContext.delete(cr)
            }
            
            do {
                try backgroundContext.save()
                self.loginCredentials = try persitentContainer.viewContext.fetch(Credentials.fetchRequest())
            } catch {
                print("Credentials Saving/Fetching Failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Function that setups the connection the the smtp mail server
    func loadSmtpSession(){
        if smtpLoaded{
            return
        }
        
        let cr = getUserCredentials(index: 0)
        
        // Values to be loaded from Core Data
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = cr.email
        smtpSession.password = cr.password
        smtpSession.port = 465
        smtpSession.connectionType = .TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            print(type)
            print(data as Any)
            if data == nil {
                print("Connection error while setting SMTP session")
            }
        }
        
        smtpLoaded = true
    }
    
    // Function that setups the connection to the imap mail server
    func loadImapConnection(){
        if imapLoaded{
            return
        }
        
        let cr = getUserCredentials(index: 0)
        
        // Values to be loaded from CoreData
        imapSession.hostname = "imap.gmail.com"
        imapSession.username = cr.email
        imapSession.password = cr.password
        imapSession.port = 993
        imapSession.authType = .saslPlain
        imapSession.connectionType = .TLS
        imapSession.connectionLogger = {(connectionID, type, data) in
            print(type)
            print(data as Any)
            if data == nil {
                print("Connection error while setting IMAP session")
            }
        }
        
        imapLoaded = true
    }
    
    func getImapSession() -> MCOIMAPSession{
        return imapSession
    }
    
    func getSmtpSession() -> MCOSMTPSession{
        return smtpSession
    }
}
