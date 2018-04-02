//
//  StatementAlertViewController.swift
//  partnershit
//
//  Created by user on 3/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit

class StatementAlertViewController: UIViewController {

    @IBAction func canncelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okBtn(_ sender: Any) {
    }
    @IBOutlet var messageTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        resizeViewForKeyboard()
        // Do any additional setup after loading the view.
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
