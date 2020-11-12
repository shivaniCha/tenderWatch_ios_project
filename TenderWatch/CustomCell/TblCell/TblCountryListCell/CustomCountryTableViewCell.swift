//
//  CustomCountryTableViewCell.swift
//  TenderWatch
//
//  Created by Bhumi Joshi on 02/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class CustomCountryTableViewCell: UITableViewCell {

    @IBOutlet weak var countryNameTxt: UILabel!
    @IBOutlet weak var countryImg: UIImageView!
    @IBOutlet weak var imgSelected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
