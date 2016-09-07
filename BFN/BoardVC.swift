//
//  ViewController.swift
//  BFN
//
//  Created by Lai, Allen on 7/14/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import CoreData

class BoardVC: UIViewController {

    @IBOutlet weak var monthsScrollView: UIScrollView!
    // DataSource
    private var allFriends = [Friend]()
    private var friendsSortedByMonths = [FriendsByMonth]()
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entries: [NSManagedObject]!
    
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!

    @IBOutlet weak var t1: UITableView!
    @IBOutlet weak var t2: UITableView!
    @IBOutlet weak var t3: UITableView!
    @IBOutlet weak var t4: UITableView!
    @IBOutlet weak var t5: UITableView!
    @IBOutlet weak var t6: UITableView!
    @IBOutlet weak var t7: UITableView!
    @IBOutlet weak var t8: UITableView!
    @IBOutlet weak var t9: UITableView!
    @IBOutlet weak var t10: UITableView!
    @IBOutlet weak var t11: UITableView!
    @IBOutlet weak var t12: UITableView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            settingsBarButton.target = self.revealViewController()
            settingsBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
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
        sortFriendsByMonthForBoard()
        t1.reloadData()
        t2.reloadData()
        t3.reloadData()
        t4.reloadData()
        t5.reloadData()
        t6.reloadData()
        t7.reloadData()
        t8.reloadData()
        t9.reloadData()
        t10.reloadData()
        t11.reloadData()
        t12.reloadData()
        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "📜"
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
                // add shape for boards
                if let shape = entry.valueForKey("shape") {
                    friend.shape = shape as? Int
                }
                
                self.allFriends.insert(friend, atIndex: 0)
                
            }
            
        } catch let error as NSError {
            print("could not fetch entries \(error), \(error.userInfo)")
        }
    }
    func sortFriendsByMonthForBoard() {
        let monthsArrayString = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        for month in monthsArrayString {
            friendsSortedByMonths.append(FriendsByMonth(month: month, friends: [Friend]()))
        }
        for friend in allFriends {
            let monthNum: Int = (friend.birthdate?.month!)!
            let monthIndex = monthNum - 1
            friendsSortedByMonths[monthIndex].friends.append(friend)
        }
        
        
        // sort the friends within the month
        for monthFriends in friendsSortedByMonths {
            monthFriends.friends.sortInPlace({ $0.birthdate?.day < $1.birthdate?.day })
        }

        
    }

}



extension BoardVC: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if allFriends.count == 0 {
            return 0
        }
        switch tableView {
        case t1:
            return friendsSortedByMonths[0].friends.count
        case t2:
            return friendsSortedByMonths[1].friends.count
        case t3:
            return friendsSortedByMonths[2].friends.count
        case t4:
            return friendsSortedByMonths[3].friends.count
        case t5:
            return friendsSortedByMonths[4].friends.count
        case t6:
            return friendsSortedByMonths[5].friends.count
        case t7:
            return friendsSortedByMonths[6].friends.count
        case t8:
            return friendsSortedByMonths[7].friends.count
        case t9:
            return friendsSortedByMonths[8].friends.count
        case t10:
            return friendsSortedByMonths[9].friends.count
        case t11:
            return friendsSortedByMonths[10].friends.count
        case t12:
            return friendsSortedByMonths[11].friends.count
        default: return 0
            
        }
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = t1.dequeueReusableCellWithIdentifier("board cell") as! BoardTableViewCell
        
        switch tableView {
        case t1:
            cell.friend = friendsSortedByMonths[0].friends[indexPath.row]
            return cell
        case t2:
            cell.friend = friendsSortedByMonths[1].friends[indexPath.row]
            return cell
        case t3:
            cell.friend = friendsSortedByMonths[2].friends[indexPath.row]
            return cell
        case t4:
            cell.friend = friendsSortedByMonths[3].friends[indexPath.row]
            return cell
        case t5:
            cell.friend = friendsSortedByMonths[4].friends[indexPath.row]
            return cell
        case t6:
            cell.friend = friendsSortedByMonths[5].friends[indexPath.row]
            return cell
        case t7:
            cell.friend = friendsSortedByMonths[6].friends[indexPath.row]
            return cell
        case t8:
            cell.friend = friendsSortedByMonths[7].friends[indexPath.row]
            return cell
        case t9:
            cell.friend = friendsSortedByMonths[8].friends[indexPath.row]
            return cell
        case t10:
            cell.friend = friendsSortedByMonths[9].friends[indexPath.row]
            return cell
        case t11:
            cell.friend = friendsSortedByMonths[10].friends[indexPath.row]
            return cell
        case t12:
            cell.friend = friendsSortedByMonths[11].friends[indexPath.row]
            return cell
        default: return cell
        }
        
    }
}



extension BoardVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var friend: Friend!
        switch tableView {
        case t1:
            friend = friendsSortedByMonths[0].friends[indexPath.row]
        case t2:
            friend = friendsSortedByMonths[1].friends[indexPath.row]
        case t3:
            friend = friendsSortedByMonths[2].friends[indexPath.row]
        case t4:
            friend = friendsSortedByMonths[3].friends[indexPath.row]
        case t5:
            friend = friendsSortedByMonths[4].friends[indexPath.row]
        case t6:
            friend = friendsSortedByMonths[5].friends[indexPath.row]
        case t7:
            friend = friendsSortedByMonths[6].friends[indexPath.row]
        case t8:
            friend = friendsSortedByMonths[7].friends[indexPath.row]
        case t9:
            friend = friendsSortedByMonths[8].friends[indexPath.row]
        case t10:
            friend = friendsSortedByMonths[9].friends[indexPath.row]
        case t11:
            friend = friendsSortedByMonths[10].friends[indexPath.row]
        case t12:
            friend = friendsSortedByMonths[11].friends[indexPath.row]
        default:
            friend = Friend()
        }
        
        // update the shape
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BoardTableViewCell {
            // workaround
            if cell.friend.shape == 0 {
               cell.friend.shape = 1
            }
            
            
            cell.friend.shape = cell.friend.shape! + 1
            
            if cell.friend.shape! == 5 {
                cell.friend.shape! = 1
            }
            switch cell.friend.shape! {
            case 1:
                cell.img.image = UIImage(named: "Circle Board")
            case 2:
                cell.img.image = UIImage(named: "Heart Board")
            case 3:
                cell.img.image = UIImage(named: "Square Board")
            case 4:
                cell.img.image = UIImage(named: "Triangle Board")
            default:
                cell.img.image = UIImage(named: "Heart Board")
            }
            
        }
        
        // find the entry that needs to be updated
        var counter = 0
        for entry in self.entries {
            let firstName = entry.valueForKey("firstName") as! String
            let lastName = entry.valueForKey("lastName") as! String
            let month = entry.valueForKey("month") as! Int
            let day = entry.valueForKey("day") as! Int
            
            if firstName == friend.firstName && lastName == friend.lastName && month == friend.birthdate?.month && day == friend.birthdate?.day {
                // save the updated entry
                entry.setValue(friend.firstName, forKey: "firstName")
                entry.setValue(friend.lastName, forKey: "lastName")
                entry.setValue(friend.birthdate?.day, forKey: "day")
                entry.setValue(friend.birthdate?.month, forKey: "month")
                entry.setValue(friend.birthdate?.year, forKey: "year")
                entry.setValue(friend.profilePicture, forKey: "profilePicture")
                entry.setValue(friend.notes, forKey: "notes")
                entry.setValue(friend.shape, forKey: "shape")
                
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    print("could not save \(error)")
                }
            }
            counter += 1
        }
        
        
    }
    
}









