//
//  DetailViewController.swift
//  partnershit
//
//  Created by user on 14/10/2017.
//  Copyright © 2017 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var detailTV: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var msgTxt: UITextField!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var statusTxt: UILabel!
    @IBOutlet weak var statusBtnOutlet: UIButton!
    @IBAction func statusBtnAction(_ sender: Any) {
        let key = "status"
        var value: String! = "Car is using"
        if (status == "Car is using") {
           value = "Car is parked"
        } else if (status == "Car is parked") {
           value = "Car is using"
        }
        let childUpdates = [key: value!]
        ref.updateChildValues(childUpdates)
    }
    @IBAction func sendBtn(_ sender: Any) {
        let key = ref.child("statement").childByAutoId().key
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yy-mm-dd"
        let dateString = dateFormater.string(from: datePicker.date)
        var message = name
        if (msgTxt.text != ""){
            message = name + ": " + msgTxt.text!
        }
        let post = ["date": dateString, "price":priceTxt.text, "message": message] as [String : Any]
        let childUpdates = ["statement/" + key: post]
        ref.updateChildValues(childUpdates)
    }
    
    var userName: String? = nil
    var ref: DatabaseReference! = Database.database().reference()
    var detailList = [String: AnyObject]()
    var keyList = [String]()
    var status: String! = ""
    var name: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        statusBtnOutlet.isEnabled = false
        ref.observe(DataEventType.value, with: {(snapshot) in
            self.keyList = []
            self.detailList = [:]
            let postDict = snapshot.value as? [String: AnyObject] ?? [:]
            let statement = postDict["statement"]! as? [String: AnyObject] ?? [:]
            for (key, value) in statement {
                self.keyList.append(key)
                self.detailList[key] = value
            }
            self.detailTV.reloadData()
            
            if let status = postDict["status"] {
                self.status = status as! String
                self.statusTxt.text = self.status
                self.statusBtnOutlet.isEnabled = true
                if (self.status == "Car is using") {
                    self.statusBtnOutlet.setTitle("Parked", for: .normal)
                } else if (self.status == "Car is parked") {
                    self.statusBtnOutlet.setTitle("Going to use", for: .normal)
                }
            }
        })
        
        let nib = UINib(nibName: "StatementCellTableViewCell", bundle: nil)
        detailTV.register(nib, forCellReuseIdentifier: "Cell")
        setUserName(email: userName!)
    }
    
    func setUserName (email: String) -> Void {
        if (email == "chanyunyuen@gmail.com") {
            name = "Yuen"
        } else {
            name = "Cho"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTV.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatementCellTableViewCell
        var cellData = [String: AnyObject]()
        cellData = detailList[keyList[indexPath[1]]] as! [String: AnyObject]
        if let date = cellData["date"] as? String {
            cell.dateTxt.text = date
        }
        if let message = cellData["message"] as? String {
            cell.msgTxt.text = message
        } else {
            cell.msgTxt.text = ""
        }
        
        if let price = cellData["price"] as? String {
            cell.priceTxt.text = "$" + price
        }
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
