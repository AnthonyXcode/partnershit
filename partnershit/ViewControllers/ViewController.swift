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
import FacebookLogin
import FacebookCore

class ViewController: UIViewController {
    
    let preferences = UserDefaults.standard

    @IBOutlet var nameTxt: UITextField!
    @IBOutlet weak var accountTxt: UITextField!
    @IBOutlet weak var pwTxt: UITextField!
    @IBAction func confirmBtn(_ sender: Any) {
        self.login(name: nameTxt.text!, email: accountTxt.text!, password: pwTxt.text!)
    }
    @IBAction func facebookLoginBtn(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile, ReadPermission.email], viewController: self, completion: { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("cancel")
            case .success(grantedPermissions: _, declinedPermissions: _, token: let accessToken):
                self.getFbProfile(token: accessToken)
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signIn(with: credential)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Auth.auth().addStateDidChangeListener{(auth, user) in
            if let u = user {
                self.preferences.set(u.uid, forKey: Constants.uid)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabbar")
                {
                    self.showDetailViewController(vc, sender: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        resizeViewForKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(name: String, email: String, password: String) {
        if (name != "") {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if (error != nil) {
                    Auth.auth().signIn(withEmail: self.accountTxt.text!, password: self.pwTxt.text!) {(user, error) in
                        if (error != nil) {
                            let alert = UIAlertController(title: "error", message: "login or register failed", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.preferences.set(email, forKey: Constants.Email)
                            self.preferences.set(name, forKey: Constants.UserName)
                        }
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "error", message: "Please choose a user name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getFbProfile(token: AccessToken) {
        let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"first_name,email, picture.type(large)"], accessToken: token , httpMethod: .GET)
        graphRequest.start({ (response, result) in
            switch result {
            case .failed(let error):
                print(error)
            case .success(let result):
                if let data = result.dictionaryValue {
                    let email = data["email"] as! String
                    let first_name = data["first_name"] as! String
                    self.preferences.set(email, forKey: Constants.Email)
                    self.preferences.set(first_name, forKey: Constants.UserName)
                }
            }
        })
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

