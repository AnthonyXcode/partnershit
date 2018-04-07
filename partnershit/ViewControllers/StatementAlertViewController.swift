//
//  StatementAlertViewController.swift
//  partnershit
//
//  Created by user on 3/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase

class StatementAlertViewController: UIViewController {

    @IBAction func canncelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okBtn(_ sender: Any) {
        self.addStatement()
    }
    @IBOutlet var messageTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var ref: DatabaseReference! = Database.database().reference()
    let preferences = UserDefaults.standard
    
    var userName = ""
    var userId = ""
    var channelId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        resizeViewForKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addStatement() {
        let msg = messageTxt.text
        let price = priceTxt.text
        if (price != "") {
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let dateString = dateFormater.string(from: datePicker.date)
            let key = ref.childByAutoId().key
            let post = ["date": dateString, "price": price, "message": msg, "sender_name": self.userName, "sender_id": self.userId]
            let childUpdates = ["statement/" + channelId + "/" + key: post]
            self.ref.updateChildValues(childUpdates)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
