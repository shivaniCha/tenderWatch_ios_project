//
//  SignUpDetailVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 28/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import AVKit
import Photos
import PhoneNumberKit
import SideMenu


class SignUpDetailVC: BaseViewController,UITextFieldDelegate,AboutMeTextDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SelectCountyDelegate,ServiceManagerDelegate {
    
    //MARK:- outlet
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var lblDialingCode: UILabel!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtOccupation: UITextField!
    @IBOutlet weak var txtAboutMe: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnRemoveAccount: UIButton!
    @IBOutlet weak var constrainHeightBtnRemoveAccount: NSLayoutConstraint!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    var strAboutMe = ""
    let doUpdateProfile = "do update profile"
    let doFetchCountryList = "do fetch country list for signup detail VC"
    let doRemoveAccount = "do remove account"
    var isCommingForUpdateProfile = false
    var strDialingCode = ""
    var dicUserDataForSignUp = [String:Any]()
    var pickerImage = UIImagePickerController()
    var selectedIsoCode = ""
    let phoneNumberKit = PhoneNumberKit()
    let doGetAllInterestedContractor = "do get Interested Contractor for SignUpDetailVC"
    let doSendDetailForRemoveAccount = "do Send Detail For Remove Account"
    var arrInterestedContractors = [[String:Any]]()
    
    
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //show navigation bar
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        if  isCommingForUpdateProfile {
            self.setupSidemenu()
            self.setupData()
            self.callAllInterestedContractorListApi()
        }
        
        serviceManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //MARK:- setupUI
    func setupUI(){
        imgProfile.cornerRadius = imgProfile.Getheight/2
        imgProfile.layer.borderColor  = UIColor.black.cgColor
        imgProfile.layer.borderWidth = 2
        btnNext.cornerRadius = btnNext.Getheight/2
        
        if isCommingForUpdateProfile
        {
            btnNext.setTitle("Update", for: .normal)
            //show remove account btn
            constrainHeightBtnRemoveAccount.constant = 35
        }
        else{
            btnNext.setTitle("Next", for: .normal)
            //hide remove account btn
            constrainHeightBtnRemoveAccount.constant = 0
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickImage(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        imgProfile.addGestureRecognizer(tapGesture)
        
    }
    
    
    func setupSidemenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sideMenuVC = storyboard.instantiateViewController(withIdentifier: "SideMenuVC")
        let menuLeftNavigationController = SideMenuNavigationController(rootViewController: sideMenuVC)
        menuLeftNavigationController.leftSide = true
        menuLeftNavigationController.navigationBar.isHidden = true
        menuLeftNavigationController.statusBarEndAlpha = 0
        menuLeftNavigationController.menuWidth = 300
        SideMenuManager.default.leftMenuNavigationController = menuLeftNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        
    }
    
    //MARK:- Setup Data
    func setupData(){
        guard let dicLoginUserData = utils.getLoginUserData() else {return}
        
        imgProfile.setImageWithActivityIndicator(imageURL: "\(dicLoginUserData["profilePhoto"] ?? "")", indicatorStyle: .gray , placeHolderImage: UIImage(named: "ic_avtar")!)
        txtFirstName.text = "\(dicLoginUserData["firstName"] ?? "")"
        txtLastName.text = "\(dicLoginUserData["lastName"] ?? "")"
        txtCountry.text = "\(dicLoginUserData["country"] ?? "")"
        txtMobileNumber.text = "\(dicLoginUserData["contactNo"] ?? "")"
        txtOccupation.text = "\(dicLoginUserData["occupation"] ?? "")"
        txtAboutMe.text = "\(dicLoginUserData["aboutMe"] ?? "")"
        
        //call country api for country data
        self.callCountryDataAPI()
    }
    
    //MARK:- setup Navigation Bar
    func setupNavigationBar()
    {
        self.addLeftBarButton()
        if isCommingForUpdateProfile{
            self.setNavigationBarHeaderTitle(strTitle: "Edit Profile")
            self.navigationController?.navigationBar.barTintColor = appColor
        }
        else
        {
            self.setNavigationBarHeaderTitle(strTitle: "")
            self.navigationController?.navigationBar.barTintColor = UIColor.white
        }
    }
    
    func setNavigationBarHeaderTitle(strTitle:String)
    {
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21)]
        
