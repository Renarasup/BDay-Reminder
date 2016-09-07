//
//  SortByMonthVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/20/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import CoreData

class SortByMonthVC: UIViewController {

    
    private var allFriends = [Friend]()
    private var friendsSortedByMonths = [FriendsByMonth]()
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entries: [NSManagedObject]!
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var birthdayTableView: UITableView!
    
    @IBOutlet weak var importContactsBigButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        importContactsBigButton.hidden = true

        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 25/255, green: 181/255, blue: 255/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Avenir-Book", size: 18)!]
        
        // Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
    
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        allFriends.removeAll()
        friendsSortedByMonths.removeAll()
        
        fetchFriends()
        sortFriendsByMonth()
        birthdayTableView.reloadData()
        if allFriends.count == 0 {
            self.birthdayTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.importContactsBigButton.hidden = false
        } else {
            self.birthdayTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.importContactsBigButton.hidden = true
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "📅"
    }
    func fetchFriends() {
        let fetchRequest = NSFetchRequest(entityName: "Friend")
        do {
            let entryObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            self.entries = entryObjects as! [NSManagedObject]
            
            // parse NSManagedObject to Scene Objects
            for entry in self.entries {
                let firstName = entry.valueForKey("firstName") as! String
                let lastName = entry.valueForKey("lastName") as! String
                
                let month = entry.valueForKey("month") as! Int
                let day = entry.valueForKey("day") as! Int
                let birthday = Date(month: month, day: day)
                if let year = entry.valueForKey("year") {
                    birthday.year = year as? Int
                }
                let friend = Friend(firstName: firstName, lastName: lastName, birthdate: birthday)
                if let profilePicture = entry.valueForKey("profilePicture") {
                    friend.profilePicture = profilePicture as? UIImage
                }
                
                self.allFriends.insert(friend, atIndex: 0)
                
            }
            
        } catch let error as NSError {
            print("could not fetch entries \(error), \(error.userInfo)")
        }
    }
    func sortFriendsByMonth() {
        let monthsArrayString = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        for month in monthsArrayString {
            friendsSortedByMonths.append(FriendsByMonth(month: month, friends: [Friend]()))
        }
        for friend in allFriends {
            let monthNum: Int = (friend.birthdate?.month!)!
            let monthIndex = monthNum - 1
            friendsSortedByMonths[monthIndex].friends.append(friend)
        }
        // remove sections that dont have any friends
        friendsSortedByMonths = friendsSortedByMonths.filter({$0.friends.count > 0})
        
        // sort the friends within the month
        for monthFriends in friendsSortedByMonths {
            monthFriends.friends.sortInPlace({ $0.birthdate?.day < $1.birthdate?.day })
        }
    }
    
}


extension SortByMonthVC: UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let groupedFriends = friendsSortedByMonths[section]
        return groupedFriends.month

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return friendsSortedByMonths.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groupedFriends = friendsSortedByMonths[section]
        return groupedFriends.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("month cell", forIndexPath: indexPath) as! MonthTableViewCell
        let groupedFriends = friendsSortedByMonths[indexPath.section]
        let friendForCell = groupedFriends.friends[indexPath.row]
        cell.friend = friendForCell
        return cell

    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete {
            let friend = self.friendsSortedByMonths[indexPath.section].friends[indexPath.row]
            
            var counter = 0
            // find the entry that needs to be deleted
            for entry in self.entries {
                let firstName = entry.valueForKey("firstName") as! String
                let lastName = entry.valueForKey("lastName") as! String
                let month = entry.valueForKey("month") as! Int
                let day = entry.valueForKey("day") as! Int
                
                if firstName == friend.firstName && lastName == friend.lastName && month == friend.birthdate?.month && day == friend.birthdate?.day {
                    // delete if from all the datasources
                    self.managedObjectContext.deleteObject(entry)
                    self.entries.removeAtIndex(counter)
                    self.friendsSortedByMonths[indexPath.section].friends.removeAtIndex(indexPath.row)
                    
                    self.birthdayTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch let error as NSError {
                        print("Cannot delete object: \(error), \(error.localizedDescription)")
                    }
                    
                }
                counter += 1
            }
        }
    }
    
}

extension SortByMonthVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView   //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 25.0/255.0, green: 181.0/255.0, blue: 255.0/255.0, alpha:1.0)
        header.textLabel!.textColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0)     //make the text dark blue
        header.textLabel!.font = UIFont(name: "Avenir-Book", size: 12)

    }
    
}









