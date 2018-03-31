//
//  ViewController.swift
//  partnershit
//
//  Created by user on 14/10/2017.
//  Copyright © 2017 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class ViewController: UIViewController {
    
    let preferences = UserDefaults.standard
    let currentLevelKey = "levelKey"

    @IBOutlet weak var accountTxt: UITextField!
    @IBOutlet weak var pwTxt: UITextField!
    @IBAction func confirmBtn(_ sender: Any) {
        Auth.auth().createUser(withEmail: accountTxt.text!, password: pwTxt.text!) { (user, error) in
            if (error != nil) {
                Auth.auth().signIn(withEmail: self.accountTxt.text!, password: self.pwTxt.text!) {(user, error) in
                    if (error != nil) {
                        let alert = UIAlertController(title: "error", message: "login or register failed", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
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
            if let u = user {
                self.preferences.set(u.uid, forKey: self.currentLevelKey)
                self.preferences.set(u.email!, forKey: "USER_EMAIL")
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainNavigation")
                {
                    let vcControler = vc as! MainNavigationViewController
                    vcControler.userName = u.email
                    self.showDetailViewController(vc, sender: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        resizeViewForKeyboard()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    func resizeViewForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if (view.frame.origin.y != 0){
                view.frame.origin.y = 0
            }
            view.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if view.frame.origin.y != 0{
                view.frame.origin.y += keyboardHeight
            }
        }
        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if view.frame.origin.y != 0{
//                view.frame.origin.y += keyboardSize.height
//            }
//        }
    }
}

