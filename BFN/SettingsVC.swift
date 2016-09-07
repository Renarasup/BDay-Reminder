//
//  SettingsVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/26/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    
    var containerViewController: SettingsTableVC?
    
    var reminderEnabled: Bool!
    var numberOfDaysBefore: Int!
    var timeOfTheDayForReminder: NSDate!
    var dayOfReminder: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func done(sender: AnyObject) {
        // save user settings in NSUserDefaults
        
        reminderEnabled = containerViewController?.reminderSwitch.on
        let daysBefore: String = (containerViewController?.daysBeforeLabel.text!)!
        numberOfDaysBefore = Int(String(daysBefore.characters.first!))
        timeOfTheDayForReminder = containerViewController?.timeOfReminderPicker.date
        dayOfReminder = containerViewController?.dayOfSwitch.on
        
        
        let defaults = NSUserDefaults.standardUserDefaults()

        defaults.setBool(reminderEnabled, forKey: "reminder")
        defaults.setInteger(numberOfDaysBefore, forKey: "numberOfDaysBefore")
        defaults.setObject(timeOfTheDayForReminder, forKey: "timeOfTheDay")
        defaults.setBool(dayOfReminder, forKey: "dayOfReminder")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "embed segue" {
            let settingsTableVC = segue.destinationViewController as! SettingsTableVC
            containerViewController = settingsTableVC
            
            let defaults = NSUserDefaults.standardUserDefaults()
            settingsTableVC.reminderEnabled = defaults.boolForKey("reminder")
            settingsTableVC.numberOfDaysBefore = defaults.integerForKey("numberOfDaysBefore")
            settingsTableVC.timeOfTheDayForReminder = defaults.objectForKey("timeOfTheDay") as! NSDate
            settingsTableVC.dayOfReminder = defaults.boolForKey("dayOfReminder")
            
        }
        
    }
    
}
