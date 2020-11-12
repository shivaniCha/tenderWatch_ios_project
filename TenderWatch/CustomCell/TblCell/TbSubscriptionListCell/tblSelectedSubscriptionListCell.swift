//
//  tblSelectedSubscriptionListCell.swift
//  TenderWatch
//
//  Created by mac2019_17 on 26/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class tblSelectedSubscriptionListCell: UITableViewCell,UITableViewDataSource,UITableViewDelegate {
//MARK:- outlet
    
    @IBOutlet weak var viewBase: UIView!
    @IBOutlet weak var lblCountryName: UILabel!
    @IBOutlet weak var lblSubscription: UILabel!
    @IBOutlet weak var lblPlan: UILabel!
    @IBOutlet weak var tblSelectedCategory: UITableView!
    @IBOutlet weak var constrainHeightTblSelectedCategory: NSLayoutConstraint!
    //MARK:- variable
    
     let componentManager = UIComponantManager()
    var arrSelectedCategory = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        componentManager.registerTableViewCell(cellName: "CustomCategoryTableViewCell", to: tblSelectedCategory)
        tblSelectedCategory.delegate = self
        tblSelectedCategory.dataSource = self
        
        
    
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
       func base64Convert(base64String: String?) -> UIImage{
           if (base64String?.isEmpty)! {
               return #imageLiteral(resourceName: "ic_AppIcon")
           }else {
               // !!! Separation part is optional, depends on your Base64String !!!
               //          let temp = base64String?.components(separatedBy: ",")
               let dataDecoded : Data = Data(base64Encoded: base64String!, options: .ignoreUnknownCharacters)!
               let decodedimage = UIImage(data: dataDecoded)
               return decodedimage!
           }
       }
    
   //MARK:- table view method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrSelectedCategory.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCategoryTableViewCell", for: indexPath ) as! CustomCategoryTableViewCell
        
        cell.imgCategory.image = base64Convert(base64String: (arrSelectedCategory[indexPath.row]["imgString"] as! String))
               cell.contentMode = .scaleToFill
               cell.lblCategory.text = (arrSelectedCategory[indexPath.row]["categoryName"] as! String)
        return cell
        
    }
    
    
    
    
}
