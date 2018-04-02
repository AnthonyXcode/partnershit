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
    @IBAction func sendBtn(_ sender: Any) {
//        let key = ref.child("statement").childByAutoId().key
//        let dateFormater = DateFormatter()
//        dateFormater.dateFormat = "yyyy-MM-dd"
//        let dateString = dateFormater.string(from: datePicker.date)
//        var message = name
//        if (msgTxt.text != ""){
//            message = name + ": " + msgTxt.text!
//        }
//        let post = ["date": dateString, "price":priceTxt.text, "message": message] as [String : Any]
//        let childUpdates = ["statement/" + channelName + "/" + key: post]
//        ref.updateChildValues(childUpdates)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "addStatementAlert")
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(alert, animated: true, completion: nil)
    }
    
    var ref: DatabaseReference! = Database.database().reference()
    var detailList = [String: AnyObject]()
    var keyList = [String]()
    var pushNotiUser = [String]()
    var status: String! = ""
    var name: String! = ""
    var items = [StatementObject]()
    let oneSignalState: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
    var channelName = ""
    var channelId = ""
    let preferences = UserDefaults.standard
    let currentLevelKey = "levelKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        firebaseFetching()
        let nib = UINib(nibName: "StatementCellTableViewCell", bundle: nil)
        detailTV.register(nib, forCellReuseIdentifier: "Cell")
        if let email = preferences.string(forKey: "USER_EMAIL") {
            name = email
        }
        hideKeyboardWhenTappedAround()
        resizeViewForKeyboard()
        self.title = channelName
        preferences.set(channelName, forKey: Constants.CurrentScreen)
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
        let statement = "statement/" + channelName + "/" + key
        let oldStatement = "old statement/" + channelName + "/" + key
        let childUpdates = [statement: post, oldStatement: detailList[key] as Any] as [String : AnyObject]
        ref.updateChildValues(childUpdates)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "封存"
    }
    
    func firebaseFetching () {
        ref.child("statement").child(channelName).observe(DataEventType.value, with: {(snapshot) in
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
        
        ref.child("subscriber").child(self.channelName).observe(DataEventType.value) { (snapshot) in
            if let subscribersObj = snapshot.value as? [String: String] {
                for (_, value) in subscribersObj {
                    self.pushNotiUser.append(value)
                }
            }
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
