//
//  UploadTenderVC.swift
//  TenderWatch
//
//  Created by Bhumi Joshi on 28/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Photos
import SideMenu

class UploadTenderVC: BaseViewController ,ServiceManagerDelegate, UITextFieldDelegate , UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- Outlets
    
    @IBOutlet weak var contentviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var imageViewCountry: UIImageView!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var imageViewCategory: UIImageView!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var tableViewCategory: UITableView!
    @IBOutlet weak var categoryViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnTargetContractor: UIButton!
    @IBOutlet weak var imageViewTargetContractor: UIImageView!
    @IBOutlet weak var viewTargetContractor: UIView!
    @IBOutlet weak var tableViewTargetContractor: UITableView!
    @IBOutlet weak var targetcontaractorviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContactDetails: UIView!
    @IBOutlet weak var txtCountrySearch: UITextField!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblTelephone: UILabel!
    @IBOutlet weak var tableViewCountry: UITableView!
    @IBOutlet weak var imageViewTender: UIImageView!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var countryViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtTenderTitle: UITextField!
    @IBOutlet weak var txtWebsite: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtTelephone: UITextField!
    @IBOutlet weak var txtViewAddress: UITextView!
    @IBOutlet weak var btnCheckTenderImage: UIButton!
    @IBOutlet weak var btnCheckTenderDescription: UIButton!
    
    //MARK:- Variables
    
    var myPickerView : UIPickerView!
    var pickerDataCategory : [[String:Any]] = []
    var pickerDataCountry : [[String:Any]] = []
    var tempSearchCountry : [[String:Any]] = []
    var selectCategory : [[String:Any]] = []
    var selectedIsoCode = ""
    var selectedCountryId = ""
    var searchMode = false
    var pickerDataContractor = ["Freelancer" , "corporate" , "Everyone"];
    let utils = Utils()
    let componentManager = UIComponantManager()
    let phoneNumberKit = PhoneNumberKit()
    let serviceManager = ServiceManager()
    let doFetchCountryInfo = "do Fetch Country Info"
    let doFetchCategoryInfo = "do Fetch Category Info"
    let doPostTenderInfo = "do post Tender Info"
    let doUpdateTenderInfo = "do Update Tender Info"
    let doFetchCommonValues = "do Fetch Common Value Info"
    var isComingForEditTender = false
    var pickerImage = UIImagePickerController()
    var arrComonValues = [[String:Any]]()
    var tenderDetailId = ""
    var dicSelectedTenderData = [String:Any]()
    
    //MARK:- Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        
        //call API
        self.callCountryDataAPI()
        self.callCategoryDataAPI()
        self.callCommonValueAPI()
        componentManager.registerTableViewCell(cellName: "CustomCountryTableViewCell", to: tableViewCountry)
        componentManager.registerTableViewCell(cellName: "CustomCategoryTableViewCell", to: tableViewCategory)
        
        //        tableViewCountry.register(UINib(nibName: "CustomCountryTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCountryTableViewCell")
        //        tableViewCategory.register(UINib(nibName: "CustomCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCategoryTableViewCell")
        //        viewCountry.layer.borderWidth = 2
        let AMFunc = AMHelper()
        let color = UIColor(red: 217/255.00, green: 217/255.00, blue: 217/255.00, alpha: 1.00)
        AMFunc.setViewLayout(view: viewDescription, cornerRadius: 5, BorderColor: color , borderWidth: 2)
        DispatchQueue.main.async {
            self.imageViewTender.roundPerticularCorners(corners: [.allCorners], radius: 5, bordercolor: color, borderwidth: 2)
        }
        
        txtViewDescription.delegate = self
        txtViewDescription.text = "Tender Description"
        txtViewDescription.textColor = UIColor.lightGray
        txtViewAddress.delegate = self
        txtViewAddress.text = "Address"
        txtViewAddress.textColor = UIColor.lightGray
        serviceManager.delegate = self
        txtCountrySearch.delegate = self
        viewHeightConstraint.constant = 0
        contentviewHeightConstraint.constant = 200
        
        txtEmail.text = utils.getLoginUserEmail()
        
        //setup data
        if isComingForEditTender{
            
            //Open side menu from side
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
            
            self.setupData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        if isComingForEditTender
        {
            self.setNavigationBarHeaderTitle(strTitle: "Edit Tender")
        }
        else
        {
            self.setNavigationBarHeaderTitle(strTitle: "New Tender")
        }
        
        
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
        
        if isComingForEditTender
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
        else
        {
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
    }
    
    //MARK:- SetupData
    func setupData()
    {
        print("tenderData = \(dicSelectedTenderData)")
        
        ///Country
        let dicCountry = dicSelectedTenderData["country"] as? [String:Any]
        if dicCountry != nil
        {
            btnCountry.setTitle("\(dicCountry?["countryName"] ?? "")", for: .normal)
            selectedIsoCode = (dicCountry?["isoCode"] as! String)
            selectedCountryId = (dicCountry?["_id"] as! String)
            
            lblTelephone.text = "+" + " " + (dicCountry?["countryCode"] as! String) + " " + "-"
            lblMobile.text = "+" + " " + (dicCountry?["countryCode"] as! String) + " " + "-"
            
        }
        
        ///Category
        guard let arrCategory = dicSelectedTenderData["category"] as? [[String:Any]] else { return  }
        
        for category in arrCategory
        {
            let d = pickerDataCategory.filter{($0["_id"] as! String) == (category["_id"] as! String)}
            if d.count > 0
            {
                
                let  arrTempToFindExistance = selectCategory.filter { ($0["_id"] as! String) == (d[0]["_id"] as! String) }.map { $0 }
                
                if arrTempToFindExistance.count == 0{
                    selectCategory.append(d[0])
                }
                
            }
        }
        if selectCategory.count > 0
        {
            btnCategory.setTitle(selectCategory[0]["categoryName"] as? String, for: .normal)
        }
        
        ///Targete Contracor
        guard let arrViewers = dicSelectedTenderData["targetViewers"] as? [[String:Any]] else { return  }
        
        var arrTargetedViewer = [String]()
        for dicViewer in arrViewers
        {
            arrTargetedViewer.append(dicViewer["name"] as! String)
        }
        
        if arrTargetedViewer.count > 2
        {
            btnTargetContractor.setTitle("Everyone", for: .normal)
        }
        else
        {
            if  arrTargetedViewer[0].lowercased() == "corporate" {
                btnTargetContractor.setTitle("corporate", for: .normal)
            }
            else
            {
                btnTargetContractor.setTitle("Freelancer", for: .normal)
            }
        }
        
        ///City
        txtCity.text = dicSelectedTenderData["city"] as? String
        
        /// Tender Title
        txtTenderTitle.text = dicSelectedTenderData["tenderName"] as? String
        
        //Description
        txtViewDescription.text = dicSelectedTenderData["description"] as? String
        
        if txtViewDescription.text != "" && txtViewDescription.text != "Tender Description"
        {
            txtViewDescription.textColor = UIColor.black
        }
        
        ///WebsiteLink
        txtWebsite.text = dicSelectedTenderData["descriptionLink"] as? String
        
        ///Email
        txtEmail.text = dicSelectedTenderData["email"] as? String
        
        
        ///Mobile no
        let tempDialingCode = "\(lblMobile.text ?? "")".trim().replacingOccurrences(of: " ", with: "")
        
        var strContactNo = dicSelectedTenderData["contactNo"] as? String
        
        if strContactNo != nil && strContactNo?.hasPrefix("-") ?? false
        {
            strContactNo!.remove(at: strContactNo!.startIndex)
        }
        
        //check Mobile number has already prefix with "countryCode" or not
        if strContactNo != ""
        {
            if strContactNo?.hasPrefix("+") ?? false
            {
                strContactNo = strContactNo?.replacingOccurrences(of: tempDialingCode, with: "")
            }
            txtMobile.text = strContactNo
        }
        
        /// LandLine no
        var strLandlineNo = dicSelectedTenderData["landlineNo"] as? String
        
        if strLandlineNo != nil && strLandlineNo?.hasPrefix("-") ?? false
        {
            strLandlineNo!.remove(at: strLandlineNo!.startIndex)
        }
        
        //check Landline number has already prefix with "countryCode" or not
        if strLandlineNo != ""
        {
            if strLandlineNo?.hasPrefix("+") ?? false
            {
                strLandlineNo = strLandlineNo?.replacingOccurrences(of: tempDialingCode, with: "")
            }
            txtTelephone.text = strLandlineNo
        }
        
        ///Address
        txtViewAddress.text = dicSelectedTenderData["address"] as? String
        if txtViewAddress.text != "" && txtViewAddress.text != "Address"
        {
            txtViewAddress.textColor = UIColor.black
        }
        else
        {
            txtViewAddress.text = "Address"
        }
        
        /// Follow TEnder PRocess
        if dicSelectedTenderData["isFollowTender"] as? Int == 1
        {
            btnCheckTenderImage.setImage(UIImage(named: "ic_check"), for: .normal)
        }
        else
        {
            btnCheckTenderImage.setImage(UIImage(named: "ic_unCheck"), for: .normal)
        }
        
        
        ///Follow Tender Link
        if dicSelectedTenderData["isFollowTenderLink"] as? Int == 1
        {
            btnCheckTenderDescription.setImage(UIImage(named: "ic_check"), for: .normal)
        }
        else
        {
            btnCheckTenderDescription.setImage(UIImage(named: "ic_unCheck"), for: .normal)
        }
        
        ///Tender Photo
        let  tenderPhoto = dicSelectedTenderData["tenderPhoto"] as? String
        
        if tenderPhoto != "" && tenderPhoto != "no image"
        {
            imageViewTender.setImageWithActivityIndicator(imageURL: "\(tenderPhoto ?? "")", indicatorStyle: .gray, placeHolderImage: UIImage(named: "addImage")!)
        }
    }
    
    
    
    //MARK:- TextFiled Delegate
    
    
    @IBAction func searchcountry(_ sender: UITextField) {
        if sender == txtCountrySearch {
            searchMode = true
            tempSearchCountry = pickerDataCountry.filter { ($0["countryName"] as! String).lowercased().hasPrefix(txtCountrySearch.text ?? "") }.map { $0 }
            tableViewCountry.reloadData()
        }
    }
    
    //MARK:- TextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == txtViewDescription
            {
                textView.text = "Tender Description"
            }
            if textView == txtViewAddress
            {
                textView.text = "Address"
            }
            textView.textColor = UIColor.lightGray
        }
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
    
    //MARK:- Image picker delegate method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageViewTender.image = image
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissViewController()
    }
    
    //MARK:- Servicemanager Delegate Methods
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doFetchCountryInfo{
            self.parseCountryApiData(response: response)
        }
        if tagname == doFetchCategoryInfo{
            self.parseCategoryApiData(response: response)
        }
        if tagname == doPostTenderInfo{
            self.parseUploadTenderForClientApiData(response: response)
        }
        if tagname == doFetchCommonValues{
            self.parseCommonValueApiData(response: response)
        }
        if tagname == doUpdateTenderInfo{
            self.parseUpdateTenderForClientApiData(response:response)
        }
        
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        print(error as Any)
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- Calling API
    
    func callCountryDataAPI()
    {
        if utils.connected(){
            let webPath = "\(BASE_URL)\(COUNTRY_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCountryInfo)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCountryApiData(response:Any?){
        if response != nil
        {
            let dicResponseData = response as! [[String:Any]]
            
            for i in dicResponseData {
                
                pickerDataCountry.append(i)
                
            }
            tableViewCountry.reloadData()
        }
        
        //setup data
        if isComingForEditTender{
            self.setupData()
        }
        
    }
    
    func callCategoryDataAPI()
    {
        if utils.connected(){
            let webPath = "\(BASE_URL)\(TENDERCATEGORY_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCategoryInfo)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCategoryApiData(response:Any?){
        
        if response != nil
        {
            let dicResponseData = response as! [[String:Any]]
            
            for i in dicResponseData {
                
                pickerDataCategory.append(i)
            }
            tableViewCategory.reloadData()
            
        }
        
        //setup data
        if isComingForEditTender{
            self.setupData()
        }
    }
    
    
    func callCommonValueAPI()
    {
        if utils.connected(){
            let webPath = "\(BASE_URL)\(COMMON_VALUE_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCommonValues)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseCommonValueApiData(response:Any?){
        if response != nil
        {
            let arrResponseData = response as! [[String:Any]]
            arrComonValues = arrResponseData
        }
        
        //setup data
        if isComingForEditTender{
            self.setupData()
        }
    }
    
    func callUploadTenderForClientApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            ///Selected Category
            var arrCategory = [String]()
            for dicCategory in selectCategory
            {
                arrCategory.append(dicCategory["_id"] as! String)
            }
            /// Targeted Viewers
            var arrTargetedViewer = [String]()
            if btnTargetContractor.title(for: .normal) == "Everyone"{
                for dicViewer in arrComonValues
                {
                    arrTargetedViewer.append(dicViewer["_id"] as! String)
                }
            }
            else
            {
                for dicViewer in arrComonValues
                {
                    if (dicViewer["name"] as? String)?.lowercased() == (btnTargetContractor.title(for: .normal))?.lowercased()
                    {
                        arrTargetedViewer.append(dicViewer["_id"] as! String)
                    }
                }
            }
            
            /*      let dicParameter = ["tenderName":"\(txtTenderTitle.text ?? "")",
             "city":"\(txtCity.text ?? "")",
             "description":"\(txtViewDescription.text ?? "")",
             "descriptionLink":"\(txtWebsite.text ?? "")",
             "contactNo":"\(txtMobile.text ?? "")",
             "landlineNo":"\(txtTelephone.text ?? "")",
             "address":"\(txtViewAddress.text ?? "")",
             "country":selectedCountryId,
             "category":arrCategory,
             "isFollowTender":(btnCheckTenderImage.image(for: .normal) == UIImage(named: "ic_check")) ? "1":"0",
             "isFollowTenderLink":(btnCheckTenderDescription.image(for: .normal) == UIImage(named: "ic_check")) ? "1":"0",
             "targetViewers":arrTargetedViewer] as [String : Any]
             */
            
            ///Address
            var address = ""
            if txtViewAddress.text != "Address"{
                address = "\(txtViewAddress.text ?? "")"
            }
            
            
            let dicParameter = ["tenderName":"\(txtTenderTitle.text ?? "")",
                "city":"\(txtCity.text ?? "")",
                "description":"\(txtViewDescription.text ?? "")",
                "descriptionLink":"\(txtWebsite.text ?? "")",
                "contactNo":"\(txtMobile.text ?? "")",
                "landlineNo":"\(txtTelephone.text ?? "")",
                "address":address,
                "country":selectedCountryId,
                "category":arrCategory.joined(separator:","),
                "email": "\(txtEmail.text ?? "")",
                "isFollowTender":(btnCheckTenderImage.image(for: .normal) == UIImage(named: "ic_check")) ? "1":"0",
                "isFollowTenderLink":(btnCheckTenderDescription.image(for: .normal) == UIImage(named: "ic_check")) ? "1":"0",
                "targetViewers":self.convertToJsonString(from: arrTargetedViewer) ?? ""] as [String : Any]
            
            
            print("DicParameter = \(dicParameter)")
            
            let imgDataTenderImage = AttachmentViewModel()
            
            if !imageViewTender.image!.isEqualToImage(image: UIImage(named: "addImage")!)
            {
                imgDataTenderImage.Image = imageViewTender.image!
                imgDataTenderImage.ImageFileName = "image"
            }
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(UPLOADTENDER_API)"
            serviceManager.callWebServiceWithPostWithHeaders(webpath: webPath, withTag: doPostTenderInfo, params: dicParameter, imgArray: [imgDataTenderImage], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
        
    }
    
    func parseUploadTenderForClientApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            
            let alert = UIAlertController(title: "Tender Watch", message:"Your tender has been posted out to all potential Contractors. You will be notified when any Contractor is interested in your Tender", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { _ in
                //back to dash board
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.PopToViewController(specificVC: DashboardClientTenderListVC.self)
                }
            }
            
            alert.addAction(ok)
            self.present(alert, animated: true){}
            
        }
    }
    
    
    func callUpdateTenderForClientApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            ///Selected Category
            var arrCategory = [String]()
            for dicCategory in selectCategory
            {
                arrCategory.append(dicCategory["_id"] as! String)
            }
            /// Targeted Viewers
            var arrTargetedViewer = [String]()
            if btnTargetContractor.title(for: .normal) == "Everyone"{
                for dicViewer in arrComonValues
                {
                    arrTargetedViewer.append(dicViewer["_id"] as! String)
                }
            }
            else
            {
                for dicViewer in arrComonValues
                {
                    if (dicViewer["name"] as? String)?.lowercased() == (btnTargetContractor.title(for: .normal))?.lowercased()
                    {
                        arrTargetedViewer.append(dicViewer["_id"] as! String)
                    }
                }
            }
            
            ///Address
            var address = ""
            if txtViewAddress.text != "Address"{
                address = "\(txtViewAddress.text ?? "")"
            }
            
            
            let dicParameter = ["tenderName":"\(txtTenderTitle.text ?? "")",
                "city":"\(txtCity.text ?? "")",
                "description":"\(txtViewDescription.text ?? "")",
                "descriptionLink":"\(txtWebsite.text ?? "")",
                "contactNo":"\(txtMobile.text ?? "")",
                "landlineNo":"\(txtTelephone.text ?? "")",
                "address":address,
                "country":selectedCountryId,
                "category":arrCategory.joined(separator:","),
                "email": "\(txtEmail.text ?? "")",
                "isFollowTender":(btnCheckTenderImage.image(for: .normal) == UIImage(named: "ic_check")) ? "1":"0",
                "isFollowTenderLink":(btnCheckTenderDescription.image(for: .normal) == UIImage(named: "ic_check")) ? "1":"0",
                "targetViewers":self.convertToJsonString(from: arrTargetedViewer) ?? ""] as [String : Any]
            
            
            print("DicParameter = \(dicParameter)")
            
            let imgDataTenderImage = AttachmentViewModel()
            
            if !imageViewTender.image!.isEqualToImage(image: UIImage(named: "addImage")!)
            {
                imgDataTenderImage.Image = imageViewTender.image!
                imgDataTenderImage.ImageFileName = "image"
            }
            
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(UPDATE_TENDER_API)\(tenderDetailId)"
            
            
            if !imageViewTender.image!.isEqualToImage(image: UIImage(named: "addImage")!)
            { //With image
                serviceManager.callWebServiceWithPutWithHeaders(webpath: webPath, withTag: doUpdateTenderInfo, params: dicParameter, imgArray: [imgDataTenderImage], headers: headers)
            }
            else
            { //without image
                serviceManager.callWebServiceWithPutWithHeaders(webpath: webPath, withTag: doUpdateTenderInfo, params: dicParameter, imgArray: [], headers: headers)
            }
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseUpdateTenderForClientApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            
            
            let alert = UIAlertController(title: "Tender Watch", message:"Tender Amended Successfully!!!", preferredStyle: .alert)
            
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
    //MARK:- btn Click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func slideMenuPressed() {
        
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func btnCountry(_ sender: Any) {
        if(countryViewHeightConstraint.constant == 200)
        {
            contentviewHeightConstraint.constant = 200
            countryViewHeightConstraint.constant = 0
            viewCountry.isHidden = true
            
            imageViewCountry.image = UIImage(named: "Downarrow")
            
        }
        else {
            contentviewHeightConstraint.constant = 400
            categoryViewHeightConstraint.constant = 0
            viewCategory.isHidden = true
            imageViewCategory.image = UIImage(named: "Downarrow")
            targetcontaractorviewHeightConstraint.constant = 0
            viewTargetContractor.isHidden = true
            imageViewTargetContractor.image = UIImage(named: "Downarrow")
            countryViewHeightConstraint.constant = 200
            viewCountry.isHidden = false
            imageViewCountry.image = UIImage(named: "Uparrow")
        }
        
    }
    @IBAction func btnCategoryClick(_ sender: Any) {
        contentviewHeightConstraint.constant = 400
        targetcontaractorviewHeightConstraint.constant = 0
        viewTargetContractor.isHidden = true
        imageViewTargetContractor.image = UIImage(named: "Downarrow")
        countryViewHeightConstraint.constant = 0
        viewCountry.isHidden = true
        
        imageViewCountry.image = UIImage(named: "Downarrow")
        categoryViewHeightConstraint.constant = 200
        viewCategory.isHidden = false
        imageViewCategory.image = UIImage(named: "Uparrow")
    }
    @IBAction func btnDoneClick(_ sender: Any) {
        if selectCategory.count > 0
        {
            if  selectCategory.count == 1 {
                btnCategory.setTitle((selectCategory[0]["categoryName"] as! String), for: .normal)            }
            else
            {
                btnCategory.setTitle(String(selectCategory.count) +  " category selected", for: .normal)
            }
            categoryViewHeightConstraint.constant = 0
            viewCategory.isHidden = true
            imageViewCategory.image = UIImage(named: "Downarrow")
        }
    }
    @IBAction func btnTargetContactorClick(_ sender: Any) {
        contentviewHeightConstraint.constant = 400
        categoryViewHeightConstraint.constant = 0
        viewCategory.isHidden = true
        imageViewCategory.image = UIImage(named: "Downarrow")
        countryViewHeightConstraint.constant = 0
        viewCountry.isHidden = true
        
        imageViewCountry.image = UIImage(named: "Downarrow")
        targetcontaractorviewHeightConstraint.constant = 150
        viewTargetContractor.isHidden = false
        imageViewTargetContractor.image = UIImage(named: "Uparrow")
    }
    @IBAction func addImagebtn(_ sender: Any) {
        self.OpenActionSheet()
    }
    
    
    @IBAction func btnCheckClick(_ sender: UIButton) {
        
        if sender.image(for: .normal) == UIImage(named: "ic_unCheck")
        {
            sender.setImage(UIImage(named: "ic_check"), for: .normal)
        }
        else{
            sender.setImage(UIImage(named: "ic_unCheck"), for: .normal)
        }
    }
    @IBAction func btnSubmitContactDetailsClick(_ sender: Any) {
        
        if (txtEmail.text != "" || txtMobile.text != "" || txtTelephone.text != "" || txtViewAddress.text != "Address" )
        {
            
            if( phoneNumberKit.isValidPhoneNumber(txtMobile.text!, withRegion: selectedIsoCode, ignoreType: true) )
            {
                //Hide View
                viewHeightConstraint.constant = 0
                contentviewHeightConstraint.constant = 300
                self.view.layoutIfNeeded()
            }
            else{
                
                showToast(title: "Please Enter valid Number", duration: 1.0, position: .center)
            }
        }
        else{
            showToast(title: "You must enter on contact details", duration: 1.0, position: .center)
        }
        
    }
    @IBAction func btnUploadTenderClick(_ sender: Any) {
        if(btnCountry.titleLabel?.text != "Select Country")
        {
            if(btnCategory.titleLabel?.text != "Select Category")
            {
                if(btnTargetContractor.titleLabel?.text != "Target Contractor")
                {
                    if(txtCity.text != "")
                    {
                        if(txtTenderTitle.text != "")
                        {
                            if(txtViewDescription.text != "Tender Description" || txtWebsite.text != "" )
                            {
                                if isComingForEditTender
                                {//Update tender
                                    self.callUpdateTenderForClientApi()
                                }
                                else
                                { //Upload new tender
                                    self.callUploadTenderForClientApi()
                                }
                                
                            }
                            else{
                                
                                showToast(title: "Please Enter Details", duration: 1.0, position: .bottom)
                            }
                        }
                        else{
                            
                            showToast(title: "Please Enter Tender Title", duration: 1.0, position: .bottom)
                        }
                    }
                    else{
                        
                        showToast(title: "Please Enter City", duration: 1.0, position: .bottom)
                    }
                }
                else{
                    showToast(title: "Please Select Target Contractor", duration: 1.0, position: .bottom)
                }
            }
            else{
                showToast(title: "Please Select Category", duration: 1.0, position: .bottom)
            }
        }
        else
        {
            showToast(title: "Please Select Country", duration: 1.0, position: .bottom)
        }
    }
    
    @IBAction func tenderDetails(_ sender: Any) {
        //        print(btnCountry.titleLabel?.text!)
        if(btnCountry.titleLabel?.text == "Select Country")
        {
            let alert = UIAlertController(title: "Tender Watch", message: "First select Country and Category", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (ok) in
                
            }
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
        else{
            if (viewHeightConstraint.constant == 0)
            {
                contentviewHeightConstraint.constant = 800
                viewHeightConstraint.constant = 550
                contentviewHeightConstraint.constant = 1100
                viewContactDetails.layoutIfNeeded()
                viewContactDetails.isHidden = false
                let amt = AMHelper()
                amt.setViewLayout(view: viewContactDetails, cornerRadius: 10, BorderColor: UIColor.black, borderWidth: 2)
            }
            else
            {
                viewHeightConstraint.constant = 0
                contentviewHeightConstraint.constant = 300
            }
        }
    }
    
    
    //MARK:- convertToJsonString
    
    func convertToJsonString(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}

extension UploadTenderVC : UITableViewDelegate,UITableViewDataSource
{
    
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
    
    //MARK:- Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tableViewCountry)
        {
            if searchMode
            {
                return tempSearchCountry.count
            }
            
            return pickerDataCountry.count
        }
        else if tableView == tableViewCategory
        {
            return pickerDataCategory.count
        }
        return pickerDataContractor.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewCountry
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCountryTableViewCell", for: indexPath ) as! CustomCountryTableViewCell
            if searchMode
            {
                cell.countryImg.image = base64Convert(base64String: (tempSearchCountry[indexPath.row]["imageString"] as! String))
                cell.contentMode = .scaleToFill
                cell.countryNameTxt.text = (tempSearchCountry[indexPath.row]["countryName"] as! String)
                return cell
            }
            cell.countryImg.image = base64Convert(base64String: (pickerDataCountry[indexPath.row]["imageString"] as! String))
            cell.contentMode = .scaleToFill
            cell.countryNameTxt.text = (pickerDataCountry[indexPath.row]["countryName"] as! String)
            return cell
        }
        else if tableView == tableViewCategory
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCategoryTableViewCell", for: indexPath ) as! CustomCategoryTableViewCell
            cell.imgCategory.image = base64Convert(base64String: (pickerDataCategory[indexPath.row]["imgString"] as! String))
            cell.contentMode = .scaleToFill
            cell.lblCategory.text = (pickerDataCategory[indexPath.row]["categoryName"] as! String)
            tempSearchCountry = selectCategory.filter { ($0["categoryName"] as! String) == (pickerDataCategory[indexPath.row]["categoryName"] as! String) }.map { $0 }
            cell.imgSelected.isHidden = true
            cell.viewCategory.backgroundColor = UIColor.white
            if tempSearchCountry.count != 0
            {
                tempSearchCountry = []
                print(indexPath)
                
                cell.imgSelected.isHidden = false
                cell.viewCategory.backgroundColor = UIColor.lightGray
                
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "contractorcell")
        cell.textLabel!.text = pickerDataContractor[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewCountry
        {
            if searchMode
            {
                btnCountry.setTitle((tempSearchCountry[indexPath.row]["countryName"] as! String), for: .normal)
                lblTelephone.text = "+" + " " + (tempSearchCountry[indexPath.row]["countryCode"] as! String) + " " + "-"
                lblMobile.text = "+" + " " + (tempSearchCountry[indexPath.row]["countryCode"] as! String) + " " + "-"
                selectedIsoCode = (tempSearchCountry[indexPath.row]["isoCode"] as! String)
                selectedCountryId = (tempSearchCountry[indexPath.row]["_id"] as! String)
            }
            else
            {
                btnCountry.setTitle((pickerDataCountry[indexPath.row]["countryName"] as! String), for: .normal)
                lblTelephone.text = "+" + " " + (pickerDataCountry[indexPath.row]["countryCode"] as! String) + " " + "-"
                lblMobile.text = "+" + " " + (pickerDataCountry[indexPath.row]["countryCode"] as! String) + " " + "-"
                selectedIsoCode = (pickerDataCountry[indexPath.row]["isoCode"] as! String)
                
                selectedCountryId = (pickerDataCountry[indexPath.row]["_id"] as! String)
            }
            countryViewHeightConstraint.constant = 0
            viewCountry.isHidden = true
            imageViewCountry.image = UIImage(named: "Downarrow")
        }
        else if tableView == tableViewCategory
        {
            
            tempSearchCountry = selectCategory.filter { ($0["categoryName"] as! String) == (pickerDataCategory[indexPath.row]["categoryName"] as! String) }.map { $0 }
            if tempSearchCountry.count == 0
            {
                selectCategory.append((pickerDataCategory[indexPath.row]))
                
            }
            else
            {
                
                selectCategory.remove(at: selectCategory.firstIndex(where: { ($0["categoryName"] as! String) == (tempSearchCountry[0]["categoryName"] as! String)
                })!)
            }
            tableViewCategory.reloadData()
        }
        else{
            btnTargetContractor.setTitle(pickerDataContractor[indexPath.row], for: .normal)
            targetcontaractorviewHeightConstraint.constant = 0
            viewTargetContractor.isHidden = true
            imageViewTargetContractor.image = UIImage(named: "Downarrow")
        }
    }
}

extension UIImage {
    func isEqualToImage(image: UIImage) -> Bool {
        let data1: NSData = self.pngData()! as NSData
        let data2: NSData = image.pngData()! as NSData
        return data1.isEqual(data2)
    }
    
}
