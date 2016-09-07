//
//  AlphebeticalTableViewCell.swift
//  BFN
//
//  Created by Lai, Allen on 7/14/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit

class AlphebeticalTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdateLabel: UILabel!
    
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
            
            // if lastName exists use it if not don't
            if let lastName = friend.lastName {
                nameLabel.text = friend.firstName + " " + lastName
            } else {
                nameLabel.text = friend.firstName
            }
            
            if let birthYear = friend.birthdate?.year {
                let birthYearStr = String(birthYear)
                let yearFormat: String = birthYearStr.substringWithRange(Range<String.Index>(start: birthYearStr.startIndex.advancedBy(2), end: birthYearStr.endIndex))

                birthdateLabel.text = String(friend.birthdate!.month!) + "/" + String(friend.birthdate!.day!) + "/" + yearFormat
            } else {
                birthdateLabel.text = String(friend.birthdate!.month!) + "/" + String(friend.birthdate!.day!)
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
            
            if let notes = friend.notes {
                if notes != "" {
                    nameLabel.textColor = UIColor(red: 25/255, green: 181/255, blue: 255/255, alpha: 1)
                } else {
                    nameLabel.textColor = UIColor.blackColor()
                }
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


