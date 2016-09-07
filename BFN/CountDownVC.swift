//
//  CountDownVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/25/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit

class CountDownVC: UIViewController {

    
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    @IBOutlet weak var thereAreOnlyLabel: UILabel!  // There are only
    @IBOutlet weak var numberOfDaysLabel: UILabel!  // ## days
    @IBOutlet weak var untilLabel: UILabel! // until Allen Lai's
    
    @IBOutlet weak var numberNDLabel: UILabel!  // 21st, 22nd, 23rd, 24th, 25th, 26th, 27th, 28th, 29th
    @IBOutlet weak var birthdayLabel: UILabel!  // birthday!
    

    var friend: Friend!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // make profileImage rounded
        self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2
        self.profilePictureImageView.clipsToBounds = true
        
        var back = UIImage(named: "BackButton")
        back = back?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backIndicatorImage = back
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = back

    
    
        // set up the view
        if let image = friend.profilePicture {
            profilePictureImageView.image = image
        }
        
        if let daysUntil = friend.daysUntil {
            numberOfDaysLabel.text = String(daysUntil) + " days"
        }
    
        if let lastName = friend.lastName {
            untilLabel.text = "until " + friend.firstName + " " + lastName + "'s"
            
        } else {
            untilLabel.text = "until " + friend.firstName + "'s"
        }
    
        if let year = friend.birthdate?.year {
            let currentDate = NSDate()
            let currentYear = currentDate.year()
            let age = currentYear - year
            var suffix: String
            let ones = age % 10
            switch ones {
            case 1:
                suffix = "st"
            case 1:
                suffix = "nd"
            case 1:
                suffix = "rd"
            default:
                suffix = "th"
            }
            numberNDLabel.text = String(age) + suffix
        } else {
            // no number
            numberNDLabel.text = "birthday!"
            birthdayLabel.hidden = true
        }
    
    
    
    
    }

    
    
    
    
    
    
    
    
    
    

}
