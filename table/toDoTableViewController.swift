//
//  toDoTableViewController.swift
//  table
//
//  Created by Risul Rashed
//

import UIKit

private let dateMaking: DateFormatter = {
    print("Date is created only once, because it's resource intensive")
    let setDate = DateFormatter()
    setDate.dateStyle = .short
    setDate.timeStyle = .short
    return setDate
}()

class toDoTableViewController: UITableViewController {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var toDoName: UITextField!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var notTextLabel: UITextView!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    
    var toDoIteam: ToDoItem!

   // var hold: IndexPath = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nil value will caouse problem
        if toDoIteam == nil{
            toDoIteam = ToDoItem(name: "", date: Date().addingTimeInterval(24*60*60), note: "", reminder: false, completed: false)
        }
        updateInterface()
    }
    @IBAction func datePickerPressed(_ sender: UIDatePicker) {
        dateLabel.text = dateMaking.string(from: sender.date)
    }
    
    
    // Update interface
    func updateInterface(){
        toDoName.text = toDoIteam.name
        dateTimePicker.date = toDoIteam.date
        notTextLabel.text = toDoIteam.note
        reminderSwitch.isOn = toDoIteam.reminder
        // If or ternary operator
        //dateLabel.textColor = (reminderSwitch.isOn ? .black : .gray)
        if reminderSwitch.isOn{
            dateLabel.textColor = UIColor.black
        }
        else{
            dateLabel.textColor = UIColor.gray
        }
        dateLabel.text = dateMaking.string(from: toDoIteam.date)
    }
    
    // Preparing tbale view for next segua -> toDoViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        toDoIteam = ToDoItem(name: toDoName.text!, date: dateTimePicker.date, note: notTextLabel.text, reminder: reminderSwitch.isOn, completed: toDoIteam.completed) // .isOn sends if it's true or false
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        let currentViewAddModal = presentingViewController is UINavigationController
        if currentViewAddModal{
            dismiss(animated: true)
        }
        else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        dateLabel.textColor = (reminderSwitch.isOn ? .black : .gray)
        // We need to call to change the view for height change
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
extension toDoTableViewController{
    // Built-in function to change Height of table view row **Using for switch toggle
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath{
        case IndexPath(row: 1, section: 1): // Creating IndexPath to compare with indexPath(lowercase)
            return reminderSwitch.isOn ? dateTimePicker.frame.height : 0
        case IndexPath(row: 0, section: 2):
            return 200
        default:
            return 44
        }
    }
}
