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
    var channels = [String]()
    let realm = try! Realm()
    var ref: DatabaseReference! = Database.database().reference()
    var uid: String! = ""
    
    let preferences = UserDefaults.standard
    let currentLevelKey = "levelKey"
    
    @IBAction func addChannelBtn(_ sender: Any) {
        let alert = UIAlertController(title: "加入頻道", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "頻道名稱"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            var isUnique = false
            for channelName in self.channels {
                if channelName == textField!.text {
                    isUnique = true
                }
            }
            if (!isUnique){
                let channel = ChannelsObject()
                channel.name = textField!.text!
                try! self.realm.write {
                    self.realm.add(channel)
                }
                self.channels.append(channel.name)
                self.channelsTableView.reloadData()
                self.ref.child("users").child(self.uid).child("channels").updateChildValues([channel.name: true])
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realmChannels = realm.objects(ChannelsObject.self)
        for obj in realmChannels {
            channels.append(obj.name)
        }
        uid = preferences.object(forKey: currentLevelKey) as! String
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let detailScreen = preferences.string(forKey: Constants.CurrentScreen) {
            self.performSegue(withIdentifier: "ToDetailSegue", sender: detailScreen)
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelItem", for: indexPath)
        cell.textLabel?.text = channels[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ToDetailSegue", sender: self.channels[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailView = segue.destination as? DetailViewController {
            detailView.channel = sender as! String
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let channel = realm.objects(ChannelsObject.self).filter("name == %@", channels[indexPath.row])
            try! realm.write {
                realm.delete(channel)
            }
            self.ref.child("users").child(self.uid).child("channels").updateChildValues([channels[indexPath.row]: false])
            OneSignal.deleteTag(channels[indexPath.row])
            channels.remove(at: indexPath.row)
            channelsTableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

}
