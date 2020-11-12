//
//  TblInteresetedContractorCell.swift
//  TenderWatch
//
//  Created by mac2019_17 on 20/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class TblInteresetedContractorCell: UITableViewCell {

    //MARK:- outlet
    @IBOutlet weak var viewBase: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
