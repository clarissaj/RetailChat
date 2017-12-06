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

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var objectLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clears the text contained in the labels
        fromLabel.text = ""
        toLabel.text = ""
        objectLabel.text = ""
        bodyLabel.text = ""
    }
}
