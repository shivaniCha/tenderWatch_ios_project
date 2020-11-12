//
//  ClientTenderDetailVC.swift
//  TenderWatch
//
//  Created by lcom on 29/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import GSImageViewerController
import MessageUI

class ClientTenderDetailVC: BaseViewController,ServiceManagerDelegate,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate{
    
    //MARK:- outlet
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblTenderTitle: UILabel!
    @IBOutlet weak var imgCountryFlag: UIImageView!
    @IBOutlet weak var lblCountryName: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var tblCategory: UITableView!
    
    @IBOutlet weak var constrainHeightTblCategory: NSLayoutConstraint!
    @IBOutlet weak var lblTargetViewers: UILabel!
    @IBOutlet weak var lblExpiryDays: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblWebSiteLink: UILabel!
    @IBOutlet weak var constrainHeightForWebsiteLinkTitle: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightForWebsiteLink: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightBtnWebSiteLink: NSLayoutConstraint!
    
    @IBOutlet weak var constrainHeightViewContactNo: NSLayoutConstraint!
    @IBOutlet weak var lblContactNo: UILabel!
    
    @IBOutlet weak var constrainHeightViewLandline: NSLayoutConstraint!
    @IBOutlet weak var lblLandlineNumber: UILabel!
    
    @IBOutlet weak var constrainHeightViewEmail: NSLayoutConstraint!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var constrainHeightViewAddress: NSLayoutConstraint!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var constrainHeightViewFollowTenderProcess: NSLayoutConstraint!
    
    @IBOutlet weak var constrainHeightViewFollowTenderLink: NSLayoutConstraint!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnAmend: UIButton!
    @IBOutlet weak var tblInterestedContractors: UITableView!
    
    @IBOutlet weak var constrainHeightTblInterestedContractor: NSLayoutConstraint!
    
    @IBOutlet weak var constrainHeightLblInterestedContractorTitle: NSLayoutConstraint!
    
    @IBOutlet weak var btnClientDetail: UIButton!
    
    //MARK:- variable
    let utils = Utils()
    let componentManager = UIComponantManager()
    let serviceManager = ServiceManager()
    let doGetTenderDetails = "do get Tender Details"
    let doGetInterestedContractor = "do get Interested Contractor for ClientTenderDetailVC"
    let doRemoveTender = "do Remove Tender for ClientTenderDetailVC"
    let doSendDetailForRemoveTender = "do Send Detail For Remove Tender for ClientTenderDetailVC"
    let doAddFavoriteTender =  "do Add Favorite Tender"
    let doRemoveFavoriteTender =  "do Remove Favorite Tender"
    let doAddInterestTender =  "do Add Interest Tender"
    let doRemoveInterestTender =  "do Remove Interest Tender"
    var dicTenderDetail = [String:Any]()
    var tenderDetailId = ""
    var arrInterestedContractors = [[String:Any]]()
    var arrActiveInterestedContractors = [[String:Any]]()
    var arrCategoryData = [[String:Any]]()
    var countryId = ""
    var countryName = ""
    let MFMailComposer = MFMailComposeViewController.self
    
    //MARK:- view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        serviceManager.delegate = self
        
        //call tender detail api
        self.callTenderDetailApi()
        self.callInterestedContractorListApi()
        
        componentManager.registerTableViewCell(cellName: "TblInteresetedContractorCell", to: tblInterestedContractors)
        
