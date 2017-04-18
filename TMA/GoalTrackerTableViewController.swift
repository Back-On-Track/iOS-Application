//
//  GoalTrackerTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 4/13/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift

class GoalTrackerViewCell: UITableViewCell {
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
}

class GoalTrackerTableViewController: UITableViewController {

    let realm = try! Realm()
    let eventStore = EKEventStore()
    var events = [Event]()
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var pageTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = pageTitle
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let identifier = UserDefaults.standard.value(forKey: calendarKey) {
            if let calendar = getCalendar(withIdentifier: identifier as! String) {
                let calEvents = getCalendarEvents(forDate: Date(), fromCalendars: [calendar])
                print(calEvents.count)
                self.events = findFreeTimes(onDate: Date(), withEvents: calEvents)
            }
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 11)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerCell", for: indexPath) as! GoalTrackerViewCell

        let event = self.events[indexPath.row]
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        cell.day?.text = dayFormatter.string(from: event.date)
        
        cell.title?.text = "Free"
        
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = TimeZone.current
        
        if(event.duration == 24.0) {
            cell.time?.text = "All Day"
        }
        else {
            cell.time?.text = timeFormatter.string(from: event.date) + " - " + timeFormatter.string(from: Date.getEndDate(fromStart: event.date, withDuration: event.duration))
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}