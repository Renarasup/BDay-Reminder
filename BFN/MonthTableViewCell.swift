//
//  MonthTableViewCell.swift
//  BFN
//
//  Created by Lai, Allen on 7/18/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit

class MonthTableViewCell: UITableViewCell {

    
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var friend: Friend! {
        didSet {
        
            if let dayDate = friend.birthdate?.day {
                dayDateLabel.text = String(dayDate)
            }
            
            if let lastName = friend.lastName {
                nameLabel.text = friend.firstName + " " + lastName
            } else {
                nameLabel.text = friend.firstName
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
