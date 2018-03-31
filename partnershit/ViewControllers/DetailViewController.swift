//
//  DetailViewController.swift
//  partnershit
//
//  Created by user on 14/10/2017.
//  Copyright © 2017 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import Firebase

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var detailTV: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var msgTxt: UITextField!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var statusBtnOutlet: UIButton!
    @IBAction func statusBtnAction(_ sender: Any) {
        var value: String! = "Parked"
        if (status == "Parked") {
           value = "Using"
        } else {
           value = "Parked"
        }
        ref.child("status").child(channel).setValue(value)
        OneSignal.postNotification(["contents": ["en": "Car is " + value.lowercased()], "include_player_ids": pushNotiUser])
    }
    @IBAction func sendBtn(_ sender: Any) {
        let key = ref.child("statement").childByAutoId().key
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormater.string(from: datePicker.date)
        var message = name
        if (msgTxt.text != ""){
            message = name + ": " + msgTxt.text!
        }
        let post = ["date": dateString, "price":priceTxt.text, "message": message] as [String : Any]
        let childUpdates = ["statement/" + channel + "/" + key: post]
        ref.updateChildValues(childUpdates)
    }
    
    var ref: DatabaseReference! = Database.database().reference()
    var detailList = [String: AnyObject]()
    var keyList = [String]()
    var pushNotiUser = [String]()
    var status: String! = ""
    var name: String! = ""
    var items = [StatementObject]()
    let oneSignalState: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
    var channel = ""
    let preferences = UserDefaults.standard
    let currentLevelKey = "levelKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBtnOutlet.isEnabled = false
        firebaseFetching()
        let nib = UINib(nibName: "StatementCellTableViewCell", bundle: nil)
        detailTV.register(nib, forCellReuseIdentifier: "Cell")
        if let email = preferences.string(forKey: "USER_EMAIL") {
            name = email
        }
        hideKeyboardWhenTappedAround()
        resizeViewForKeyboard()
        updatePlayerId()
        self.title = channel
        preferences.set(channel, forKey: Constants.CurrentScreen)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        preferences.removeObject(forKey: Constants.CurrentScreen)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTV.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatementCellTableViewCell
        cell.dateTxt.text = items[indexPath[1]].date
        cell.msgTxt.text = items[indexPath[1]].message
        cell.priceTxt.text = items[indexPath[1]].price
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let key = items[indexPath[1]].key
        let post = [:] as [String : Any]
        let statement = "statement/" + channel + "/" + key
        let oldStatement = "old statement/" + channel + "/" + key
        let childUpdates = [statement: post, oldStatement: detailList[key] as Any] as [String : AnyObject]
        ref.updateChildValues(childUpdates)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "封存"
    }
    
    func firebaseFetching () {
        ref.child("status").child(channel).observe(DataEventType.value) { (snapshot) in
            if let status = snapshot.value as? String{
                self.status = status
                self.statusBtnOutlet.isEnabled = true
                self.statusBtnOutlet.setTitle(status, for: .normal)
            } else {
                self.ref.child("status").child(self.channel).setValue("Parked")
            }
        }
        ref.child("statement").child(channel).observe(DataEventType.value, with: {(snapshot) in
            self.keyList = []
            self.detailList = [:]
            self.items = []
            if let postDict = snapshot.value as? [String: AnyObject] {
                for (key, value) in postDict {
                    let object = StatementObject()
                    object.date = value["date"] as! String
                    object.message = value["message"] as! String
                    object.price = value["price"] as! String
                    object.key = key
                    self.items.append(object)
                    self.keyList.append(key)
                    self.detailList[key] = value
                }
                self.items.sort(by: {$0.date > $1.date})
            }
            
            self.detailTV.reloadData()
        })
        
        ref.child("subscriber").child(self.channel).observe(DataEventType.value) { (snapshot) in
            if let subscribersObj = snapshot.value as? [String: String] {
                for (_, value) in subscribersObj {
                    self.pushNotiUser.append(value)
                }
            }
        }
    }
    
    func updatePlayerId() {
        let uid = preferences.object(forKey: currentLevelKey) as! String
        if let userId = oneSignalState.subscriptionStatus.userId {
            let value = userId
            let updates = [uid: value]
            self.ref.child("subscriber").child(self.channel).updateChildValues(updates)
        }
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
