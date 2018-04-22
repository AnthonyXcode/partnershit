//
//  ViewController.swift
//  partnershit
//
//  Created by user on 14/10/2017.
//  Copyright © 2017 AnthonyChan. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FacebookCore

class ViewController: UIViewController {
    
    let preferences = UserDefaults.standard
    let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!

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
        if self.preferences.string(forKey: Constants.versionCode) == nil {
            try! Auth.auth().signOut()
            self.preferences.set(self.version as! String, forKey: Constants.versionCode)
        }
        Auth.auth().addStateDidChangeListener{(auth, user) in
            if let u = user {
                if self.preferences.string(forKey: Constants.versionCode) != nil {
                    self.preferences.set(u.uid, forKey: Constants.uid)
                    self.preferences.set(true, forKey: Constants.isLogin)
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabbar")
                    {
                        self.showDetailViewController(vc, sender: self)
                    }
                } else {
                    try! Auth.auth().signOut()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(name: String, email: String, password: String) {
        if (name == "") {
            let alert = UIAlertController(title: "錯誤", message: "請輸入用戶名稱", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (password.count < 8) {
            let alert = UIAlertController(title: "錯誤", message: "密碼長度不足", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.preferences.set(email, forKey: Constants.Email)
        self.preferences.set(name, forKey: Constants.UserName)
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if (error != nil) {
                let errorCode = (error! as NSError).code
                if (errorCode == 17011) {
                    print(errorCode)
                    self.createAccAndSignIn(email: email, password: password, name: name)
                } else {
                    let alert = UIAlertController(title: "錯誤", message: "登入失敗", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func createAccAndSignIn(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            if (error != nil) {
                let alert = UIAlertController(title: "錯誤", message: "新增賬號失敗", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.login(name: name, email: email, password: password)
            }
        })
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
