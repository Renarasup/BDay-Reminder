//
//  UpcomingTableViewCell.swift
//  BFN
//
//  Created by Lai, Allen on 7/18/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit

class UpcomingTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    
    
    var friend: Friend! {
        didSet {
            
            var initials: String = ""
            
            if let lastName = friend.lastName {
                nameLabel.text = friend.firstName + " " + lastName
                
                // find a better way of doing this
                if lastName.isEmpty {
                    initials = String(friend.firstName.characters.first!)
                } else {
                    initials = String(friend.firstName.characters.first!) + String(lastName.characters.first!)
                }
            } else {
                nameLabel.text = friend.firstName
                initials = String(friend.firstName.characters.first!)
            }
            
            if let birthdate = friend.birthdate?.day {
                dayDateLabel.text = String(birthdate)
            }
         
            if let image = friend.profilePicture {
                // make profileImage rounded
                self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2
                self.profilePictureImageView.clipsToBounds = true
                self.profilePictureImageView.image = image

                initialsLabel.text = ""
            } else {
                self.profilePictureImageView.image = UIImage(named: "GreyCircle")
                initialsLabel.text = initials
            }
            
            if let days = friend.daysUntil {
                if days > 0 {
                    upcomingLabel.text = "in " + String(days) + " days"
                } else if days < 0 {
                    upcomingLabel.text = String(abs(days)) + " days ago"
                } else {
                    upcomingLabel.text = "Today"

                }
            }
            
            
            let currentDate = NSDate()
            let currentMonth = currentDate.month()
            let year = currentDate.year()
            let birthdate = NSDateComponents()
            birthdate.month = (friend.birthdate?.month!)!
            birthdate.day = (friend.birthdate?.day!)!
            if birthdate.month >= currentMonth {    // if birth month is coming up than use current year
                birthdate.year = year
            } else {
                birthdate.year = year + 1
            }
            let date: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(birthdate))!
            if let dayOfTheWeek = date.dayOfWeek() {
                dayOfTheWeekLabel.text = dayOfTheWeek
            }
            
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


