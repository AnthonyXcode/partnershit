//
//  ArchiveTableViewController.swift
//  partnershit
//
//  Created by user on 7/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase

class ArchiveTableViewController: UITableViewController {

    var ref: DatabaseReference! = Database.database().reference()
    var userId = ""
    let preferences = UserDefaults.standard
    var archiveItems = [String: [StatementObject]]()
    var channels = [ChannelsObject]()
    var statementValus = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "StatementCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        if let id = preferences.string(forKey: Constants.uid) {
            userId = id
        }
        self.tabBarController?.tabBar.isHidden = true
        self.firebaseFetching()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return archiveItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let keys = Array(archiveItems.keys)
        return (archiveItems[keys[section]]?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatementCellTableViewCell
        let keys = Array(archiveItems.keys)
        let key = keys[indexPath[0]]
        if let statements = archiveItems[key] {
            let statement = statements[indexPath[1]]
            cell.dateTxt.text = statement.date
            cell.msgTxt.text = statement.message
            cell.nameTxt.text = statement.senderName
            cell.priceTxt.text = statement.price
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var displayName = ""
        let keys = Array(archiveItems.keys)
        let currenyId = keys[section]
        for channel in channels {
            if (channel.id == currenyId) {
                displayName = channel.name
            }
        }
        return displayName
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let keys = Array(archiveItems.keys)
        let key = keys[indexPath[0]]
        if let statements = archiveItems[key] {
            let statement = statements[indexPath[1]]
            if (statement.senderId == userId) {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "取消封存"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let channelsKeys = Array(archiveItems.keys)
        let channelKey = channelsKeys[indexPath[0]]
        if let statements = archiveItems[channelKey] {
            let statement = statements[indexPath[1]]
            let statementKey = statement.key
            let oldPost = [:] as [String : Any]
            let newPost = statementValus[statementKey] as Any
            let oldStatement = "old statement/" + channelKey + "/" + statementKey
            let newStatement = "statement/" + channelKey + "/" + statementKey
            let childUpdates = [newStatement: newPost, oldStatement: oldPost] as [String : AnyObject]
            ref.updateChildValues(childUpdates)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    func firebaseFetching () {
        ref.child("users").child(userId).child("channels").observe(DataEventType.value, with: {(snapshot) in
            self.archiveItems = [:]
            self.channels = []
            self.statementValus = [:]
            self.tableView.reloadData()
            if let postDict = snapshot.value as? [String: String] {
                for (key, value) in postDict {
                    let channel = ChannelsObject(id: key, name: value)
                    self.channels.append(channel)
                    self.firebaseFetchingOnch(channelId: key)
                }
            }
        })
    }
    
    func firebaseFetchingOnch (channelId: String) {
        ref.child("old statement").child(channelId).observe(.value, with: {snapshot in
            if let postDict = snapshot.value as? [String: AnyObject] {
                var statements = [StatementObject]()
                for (key, value) in postDict {
                    let statement = StatementObject()
                    statement.key = key
                    statement.date = value["date"] as! String
                    statement.message = value["message"] as! String
                    statement.price = value["price"] as! String
                    statement.senderId = value["sender_id"] as! String
                    statement.senderName = value["sender_name"] as! String
                    statements.append(statement)
                    self.statementValus[key] = value
                }
                if (statements.count > 0) {
                    self.archiveItems[channelId] = statements
                } else {
                    self.archiveItems[channelId] = nil
                }
            }
            self.tableView.reloadData()
        })
    }
}
