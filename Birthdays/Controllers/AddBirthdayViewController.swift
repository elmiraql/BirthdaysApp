//
//  AddBirthdayViewController.swift
//  Birthdays
//
//  Created by Elmira on 07.03.21.
//

import UIKit
import CoreData
import UserNotifications


class AddBirthdayViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    public var completion: ((String, String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
        saveButton.layer.cornerRadius = 40
        saveButton.layer.borderWidth = 3
        saveButton.layer.borderColor = UIColor(named: "GreenBlue")!.cgColor
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let birthDate = datePicker.date as Date? {
            completion?(firstName, lastName, birthDate)
        }        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
}
