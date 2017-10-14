//
//  ViewController.swift
//  partnershit
//
//  Created by user on 14/10/2017.
//  Copyright © 2017 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var accountTxt: UITextField!
    @IBOutlet weak var pwTxt: UITextField!
    @IBAction func confirmBtn(_ sender: Any) {
        Auth.auth().signIn(withEmail: accountTxt.text!, password: pwTxt.text!)
    }
    @IBAction func signoutBtn(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("sign out")
        } catch {
            print("error")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Auth.auth().addStateDidChangeListener{(auth, user) in
            if (user != nil){
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailView")
                {
                    let vcControler = vc as! DetailViewController
                    vcControler.userName = user!.email
                    self.showDetailViewController(vc, sender: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

