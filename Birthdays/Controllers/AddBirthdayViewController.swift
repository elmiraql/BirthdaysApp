//
//  AddBirthdayViewController.swift
//  Birthdays
//
//  Created by Elmira on 07.03.21.
//

import UIKit
import CoreData
import UserNotifications

protocol RefreshData {
    func refreshArray(_ element: Birthday)
}


class AddBirthdayViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: RefreshData?
    
    var birthdaysViewController = BirthdaysViewController()

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
        saveButton.layer.cornerRadius = 40
        saveButton.layer.borderWidth = 3
        saveButton.layer.borderColor = UIColor(named: "PinkColor")!.cgColor
    }
   
    
    func saveItems(){
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
   
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let birthDate = datePicker.date as Date? {
            
            let newBirthday = Birthday(context: context)
            newBirthday.firstName = firstName
            newBirthday.lastName = lastName
            newBirthday.date = birthDate
            newBirthday.birthdayId = UUID().uuidString
            saveItems()
            delegate?.refreshArray(newBirthday)
            saveItems()
            do {
            let message = "It is \(firstName) \(lastName) birthday today!"
            let content = UNMutableNotificationContent()
            content.body = message
            content.sound = UNNotificationSound.default
            var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthDate)
            dateComponents.hour = 18
            dateComponents.minute = 37
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            if let identifier = newBirthday.birthdayId {
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
                }
            } catch {
                print(error)
            }
         }
            dismiss(animated: true, completion: nil)
        
    }
   
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