        SetNavigationBarTitle(string: strTitle)
    }
    
    func addLeftBarButton() {
        
        if isCommingForUpdateProfile{
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(named: "menu"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 1, bottom: 5, right: 1)
            button.addTarget(self, action: #selector(slideMenuPressed), for: UIControl.Event.touchUpInside)
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            view.addSubview(button)
            let barButton = UIBarButtonItem(customView: view)
            self.navigationItem.leftBarButtonItem = barButton
        }
        else
        {
            self.navigationItem.setHidesBackButton(true, animated:false)
            
            //your custom view for back image with custom size
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
            if let imgBackArrow = UIImage(named: "ic_back") {
                imageView.image = imgBackArrow
            }
            view.addSubview(imageView)
            
            let backTitle = UILabel(frame: CGRect(x: 25, y: 5, width: 80, height: 30))
            backTitle.text = "Back"
            view.addSubview(backTitle)
            
            let backTap = UITapGestureRecognizer(target: self, action: #selector(backBtnPressed))
            view.addGestureRecognizer(backTap)
            
            let leftBarButtonItem = UIBarButtonItem(customView: view )
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    }
    
    
    //MARK:- touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK:- text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtCountry{
            //navigate for select country
            guard let selectCountryVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SelectCountryVC") as?  SelectCountryVC else { return false}
            selectCountryVC.delegate = self
            pushViewController(selectCountryVC)
            return false
        }
        
        if textField == txtAboutMe{
            //navigate for enter About me
            guard let aboutMeVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "AboutMeVC") as?  AboutMeVC else { return false}
            aboutMeVC.delegate = self
            aboutMeVC.strAbout = txtAboutMe.text
            pushViewController(aboutMeVC)
            return false
        }
        
        if textField == txtMobileNumber{
            if Validation.isStringEmpty(txtCountry.text ?? "")
            {
                showToast(title: "First select country", duration: 1.0, position: .top)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    //navigate to select country
                    
                }
                
                return false
            }
        }
        
        return true
    }
    
    //MARK:- custom delegate method
    
    func getAboutMeText(strAboutMe: String) {
        
        self.strAboutMe = strAboutMe
        txtAboutMe.text = strAboutMe
    }
    func getSelectedCountryData(dicCountryData: [String : Any]) {
        
        lblDialingCode.text = "+\(dicCountryData["countryCode"] ?? "")"
        txtCountry.text = "\(dicCountryData["countryName"] ?? "")"
        selectedIsoCode = (dicCountryData["isoCode"] as! String)
    }
    
    
    //MARK:- pickImage
    @objc func pickImage(_ sender: UITapGestureRecognizer) {
        self.OpenActionSheet()
    }
    
    //MARK:- Camera and gallery permission
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
        })
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to capture photo for set theme.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func requestGalleryPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
            
        })
    }
    
    
    func alertGalleryAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Gallery Access",
            message: "Gallery access is required to get photo for set profile image.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Gallery Access", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    //MARK:- Open ActionSheet
    func OpenActionSheet()
    {
        let alert = UIAlertController(title: "Choose Photo", message: "Select method of input", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            
            self.OpenGallery()
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            self.OpenCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    
    func OpenCamera()
    {
        pickerImage = UIImagePickerController()
        pickerImage.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            //check permission
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                //already authorized, open camera
                pickerImage.sourceType = .camera
                self.present(self.pickerImage, animated: true)
            }
                
            else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                //request for camera permission
                self.requestCameraPermission()
                
            }
            else
            {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        //access allowed
                        self.pickerImage.sourceType = .camera
                        self.present(self.pickerImage, animated: true)
                        
                    } else {
                        //access denied or restricted
                        self.alertCameraAccessNeeded()
                    }
                })
            }
            
        } else {
            //if camera is not available then show alert
            let alert = UIAlertController(title: "Alert", message: "No Camera Available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
            }))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
    func OpenGallery()
    {
        //check user has allowed permission or not
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                
                DispatchQueue.main.async {
                    self.pickerImage = UIImagePickerController()
                    self.pickerImage.delegate = self
                    self.pickerImage.sourceType = .savedPhotosAlbum
                    self.present(self.pickerImage, animated: true)
                }
                
                
                break
            case .denied, .restricted:
                self.alertGalleryAccessNeeded()
                break
            case .notDetermined:
                self.requestGalleryPermission()
                break
            default:
                break
            }
        }
    }
    
    //MARK:- ImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //hide picker
        picker.dismiss(animated: true) {
            guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{ return}
            self.imgProfile.image = selectedImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissViewController()
    }
    
    
    //MARK:- Validate Data
    func isDataValid() -> Bool{
        var strError = ""
        
        if Validation.isStringEmpty(txtAboutMe.text ?? ""){
            strError = "Enter about me"
        }
        
        if Validation.isStringEmpty(txtOccupation.text ?? ""){
            strError = "Enter occupation"
        }
        
        if Validation.isStringEmpty(txtMobileNumber.text ?? ""){
            strError = "Enter mobile number"
        }
        else if( !phoneNumberKit.isValidPhoneNumber(txtMobileNumber.text ?? "", withRegion: selectedIsoCode, ignoreType: true) )
        {
            strError = "Enter valid mobile number"
        }
        
        if Validation.isStringEmpty(txtLastName.text ?? ""){
            strError = "Enter lastname"
        }
        if Validation.isStringEmpty(txtFirstName.text ?? ""){
            strError = "Enter firstname"
        }
        
        if Validation.isStringEmpty(txtCountry.text ?? ""){
            strError = "Enter country"
        }
        
        if strError != ""{
            showToast(title: strError, duration: 1.0, position: .top)
            return false
        }
        else
        {
            return true
        }
    }
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        
        if tagname == doFetchCountryList{
            self.parseCountryApiData(response: response)
        }
        
        if tagname == doUpdateProfile{
            self.parseUpdateProfileApiData(response: response)
        }
        
        if tagname == doSendDetailForRemoveAccount{
            self.parseSendDetailAboutRemoveAccountApiData(response: response)
        }
        
        
        if tagname == doGetAllInterestedContractor{
            self.parseAllInterestedContractorListData(response: response)
        }
        
        if tagname == doRemoveAccount{
            self.parseRemoveAccounApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    
    //MARK:- API Calling
    
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
                    
                    lblDialingCode.text = "+\(dicCountryData["countryCode"] ?? "") -"
                    selectedIsoCode = (dicCountryData["isoCode"] as! String)
                    
                    return
                }
            }
        }
    }
    
    
    func callUpdateProfileApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let dicParameters = [
                "firstName":"\(dicUserDataForSignUp["firstName"] ?? "")",
                "lastName":"\(dicUserDataForSignUp["lastName"] ?? "")",
                "country":"\(dicUserDataForSignUp["country"] ?? "")",
                "contactNo":"\(dicUserDataForSignUp["contactNo"] ?? "")",
                "occupation":"\(dicUserDataForSignUp["occupation"] ?? "")",
                "aboutMe":"\(dicUserDataForSignUp["aboutMe"] ?? "")",
                "androidDeviceId":"\(dicUserDataForSignUp["androidDeviceId"] ?? "")"]
            
            let model = AttachmentViewModel()
            model.ImageFileName = "image"
            model.Image = dicUserDataForSignUp["image"] as! UIImage
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            
            let webPath = "\(BASE_URL)\(UPDATE_PROFILE_API)\(utils.getLoginUserId())"
            serviceManager.callWebServiceWithPostWithHeaders(webpath: webPath, withTag: doUpdateProfile, params: dicParameters, imgArray: [model], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseUpdateProfileApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            var dicLoginUserData = utils.getLoginUserData()
            dicLoginUserData?["_id"] = dicResponseData?["_id"]
            dicLoginUserData?["profilePhoto"] = dicResponseData?["profilePhoto"]
            dicLoginUserData?["firstName"] = dicResponseData?["firstName"]
            dicLoginUserData?["lastName"] = dicResponseData?["lastName"]
            dicLoginUserData?["email"] = dicResponseData?["email"]
            dicLoginUserData?["country"] = dicResponseData?["country"]
            dicLoginUserData?["contactNo"] = dicResponseData?["contactNo"]
            dicLoginUserData?["occupation"] = dicResponseData?["occupation"]
            dicLoginUserData?["role"] = dicResponseData?["role"]
            dicLoginUserData?["aboutMe"] = dicResponseData?["aboutMe"]
            
            //save user data
            utils.setLoginUserData(data: dicLoginUserData!)
            
            //save user's id andemail id
            guard let id = dicLoginUserData?["_id"] else {return}
            utils.setLoginUserId(id: id as! String)
            guard let email = dicLoginUserData?["email"] else {return}
            utils.setLoginUserEmail(email: email as! String)
            
            // fire notification to indicate user data is upated
            NotificationCenter.default.post(name: Notification.Name(UPDATE_USER_DATA_NOTIFICATION), object: nil)
            
            self.showToast(title: "Profile is updated successfully", duration: 1.2, position: .top)
            
        }
    }
    
    
    func callAllInterestedContractorListApi(){
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
            
            let webPath = "\(BASE_URL)\(ALL_INTERESTED_CONTRACTOR_FOR_PROFILE_API)\(utils.getLoginUserId())"
            serviceManager.callWebServiceWithGetWithHeaders(webpath: webPath, withTag: doGetAllInterestedContractor, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseAllInterestedContractorListData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let arrResponseData = response as? [[String:Any]] else {return}
            
            arrInterestedContractors = arrResponseData
        }
    }
    
    
    func callSendDetailAboutRemoveAccountApi(){
        
        if utils.connected(){
            //show loader
            //                showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            ///Contractors
            var arrEmailsOfContractors = [[String:Any]]()
            for dic in arrInterestedContractors
            {
                var dicTemp = [String:Any]()
                dicTemp["_id"] = "\(dic["_id"] as? String ?? "")"
                dicTemp["email"] = "\(dic["email"] as? String ?? "")"
                
                arrEmailsOfContractors.append(dicTemp)
                
            }
            
            print(arrEmailsOfContractors)
            
            let userData = utils.getLoginUserData()
            let userName = "\(userData?["firstName"] ?? "") \(userData?["lastName"] ?? "")"
            
            //Tender Uploader
            //                let dicTenderUploader = dicTenderDetail["tenderUploader"] as? [String:Any]
            //                let userName = "\(dicTenderUploader?["firstName"] ?? "") \(dicTenderUploader?["lastName"] ?? "")"
            
            //
            //            let dicParameter = ["Email": "\(self.convertToJsonString(from: arrEmailsOfContractors) ?? "")",
            //                "Category":"\(arrCategory.joined(separator:","))",
            //                "TenderName":lblTenderTitle.text ?? "",
            //                "CountryName":lblCountryName.text ?? "",
            //                "UserName":userName,
            //                "Operation" : "Remove"
            //
            //            ]
            
            let dicParameter = ["Email":arrEmailsOfContractors,
                                "UserName":userName,
                                "Operation" : "Remove"
                
                ] as [String : Any]
            
            print(dicParameter)
            
            var autoraizationToken = ""
            
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)",
                "Content-Type" : "application/json;charset=UTF-8"
            ]
            
            let webPath = "\(BASE_URL)\(SEND_DETAIL_ABOUT_REMOVE_ACCOUNT_API)"
            
            serviceManager.callWebServiceWithPOSTWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doSendDetailForRemoveAccount, params: dicParameter, headers: headers)
            
            //            serviceManager.callWebServiceWithPutWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doSendDetailForRemoveAccount, params: dicParameter, headers: headers)
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
        
    }
    
    
    func parseSendDetailAboutRemoveAccountApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        guard let dicResponseData = response as? [String:Any] else {return}
        if dicResponseData["data"] as? Int == 1
        {
            //call api for remove account
            self.callRemoveAccountApi()
        }
        else
        {
            showToast(title: SOMETHING_WENT_WRONGE, duration: 1.0, position: .top)
        }
    }
    func callRemoveAccountApi(){
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
            
            let webPath = "\(BASE_URL)\(REMOVE_ACCOUNT_API)\(utils.getLoginUserId())"
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doRemoveAccount, params: [:], headers: headers)
            
            //            serviceManager.callWebServiceWithDeleteWithHeader(webpath: webPath, withTag: doRemoveAccount, params: [:], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseRemoveAccounApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            
            //remove user data
            utils.setLoginUserData(data:[:])
            
            //remove user's id andemail id
            utils.setLoginUserId(id: "")
            
            utils.setLoginUserEmail(email:"")
            
            self.showToast(title: "Profile is remove successfully", duration: 1.2, position: .top)
            
            
            ///navigate to "User SelectionVC"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                let userSelectionVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UserSelectionVC") as! UserSelectionVC
                self.pushViewController(userSelectionVC)
                
            }
        }
    }
    
    
    
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func slideMenuPressed() {
        
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        if isDataValid()
        {
            dicUserDataForSignUp["firstName"] = txtFirstName.text
            dicUserDataForSignUp["lastName"]  = txtLastName.text
            dicUserDataForSignUp["country"]   = txtCountry.text
            dicUserDataForSignUp["contactNo"] = "\(txtMobileNumber.text ?? "")"
            dicUserDataForSignUp["occupation"]   = txtOccupation.text
            dicUserDataForSignUp["aboutMe"]   = txtAboutMe.text
            dicUserDataForSignUp["role"]   = utils.getUserType()
            dicUserDataForSignUp["androidDeviceId"]   = utils.getFcmToken()
            dicUserDataForSignUp["image"]   = imgProfile.image
            
            print(dicUserDataForSignUp)
            
            if isCommingForUpdateProfile {
                self.callUpdateProfileApi()
            }
            else
            {
                //navigate to rules and regulation page
                guard let rulesAndRegulationVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "RulesAndRegulationVC") as? RulesAndRegulationVC else { return }
                //pass user data to upload on server
                rulesAndRegulationVC.dicUserDataForSignUp = dicUserDataForSignUp
                pushViewController(rulesAndRegulationVC)
            }
        }
    }
    
    @IBAction func btnRemoveAccountClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message:"Are you sure want to remove account from TenderWatch? This will permanently remove all your data and presence on TenderWatch?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "REMOVE", style: .default) { _ in
            
            //if there is any interested contractor then inform him
            if self.arrInterestedContractors.count > 0
            {
                self.callSendDetailAboutRemoveAccountApi()
            }
            else
            {
                //call api for remove account
                self.callRemoveAccountApi()
            }
            
        }
        let cancle = UIAlertAction(title: "CANCEL", style: .cancel) { _ in }
        
        alert.addAction(cancle)
        alert.addAction(ok)
        self.present(alert, animated: true){}
    }
}
