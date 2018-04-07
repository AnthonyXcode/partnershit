//
//  MyViewController.swift
//  partnershit
//
//  Created by user on 1/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class MyViewController: UIViewController {
    
    let preferences = UserDefaults.standard
    let realm = try! Realm()
    var userName = ""
    
    @IBAction func logoutBtn(_ sender: Any) {
        try! Auth.auth().signOut()
        let dictionary = preferences.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            preferences.removeObject(forKey: key)
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "homePage")
        {
            self.showDetailViewController(vc, sender: self)
        }
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    @IBAction func nameBtn(_ sender: Any) {
        let alert = UIAlertController(title: "更改名稱", message: "請輸入名稱", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "名稱"
            textField.text = self.userName
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: {(_) in
            let textField = alert.textFields![0]
            if let name = textField.text {
                self.preferences.set(name, forKey: Constants.UserName)
                self.nameLab.text = name
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func archiveBtn(_ sender: Any) {
    }
    
    @IBOutlet weak var nameLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = self.preferences.string(forKey: Constants.UserName) {
            self.userName = name
            self.nameLab.text = name
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
