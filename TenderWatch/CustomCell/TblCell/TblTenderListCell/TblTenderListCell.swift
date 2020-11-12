//
//  TblTenderListCell.swift
//  TenderWatch
//
//  Created by lcom on 28/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class TblTenderListCell: UITableViewCell {
    
    
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblExpDays: UILabel!
    @IBOutlet weak var lblNew: UILabel!
    @IBOutlet weak var imgInterested: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        //Set Corner Radius To Profile Imageview
        imgViewIcon.layer.cornerRadius = imgViewIcon.frame.size.width / 2
        imgViewIcon.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
