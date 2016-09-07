//
//  boardTableViewCell.swift
//  BFN
//
//  Created by Lai, Allen on 7/22/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit

class BoardTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dayDateLabel: UILabel!
    
    
    var friend: Friend! {
        didSet {

            switch friend.shape! {
            case 1:
                img.image = UIImage(named: "Circle Board")
            case 2:
                img.image = UIImage(named: "Heart Board")
            case 3:
                img.image = UIImage(named: "Square Board")
            case 4:
                img.image = UIImage(named: "Triangle Board")
            default:
                img.image = UIImage(named: "Circle Board")
            }
            
            nameLabel.text = friend.firstName
            let day: Int = (friend.birthdate?.day!)!
            dayDateLabel.text = String(day)
  
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





















