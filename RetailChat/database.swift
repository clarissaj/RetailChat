//
//  database.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import Foundation

final class database{

    static let sharedInstance = database()
    
    private var productRequestArray = [ProductRequests]()
    private var mailsArray = [Mail]()
    
    private init(){}
    
    // Function that gets data from CoreData and fills the arrays
    func populateArrays(){
    
    }
    
    func getMailArray() -> [Mail]{
        return mailsArray
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
    
    func deleteMail(atIndex: Int){
         // Remove from CoreData
        
        // mailsArray.remove(at: atIndex) //Maybe not necessary with CoreData
    }
}
