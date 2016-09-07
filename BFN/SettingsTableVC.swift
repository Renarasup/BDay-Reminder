//
//  SettingsTableVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/26/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import MessageUI
import CoreData


class SettingsTableVC: UITableViewController, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var daysBeforeLabel: UILabel!
    @IBOutlet weak var dayOfSwitch: UISwitch!
    @IBOutlet weak var timeOfReminderLabel: UILabel!
    
    @IBOutlet weak var daysBeforeCheatTextField: UITextField!
    @IBOutlet weak var timeCheatTextField: UITextField!
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entries: [NSManagedObject]!
    
    var timeOfReminderPicker = UIDatePicker()
    
    var numDaysPicker = UIPickerView()
    var daysBeforeArray: [String] = ["1 day", "2 days", "3 days", "4 days", "5 days", "6 days", "7 days"]

    // settings
    var reminderEnabled: Bool!
    var numberOfDaysBefore: Int!
    var timeOfTheDayForReminder: NSDate!
    var dayOfReminder: Bool!
    
    let messageComposer = MessageComposer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        numDaysPicker.dataSource = self
        numDaysPicker.delegate = self
        numDaysPicker.showsSelectionIndicator = true

        timeOfReminderPicker.datePickerMode = UIDatePickerMode.Time
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SettingsTableVC.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SettingsTableVC.cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        
        daysBeforeCheatTextField.inputView = numDaysPicker
        daysBeforeCheatTextField.inputAccessoryView = toolBar
        timeCheatTextField.inputView = timeOfReminderPicker
        timeCheatTextField.inputAccessoryView = toolBar
        
        
        // update view to the user settings
        reminderSwitch.on = reminderEnabled
        switch numberOfDaysBefore {
        case 1:
            daysBeforeLabel.text = "1 day"
            daysBeforeCheatTextField.text = "1 day"
            numDaysPicker.selectRow(0, inComponent: 0, animated: false)
        case 2:
            daysBeforeLabel.text = "2 days"
            daysBeforeCheatTextField.text = "2 days"
            numDaysPicker.selectRow(1, inComponent: 0, animated: false)
        case 3:
            daysBeforeLabel.text = "3 days"
            daysBeforeCheatTextField.text = "3 days"
            numDaysPicker.selectRow(2, inComponent: 0, animated: false)
        case 4:
            daysBeforeLabel.text = "4 days"
            daysBeforeCheatTextField.text = "4 days"
            numDaysPicker.selectRow(3, inComponent: 0, animated: false)
        case 5:
            daysBeforeLabel.text = "5 days"
            daysBeforeCheatTextField.text = "5 days"
            numDaysPicker.selectRow(4, inComponent: 0, animated: false)
        case 6:
            daysBeforeLabel.text = "6 days"
            daysBeforeCheatTextField.text = "6 days"
            numDaysPicker.selectRow(5, inComponent: 0, animated: false)
        case 7:
            daysBeforeLabel.text = "7 days"
            daysBeforeCheatTextField.text = "7 days"
            numDaysPicker.selectRow(6, inComponent: 0, animated: false)
        default:
            break
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "H:mm a"
        timeOfReminderLabel.text = dateFormatter.stringFromDate(timeOfTheDayForReminder)
        timeOfReminderPicker.setDate(timeOfTheDayForReminder, animated: false)

        
        dayOfSwitch.on = dayOfReminder

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }
    func donePicker() {

        if daysBeforeCheatTextField.isFirstResponder() {
            daysBeforeLabel.text = daysBeforeCheatTextField.text!
            daysBeforeCheatTextField.resignFirstResponder()
            tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0) , animated: true)
            return
        }
        
        if timeCheatTextField.isFirstResponder() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let timeStr = dateFormatter.stringFromDate(timeOfReminderPicker.date)
            timeOfReminderLabel.text = timeStr
            timeCheatTextField.resignFirstResponder()
            tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0) , animated: true)
            return
        }
        
    }
    func cancelPicker() {
        timeCheatTextField.resignFirstResponder()
        daysBeforeCheatTextField.resignFirstResponder()
        tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: false)
        tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0), animated: false)

    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["alai18@terpmail.umd.edu"])
        mailComposerVC.setSubject("FeedBack for your B-Day App")
        mailComposerVC.setMessageBody("Hello, ", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 1
        case 2:
            return 3
        case 3:
            return 0
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            // REMINDER section
            switch indexPath.row {
            case 0:
                reminderSwitch.on = !reminderSwitch.on
                tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0) , animated: true)
                return
            case 1:
                daysBeforeCheatTextField.becomeFirstResponder()
                return
            case 2:
                timeCheatTextField.becomeFirstResponder()
                return
            case 3:
                dayOfSwitch.on = !dayOfSwitch.on
                tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0) , animated: true)
                return
            default:
                break
            }
        case 1:
            // advanced section of Reset/Delete All Friends
            // alert to get user if they really want to RESET
            let alertController = UIAlertController(title: "Deleting All Friends", message: "Are you sure?", preferredStyle: .Alert)
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                ABNScheduler.cancelAllNotifications()
                let fetchRequest = NSFetchRequest(entityName: "Friend")
                do {
                    let entryObjects = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                    for entry in entryObjects as! [NSManagedObject] {
                        self.managedObjectContext.deleteObject(entry)
                        do {
                            try self.managedObjectContext.save()
                        } catch let error as NSError {
                            print("Cannot delete object: \(error), \(error.localizedDescription)")
                        }
                    }
                } catch let error as NSError {
                    print("could not fetch entries \(error), \(error.userInfo)")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            let okAction = UIAlertAction(title: "Yes", style: .Default, handler: callActionHandler)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)

            tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1) , animated: true)


            return
        case 2:
            // MORE section
            switch indexPath.row {
            case 0:
                // rate this app
                let path = NSURL(string: "itms-apps://itunes.apple.com/app/id1138332565")
                UIApplication.sharedApplication().openURL(path!)
                return
            case 1:
                // send feedback
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
                
                return
            case 2:
                // share with a friend
                if (messageComposer.canSendText()) {
                    // Obtain a configured MFMessageComposeViewController
                    let messageComposeVC = messageComposer.configuredMessageComposeViewController()
                    
                    // Present the configured MFMessageComposeViewController instance
                    // Note that the dismissal of the VC will be handled by the messageComposer instance,
                    // since it implements the appropriate delegate call-back
                    presentViewController(messageComposeVC, animated: true, completion: nil)
                } else {
                    // Let the user know if his/her device isn't able to send text messages
                    let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
                    errorAlert.show()
                }
                
                return
            default:
                break
            }
        default:
            break
        }
        
        
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsTableVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return daysBeforeArray.count
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        daysBeforeCheatTextField.text = daysBeforeArray[row]
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return daysBeforeArray[row]
    }
    
}

extension SettingsTableVC: MFMessageComposeViewControllerDelegate {

    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}