        componentManager.registerTableViewCell(cellName: "CustomCategoryTableViewCell", to: tblCategory)
        
        
        //        DispatchQueue.main.async {
        //                      self.setupData()
        //                   }
        
    }
    
    
    //MARK:- setupUI
    func setupUI(){
        
        if  utils.getUserType() == USER_CONTRACTOR
        {
            btnClientDetail.isHidden = false
            btnRemove.setTitle("FAVORITE", for: .normal)
            btnAmend.setTitle("INTERESTED", for: .normal)
            btnAmend.backgroundColor = hexStringToUIColor(hex: "#32C057")
            
            self.addRightBarButton()
        }
        else
        {
            btnClientDetail.isHidden = true
            btnRemove.setTitle("Remove", for: .normal)
            btnAmend.setTitle("Amend", for: .normal)
            btnAmend.backgroundColor = hexStringToUIColor(hex: "#787878")
        }
        
        btnAmend.cornerRadius = 8
        btnRemove.cornerRadius = 8
        
    }
    
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        self.setNavigationBarHeaderTitle(strTitle: "Tender Detail")
        self.addLeftBarButton()
    }
    
    func setNavigationBarHeaderTitle(strTitle:String)
    {
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21)]
        
        SetNavigationBarTitle(string: strTitle)
    }
    
    
    func addLeftBarButton() {
        
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        //your custom view for back image with custom size
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        if let imgBackArrow = UIImage(named: "ic_backWhite") {
            imageView.image = imgBackArrow
        }
        view.addSubview(imageView)
        
        let backTitle = UILabel(frame: CGRect(x: 25, y: 5, width: 80, height: 30))
        backTitle.text = "Back"
        backTitle.textColor = UIColor.white
        view.addSubview(backTitle)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backBtnPressed))
        view.addGestureRecognizer(backTap)
        
        let leftBarButtonItem = UIBarButtonItem(customView: view )
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    
    func addRightBarButton() {
        
        //your custom view
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        if let imgBackArrow = UIImage(named: "ic_sendMail") {
            imageView.image = imgBackArrow
        }
        view.addSubview(imageView)
        
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(sendEmailBtnPressed))
        view.addGestureRecognizer(saveTap)
        
        let rightBarButtonItem = UIBarButtonItem(customView: view )
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    
    //MARK:- setup Data
    func setupData(){
        print(dicTenderDetail)
        
        if (dicTenderDetail["tenderPhoto"] as? String != "no image" && dicTenderDetail["tenderPhoto"] as? String != ""){
            imgProfile.setImageWithActivityIndicator(imageURL: (dicTenderDetail["tenderPhoto"] as? String) ?? "", indicatorStyle: .gray, placeHolderImage: UIImage(named: "ic_avtar")!)
        }
        lblTenderTitle.text = dicTenderDetail["tenderName"] as? String
        
        ///Country
        let dicCountry = dicTenderDetail["country"] as? [String:Any]
        var strCountryCode = ""
        if dicCountry != nil
        {
            //country id
            countryId = dicCountry?["_id"] as? String ?? ""
            
            //country code
            strCountryCode  = dicCountry?["countryCode"] as? String ?? ""
            //country name
            lblCountryName.text = dicCountry?["countryName"] as? String
            countryName = dicCountry?["countryName"] as? String ?? ""
            
            //country flag
            if (dicCountry!["imageString"] as? String != "no image" && dicCountry!["imageString"] as? String != ""){
                let strCountryFlagImage = dicCountry!["imageString"] as? String
                imgCountryFlag.image = strCountryFlagImage?.base64ToImage()
            }
        }
        
        ///Category
        arrCategoryData = (dicTenderDetail["category"] as? [[String:Any]] ?? [[String:Any]]())
        tblCategory.reloadData()
        DispatchQueue.main.async {
            self.constrainHeightTblCategory.constant = CGFloat(self.arrCategoryData.count * 60)
            self.view.layoutIfNeeded()
        }
        
        
        
        ///city
        lblCity.text = dicTenderDetail["city"] as? String
        
        
        ///Target Viewers
        let arrTargetViewers = dicTenderDetail["targetViewers"] as? [[String:Any]]
        if arrTargetViewers != nil
        {
            var arrTemp = [String]()
            for dicTargetViewers in arrTargetViewers!
            {
                arrTemp.append(dicTargetViewers["name"] as? String ?? "")
            }
            
            if arrTemp.count>0{
                lblTargetViewers.text = arrTemp.map { String($0) }.joined(separator: ",")
            }
            else
            {
                lblTargetViewers.text = ""
            }
            
        }
        
        ///show expiry date including last date
        let expiryDate = dicTenderDetail["expiryDate"] as? String
        let strDate = expiryDate?.components(separatedBy: "T")[0]
        if strDate != nil
        {
            let strCurrentDate = Date().formateDate(format: "YYYY-MM-dd")
            lblExpiryDays.text = "\(self.calculateDaysBetweenTwoDates(strStartDate: strCurrentDate, strEndDate: strDate!)) days"
        }
        
        
        ///Description
        lblDescription.text = dicTenderDetail["description"] as? String
        lblWebSiteLink.text = dicTenderDetail["descriptionLink"] as? String
        
        //hide or show webswite link
        if lblWebSiteLink.text == "" || lblWebSiteLink.text == nil
        {
            constrainHeightForWebsiteLinkTitle.constant = 0
            constrainHeightForWebsiteLink.constant = 0
        }
        else
        {
            constrainHeightForWebsiteLinkTitle.constant = 17
            constrainHeightForWebsiteLink.constant = 21
        }
        ///Contact no
        
        var strContactNo = dicTenderDetail["contactNo"] as? String
        
        if strContactNo != nil && strContactNo?.hasPrefix("-") ?? false
        {
            strContactNo!.remove(at: strContactNo!.startIndex)
        }
        
        
        //check contact number has already prefix with "countryCode" or not
        if strContactNo != "" && strContactNo != nil
        {
            if strContactNo?.hasPrefix("+") ?? false
            {
                lblContactNo.text = "\(strContactNo ?? "")"
            }
            else
            {
                lblContactNo.text = "+\(strCountryCode )-\(strContactNo ?? "")"
            }
            //show contact number
            constrainHeightViewContactNo.constant = 31
        }
        else
        { //hide contyact number
            constrainHeightViewContactNo.constant = 0
        }
        
        
        
        
        ///landlineNo
        var strLandlineNo = dicTenderDetail["landlineNo"] as? String
        
        if strLandlineNo != nil && strLandlineNo?.hasPrefix("-") ?? false
        {
            strLandlineNo!.remove(at: strLandlineNo!.startIndex)
        }
        
        //check landline number has already prefix with "countryCode" or not
        if strLandlineNo != "" && strLandlineNo != nil
        {
            if strLandlineNo?.hasPrefix("+") ?? false
            {
                lblLandlineNumber.text = strLandlineNo
            }
            else
            {
                lblLandlineNumber.text = "+\(strCountryCode )-\(strLandlineNo ?? "")"
            }
            //show landline number
            constrainHeightViewLandline.constant = 31
        }
        else
        { //hide landline number
            constrainHeightViewLandline.constant = 0
        }
        
        ///Email
        lblEmail.text = dicTenderDetail["email"] as? String
        
        /// Address
        lblAddress.text = dicTenderDetail["address"] as? String
        
        if ((dicTenderDetail["address"] as? String) != "") && ((dicTenderDetail["address"] as? String) != nil)
            
        {
            constrainHeightViewAddress.constant = 31
        }
        else
        {
            constrainHeightViewAddress.constant = 0
        }
        
        /// isFollowTenderProcess
        if (dicTenderDetail["isFollowTender"] as? Bool ?? false)
        {
            constrainHeightViewFollowTenderProcess.constant = 31
        }
        else
        {
            constrainHeightViewFollowTenderProcess.constant = 0
        }
        
        
        /// isFollowTenderLink
        if (dicTenderDetail["isFollowTenderLink"] as? Bool ?? false)
        {
            constrainHeightViewFollowTenderLink.constant = 31
        }
        else
        {
            constrainHeightViewFollowTenderLink.constant = 0
        }
        
        //Favorite
        if utils.getUserType() == USER_CONTRACTOR
        {
            let arrFavorite =   dicTenderDetail["favorite"] as? [String]
            if arrFavorite?.count ?? 0 > 0
            {
                //if userID is in array that means user make tender favourite
                for id in arrFavorite!
                {
                    if id == utils.getLoginUserId()
                    {
                        btnRemove.setTitle("REMOVE FAVORITE", for: .normal)
                        break
                    }
                }
            }
            else
            {
                btnRemove.setTitle("FAVORITE", for: .normal)
            }
            
            
            let arrInterested =   dicTenderDetail["interested"] as? [String]
            if arrInterested?.count ?? 0 > 0
            {
                //if userID is in array that means user is Interested in Tender
                for id in arrInterested!
                {
                    if id == utils.getLoginUserId()
                    {
                        btnAmend.setTitle("REMOVE INTERESTED", for: .normal)
                        break
                    }
                }
                
            }
            else
            {
                btnAmend.setTitle("INTERESTED", for: .normal)
            }
        }
        
        
        
        
        
        self.view.layoutIfNeeded()
    }
    
    //MARK:- calculate days
    func calculateDaysBetweenTwoDates(strStartDate:String,strEndDate:String) -> Int{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.date(from: strStartDate)
        let endDate = dateFormatter.date(from: strEndDate)
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day], from: startDate!
            , to: endDate!)
        
        //include end date
        return components.day! + 1
        
    }
    //MARK:- table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblCategory
        {
            return arrCategoryData.count
        }
        else
        {
            return arrActiveInterestedContractors.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == tblCategory
        {
            let cell: CustomCategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCategoryTableViewCell", for: indexPath) as? CustomCategoryTableViewCell ?? CustomCategoryTableViewCell()
            let dicCategoryData = arrCategoryData[indexPath.row]
            cell.imgCategory.image = (dicCategoryData["imgString"] as? String)?.base64ToImage()
            cell.lblCategory.text = dicCategoryData["categoryName"] as? String
            return cell
        }
        else{
            let cell: TblInteresetedContractorCell = tableView.dequeueReusableCell(withIdentifier: "TblInteresetedContractorCell", for: indexPath) as? TblInteresetedContractorCell ?? TblInteresetedContractorCell()
            
            DispatchQueue.main.async {
                cell.viewBase.dropShadow(offsetX: 0, offsetY: 0, color: .black, opacity: 0.3, radius: 1.5)
            }
            
            let contractorDetail = arrActiveInterestedContractors[indexPath.row]
            cell.lblName.text = "Name:        \(contractorDetail["firstName"] ?? "") \(contractorDetail["lastName"] ?? "")"
            
            var strContactNo = contractorDetail["contactNo"] as? String
            
            if strContactNo != nil && strContactNo?.hasPrefix("-") ?? false
            {
                strContactNo!.remove(at: strContactNo!.startIndex)
            }
            
            cell.lblContact.text = "Contact:    \(strContactNo ?? "")"
            cell.lblEmail.text = "Email:         \(contractorDetail["email"] ?? "")"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblInterestedContractors
        {
            let contractorDetail = arrActiveInterestedContractors[indexPath.row]
            let   selectedSenderId = contractorDetail["_id"] as! String
            //Navigate to User Detail Screen
            guard let userDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UserDetailVC") as? UserDetailVC else { return }
            userDetailVC.selectedSenderId = selectedSenderId
            pushViewController(userDetailVC)
        }
    }
    
    //MARK:- mail compose
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        //           mailComposerVC.setToRecipients(["support@tenderwatch.com"])
        mailComposerVC.setSubject("Tender Details - \(dicTenderDetail["tenderName"] ?? "")")
        
        
        ///Country
        var arrSelectedCategoryName = [String]()
        let dicCountry = dicTenderDetail["country"] as? [String:Any]
        
        /// Category
        for dicCategory in arrCategoryData
        {
            arrSelectedCategoryName.append(dicCategory["categoryName"] as! String)
        }
        
        
        ///Target Contractor
        var targetContractor = ""
        let arrTargetViewers = dicTenderDetail["targetViewers"] as? [[String:Any]]
        if arrTargetViewers != nil
        {
            var arrTemp = [String]()
            for dicTargetViewers in arrTargetViewers!
            {
                arrTemp.append(dicTargetViewers["name"] as? String ?? "")
            }
            
            if arrTemp.count>0{
                targetContractor = arrTemp.map { String($0) }.joined(separator: ",")
            }
            else
            {
                targetContractor = ""
            }
        }
        
        /// expiry date including last date
        var finalExpiryDate  = ""
        let expiryDate = dicTenderDetail["expiryDate"] as? String
        let strDate = expiryDate?.components(separatedBy: "T")[0]
        if strDate != nil
        {
            let strCurrentDate = Date().formateDate(format: "YYYY-MM-dd")
            finalExpiryDate = "\(self.calculateDaysBetweenTwoDates(strStartDate: strCurrentDate, strEndDate: strDate!)) days"
        }
        
        
        //Tender photo
        var tenderPhoto = ""
        if (dicTenderDetail["tenderPhoto"] as? String == "no image" && dicTenderDetail["tenderPhoto"] as? String == ""){
            tenderPhoto = "no image"
        }
        
        let body = "Shared From www.tenderwatch.com\n\nShared By: \(dicTenderDetail["email"] as? String ?? "")\n\nTender Title:\(dicTenderDetail["tenderName"] as? String ?? "")\n\nCountry:\(dicCountry?["countryName"] as? String ?? "")\n\nCity:\(dicTenderDetail["city"] as? String ?? "")\n\nCategory:\(arrSelectedCategoryName.joined(separator: ","))\n\nTarget Contractor:\(targetContractor)\n\nExpiry Day:\(finalExpiryDate)\n\nDescription:\(dicTenderDetail["description"] as? String ?? "")\n\n\(dicTenderDetail["descriptionLink"] as? String ?? "")\n\nHow To Contact Client For This Tender:\n\nEmail:\(dicTenderDetail["email"] as? String ?? "")\n\nTender Photo:\(tenderPhoto)"
        
        
        mailComposerVC.setMessageBody("\(body)", isHTML: false)
        
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        showToast(title:"Your device could not send e-mail.  Please check e-mail configuration and try again.", duration: 1.0, position: .center)
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK:- convertToJsonString
    
    func convertToJsonString(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doGetTenderDetails{
            self.parseTenderDetailApiData(response: response)
        }
        
        if tagname == doGetInterestedContractor{
            self.parseInterestedContractorListApiData(response: response)
        }
        if tagname == doRemoveTender{
            self.parseRemoveTenderApiData(response: response)
        }
        if tagname == doSendDetailForRemoveTender{
            self.parseSendDetailAboutRemoveTenderApiData(response: response)
        }
        if tagname == doAddFavoriteTender{
            self.parseAddFavoriteTenderApiData(response: response)
        }
        if tagname == doRemoveFavoriteTender{
            self.parseRemoveFavoriteTenderApiData(response: response)
        }
        
        if tagname == doAddInterestTender{
            self.parseAddInterestTenderApiData(response: response)
        }
        
        if tagname == doRemoveInterestTender{
            self.parseRemoveInterestTenderApiData(response: response)
        }
        
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    
    //MARK:- API Calling
    func callTenderDetailApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let dicParameters = [String:String]()
            
            let webPath = "\(BASE_URL)\(TENDER_DETAIL_API)\(tenderDetailId)"
            //            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doGetTenderDetails, params: [:], headers: headers)
            serviceManager.callWebServiceWithGetWithHeaders(webpath: webPath, withTag: doGetTenderDetails, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseTenderDetailApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            print(dicResponseData)
            dicTenderDetail = dicResponseData
            
            DispatchQueue.main.async {
                self.setupData()
            }
        }
    }
    
    func callInterestedContractorListApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(TENDER_DETAIL_API)\(tenderDetailId)"
            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doGetInterestedContractor, params: [:], headers: headers)
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseInterestedContractorListApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            if let response = response as? [String:Any]{  // For contractor
                if "\(response["message"] ?? "")" == "contractor is not allowed to fetch tender list"
                {
                    self.constrainHeightLblInterestedContractorTitle.constant = 0
                    self.constrainHeightTblInterestedContractor.constant = 0
                    return
                }
            }
            
            guard let arrResponseData = response as? [[String:Any]] else {return}
            
            arrInterestedContractors = arrResponseData
            
            for contractor in arrInterestedContractors
            {
                print(contractor)
                
                if (contractor["isActive"] as? Bool ?? false)
                {
                    arrActiveInterestedContractors.append(contractor)
                }
            }
            
            DispatchQueue.main.async {
                self.tblInterestedContractors.reloadData()
                self.constrainHeightTblInterestedContractor.constant = CGFloat(self.arrActiveInterestedContractors.count * 66)
                
                if self.arrActiveInterestedContractors.count>0
                {
                    self.constrainHeightLblInterestedContractorTitle.constant = 32
                }
                else
                {
                    self.constrainHeightLblInterestedContractorTitle.constant = 0
                }
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func callRemoveTenderApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(REMOVE_TENDER_API)\(tenderDetailId)"
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doRemoveTender, params: [:], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    func parseRemoveTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            if dicResponseData["data"] as? Int == 1
            {
                let alert = UIAlertController(title: "Tender Watch", message:"Tender Removed!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { _ in
                    
                    //back to dash board
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.PopToViewController(specificVC: DashboardClientTenderListVC.self)
                    }
                    
                }
                alert.addAction(ok)
                self.present(alert, animated: true){}
            }
            
        }
    }
    
    func callSendDetailAboutRemoveTenderApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            
            ///Contractors
            var arrEmailsOfContractors = [[String:Any]]()
            for dic in arrInterestedContractors
            {
                var dicTemp = [String:Any]()
                dicTemp["_id"] = "\(dic["_id"] as? String ?? "")"
                dicTemp["email"] = "\(dic["email"] as? String ?? "")"
                
                arrEmailsOfContractors.append(dicTemp)
                
            }
            
            
            ///category
            var arrCategory = [String]()
            for dicCategory in arrCategoryData
            {
                arrCategory.append(dicCategory["categoryName"] as! String)
            }
            
            //Tender Uploader
            let dicTenderUploader = dicTenderDetail["tenderUploader"] as? [String:Any]
            let userName = "\(dicTenderUploader?["firstName"] ?? "") \(dicTenderUploader?["lastName"] ?? "")"
            
            let dicParameter = ["Email":arrEmailsOfContractors,
                                "Category":"\(arrCategory.joined(separator: " || "))",
                "TenderName":lblTenderTitle.text ?? "",
                "CountryName":countryName,
                "UserName":userName,
                "Operation" : "Remove"
                
                ] as [String : Any]
            
            print(dicParameter)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(SEND_DETAIL_ABOUT_REMOVE_TENDER_API)"
            
            serviceManager.callWebServiceWithPOSTWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doSendDetailForRemoveTender, params: dicParameter, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseSendDetailAboutRemoveTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            if dicResponseData["data"] as? Int == 1
            {
                //call api for remove tender
                self.callRemoveTenderApi()
            }
        }
    }
    
    
    func callAddFavoriteTenderApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(ADD_OR_REMOVE_FAVORITE_TENDER_API)\(tenderDetailId)"
            
            serviceManager.callWebServiceWithPutWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doAddFavoriteTender, params: [:], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseAddFavoriteTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            
            print(dicResponseData)
            if dicResponseData["data"] as? Int == 1
            {
                
                self.showToast(title: "Tender added to Favorite", duration: 1.0, position: .bottom)
                //added to favorite...change title of buttons
                btnRemove.setTitle("REMOVE FAVORITE", for: .normal)
            }
            else{
                showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
            }
        }
    }
    
    func callRemoveFavoriteTenderApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(ADD_OR_REMOVE_FAVORITE_TENDER_API)\(tenderDetailId)"
            
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doRemoveFavoriteTender, params: [:], headers: headers)
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseRemoveFavoriteTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            
            print(dicResponseData)
            if dicResponseData["data"] as? Int == 1
            {
                self.showToast(title: "Tender removed from Favorite", duration: 1.0, position: .bottom)
                
                //added to favorite...change title of buttons
                btnRemove.setTitle("FAVORITE", for: .normal)
            }
            else{
                showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
            }
        }
    }
    
    
    func callAddInterestTenderApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(ADD_OR_REMOVE_INTEREST_TENDER_API)\(tenderDetailId)"
            
            serviceManager.callWebServiceWithPutWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doAddInterestTender, params: [:], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseAddInterestTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            
            print(dicResponseData)
            if dicResponseData["data"] as? Int == 1
            {
                
                //added to interest...change title of buttons
                btnAmend.setTitle("REMOVE INTERESTED", for: .normal)
                
                //show alert
                showDefaultAlert(viewController: self, title: "Tender Watch", message: "We have notified the client about your interest in this Tender.\nTo pursue please continue with the process as specified in Tender Details")
                
            }
            else{
                showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
            }
        }
    }
    
    
    func callRemoveInterestTenderApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(ADD_OR_REMOVE_INTEREST_TENDER_API)\(tenderDetailId)"
            
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doRemoveInterestTender, params: [:], headers: headers)
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    func parseRemoveInterestTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            
            print(dicResponseData)
            if dicResponseData["data"] as? Int == 1
            {
                //removed from interest...change title of buttons
                btnAmend.setTitle("INTERESTED", for: .normal)
                
                //show alert
                showDefaultAlert(viewController: self, title: "Tender Watch", message: "You are no longer interested in this tender")
            }
            else{
                showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
            }
        }
    }
    
    
    //MARK:- btn click
    
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func sendEmailBtnPressed() {
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            //            self.showSendMailErrorAlert()
        }
    }
    
    
    @IBAction func btnWebsiteLinkClicked(_ sender: Any) {
        var link = "\(lblWebSiteLink.text ?? "")"
        if !(link.hasPrefix("http://") ||  link.hasPrefix("https://"))
        {
            link = "http://\(link)"
        }
        
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func btnContactNoClicked(_ sender: Any) {
        utils.callNumber(phoneNumber: lblContactNo.text ?? "")
    }
    
    @IBAction func btnLandlineNoClicked(_ sender: Any) {
        utils.callNumber(phoneNumber: lblLandlineNumber.text ?? "")
    }
    
    @IBAction func btnEmailClicked(_ sender: Any) {
    }
    
    
    @IBAction func btnFollowTenderProcessClicked(_ sender: Any) {
        
        let imageInfo   = GSImageInfo(image: imgProfile.image!, imageMode: .aspectFit)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo)
        navigationController?.pushViewController(imageViewer, animated: true)
        
    }
    
    @IBAction func btnFollowTenderLinkClicked(_ sender: Any) {
        var link = "\(lblWebSiteLink.text ?? "")"
        if !(link.hasPrefix("http://") ||  link.hasPrefix("https://"))
        {
            link = "http://\(link)"
        }
        
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func btnRemoveClicked(_ sender: Any) {
        
        
        if utils.getUserType() == USER_CONTRACTOR
        {
            if btnRemove.title(for: .normal) == "FAVORITE"
            {
                //add to favorite
                self.callAddFavoriteTenderApi()
            }
            else
            {
                //if already favorite then remove from favorite
                self.callRemoveFavoriteTenderApi()
            }
            
        }
        else
        {
            let alert = UIAlertController(title: "Tender Watch", message:"Tender will be completely removed from TenderWatch, Are you sure want to remove Tender?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "REMOVE", style: .default) { _ in
                
                if self.arrInterestedContractors.count > 0
                {
                    //call api for Notify interested contractor, that tender is removed
                    self.callSendDetailAboutRemoveTenderApi()
                }
                else
                { //call api for remove tender
                    self.callRemoveTenderApi()
                }
                
            }
            let cancle = UIAlertAction(title: "CANCEL", style: .cancel) { _ in }
            
            alert.addAction(cancle)
            alert.addAction(ok)
            self.present(alert, animated: true){}
        }
    }
    
    @IBAction func btnAmendClicked(_ sender: Any) {
        
        if utils.getUserType() == USER_CONTRACTOR
        {
            if btnAmend.title(for: .normal) == "INTERESTED"
            {
                //add to Interest
                self.callAddInterestTenderApi()
            }
            else
            {
                //if already interested then remove from interest
                self.callRemoveInterestTenderApi()
            }
        }
        else
        {
            
            guard let uploadTenderVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UploadTenderVC") as? UploadTenderVC else { return }
            uploadTenderVC.isComingForEditTender = true
            uploadTenderVC.tenderDetailId = tenderDetailId
            uploadTenderVC.dicSelectedTenderData = dicTenderDetail
            pushViewController(uploadTenderVC)
            
        }
        
    }
    
    @IBAction func btnClientDetailClicked(_ sender: Any) {
        
        let dicTenderUploader = dicTenderDetail["tenderUploader"] as? [String:Any]
        
        let   selectedSenderId = dicTenderUploader?["_id"] as! String
        //Navigate to User Detail Screen
        guard let userDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UserDetailVC") as? UserDetailVC else { return }
        userDetailVC.selectedSenderId = selectedSenderId
        pushViewController(userDetailVC)
    }
    
}
