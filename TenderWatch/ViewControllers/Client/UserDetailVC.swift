//
//  UserDetailVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 23/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import Cosmos
import MessageUI

class UserDetailVC: BaseViewController,UITextFieldDelegate,ServiceManagerDelegate,MFMailComposeViewControllerDelegate {
    
    //MARK:- outlet
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblRatingInDigits: UILabel!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var txtCountry: UITextField!
    
    @IBOutlet weak var txtOccupation: UITextField!
    @IBOutlet weak var txtAboutMe: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var viewStarRating: CosmosView!
    
    @IBOutlet weak var lblReview: UILabel!
    
    @IBOutlet weak var viewAboutMeBase: UIView!
    @IBOutlet weak var lblAboutMe: UILabel!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doFetchUserDetail = "do fetch user Detail"
    let doFetchCountryList = "do Fetch Country List For User Detail VC"
    let doFetchCountryInfo = "do Fetch Country Info For User Detail VC"
    let doGiveReview = "do give review"
    var selectedSenderId = ""
    var givenRating = 0.0
    var newRating = 0.0
    let MFMailComposer = MFMailComposeViewController.self
    var selectedCountryCode = ""
    var dicUserDetails = [String:Any]()
    
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        
        DispatchQueue.main.async {
            self.setupUI()
            self.setupStarRating()
        }
        serviceManager.delegate = self
        
