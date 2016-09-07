//
//  ViewController.swift
//  BFN
//
//  Created by Lai, Allen on 7/14/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import Contacts
import CoreData

class SortByUpcomingVC: UIViewController {

    // DataSource
    private var allFriends = [Friend]()
    private var friendsSortedByUpcomingMonths = [FriendsByMonth]()
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entries: [NSManagedObject]!
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var birthdayTableView: UITableView!
    @IBOutlet weak var footerLabel: UILabel!
    
    @IBOutlet weak var importContactsBigButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        
        if self.revealViewController() != nil {
            settingsBarButton.target = self.revealViewController()
            settingsBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        importContactsBigButton.hidden = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 25/255, green: 181/255, blue: 255/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Avenir-Book", size: 18)!]


    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        allFriends.removeAll()
        friendsSortedByUpcomingMonths.removeAll()
        
        fetchFriends()
        sortFriendsByUpcoming()
        

        birthdayTableView.reloadData()
        if allFriends.count == 0 {
            footerLabel.hidden = true
            self.birthdayTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.importContactsBigButton.hidden = false
        } else {
            footerLabel.hidden = false
            let currentDate = NSDate()
            let currentMonth = currentDate.month()
            let monthsArrayString = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
            let currMonthString: String = monthsArrayString[currentMonth]
            
            
            if friendsSortedByUpcomingMonths[0].month != currMonthString {
                footerLabel.text = "No birthdays this month 😢"
            } else {
                let numberOfBirthdays = friendsSortedByUpcomingMonths[0].friends.count
                if numberOfBirthdays == 0 {
                    footerLabel.text = "No birthdays this month 😢"
                } else if numberOfBirthdays == 1 {
                    footerLabel.text = "Only 1 birthday this month 😐"
                } else if numberOfBirthdays > 1 && numberOfBirthdays < 5 {
                    footerLabel.text = String(numberOfBirthdays) + " birthdays this month 🎉"
                } else if numberOfBirthdays > 5 && numberOfBirthdays < 20 {
                    footerLabel.text = String(numberOfBirthdays) + " birthdays this month 🎉🎉🎉"
                } else {
                    footerLabel.text = String(numberOfBirthdays) + " birthdays this month 🎉🎉🎉🎉🎉🎉🎉🎉🎉"
                }
            }
            self.birthdayTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.importContactsBigButton.hidden = true
        }

    }
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "🔜"
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
    
    func sortFriendsByUpcoming() {
        
        // copied from sortFriendsByMonth but no removing months
        let monthsArrayString = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        for month in monthsArrayString {
            friendsSortedByUpcomingMonths.append(FriendsByMonth(month: month, friends: [Friend]()))
        }
        for friend in allFriends {
            let monthNum: Int = (friend.birthdate?.month!)!
            let monthIndex = monthNum - 1
            friendsSortedByUpcomingMonths[monthIndex].friends.append(friend)
        }
        for monthFriends in friendsSortedByUpcomingMonths {
            monthFriends.friends.sortInPlace({ $0.birthdate?.day < $1.birthdate?.day })
        }
        
        let currentDate = NSDate()
        let currentMonth = currentDate.month()
        let year = currentDate.year()
        
        // calculate all your friends daysUntil
        for friendGroup in friendsSortedByUpcomingMonths {
            for friend in friendGroup.friends {
                let birthdate = NSDateComponents()
                birthdate.month = (friend.birthdate?.month!)!
                birthdate.day = (friend.birthdate?.day!)!
                if birthdate.month >= currentMonth {    // if birth month is coming up than use current year
                    birthdate.year = year
                } else {
                    birthdate.year = year + 1
                }
                let date: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(birthdate))!
                
                // calculates the difference in days and stores in friend daysUntil field
                friend.daysUntil = currentDate.differenceInDaysWithDate(date)
            }
        }

        
        // fill in the year field for FriendsByMonth
        for i in currentMonth-1 ..< 12 {
            friendsSortedByUpcomingMonths[i].year = year
        }
        let nextYear = year + 1
        for i in 0 ..< currentMonth-1 {
            friendsSortedByUpcomingMonths[i].year = nextYear
        }
        
        // shift the array so current month is first element
        friendsSortedByUpcomingMonths = friendsSortedByUpcomingMonths.rotate(currentMonth-1)
        // delete months that are empty
        friendsSortedByUpcomingMonths = friendsSortedByUpcomingMonths.filter({$0.friends.count > 0})
        
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "Show Countdown" {
            let countDownVC = segue.destinationViewController as! CountDownVC
            countDownVC.friend = sender as? Friend
        } 

        
        
    }
}


extension SortByUpcomingVC: UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let groupedFriends = friendsSortedByUpcomingMonths[section]
        return groupedFriends.month + " " + String(groupedFriends.year!)
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return friendsSortedByUpcomingMonths.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groupedFriends = friendsSortedByUpcomingMonths[section]
        return groupedFriends.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("upcoming cell", forIndexPath: indexPath) as! UpcomingTableViewCell
        let groupedFriends = friendsSortedByUpcomingMonths[indexPath.section]
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
            let friend = self.friendsSortedByUpcomingMonths[indexPath.section].friends[indexPath.row]
            
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
                    self.friendsSortedByUpcomingMonths[indexPath.section].friends.removeAtIndex(indexPath.row)
                    
                    
                    self.birthdayTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    do {
                        try self.managedObjectContext.save()
                    } catch let error as NSError {
                        print("Cannot delete object: \(error), \(error.localizedDescription)")
                    }
                    
                }
                counter += 1
            }
            
            var fullName: String = friend.firstName
            if let lastName = friend.lastName {
                fullName = fullName + " " + lastName
            }
            
            // cancel notification
            let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
            guard scheduledNotifications != nil else {return} // Nothing to remove, so return

            for notification in scheduledNotifications! { // loop through notifications...
                
//                print("getting canceled")
//                if let notiName = notification.userInfo!["full name"] {
//                    if notiName as! String == fullName {
//                        print("canceled")
//                        UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
//                        break
//                    }
//                }

            }
            
            
            
            
            
        }
    }

}

extension SortByUpcomingVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let friend = self.friendsSortedByUpcomingMonths[indexPath.section].friends[indexPath.row]
        self.performSegueWithIdentifier("Show Countdown", sender: friend)
        
    }
    

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView   //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 25.0/255.0, green: 181.0/255.0, blue: 255.0/255.0, alpha:1.0)
        header.textLabel!.textColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0)     //make the text dark blue
        header.textLabel!.font = UIFont(name: "Avenir-Book", size: 12)

    }

}













