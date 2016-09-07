//
//  Friend.swift
//  BFN
//
//  Created by Lai, Allen on 7/13/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import CoreData

public class Friend {

    var firstName: String!
    var lastName: String?
    var birthdate: Date?
    var profilePicture: UIImage?
    
    var daysUntil: Int?     // for upcoming sorting
    
    
    var notes: String?
    var shape: Int?
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.birthdate = Date()
        
        self.shape = 1
    }
    
    // non optional init
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        
        self.shape = 1

    }
    init(firstName: String, birthdate: Date) {
        self.firstName = firstName
        self.birthdate = birthdate
        
        self.lastName = ""
        
        self.shape = 1

    }
    
    init(firstName: String, lastName: String, birthdate: Date) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthdate = birthdate
        
        self.shape = 1
    }
    

    init(firstName: String, lastName: String, birthdate: Date, daysUntil: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthdate = birthdate
        self.daysUntil = daysUntil
        
        self.shape = 1
    }
    
}

public class Date {
    
    var month: Int?
    var day: Int?
    var year: Int?
    
    init() {
        self.month = nil
        self.day = nil
        self.year = nil
    }

    init(month: Int, day: Int) {
        self.month = month
        self.day = day
        self.year = nil
    }
    
    init(month: Int, day: Int, year: Int) {
        self.month = month
        self.day = day
        self.year = year
    }
    
    
    
}

public class FriendsByAlphabet {
    
    var letter: String          // the letter that the friend's first name start with
    var friends: [Friend]
    
    init(letter: String, friends: [Friend])
    {
        self.letter = letter
        self.friends = friends
    }
    
}

public class FriendsByMonth {
    
    var month: String
    var friends: [Friend]
    
    var year: Int?           // for upcoming
    
    init(month: String, friends: [Friend])
    {
        self.month = month
        self.friends = friends
    }
    
}





extension NSDate
{
    func month() -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Month, fromDate: self)
        let month = components.month
        return month
    }
    func day() -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Day, fromDate: self)
        let day = components.day
        return day
    }
    func year() -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Year, fromDate: self)
        let year = components.year
        return year
    }
    func differenceInDaysWithDate(date: NSDate) -> Int {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let date1 = calendar.startOfDayForDate(self)
        let date2 = calendar.startOfDayForDate(date)
        
        let components = calendar.components(.Day, fromDate: date1, toDate: date2, options: [])
        return components.day
    }
    func dayOfWeek() -> String? {
        if
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Weekday, fromDate: self) {
            let weekday = comp.weekday
            switch weekday {
            case 1:
                return "Sun"
            case 2:
                return "Mon"
            case 3:
                return "Tue"
            case 4:
                return "Wed"
            case 5:
                return "Thu"
            case 6:
                return "Fri"
            case 7:
                return "Sat"
            default:
                print("Error fetching days")
                return "Day"
            }
        } else {
            return nil
        }
    }
}

extension Array {
    func rotate(shift:Int) -> Array {
        var array = Array()
        if (self.count > 0) {
            array = self
            if (shift > 0) {
                for _ in 1...shift {
                    array.append(array.removeAtIndex(0))
                }
            }
            else if (shift < 0) {
                for _ in 1...abs(shift) {
                    array.insert(array.removeAtIndex(array.count-1),atIndex:0)
                }
            }
        }
        return array
    }
}