        self.callUserDetailDataAPI()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        viewAboutMeBase.isHidden = true
    }
    //MARK:- setupUI
    func setupUI(){
        imgProfile.cornerRadius = imgProfile.Getheight/2
        imgProfile.layer.borderColor  = UIColor.black.cgColor
        imgProfile.layer.borderWidth = 2
        btnSubmit.cornerRadius = btnSubmit.Getheight/2
        
        let tapOnAboutMe = UITapGestureRecognizer(target: self, action: #selector(hideAboutme))
        viewAboutMeBase.addGestureRecognizer(tapOnAboutMe)
        
    }
    
    //MARK:- hide About me
    @objc func hideAboutme()
    {
        viewAboutMeBase.isHidden = true
    }
    
    //MARK:- setup Navigation Bar
    func setupNavigationBar()
    {
        self.setNavigationBarHeaderTitle(strTitle: "User Detail")
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
    
    //MARK:- Star rating setup and method
    func setupStarRating(){
        
        viewStarRating.settings.fillMode = .half
        viewStarRating.rating = newRating
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        viewStarRating.didFinishTouchingCosmos = { rating in
            print(rating)
            
            self.newRating = rating
            self.calculateAvgRating(rating: self.newRating)
            
        }
    }
    
    //MARK:- setupdata
    func setUpdata(dicResponseData:[String:Any])
    {
        if (dicResponseData["tenderPhoto"] as? String != "no image" && dicResponseData["tenderPhoto"] as? String != ""){
            imgProfile.setImageWithActivityIndicator(imageURL: "\(dicResponseData["profilePhoto"] ?? "")", indicatorStyle: .gray, placeHolderImage: UIImage(named: "ic_avtar")!)
        }
        
        txtEmail.text = "\(dicResponseData["email"] ?? "")"
        
        var  strContactNo = "\(dicResponseData["contactNo"] ?? "")"
        if strContactNo != "" && strContactNo.hasPrefix("-")
        {
            strContactNo.remove(at: strContactNo.startIndex)
        }
        
        //check Mobile number has already prefix with "countryCode" or not
        if strContactNo != ""
        {
            if strContactNo.hasPrefix("+")
            {
                txtMobileNumber.text = strContactNo
            }
            else
            {
                txtMobileNumber.text = "+" + "\(selectedCountryCode)" + " " + strContactNo
            }
            
        }
        
        txtCountry.text = "\(dicResponseData["country"] ?? "")"
        txtOccupation.text = "\(dicResponseData["occupation"] ?? "")"
        
        lblAboutMe.text = "\(dicResponseData["aboutMe"] ?? "")"
        if lblAboutMe.text == ""
        {
            lblAboutMe.text = "No description available"
        }
        
        givenRating = dicResponseData["avg"] as? Double ?? 0.0
        lblRatingInDigits.text = "\(givenRating)/5.0"
        
        if let review  = dicResponseData["review"] as? [String:Any]
        {
            let rating = review["rating"] as? Double
            
            if rating !=  0 && rating !=  0.0
            {
                
                newRating = rating ?? 0.0
                
            }
            
            self.setupStarRating()
        }
    }
    
    //MARK:- text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtEmail{
            
            let mailComposeViewController = configuredMailComposeViewController()
            
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                //            self.showSendMailErrorAlert()
            }
        }
        
        
        if textField == txtMobileNumber{
            utils.callNumber(phoneNumber: txtMobileNumber.text ?? "")
        }
        
        if textField == txtAboutMe{
            viewAboutMeBase.isHidden = false
        }
        
        return false
    }
    
    
    //MARK:- Compose mail
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["\(txtEmail.text ?? "")"])
        
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        showToast(title:"Your device could not send e-mail.  Please check e-mail configuration and try again.", duration: 1.0, position: .center)
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSubmitClicked(_ sender: Any) {
        self.callGiveReviewAPI()
    }
    
    
    //MARK:- calculate avg rating
    func calculateAvgRating(rating:Double){
        
        if (rating < 1.1) {
            lblReview.text = "Poor"
            
        } else if (rating < 2.2) {
            lblReview.text = "Average"
            
        } else if (rating < 3.3) {
            lblReview.text = "Good"
            
        } else if (rating < 4.4) {
            lblReview.text = "Very Good"
            
        } else {
            lblReview.text = "Excellent"
            
        }
        
    }
    
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        
        if tagname == doFetchUserDetail{
            self.parseUserDetailApiData(response: response)
        }
        
        if tagname == doFetchCountryList{
            self.parseCountryApiData(response: response)
        }
        if tagname == doGiveReview{
            self.parseGiveReviewApiData(response: response)
        }
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    func callUserDetailDataAPI()
    {
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
            
            let webPath = "\(BASE_URL)\(USER_DETAIL_API)\(selectedSenderId)"
            serviceManager.callWebServiceWithGetWithHeaders(webpath: webPath, withTag: doFetchUserDetail, headers: headers)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseUserDetailApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as! [String:Any]
            print(dicResponseData)
            
            dicUserDetails = dicResponseData
            //setup user data
            self.setUpdata(dicResponseData: dicUserDetails)
            
            self.callCountryDataAPI()
            
        }
    }
    
    
    func callCountryDataAPI()
    {
        if utils.connected(){
            let webPath = "\(BASE_URL)\(COUNTRY_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCountryList)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCountryApiData(response:Any?){
        if response != nil
        {
            
            let arrResponseData = response as! [[String:Any]]
            for dicCountryData in arrResponseData
            {
                
                if "\(dicCountryData["countryName"] ?? "")" == txtCountry.text{
                    
                    print(dicCountryData)
                    imgCountry.image = (dicCountryData["imageString"] as! String).base64ToImage()
                    
                    selectedCountryCode = (dicCountryData["countryCode"] as! String)
                    break
                }
            }
            
            //refresh user data
            self.setUpdata(dicResponseData: dicUserDetails)
            
        }
    }
    
    
    func callGiveReviewAPI()
    {
        if utils.connected(){
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            
            let webPath = "\(BASE_URL)\(REVIEW_API)"
            
            let dicPara = ["user":selectedSenderId,
                           "rating":"\(newRating)"]
            
            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doGiveReview, params: dicPara, headers: headers)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseGiveReviewApiData(response:Any?){
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            let alert = UIAlertController(title: "Tender Watch", message:"Thank you for rating", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { _ in
                
            }
            
            alert.addAction(ok)
            self.present(alert, animated: true){}
            
        }
    }
}
