//
//  ChannelTableViewController.swift
//  partnershit
//
//  Created by user on 15/1/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import Firebase
import OneSignal

class ChannelTableViewController: UITableViewController {
    
    @IBOutlet var channelsTableView: UITableView!
    var channels = [String: String]()
    let realm = try! Realm()
    var ref: DatabaseReference! = Database.database().reference()
    let oneSignalState: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
    var uid: String! = ""
    var userName: String! = ""
    
    let preferences = UserDefaults.standard
    
    @IBAction func addChannelBtn(_ sender: Any) {
        let alert = UIAlertController(title:"請選擇", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "新增帳薄", style: .default, handler: {(_) in
            self.addChannelAlert()
        }))
        alert.addAction(UIAlertAction(title: "加入帳薄", style: .default, handler: {(_) in
            self.joinChannelAlert()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realmChannels = realm.objects(ChannelsObject.self)
        for obj in realmChannels {
            channels[obj.id] = obj.name
        }
        uid = preferences.object(forKey: Constants.uid) as! String
        userName = preferences.object(forKey: Constants.UserName) as! String
        firebaseFetching()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelItem", for: indexPath) as! ChannelTableViewCell
        let channelId = Array(channels.keys)[indexPath.row]
        cell.channelName.text = channels[channelId]
        cell.channelCodeBtn.setTitle(channelId, for: .normal)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channelId = Array(channels.keys)[indexPath.row]
        let channel = [channelId: channels[channelId]]
        self.performSegue(withIdentifier: "ToDetailSegue", sender: channel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailView = segue.destination as? DetailViewController {
            for (id, name) in (sender as? [String: String])! {
                detailView.channelName = name
                detailView.channelId = id
            }
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channelId = Array(channels.keys)[indexPath.row]
            let channel = realm.objects(ChannelsObject.self).filter("id == %@", channelId)
            try! realm.write {
                realm.delete(channel)
            }
            self.ref.child("users").child(self.uid).child("channels").child(channelId).removeValue()
            self.removeSubscriber(channelId: channelId)
            channels.removeValue(forKey: channelId)
            channelsTableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
        }
    }
    
    func addChannelAlert() {
        let alert = UIAlertController(title: "新增帳薄", message: "請輸入帳薄名稱", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "帳薄名稱"}
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: {(_) in
            let textField = alert.textFields![0]
            if let channelName = textField.text {
                self.addChannel(channelName: channelName)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func joinChannelAlert() {
        let alert = UIAlertController(title: "加入帳薄", message: "請輸入帳薄代碼", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "帳薄代碼"}
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: {(_) in
            let textField = alert.textFields![0]
            if let channelId = textField.text {
                self.joinChannel(channelId: channelId)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addChannel(channelName: String) {
        let channelId = CommonFunction.randomString(length: 5)
        self.ref.child("users").child(self.uid).child("channels").updateChildValues([channelId: channelName])
        self.ref.child("channels").child(channelId).updateChildValues(["name": channelName])
        self.newSubscriber(channelId: channelId)
    }
    
    func joinChannel (channelId: String) {
        ref.child("channels").child(channelId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                print(value)
                let channelName = value["name"] as! String
                self.ref.child("users").child(self.uid).child("channels").updateChildValues([channelId: channelName])
                self.newSubscriber(channelId: channelId)
            }
        })
    }
    
    func newSubscriber (channelId: String) {
        if let userId = oneSignalState.subscriptionStatus.userId {
            self.ref.child("subscriber").child(channelId).child(self.uid).updateChildValues(["onesignal_id": userId, "user_name": self.userName])
        }
    }
    
    func removeSubscriber(channelId: String) {
        self.ref.child("subscriber").child(channelId).child(self.uid).removeValue()
    }
    
    func firebaseFetching () {
        self.ref.child("users").child(self.uid).child("detail").updateChildValues(["user_name": self.userName])
        self.ref.child("users").child(self.uid).child("channels").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for (id, name) in value {
                    self.channels[id as! String] = name as? String
                    let channel = ChannelsObject()
                    channel.id = id as! String
                    channel.name = name as! String
                    try! self.realm.write {
                        self.realm.add(channel)
                    }
                    self.channelsTableView.reloadData()
                }
            }
        })
    }

}
