//
//  ViewController.swift
//  table
//
//  Created by Risul Rashed
//

import UIKit
import UserNotifications

class toDoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var someData: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        myNotification()
    }
    
    // Getting permission to show notifications
    func myNotification(){
        // If user agrees then means granted, if nothing then probably error
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard error == nil else{
                print("Error: \(error!.localizedDescription)")
                return
            }
            if granted{
                print("User Agreed to sned notification")
            }
            else{
                print("User denied to get notification")
            }
        }
    }
    // Creating notifications for our app
    func myCalenderNotification(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound?, date: Date) -> String {
        // Creating notiication content
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = sound
        content.body = body
        content.badge = badgeNumber
        
        // The trigger
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponents.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // The request
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        // Register request with notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let myError = error{
                print("Error: \(myError.localizedDescription)")
            }
            else{
                print("Notification Scheduled \(notificationID), title: \(content.title)")
            }
        }
        return notificationID
    }
    // Creating Notification
    func createNotification(){
        guard someData.count > 0 else{
            return
        }
        // Remove all previous notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Create fresh notification
        for index in 0..<someData.count{
            if someData[index].reminder{
                var item = someData[index]
                item.notificationID = myCalenderNotification(title: item.name, subtitle: "Nothing", body: item.note, badgeNumber: nil, sound: .default, date: item.date)
            }
        }
    }
    
    
    // Saving Data to directory // We are just writing the data or ecoding it
                                // Later we need to decode the data and load it
    // to save  data we can use path or url(we will use, because it's easier to work with
    func saveData(){
        // We will use following code over and over to save user data
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("myDocument").appendingPathExtension("json")
        let myJasonEncoder = JSONEncoder()
        let data = try? myJasonEncoder.encode(someData)
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch{
            print("Couldn't Save data 😢\\_/\(error.localizedDescription)")
        }
        
        // Setting Up the notification
        createNotification()
    }
    // Decoding the saved data (loading data)
    func loadData(){
        // We will use following code over and over to save user data
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("myDocument").appendingPathExtension("json")
        
        // User might be opening app for the first time with no data
        guard let data = try? Data(contentsOf: documentURL) else{return}
        let myJasonDecoder = JSONDecoder()
        do{ // Might throw error
            someData = try myJasonDecoder.decode(Array<ToDoItem>.self, from: data)
            tableView.reloadData()
        } catch{
            print("Couldn't load data 😢\\_/\(error.localizedDescription)")
        }
    }
    
    // Preparing tbale view for next segua -> toDoTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{ // reffering to toDoTableViewController
            let destination = segue.destination as! toDoTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoIteam = someData[selectedIndexPath.row]
        } else{ // Since we only have the other segue, so we won't check
            if let selectedIndexPath723 = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selectedIndexPath723, animated: true)
            }
        }
    }
    
    // Coming Back to this segue // Unwind
    @IBAction func myUnwindingFromDetail(segue: UIStoryboardSegue){
        let source = segue.source as! toDoTableViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow{
            // .row is same as index of array data
            someData[selectedIndexPath.row] = source.toDoIteam
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else{
            let newIndexPath = IndexPath(row: someData.count, section: 0)
            someData.append(source.toDoIteam)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
        saveData()
    }
    
    // Deleating Cells
    @IBAction func editPress(_ sender: UIBarButtonItem) {
        if tableView.isEditing == true{
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addButton.isEnabled = true
        }
        else{
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addButton.isEnabled = false
        }
    }
    // This function wroks for both insersion and deletion. We used for DELETE only
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            someData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            saveData()
        }
    }
    // This built-in function moves view cell from one place to another
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let iteamToMove = someData[sourceIndexPath.row]
        someData.remove(at: sourceIndexPath.row)
        someData.insert(iteamToMove, at: destinationIndexPath.row)
        saveData()
    }
    
    
}

extension toDoViewController: UITableViewDelegate, UITableViewDataSource, ListTableViewCellDelegate{
    func checkBoxToggle(sender: listTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender){
            someData[selectedIndexPath.row].completed = !someData[selectedIndexPath.row].completed
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            saveData()
        }
    }
    
    // numberOfRowsInSection is our count of array data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return someData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! listTableViewCell
        myCell.delegate = self
        myCell.nameLabel.text = someData[indexPath.row].name
        myCell.ckeckBoxButton.isSelected = someData[indexPath.row].completed
        return myCell
    }
    
}

