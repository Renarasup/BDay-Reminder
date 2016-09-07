//
//  ImportContactTableViewCell.swift
//  BFN
//
//  Created by Lai, Allen on 7/20/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import Contacts

protocol ImportCellDelegate {
    func checkButtonTappedAdd(indexPath: Int)
}

class ImportContactTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var initialsLabel: UILabel!
    
    var delegate: ImportCellDelegate!
    var index: Int!

    var contact: CNContact! {
        didSet {
        

            if let nameLabel = self.nameLabel {
                nameLabel.text = CNContactFormatter.stringFromContact(contact, style: .FullName)
            }
            
            if let imageView = self.profilePictureImageView {
                if contact.imageData != nil {
                    initialsLabel.text = ""
                    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2
                    self.profilePictureImageView.clipsToBounds = true
                    imageView.image = UIImage(data: contact.imageData!)
                } else {
                    var initials: String
                    if let lInitial = contact.familyName.characters.first {
                        initials =  String(contact.givenName.characters.first!) + String(lInitial)
                    } else {
                        initials =  String(contact.givenName.characters.first!)
                    }
                    initialsLabel.text = initials
                    self.profilePictureImageView.image = UIImage(named: "GreyCircle")
                }
            }
            
            if let birthdayLabel = self.birthdayLabel {
                if let birthday = contact.birthday {
                    if birthday.year < 1915 || birthday.year > 2020 {
                        
                        let birthdate = NSDateComponents()
                        birthdate.month = (contact.birthday?.month)!
                        birthdate.day = (contact.birthday?.day)!

                        let date: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(birthdate))!
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MMMM d"
                        birthdayLabel.text = dateFormatter.stringFromDate(date)
                        
                    } else {
                        let birthdate = NSDateComponents()
                        birthdate.month = (contact.birthday?.month)!
                        birthdate.day = (contact.birthday?.day)!
                        birthdate.year = (contact.birthday?.year)!
                        
                        let date: NSDate = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(birthdate))!
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MMMM d, yyyy"
                        birthdayLabel.text = dateFormatter.stringFromDate(date)

                    }

                }
            }
            
        }
    }
    
    // let the TableVC know that its been tapped
    @IBAction func checkButtonTapped(sender: AnyObject) {
        delegate.checkButtonTappedAdd(index)
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










