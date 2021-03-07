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

class SecondViewController : UIViewController {
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
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
    
}
