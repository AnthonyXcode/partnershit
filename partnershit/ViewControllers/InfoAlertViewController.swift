//
//  InfoAlertViewController.swift
//  partnershit
//
//  Created by user on 3/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

class InfoAlertViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var msgTxtFiled: UITextField!
    @IBOutlet weak var priceStatLab: UILabel!
    @IBOutlet weak var priceLab: UILabel!
    @IBOutlet weak var memberTV: UITableView!
    @IBOutlet weak var msgTV: UITableView!
    @IBAction func closeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sendBtn(_ sender: Any) {
        if let msg = msgTxtFiled.text {
            if (msg != "") {
                let date = Date()
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "yyyy-MM-dd-HH-mm-ss"
                let dateString = dateFormater.string(from: date)
                self.ref.child("messages").child(self.channelId).updateChildValues([dateString: ["message": msg, "sender_name": userName, "sender_id": userId]])
                var onesignalIdArr = [String]()
                for member in members {
                    if (member.userId != self.userId) {
                        onesignalIdArr.append(member.oneSignalId)
                    }
                }
                OneSignal.postNotification(["contents": ["en": userName + ":" + msg], "include_player_ids": onesignalIdArr])
                msgTxtFiled.text = ""
            }
        }
        dismissKeyboard()
    }
    
    let ref: DatabaseReference! = Database.database().reference()
    
    var userId = ""
    var userName = ""
    var channelId = ""
    var members = [Member]()
    var messages = [Message]()
    var statements = [StatementObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let memberNib = UINib(nibName: "MemberTableViewCell", bundle: nil)
        memberTV.register(memberNib, forCellReuseIdentifier: "memberCell")
        let messageNib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        msgTV.register(messageNib, forCellReuseIdentifier: "msgCell")
        firebaseFetching()
        hideKeyboardWhenTappedAround()
        resizeViewForKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == memberTV) {
            return members.count
        } else if (tableView == msgTV) {
            return messages.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == memberTV) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MemberTableViewCell
            let member = members[indexPath.row]
            cell.nameTxt.text = member.userName
            cell.containerView.layer.cornerRadius = 4
            return cell
        } else if (tableView == msgTV) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "msgCell", for: indexPath) as! MessageTableViewCell
            let message = messages[indexPath.row]
            cell.dateTxt.text = String(message.date.prefix(10))
            cell.msgTxt.text = message.message
            cell.nameTxt.text = message.userName + ": "
            if (message.userId == self.userId) {
                cell.containerView.layer.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.6470588235, blue: 0.9607843137, alpha: 1)
            } else {
                cell.containerView.layer.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.3137254902, alpha: 1)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MemberTableViewCell
            let member = members[indexPath.row]
            cell.nameTxt.text = member.userName
            return cell
        }
    }
    
    func getPayCount() -> Double {
        var sum = 0.0
        var userPay = 0.0
        for statement in statements {
            let price = Double(statement.price)
            if (statement.senderId == self.userId) {
                userPay = userPay + price!
            }
            sum = sum + price!
        }
        let averagePrice = sum / Double(members.count)
        return userPay - averagePrice
    }
    
    func reloadStatement() {
        if (self.getPayCount() == Double.infinity) {
            self.priceStatLab.text = ""
            self.priceLab.text = "計算中"
        } else if (self.getPayCount() >= 0){
            self.priceStatLab.text = "可收回: "
            self.priceLab.text = "$" + String(self.getPayCount())
        } else {
            self.priceStatLab.text = "應繳付: "
            self.priceLab.text = "$" + String(abs(self.getPayCount()))
        }
    }
    
    func firebaseFetching () {
        ref.child("subscriber").child(channelId).observe(DataEventType.value, with: {(snapshot) in
            self.members = []
            if let postDict = snapshot.value as? [String: AnyObject] {
                for (key, value) in postDict {
                    let object = Member()
                    object.userId = key
                    print(value)
                    object.userName = value["user_name"] as! String
                    object.oneSignalId = value["onesignal_id"] as! String
                    self.members.append(object)
                }
            }
            self.memberTV.reloadData()
            self.reloadStatement()
        })
        
        ref.child("messages").child(channelId).observe(DataEventType.value) { (snapshot) in
            self.messages = []
            if let messageObj = snapshot.value as? [String: AnyObject] {
                for (key, value) in messageObj {
                    let msg = Message()
                    msg.date = key
                    msg.userName = value["sender_name"] as! String
                    msg.userId = value["sender_id"] as! String
                    msg.message = value["message"] as! String
                    self.messages.append(msg)
                }
            }
            self.messages.sort(by: {$0.date > $1.date})
            self.msgTV.reloadData()
        }
        
        ref.child("statement").child(channelId).observe(DataEventType.value, with: { (snapshot) in
            self.statements = []
            if let statementObj = snapshot.value as? [String: AnyObject] {
                for (key, value) in statementObj {
                    let statement = StatementObject()
                    statement.key = key
                    statement.date = value["date"] as! String
                    statement.message = value["message"] as! String
                    statement.price = value["price"] as! String
                    statement.senderId = value["sender_id"] as! String
                    statement.senderName = value["sender_name"] as! String
                    self.statements.append(statement)
                }
            }
            self.reloadStatement()
        })
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
