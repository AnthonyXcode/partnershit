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
import SwiftMessages

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var detailTV: UITableView!
    @IBAction func infoBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "infoAlert") as! InfoAlertViewController
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.userName = userName
        alert.userId = userId
        alert.channelId = channelId
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func newBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "addStatementAlert") as! StatementAlertViewController
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.channelId = self.channelId
        alert.userName = userName
        alert.userId = userId
        self.present(alert, animated: true, completion: nil)
    }
    
    var ref: DatabaseReference! = Database.database().reference()
    var detailList = [String: AnyObject]()
    var keyList = [String]()
    var status: String! = ""
    var userName: String! = ""
    var userId: String! = ""
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
        if let name = preferences.string(forKey: Constants.UserName) {
            userName = name
        }
        if let uid = preferences.string(forKey: Constants.uid) {
            userId = uid
        }
        self.title = channelName
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
        cell.dateTxt.text = String(items[indexPath[1]].date.prefix(10))
        cell.msgTxt.text = items[indexPath[1]].message
        cell.priceTxt.text = "$" + items[indexPath[1]].price
        cell.nameTxt.text = items[indexPath[1]].senderName
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let statement = self.items[indexPath[1]]
        if (statement.senderId == self.userId) {
            let key = statement.key
            let post = [:] as [String : Any]
            let statement = "statement/" + channelId + "/" + key
            let oldStatement = "old statement/" + channelId + "/" + key
            let childUpdates = [statement: post, oldStatement: detailList[key] as Any] as [String : AnyObject]
            ref.updateChildValues(childUpdates)
        } else {
            var config = SwiftMessages.Config()
            config.presentationStyle = .bottom
            config.duration = .seconds(seconds: 2)
            let view = MessageView.viewFromNib(layout: .messageView)
            view.configureTheme(.info)
            view.titleLabel?.isHidden = true
            view.button?.isHidden = true
            view.iconLabel?.isHidden = true
            view.iconImageView?.isHidden = true
            view.configureContent(body: "無法封存其他成員的賬目")
            view.bodyLabel?.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "封存"
    }
    
    func firebaseFetching () {
        ref.child("statement").child(channelId).observe(DataEventType.value, with: {(snapshot) in
            self.keyList = []
            self.detailList = [:]
            self.items = []
            if let postDict = snapshot.value as? [String: AnyObject] {
                for (key, value) in postDict {
                    let object = StatementObject()
                    object.date = value["date"] as! String
                    object.message = value["message"] as! String
                    object.price = value["price"] as! String
                    object.senderId = value["sender_id"] as! String
                    object.senderName = value["sender_name"] as! String
                    object.key = key
                    self.items.append(object)
                    self.keyList.append(key)
                    self.detailList[key] = value
                }
                self.items.sort(by: {$0.date > $1.date})
            }
            
            self.detailTV.reloadData()
        })
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
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
