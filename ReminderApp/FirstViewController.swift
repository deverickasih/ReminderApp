//
//  FirstViewController.swift
//  ReminderApp
//
//  Created by JAN FREDRICK on 06/03/21.
//  Copyright © 2021 JFSK. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import JGProgressHUD

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let hud = JGProgressHUD(style: .dark)
    let defaults = UserDefaults.standard
    
    var tableView : UITableView!
    var tableViewArray : [NSManagedObject] = []
    var filteredArray : [NSManagedObject] = []
    
    var topPadding : CGFloat = 0
    var bottomPadding : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.topItem?.title = "Reminders"
        
        let window = UIApplication.shared.windows[0]
        topPadding = window.safeAreaInsets.top
        bottomPadding = window.safeAreaInsets.bottom
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Reminders here.."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        /*let searchTF = UITextField(frame: CGRect(x: 0, y: topPadding, width: screenWidth, height: 40))
        view.addSubview(searchTF)
        
        searchTF.delegate = self
        searchTF.textAlignment = .center
        searchTF.placeholder = "Search Here.."*/
        
        tableView = UITableView(frame: CGRect(x: 0, y: topPadding, width: screenWidth, height: screenHeight - topPadding - bottomPadding))
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .black
        tableView.separatorStyle = .singleLine
        
        let addNewB = UIButton(frame: CGRect(x: screenWidth - 90, y: screenHeight - bottomPadding - 90, width: 70, height: 70))
        view.addSubview(addNewB)
        
        addNewB.backgroundColor = .systemBlue
        addNewB.setTitle("baru", for: .normal)
        addNewB.layer.cornerRadius = 35.0
        addNewB.layer.masksToBounds = true
        
        addNewB.addTarget(self, action: #selector(toNextView), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func toNextView() {
        print("came here")
        let nvc = SecondViewController(nibName: nil, bundle: nil)
        nvc.topPadding = topPadding
        nvc.bottomPadding = bottomPadding
        self.navigationController?.pushViewController(nvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let objectData = filteredArray[indexPath.row]
        
        let alertVC = UIAlertController(title: objectData.value(forKey: "title") as? String, message: objectData.value(forKey: "desc") as? String, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Noted.", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: false, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let objectData = filteredArray[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "WIT")
        dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
        
        let dateObject = objectData.value(forKey: "dateTime") as! Date
        
        let dateString = dateFormatter.string(from: dateObject)
        
        let correctedDate = dateFormatter.date(from: dateString)!
        
        print("Index <--\(indexPath.row)-->")
        
        print(dateString)
        
        if UpdateDate(date: Date()) > correctedDate {
            cell.backgroundColor = .systemRed
        }else{
            cell.backgroundColor = .systemGreen
        }
        
        let getDescription = objectData.value(forKey: "desc")!
        
        cell.textLabel!.text = "\(dateString) : \(getDescription)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.checkData()
        
    }
    
    func checkData() {
        
        //check if first time load
        if defaults.object(forKey: "firstCame") == nil {
            // database is empty --> call api to get data to fill database
            
            hud.textLabel.text = "fetching"
            hud.show(in: self.view, animated: true)
            
            AF.request("http://www.mocky.io/v2/5e7988f52d00005cbf18bd7b").responseJSON { (response) in
                
                self.hud.dismiss(afterDelay: 1.0)
                
                if response.error != nil {
                    print("unable to get data, reason = \(String(describing: response.error?.localizedDescription))")
                    return
                }
                
                let dataJSON = JSON(response.data!)
                
                print(dataJSON)
                
                self.addEntriesFromAPICall(with: dataJSON["todos"].arrayValue as NSArray)
                
            }
            
        }else{
            
            self.reloadDB()
            
        }
        
    }
    
    func reloadDB() {
        // retrieve data from database
        tableViewArray = loadEntriesFromDatabase()
        
        filteredArray = tableViewArray
        
        print("number of entries returned = \(filteredArray.count)")
        
        self.tableView.reloadData()
    }
    
    func loadEntriesFromDatabase() -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        
        let sort = NSSortDescriptor(key: #keyPath(Entry.dateTime), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            return result as! [NSManagedObject]
        } catch let error as NSError {
            hud.textLabel.text = error.localizedDescription
            hud.show(in: self.view, animated: true)
            hud.dismiss(afterDelay: 3.0, animated: true)
            return []
        }
    }
    
    func addEntriesFromAPICall(with array: NSArray) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "Entry", in: managedContext)!
        
        for i in 0..<array.count {
            
            print("--> \(array[i])")
            
            let dict = JSON(array[i])
            
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(dict["title"].stringValue, forKey: "title") // for title
            user.setValue(dict["description"].stringValue, forKey: "desc") // for description
            user.setValue(dict["dateTime"].stringValue.format(), forKey: "dateTime") // for date in date & time format
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            hud.textLabel.text = error.localizedDescription
            hud.show(in: self.view, animated: true)
            hud.dismiss(afterDelay: 3.0, animated: true)
            return
        }
        
        defaults.setValue("done", forKey: "firstCame")
        
        self.reloadDB()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// Update date to WIT timezone
    func UpdateDate(date: Date) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "WIT")
        dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
        
        let dateString = dateFormatter.string(from: date)
        
        print("Update Date dateString = \(dateString)")
        
        let correctedDate = dateFormatter.date(from: dateString)!
        
        return correctedDate
    }
}

extension String {
    
    func format() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.init(abbreviation: "WIT")
        
        print(self)
        
        let newDate = dateFormatter.date(from: self)!
        
        print("saved as -> \(dateFormatter.string(from: newDate))")
        
        return newDate
    }
    
}

extension FirstViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        
        if searchBar.text! != "" {
            filterContentForSearchText(searchBar.text!)
        }else{
            filteredArray = tableViewArray
        }
        
        tableView.reloadData()
    
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
        filteredArray = tableViewArray.filter({ (object: NSManagedObject) -> Bool in
            
            return (object.value(forKey: "desc") as! String).lowercased().contains(searchText.lowercased()) || (object.value(forKey: "title") as! String).lowercased().contains(searchText.lowercased())
            
        })
        
    }
}
