////
////  LogAddViewController.swift
////  TMA
////
////  Created by Arvinder Basi on 2/5/17.
////  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class LogAddViewController: UIViewController {
//

import UIKit
import RealmSwift

class LogAddViewController: UIViewController {

    let realm = try! Realm()
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    var log: Log?
    
    @IBAction func add_log(_ sender: Any) {
        self.log = Log()
        
        log!.title = titleTextField.text
        log!.duration = Int(durationTextField.text!)!
        
        Helpers.DB_insert(obj: log!)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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