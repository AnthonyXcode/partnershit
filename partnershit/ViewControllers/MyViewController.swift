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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
