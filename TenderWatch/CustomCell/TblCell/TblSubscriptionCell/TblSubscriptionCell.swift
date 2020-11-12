//
//  TblSubscriptionCell.swift
//  TenderWatch
//
//  Created by lcom on 01/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class TblSubscriptionCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
   
    var categoryArray = [[String:Any]]()
    let componentManager = UIComponantManager()
   @IBOutlet weak var btnCurrentlyActive: UIButton!
    
    @IBOutlet weak var HeightConstraintTblCategory: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tblViewCategoryList: UITableView!
    @IBOutlet weak var imgViewCountry: UIImageView!
    @IBOutlet weak var lblSubscriptionTime: UILabel!
    @IBOutlet weak var lblPlanType: UILabel!
    @IBOutlet weak var lblExpiryDate: UILabel!
    @IBOutlet weak var lblCountryName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnCurrentlyActive.layer.cornerRadius = 25.0
        componentManager.registerTableViewCell(cellName: "CustomCategoryTableViewCell", to: tblViewCategoryList)
       
               tblViewCategoryList.delegate = self
               tblViewCategoryList.dataSource = self
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 1
        mainView.layer.shadowOffset = .zero
        mainView.layer.shadowRadius = 1
    
        mainView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count ;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewCategoryList.dequeueReusableCell(withIdentifier: "CustomCategoryTableViewCell", for: indexPath) as! CustomCategoryTableViewCell;
        
        cell.imgCategory?.image = base64Convert(base64String: (categoryArray[indexPath.row]["imgString"] as! String))
        cell.lblCategory.text = (categoryArray[indexPath.row]["categoryName"] as! String)
        return cell;
       }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
}
