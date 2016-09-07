//
//  AlphabeticalVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/20/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import CoreData

class AlphabeticalVC: UIViewController {

    // DataSource
    private var allFriends = [Friend]()
    private var friendsAlphabetized = [FriendsByAlphabet]()     // for displaying alphabetically
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entries: [NSManagedObject]!
    
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var birthdayTableView: UITableView!
    
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var importContactsBigButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Avenir-Book", size: 18)!]
        
        // Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        allFriends.removeAll()
        friendsAlphabetized.removeAll()
        fetchFriends()
        alphabetizeFriends()
        
        birthdayTableView.reloadData()
        if allFriends.count == 0 {
            self.birthdayTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            self.importContactsBigButton.hidden = false
            
            footerLabel.hidden = true
        } else {
            self.birthdayTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.importContactsBigButton.hidden = true
            
            footerLabel.hidden = false
            footerLabel.text = String(allFriends.count) + " Contacts"
            let numOfContacts = allFriends.count
            if numOfContacts == 0 {
                footerLabel.text = ""
            } else if numOfContacts == 1 {
                footerLabel.text = "Only 1 contact 😐"
            } else if numOfContacts > 1 && numOfContacts < 30 {
                footerLabel.text = String(numOfContacts) + " contacts 😏"
            } else {
                footerLabel.text = String(numOfContacts) + " contacts 😏😏😏"
            }
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "🔤"
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
                friend.notes = entry.valueForKey("notes") as? String

                self.allFriends.insert(friend, atIndex: 0)
                
            }
            
        } catch let error as NSError {
            print("could not fetch entries \(error), \(error.userInfo)")
        }
    }

    func alphabetizeFriends() {
        allFriends = allFriends.sort { $0.firstName < $1.firstName }
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters {
            friendsAlphabetized.append(FriendsByAlphabet(letter: String(char), friends: [Friend]()))
        }
        friendsAlphabetized.append(FriendsByAlphabet(letter: "#", friends: [Friend]()))
        
        for friend in allFriends {
            // a = 97
            let firstLetterValue = friend.firstName.lowercaseString.unicodeScalars.first?.value
            let indexOfArray: Int = Int(firstLetterValue! - 97)
            
            if indexOfArray < 26 && indexOfArray >= 0{
                friendsAlphabetized[indexOfArray].friends.append(friend)
            } else {
                friendsAlphabetized[26].friends.append(friend)
            }
        }
        
        // remove sections that dont have any friends
        friendsAlphabetized = friendsAlphabetized.filter({$0.friends.count > 0})
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "Edit Contact" {
            let editContactVC = segue.destinationViewController as! EditContactVC
            editContactVC.entry = sender as? NSManagedObject
        }
        
    }
    
    

}

extension AlphabeticalVC: UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let groupedFriends = friendsAlphabetized[section]
        return groupedFriends.letter
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return friendsAlphabetized.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groupedFriends = friendsAlphabetized[section]
        return groupedFriends.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("alphebetical cell", forIndexPath: indexPath) as! AlphebeticalTableViewCell
            let groupedFriends = friendsAlphabetized[indexPath.section]
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
            let friend = self.friendsAlphabetized[indexPath.section].friends[indexPath.row]
            
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
                    self.friendsAlphabetized[indexPath.section].friends.removeAtIndex(indexPath.row)
                    
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

extension AlphabeticalVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let friend = self.friendsAlphabetized[indexPath.section].friends[indexPath.row]
        
        
        // find the entry that needs to be passed and updated
        var counter = 0
        for entry in self.entries {
            let firstName = entry.valueForKey("firstName") as! String
            let lastName = entry.valueForKey("lastName") as! String
            let month = entry.valueForKey("month") as! Int
            let day = entry.valueForKey("day") as! Int
            
            if firstName == friend.firstName && lastName == friend.lastName && month == friend.birthdate?.month && day == friend.birthdate?.day {

                self.performSegueWithIdentifier("Edit Contact", sender: entry)

            }
            counter += 1
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView   //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 25.0/255.0, green: 181.0/255.0, blue: 255.0/255.0, alpha:1.0)
        header.textLabel!.textColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0)     //make the text dark blue
        header.textLabel!.font = UIFont(name: "Avenir-Book", size: 12)
    }
    
}









