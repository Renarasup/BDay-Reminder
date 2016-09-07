//
//  NewBirthdayVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/14/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import CoreData
import Photos


class NewBirthdayVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var birthyearTextField: UITextField!
    
    var friend: Friend = Friend()
    private var allFriends = [Friend]()
    private var profileImage: UIImage?
    
    var birthdatePicker = PMEDatePicker()
    var birthYearPicker = PMEDatePicker()
    
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entries: [NSManagedObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // make profileImage rounded
        self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2
        self.profilePictureImageView.clipsToBounds = true
        
        firstNameTextField.useUnderline()
        lastNameTextField.useUnderline()
        birthdateTextField.useUnderline()
        birthyearTextField.useUnderline()

        // set all the delegate TextFields
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        birthdateTextField.delegate = self
        birthyearTextField.delegate = self
        
        // set the formate for datepickers
        birthdatePicker.dateFormatTemplate = "MMMd"
        birthYearPicker.dateFormatTemplate = "yyyy"
        
        // done and cancel button in toolbar setup
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewBirthdayVC.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewBirthdayVC.cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        
        birthdateTextField.inputView = birthdatePicker
        birthdateTextField.inputAccessoryView = toolBar
        birthyearTextField.inputView = birthYearPicker
        birthyearTextField.inputAccessoryView = toolBar
    
        // sets the default picker to my birthday
        let stringDate = "26-Aug-94"
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "dd-MMM-yy"
        let date = dateformatter.dateFromString(stringDate)
        birthdatePicker.setDate(date, animated: false)
        birthYearPicker.setDate(date, animated: false)
        

        firstNameTextField.becomeFirstResponder()

        // Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        fetchAllFriends()

    }
    func fetchAllFriends() {
        let fetchRequest = NSFetchRequest(entityName: "Friend")
        do {
            let entryObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            self.entries = entryObjects as! [NSManagedObject]
            
            // parse NSManagedObject to Scene Objects
            for entry in self.entries {
                let firstName = entry.valueForKey("firstName") as! String
                let lastName = entry.valueForKey("lastName") as! String
                
                let friend = Friend(firstName: firstName, lastName: lastName)
                self.allFriends.insert(friend, atIndex: 0)
                
            }
            
        } catch let error as NSError {
            print("could not fetch entries \(error), \(error.userInfo)")
        }
    }
    func donePicker() {
        // update the cell's button title and record button
        
        let dateFormatter = NSDateFormatter()
        if birthdateTextField.isFirstResponder() {
            dateFormatter.dateFormat = "MMM d"
            let dateString = dateFormatter.stringFromDate(birthdatePicker.date)
            birthdateTextField.text = dateString
            
            birthyearTextField.becomeFirstResponder()
        } else if birthyearTextField.isFirstResponder() {
            dateFormatter.dateFormat = "yyyy"
            let dateString = dateFormatter.stringFromDate(birthYearPicker.date)
            birthyearTextField.text = dateString
            
            birthyearTextField.resignFirstResponder()
        }

    }
    func cancelPicker() {
        
        if birthdateTextField.isFirstResponder() {
            birthdateTextField.text = ""
        } else if birthyearTextField.isFirstResponder() {
            birthyearTextField.text = ""
        }
        self.view.endEditing(true)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // set the scene's title
        self.view.endEditing(true)
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            friend.firstName = firstNameTextField.text
            lastNameTextField.becomeFirstResponder()
            return true
        }
        if textField == lastNameTextField {
            friend.lastName = lastNameTextField.text
            birthdateTextField.becomeFirstResponder()
            return true
        }
        if textField == birthdateTextField {
            //  TODO:: store the birthdate
            //friend.birthdateTextField = birthdateTextField.text
            birthyearTextField.becomeFirstResponder()
            return true
        }
        if textField == birthyearTextField {
            //  TODO:: store the birthdate
            //friend.birthdateTextField = birthdateTextField.text
            self.view.endEditing(true)
            return true
        }
        
        
        return true
    }
    
    
    func alert(msg: String) {
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func addFriend(sender: AnyObject) {
        
        if firstNameTextField.text == "" || birthdateTextField.text == "" {
            alert("FIRST NAME and BIRTHDAY must be filled in 🙃")
            return
        }
        
        
        friend.firstName = firstNameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        friend.lastName = lastNameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        friend.birthdate = Date(month: birthdatePicker.date.month(), day: birthdatePicker.date.day())
        if birthyearTextField.text != "" {
            friend.birthdate?.year = birthYearPicker.date.year()
        }
        friend.profilePicture = self.profileImage
        
        // search for duplicates
        for iFriend in allFriends {
            if iFriend.firstName == friend.firstName {
                if iFriend.lastName == friend.lastName {
                    alert("This name already exists in your contacts 😅")
                    return
                }
            }
        }
        
        
        // add friend to coreData
        saveFriend()
        
        
        // add a local notification for the friend if necessary
        let defaults = NSUserDefaults.standardUserDefaults()
        // get name
        var friendName: String = friend.firstName
        if let lastName = friend.lastName {
            friendName = friendName + " " + lastName
        }
        // get date and make NSDate
        let daysBefore: Int = NSUserDefaults.standardUserDefaults().integerForKey("numberOfDaysBefore")
        let dayOfTime: NSDate = NSUserDefaults.standardUserDefaults().objectForKey("timeOfTheDay") as! NSDate
        
        let dateComponent = NSDateComponents()
        dateComponent.month = birthdatePicker.date.month()                   // month
        dateComponent.day = birthdatePicker.date.day() - daysBefore          // day
        let currentDate = NSDate()
        let currentMonth = currentDate.month()
        let year = currentDate.year()
        if dateComponent.month >= currentMonth {    // if birth month is coming up than use current year
            dateComponent.year = year                                       // year
        } else {
            dateComponent.year = year + 1
        }

        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: dayOfTime)
        dateComponent.hour = components.hour                    // hour
        dateComponent.minute = components.minute                // minute
        let reminderDate: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(dateComponent))!

        dateComponent.day = dateComponent.day + daysBefore
        let birthdayReminder: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(dateComponent))!
        
        if defaults.boolForKey("reminder") {

            let notification = ABNotification(alertBody: "It is \(friendName)'s Birthday in " + String(daysBefore) + " days! 🎂")

            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            
            notification.schedule(fireDate: reminderDate)  // todo item due date (when notification will be fired)
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["full name": friendName, "type": "daysBefore"]
            
        }
        
        if defaults.boolForKey("dayOfReminder") {
            let notification = ABNotification(alertBody: "It is \(friendName)'s Birthday today!🎂")

            notification.alertAction = "open"
            notification.repeatInterval = .Yearly
            notification.schedule(fireDate: birthdayReminder)
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["full name": friendName, "type": "dayOf"]

        }
        
        
        
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func saveFriend() {
        let friendEntity = NSEntityDescription.entityForName("Friend", inManagedObjectContext: self.managedObjectContext)!
        let friendObject = NSManagedObject(entity: friendEntity, insertIntoManagedObjectContext: self.managedObjectContext)
        
        friendObject.setValue(self.friend.firstName, forKey: "firstName")
        friendObject.setValue(self.friend.lastName, forKey: "lastName")
        friendObject.setValue(self.friend.birthdate?.day, forKey: "day")
        friendObject.setValue(self.friend.birthdate?.month, forKey: "month")
        friendObject.setValue(self.friend.birthdate?.year, forKey: "year")
        friendObject.setValue(self.friend.profilePicture, forKey: "profilePicture")
        print(self.friend.profilePicture)
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("could not save the new entry \(error.description)")
        }
    }
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func pickProfileImage(sender: UITapGestureRecognizer) {

        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.pickProfileImage(sender)
                })
            })
            return
        }
        
        if authorization == .Authorized {
            let controller = ImagePickerSheetController()
            
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "ActionTitle"),
                secondaryTitle: NSLocalizedString("Use this one", comment: "Action Title"),
                handler: { (_) -> () in
                    
                    self.presentCamera()
                    
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.profileImage = images[0]
                        self.profilePictureImageView.image = self.profileImage
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { (_) -> () in
                self.profileImage = nil
                self.profilePictureImageView.image = UIImage(named: "defaultProfileImage")
                }, secondaryHandler: nil))
            presentViewController(controller, animated: true, completion: nil)
        }
    }

    

}

extension NewBirthdayVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        self.profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profilePictureImageView.image! = self.profileImage!
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UITextField {
    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.blackColor().CGColor
        border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
