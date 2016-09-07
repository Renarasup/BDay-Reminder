//
//  ImportContactsVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/19/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import Contacts
import CoreData

class ImportContactsVC: UIViewController {

    @IBOutlet weak var contactsTableView: UITableView!
    

    var contacts = [CNContact]()
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entry: NSManagedObject!
    var entries: [NSManagedObject]!
    
    
    var contactsSelected = [CNContact]()
    var addedFriends = [Friend]()
    
    private var currentFriends = [Friend]()
    
    // to prevent extra cells being selected
    var checkedIndices: NSMutableArray = NSMutableArray()
    
    var delegate: ImportCellDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        fetchCurrentFriends()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.askPermissionAndFetchContacts()
            
        }

        
    }
    func fetchCurrentFriends() {
        let fetchRequest = NSFetchRequest(entityName: "Friend")
        do {
            let entryObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            self.entries = entryObjects as! [NSManagedObject]
            
            // parse NSManagedObject to Scene Objects
            for entry in self.entries {
                let firstName = entry.valueForKey("firstName") as! String
                let lastName = entry.valueForKey("lastName") as! String
                
                let friend = Friend(firstName: firstName, lastName: lastName)
                self.currentFriends.insert(friend, atIndex: 0)
            }
            
        } catch let error as NSError {
            print("could not fetch entries \(error), \(error.userInfo)")
        }
    }
    
    func askPermissionAndFetchContacts() {
        let store = CNContactStore()

        if CNContactStore.authorizationStatusForEntityType(.Contacts) == .NotDetermined {
            
            store.requestAccessForEntityType(.Contacts) { succeeded, err in
                guard err == nil && succeeded else {
                    return
                }

                self.findContacts(store)
            }
            
        } else if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized {
            self.findContacts(store)
        }
    }
    func findContacts(store: CNContactStore) {
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactImageDataKey, CNContactBirthdayKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contactsFetched = [CNContact]()
        
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (let contact, let stop) -> Void in
                if contact.birthday != nil && !contact.givenName.isEmpty {
                    if !self.contactAlreadyExists(contact) {
                        contactsFetched.append(contact)
                    }
                }
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        self.contacts = contactsFetched
        // very import to reloadTable
        dispatch_async(dispatch_get_main_queue()) {
            self.contactsTableView.reloadData()
        }
    }
    // helper function
    func contactAlreadyExists(contact: CNContact) -> Bool {
        for iFriend in currentFriends {
            if iFriend.firstName == contact.givenName && iFriend.lastName == contact.familyName {
                return true
            }
        }
        return false
    }
    
    func saveContactCoreData(friend: Friend) {
        let friendEntity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: self.managedObjectContext)!
        let friendObject = NSManagedObject(entity: friendEntity, insertIntoManagedObjectContext: self.managedObjectContext)
        
        friendObject.setValue(friend.firstName, forKey: "firstName")
        friendObject.setValue(friend.lastName, forKey: "lastName")
        friendObject.setValue(friend.birthdate?.day, forKey: "day")
        friendObject.setValue(friend.birthdate?.month, forKey: "month")
        friendObject.setValue(friend.birthdate?.year, forKey: "year")
        friendObject.setValue(friend.profilePicture, forKey: "profilePicture")
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("could not save the new entry \(error.description)")
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func doneBarButtonTapped(sender: AnyObject) {
        
        // save all the checked contacts to Core Data and save them to Core Data

        
        for friend in addedFriends {
            saveContactCoreData(friend)
        }

        // add local notifications to all the added contacts, if needed
        if NSUserDefaults.standardUserDefaults().boolForKey("reminder") {
            
            let dateComponent = NSDateComponents()
            let calendar = NSCalendar.currentCalendar()
            let daysBefore: Int = NSUserDefaults.standardUserDefaults().integerForKey("numberOfDaysBefore")
            let dayOfTime: NSDate = NSUserDefaults.standardUserDefaults().objectForKey("timeOfTheDay") as! NSDate
            let components = calendar.components([.Hour, .Minute], fromDate: dayOfTime)
            dateComponent.hour = components.hour                    // hour
            dateComponent.minute = components.minute                // minute
            let currentDate = NSDate()
            let currentMonth = currentDate.month()
            let year = currentDate.year()

            
            for friend in addedFriends {
                dateComponent.month = (friend.birthdate?.month)!                   // month
                dateComponent.day = (friend.birthdate?.month)! - daysBefore          // day
                if dateComponent.month >= currentMonth {    // if birth month is coming up than use current year
                    dateComponent.year = year                                       // year
                } else {
                    dateComponent.year = year + 1
                }
                let reminderDate: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(dateComponent))!
                // get name
                var friendName: String = friend.firstName
                if let lastName = friend.lastName {
                    friendName = friendName + " " + lastName
                }
                let notification = ABNotification(alertBody: "It is \(friendName)'s Birthday in " + String(daysBefore) + " days! 🎂")

                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                notification.repeatInterval = .Yearly
                notification.schedule(fireDate: reminderDate)  // todo item due date (when notification will be fired)
                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                notification.userInfo = ["full name": friendName, "type": "daysBefore"]
                
            }

        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey("dayOfReminder") {
            let dateComponent = NSDateComponents()
            let calendar = NSCalendar.currentCalendar()
//            let daysBefore: Int = NSUserDefaults.standardUserDefaults().integerForKey("numberOfDaysBefore")
            let dayOfTime: NSDate = NSUserDefaults.standardUserDefaults().objectForKey("timeOfTheDay") as! NSDate
            let components = calendar.components([.Hour, .Minute], fromDate: dayOfTime)
            dateComponent.hour = components.hour                    // hour
            dateComponent.minute = components.minute                // minute
            let currentDate = NSDate()
            let currentMonth = currentDate.month()
            let year = currentDate.year()
            
            for friend in addedFriends {
                dateComponent.month = (friend.birthdate?.month)!                   // month
                dateComponent.day = (friend.birthdate?.month)!                     // day
                if dateComponent.month >= currentMonth {    // if birth month is coming up than use current year
                    dateComponent.year = year                                       // year
                } else {
                    dateComponent.year = year + 1
                }
                let dayOfDate: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(dateComponent))!
                // get name
                var friendName: String = friend.firstName
                if let lastName = friend.lastName {
                    friendName = friendName + " " + lastName
                }
                
                let notification = ABNotification(alertBody: "It is \(friendName)'s Birthday today!🎂")
                notification.alertAction = "open"
                notification.repeatInterval = .Yearly
                notification.schedule(fireDate: dayOfDate)
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.userInfo = ["full name": friendName, "type": "dayOf"]
                
            }

            
        }
        

        self.dismissViewControllerAnimated(true, completion: nil)
    }



    
}

