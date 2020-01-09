//
//  MailViewController.swift
//  RetailChat
//
//  Created by olivier andre pierre nappert on 12/6/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

// Class that shows the details of a specific mail
class MailViewController: UIViewController{

    var from: String?
    var to: String?
    var subject: String?
    var body: String?
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //label border
        fromLabel.layer.cornerRadius = 5
        fromLabel.layer.borderWidth = 1
        fromLabel.layer.borderColor = UIColor.black.cgColor
        
        //label border
        toLabel.layer.cornerRadius = 5
        toLabel.layer.borderWidth = 1
        toLabel.layer.borderColor = UIColor.black.cgColor
        
        //label border
        subjectLabel.layer.cornerRadius = 5
        subjectLabel.layer.borderWidth = 1
        subjectLabel.layer.borderColor = UIColor.black.cgColor
        
        //label border
        bodyLabel.layer.cornerRadius = 5
        bodyLabel.layer.borderWidth = 1
        bodyLabel.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let testFrom = from, let testTo = to,
            let testSubject = subject, let testBody = body{
            toLabel.text = testTo
            fromLabel.text = testFrom
            subjectLabel.text = testSubject
            bodyLabel.text = testBody
        } else {
            print("fields empty?")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clears the text contained in the labels
        fromLabel.text = ""
        toLabel.text = ""
        subjectLabel.text = ""
        bodyLabel.text = ""
    }
}
