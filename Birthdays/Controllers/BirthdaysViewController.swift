//
//  ViewController.swift
//  Birthdays
//
//  Created by Elmira on 07.03.21.
//

import UIKit
import CoreData
import UserNotifications

class BirthdaysViewController: UIViewController {
    
    var birthdays: [Birthday] = []
    let dateFormatter = DateFormatter()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        table.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest = Birthday.fetchRequest() as NSFetchRequest<Birthday>
        let sortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do{
            birthdays = try context.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        table.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "new") as? AddBirthdayViewController else {
            return
        }
        
        vc.completion = { firstName, lastName, date in
            self.navigationController?.popToRootViewController(animated: true)
            let newBirthday = Birthday(context: self.context)
            newBirthday.firstName = firstName
            newBirthday.lastName = lastName
            newBirthday.date = date
            newBirthday.birthdayId = UUID().uuidString
            self.birthdays.append(newBirthday)
            self.saveItems()
            
            let message = "It is \(firstName) \(lastName) birthday today!"
            let content = UNMutableNotificationContent()
            content.body = message
            content.sound = UNNotificationSound.default
            var dateComponents = Calendar.current.dateComponents([.month, .day], from: date)
            dateComponents.hour = 20
            dateComponents.minute = 50
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            if let identifier = newBirthday.birthdayId {
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
                }
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadItems(){
        let request: NSFetchRequest<Birthday> = Birthday.fetchRequest()
        do {
            birthdays = try context.fetch(request)
        } catch {
            print(error)
        }
        self.table.reloadData()
    }
    
    func saveItems(){
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}

extension BirthdaysViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birthdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let birthday = birthdays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseCell", for: indexPath)
        if let firstName = birthday.firstName, let lastName = birthday.lastName{
            cell.textLabel?.text = firstName + " " + lastName
        }
        if let date = birthday.date as Date?{
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
}

extension BirthdaysViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if birthdays.count > indexPath.row {
            let birthday = birthdays[indexPath.row]
            if let identifier = birthday.birthdayId {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [identifier])
            }
            context.delete(birthday)
            birthdays.remove(at: indexPath.row)
            saveItems()
            table.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