extension ImportContactsVC: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("import contact cell", forIndexPath: indexPath) as! ImportContactTableViewCell
        
        cell.delegate = self
        cell.index = indexPath.row
        
        cell.checkButton.selected = false
        if checkedIndices.containsObject(indexPath) {
            cell.checkButton.selected = true
        } else {
            cell.checkButton.selected = false
        }
        
        let contactForCell = self.contacts[indexPath.row]
        cell.contact = contactForCell
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
}

extension ImportContactsVC: UITableViewDelegate{

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ImportContactTableViewCell {
            
            cell.checkButton.selected = !cell.checkButton.selected
            let contactInCell = cell.contact
            
            // if it turned checked
            if cell.checkButton.selected {
                checkedIndices.addObject(indexPath)
                contactsSelected.append(contacts[indexPath.row])
                
                // add that friend to variable addedFriends
                let bDayComponents = contactInCell.birthday
                let birthday = Date(month: (bDayComponents?.month)!, day: (bDayComponents?.day)!)
                if let year = bDayComponents?.year {
                    if year > 1915 && year < 2020 {
                        birthday.year = year
                    }
                }
                let newFriend = Friend(firstName: contactInCell.givenName, birthdate: birthday)
                newFriend.lastName = contactInCell.familyName
                if let image = contactInCell.imageData {
                    newFriend.profilePicture = UIImage(data: image)      
                }
                addedFriends.append(newFriend)
                
            } else {
                
                // find the contact that needs to be deleted
                var counter = 0
                for contact in contactsSelected {
                    if contact.givenName == contactInCell.givenName && contact.familyName == contactInCell.familyName {
                        self.contactsSelected.removeAtIndex(counter)
                        self.checkedIndices.removeObject(indexPath)

                    }
                    counter += 1
                }

                // delete that friend from variable addedFriends
                counter = 0
                for friend in addedFriends {
                    if friend.firstName == contactInCell.givenName && friend.lastName == contactInCell.familyName {
                        self.addedFriends.removeAtIndex(counter)
                    }
                    counter += 1
                }
                
            }
        }
    }
    
}



extension ImportContactsVC: ImportCellDelegate {

    func checkButtonTappedAdd(indexPath: Int) {
        tableView(contactsTableView, didSelectRowAtIndexPath: NSIndexPath(forRow: indexPath, inSection: 0))
    }
    
}














