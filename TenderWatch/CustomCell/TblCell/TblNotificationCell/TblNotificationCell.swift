//
//  TblNotificationCell.swift
//  TenderWatch
//
//  Created by Bhumi Joshi on 08/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class TblNotificationCell: UITableViewCell {

    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var imageviewProfile: UIImageView!
    @IBOutlet weak var txtNotificationTitle: UILabel!
    @IBOutlet weak var txtNotificationDate: UILabel!
    
    @IBOutlet weak var btnCheck: UIButton!
    
    @IBOutlet weak var constrainWidthBtnCheck: NSLayoutConstraint!
    @IBOutlet weak var constrainLeadingImageViewProfile: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
