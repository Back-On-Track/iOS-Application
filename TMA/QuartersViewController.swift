//
//  QuartersViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 3/29/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//"

import UIKit
import RealmSwift
import Alamofire

class QuarterTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dates: UILabel!
    @IBOutlet weak var numCourses: UILabel!
    @IBOutlet weak var current: UIImageView!
    @IBOutlet weak var viewCourses: UIButton!
    @IBOutlet weak var viewStats: UIButton!
}

class QuartersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    var quarterToEdit: Quarter!
    var quarters: Results<Quarter>!
    
    @IBOutlet weak var tableView: UITableView!
    
    func responseHandler (response: DataResponse<Any>) {
        if let status = response.response?.statusCode {
            print("status=\(status)")
            switch(status){
            case 200:
                let chart_url = response.result.value as! [String: String]
                print(chart_url["url"]!)
                
                let alert = UIAlertController(title: "Generated Stats Page", message: "Link to online stats page.", preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.delegate = self
                    
                    textField.inputView = UIView()
                    textField.text = chart_url["url"]!
                }
                
                alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak alert] (_) in
                    let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                    
                    if let chartURL = textField.text {
                        let url = URL(string: chartURL)!
                        UIApplication.shared.open(url, options: [:])
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Copy", style: .cancel, handler: { [weak alert] (_) in
                    //copy link to the clipboard
                    let textField = alert!.textFields![0]
                    if let chartURL = textField.text {
                        let pasteBoard = UIPasteboard.general
                        pasteBoard.string = chartURL
                    }
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                break
            default:
                let alert = UIAlertController(title: "Error", message: "There was an error with the request.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                break
            }
        }
    }
        
    @IBAction func generateStats(_ sender: Any) {
        Helpers.export_data_to_server(action: "export_for_chart", responseHandler: responseHandler)
    }
    
    @IBAction func add(_ sender: Any) {
        self.performSegue(withIdentifier: "addQuarter", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("Path to realm file: " + self.realm.configuration.fileURL!.absoluteString)
                
        self.quarters = self.realm.objects(Quarter.self).sorted(byKeyPath: "startDate", ascending: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.quarters = self.realm.objects(Quarter.self).sorted(byKeyPath: "startDate", ascending: false)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.quarters.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        }

        let image = UIImage(named: "quarterBackground")!
        let topMessage = "Quarters"
        let bottomMessage = "You haven't created any quarters. All your quarters will show up here."
        
        self.tableView.backgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
        self.tableView.separatorStyle = .none
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quarters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuarterCell", for: indexPath) as! QuarterTableViewCell
        
        let quarter = quarters[indexPath.row]
        
        cell.title!.text = quarter.title
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "M/d/yy"
        
        cell.dates!.text = "\(formatter.string(from: quarter.startDate)) to \(formatter.string(from: quarter.endDate))"
        
        let count = self.realm.objects(Course.self).filter(NSPredicate(format: "quarter.title == %@", quarter.title!)).count
        cell.numCourses!.text = "\(count) courses"
        
        cell.current.backgroundColor = quarter.current ? UIColor.green : UIColor.gray
        cell.current.layer.cornerRadius = cell.current.frame.size.width / 2
        cell.current.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let quarter = self.quarters[index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(quarter.title!)\" and all associated items will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Quarter", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                quarter.delete(from: self.realm)
                self.tableView.reloadData()
            })
            optionMenu.addAction(deleteAction);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }//end delete
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            let quarters = self.realm.objects(Quarter.self).sorted(byKeyPath: "startDate", ascending: false)
            self.quarterToEdit = quarters[index.row]
            
            self.performSegue(withIdentifier: "editQuarter", sender: nil)
        }
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.quarterToEdit = self.quarters[indexPath.row]

        self.performSegue(withIdentifier: "editQuarter", sender: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let navigation: UINavigationController = segue.destination as! UINavigationController
        let quartersAddViewController = navigation.viewControllers[0] as! QuarterAddTableViewController
        
        if segue.identifier == "addQuarter" {
            quartersAddViewController.operation = "add"
        }
        else if segue.identifier == "editQuarter" {
            quartersAddViewController.operation = "edit"
            quartersAddViewController.quarter = quarterToEdit
        }

    }
    
}
