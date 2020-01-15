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

    var mail: Mail?
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelsWithBorders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearLabelTextInNewMail()
    }
    
    func clearLabelTextInNewMail() {
        // Clears the text contained in the labels
        fromLabel.text = ""
        toLabel.text = ""
        subjectLabel.text = ""
        bodyLabel.text = ""
    }
    
    func setupMail() {
        if let mail = mail {
            toLabel.text = mail.to
            fromLabel.text = mail.from
            subjectLabel.text = mail.subject
            bodyLabel.text = mail.body
        } else {
            print("mail doesn't exist")
        }
    }
    
    func setupLabelsWithBorders() {
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
}
