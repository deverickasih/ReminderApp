//
//  SecondViewController.swift
//  ReminderApp
//
//  Created by JAN FREDRICK on 06/03/21.
//  Copyright © 2021 JFSK. All rights reserved.
//

import UIKit
import CoreData
import JGProgressHUD

class SecondViewController : UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var titleTF, dateTimeTF : UITextField!
    var descTV : UITextView!
    
    let hud = JGProgressHUD(style: .dark)
    
    var topPadding : CGFloat = 0
    var bottomPadding : CGFloat = 0
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        self.title = "Add New Reminder"
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let objectWidth = screenWidth - 40
        
        print(navBarHeight)
        print(bottomPadding)
        
        titleTF = UITextField(frame: CGRect(x: 20, y: navBarHeight + topPadding + 20, width: objectWidth, height: 40))
        view.addSubview(titleTF)
        
        titleTF.delegate = self
        titleTF.textAlignment = .center
        titleTF.placeholder = "Set Title Here.."
        titleTF.setBorderColor(color: .systemGray)
        
        descTV = UITextView(frame: CGRect(x: 20, y: titleTF.frame.origin.y + 50, width: objectWidth, height: 90))
        view.addSubview(descTV)
        
        descTV.delegate = self
        descTV.text = "Set Description Here.."
        descTV.textColor = UIColor.lightGray
        descTV.setBorderColor(color: .systemGray)
        
        dateTimeTF = UITextField(frame: CGRect(x: 20, y: descTV.frame.origin.y + 100, width: objectWidth, height: 40))
        view.addSubview(dateTimeTF)
        
        dateTimeTF.delegate = self
        dateTimeTF.textAlignment = .center
        dateTimeTF.placeholder = "Tap to set date & time"
        dateTimeTF.setBorderColor(color: .systemGray)
        
        let submitB = UIButton(frame: CGRect(x: 20, y: screenHeight - bottomPadding - 70, width: objectWidth, height: 50))
        view.addSubview(submitB)
        
        submitB.backgroundColor = .systemOrange
        submitB.setTitle("Submit", for: .normal)
        submitB.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        submitB.addTarget(self, action: #selector(submitRecord), for: .touchUpInside)
        
    }
    
    @objc func submitRecord() {
        
        var errorMsg = ""
        
        if titleTF.text == "" {
            errorMsg += "\nTitle"
        }
        if descTV.textColor == UIColor.lightGray {
            errorMsg += "\nDescription"
        }
        if dateTimeTF.text == "" {
            errorMsg += "\nDate & Time"
        }
        
        if errorMsg == "" {
            //call store data function
        }else{
            // show popup
            let alertVC = UIAlertController(title: "Missing Field(s)", message: "Kindly fill in the following :" + errorMsg, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Understood", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func addNewEntry() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "Entry", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue("", forKey: "title") // for title
        user.setValue("", forKey: "desc") // for description
        user.setValue("", forKey: "dateTime") // for date in date & time format
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            hud.textLabel.text = error.localizedDescription
            hud.dismiss(afterDelay: 3.0, animated: true)
        }
        
    }
    
    func setBorderColor(view: UIView, color: UIColor){
        view.layer.borderWidth = 0.5
        view.layer.borderColor = color.cgColor
        view.layer.cornerRadius = 5.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
    
}

extension UIView {
    func setBorderColor(color: UIColor){
        self.layer.borderWidth = 1.5
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = 5.0
    }
}

extension UIViewController {

    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */

    var navBarHeight: CGFloat {
        return (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
