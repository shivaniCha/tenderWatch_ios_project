//
//  TblSideMenuCell.swift
//  TenderWatch
//
//  Created by lcom on 28/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class TblSideMenuCell: UITableViewCell {

    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNewNotificationCount: UILabel!
    @IBOutlet weak var constrainWidthLblNewNotificationCount: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
