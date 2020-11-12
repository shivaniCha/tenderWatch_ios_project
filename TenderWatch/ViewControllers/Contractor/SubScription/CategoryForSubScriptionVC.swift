//
//  CategoryForSubScriptionVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 26/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class CategoryForSubScriptionVC: BaseViewController,ServiceManagerDelegate,UITextFieldDelegate , UITextViewDelegate  {
    
    //MARK:- Outlets
    
    @IBOutlet weak var lblSelectedPlanTitle: UILabel!
    
    @IBOutlet weak var tblCategory: UITableView!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var viewBaseConfirmPurchase: UIView!
    @IBOutlet weak var lblTotalAmout: UILabel!
    @IBOutlet weak var tblselectedSubscriptionList: UITableView!
    
    //MARK:- Variables
    var pickerDataCategory : [[String:Any]] = []
    var selectCategory : [[String:Any]] = []
    var tempSearchCategory : [[String:Any]] = []
    let utils = Utils()
    let componentManager = UIComponantManager()
    let serviceManager = ServiceManager()
    let doFetchCategoryInfo = "do Fetch Category Info for CategoryForSubScriptionVC"
    let doCheckService = "do check Service"
    let doSignUp = "do sign up from Category for subscription page"
    var arrSelectedSubscriptionList = [[String:Any]]()
    var arrSelectCountry : [[String:Any]] = []
    var dicSelectedSubscriptionPlan = [String:Any]()
    var arrSectionTitle = [String]()
    var arrSelectedSectionTitle = [String]()
    var dicAllCategoryWithCountry = [String:Any]()
    var dicSelectedCategoryWithCountry = [String:Any]()
    var subscriptionPrice = 0.0
    var totalSubscriptionPrice = 0.0
    var isCommingFromRegistration = false
    var dicCountryNameWithCountryId = [String:String]()
    var selectedIndexPathSection = 0
    var selectedIndexPathRow = 0
    var dicUserDataForSignUp = [String:Any]()
    
    //MARK:- Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        serviceManager.delegate = self
        componentManager.registerTableViewCell(cellName: "CustomCategoryTableViewCell", to: tblCategory)
        componentManager.registerTableViewCell(cellName: "tblSelectedSubscriptionListCell", to: tblselectedSubscriptionList)
        
        self.callCategoryDataAPI()
        btnNext.cornerRadius = btnNext.Getheight / 2
        
        self.setupData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setupNavigationBar()
        viewBaseConfirmPurchase.isHidden = true
    }
    
    
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.setNavigationBarHeaderTitle(strTitle: "")
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
    
    //MARK:- setupData
    func setupData()
    {
        
        //make section title
        for dic in arrSelectCountry
        {
            arrSectionTitle.append("\(dic["countryName"] ?? "")")
            
            dicSelectedCategoryWithCountry["\(dic["countryName"] ?? "")"] = [Any]()
            
            //set key value pair for countryName:CountryId
            dicCountryNameWithCountryId["\(dic["countryName"] ?? "")"] = "\(dic["_id"] ?? "")"
        }
        
        //show total value for subscription
        self.showTotalValueForSubcriptionInTitle(numberOfCategrySelected: 1)
    }
    
    
    func showTotalValueForSubcriptionInTitle(numberOfCategrySelected:Int){
        
        if "\(dicSelectedSubscriptionPlan["subscriptionType"] ?? "1")" == "1"
        { ///Free Trial
            lblSelectedPlanTitle.text = "Trial Version"
            subscriptionPrice = 0.0
            totalSubscriptionPrice = 0.0
            lblTotalAmout.text = "Total Amount 0.0$ + 0.0$ vat = 0.0$"
        }
        else/// Freelancer or Corporate
        {
            let price = Double("\(dicSelectedSubscriptionPlan["amount"] ?? "0")")
            subscriptionPrice = (price ?? 0.0) * Double(numberOfCategrySelected)
            
            let vat = Double("\(dicSelectedSubscriptionPlan["vat"] ?? "0")") ?? 0.0
            
            let totalVat = subscriptionPrice * (vat / 100.0)
            //            totalVat = Double(round(1000*totalVat)/1000)  //round up to two decimal number
            
            if "\(dicSelectedSubscriptionPlan["planType"] ?? "")" == "Monthly"
            {
                lblSelectedPlanTitle.text = "\(subscriptionPrice)$ / Month"
            }
            else
            {
                lblSelectedPlanTitle.text = "\(subscriptionPrice)$ / Year"
            }
            
            let vatInString = String(format: "%.2f", totalVat)
            totalSubscriptionPrice = subscriptionPrice + totalVat
            
            lblTotalAmout.text = "Total Amount \(subscriptionPrice)$ + \(vatInString)$ vat = \(totalSubscriptionPrice)$"
            
        }
        
    }
    
    func countTotalNumberOfCategorySelected() -> Int{
        //count total number of category selected
        var totalSelectedCategory  = 0
        for countryName in arrSectionTitle
        {
            let arrCountrywiseCategory = dicSelectedCategoryWithCountry[countryName] as? [Any]
            totalSelectedCategory += arrCountrywiseCategory?.count ?? 0
        }
        return totalSelectedCategory
    }
    
    //MARK:- convertToJsonString
    
    func convertToJsonString(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    //MARK:- Servicemanager Delegate Methods
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        
        if tagname == doFetchCategoryInfo{
            self.parseCategoryApiData(response: response)
        }
        if tagname == doCheckService{
            self.parseCheckserviceApiData(response: response)
        }
        if tagname == doSignUp{
            self.parseSignUpApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        print(error as Any)
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    
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
            
            pickerDataCategory = dicResponseData
            
            
            for countryName in arrSectionTitle
            {
                dicAllCategoryWithCountry[countryName] = pickerDataCategory
            }
            
            tblCategory.reloadData()
        }
    }
    
    
    func callCheckserviceAPI(countryId:String,categoryId:String)
    {
        if utils.connected(){
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            print(autoraizationToken);
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(CHECK_SERVICE_API)"
            let dicParameters = ["countryId":countryId,
                                 "category":categoryId]
            
            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doCheckService, params: dicParameters, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.5, position: .top)
        }
    }
    
    func parseCheckserviceApiData(response:Any?){
        
        tblCategory.reloadData()
        
        if response != nil
        {
            let dicResponseData = response as! [String:Any]
            print(dicResponseData)
            if dicResponseData["status"] as? Int == 0
            {
                showToast(title: "\(dicResponseData["message"] ?? "")", duration: 1.0, position: .top)
                
                print(selectedIndexPathSection)
                print(selectedIndexPathRow)
                //Remove Already exist category from list
                let sectionTitle = arrSectionTitle[selectedIndexPathSection]
                let arrSectionData = dicAllCategoryWithCountry[sectionTitle] as? [[String:Any]]
                
                var arrSelectedSectionData = dicSelectedCategoryWithCountry[sectionTitle] as? [[String:Any]]
                
                if arrSelectedSectionData?.count ?? 0 > 0
                {
                    tempSearchCategory = ((arrSelectedSectionData?.filter { ($0["categoryName"] as! String) == (arrSectionData?[selectedIndexPathRow]["categoryName"] as! String) }.map { $0 })! )
                    if tempSearchCategory.count > 0
                    {
                        arrSelectedSectionData!.remove(at: (arrSelectedSectionData?.firstIndex(where: { ($0["categoryName"] as! String) == (tempSearchCategory[0]["categoryName"] as! String)
                        })!)!)
                    }
                    
                }
                
                dicSelectedCategoryWithCountry[sectionTitle]  = arrSelectedSectionData
                
                tblCategory.reloadData()
                
                //compute and show total price for subscription
                self.showTotalValueForSubcriptionInTitle(numberOfCategrySelected: self.countTotalNumberOfCategorySelected())
                
                
            }
            
        }
    }
    
    
    func callSignUpApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let paypalInfo = dicSelectedSubscriptionPlan["paypalInfo"] as? [String:Any]
            let selections =  paypalInfo!["selections"]
            
            let dicParameters = ["email":"\(dicUserDataForSignUp["email"] ?? "")",
                "password":"\(dicUserDataForSignUp["password"] ?? "")",
                "firstName":"\(dicUserDataForSignUp["firstName"] ?? "")",
                "lastName":"\(dicUserDataForSignUp["lastName"] ?? "")",
                "country":"\(dicUserDataForSignUp["country"] ?? "")",
                "contactNo":"\(dicUserDataForSignUp["contactNo"] ?? "")",
                "occupation":"\(dicUserDataForSignUp["occupation"] ?? "")",
                "aboutMe":"\(dicUserDataForSignUp["aboutMe"] ?? "")",
                "role":"\(dicUserDataForSignUp["role"] ?? "")",
                "androidDeviceId":"\(dicUserDataForSignUp["androidDeviceId"] ?? "")",
                "loginToken":"\(dicUserDataForSignUp["loginToken"] ?? "")",
                "subscribe":"\(dicSelectedSubscriptionPlan["subscriptionType"] ?? "1")",
                "selections":self.convertToJsonString(from: selections!) ?? ""] as [String:Any]
            
            //            "selections":self.convertToJsonString(from: selections!) ?? ""
            print(dicParameters)
            
            let model = AttachmentViewModel()
            model.ImageFileName = "image"
            model.Image = dicUserDataForSignUp["image"] as! UIImage
            
            let webPath = "\(BASE_URL)\(SIGNUP_API)"
            serviceManager.callWebServiceWithPOST(webpath: webPath, withTag: doSignUp, params: dicParameters, imgArray: [model])
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseSignUpApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            
            var dicLoginUserData = [String:Any]()
            
            dicLoginUserData["token"] = dicResponseData?["token"]
            
            guard let dicUser = dicResponseData?["user"] as? [String:Any]  else {return}
            dicLoginUserData["_id"] = dicUser["_id"]
            dicLoginUserData["profilePhoto"] = dicUser["profilePhoto"]
            dicLoginUserData["firstName"] = dicUser["firstName"]
            dicLoginUserData["lastName"] = dicUser["lastName"]
            dicLoginUserData["email"] = dicUser["email"]
            dicLoginUserData["country"] = dicUser["country"]
            dicLoginUserData["contactNo"] = dicUser["contactNo"]
            dicLoginUserData["occupation"] = dicUser["occupation"]
            dicLoginUserData["role"] = dicUser["role"]
            dicLoginUserData["aboutMe"] = dicUser["aboutMe"]
            
            //save user data
            utils.setLoginUserData(data: dicLoginUserData)
            
            //save user's id and email id
            guard let id = dicUser["_id"] else {return}
            utils.setLoginUserId(id: id as! String)
            
            guard let email = dicUser["email"] else {return}
            utils.setLoginUserEmail(email: email as! String)
            
            // fire notification to indicate user data is upated
            NotificationCenter.default.post(name: Notification.Name(UPDATE_USER_DATA_NOTIFICATION), object: nil)
            
            if "\(dicSelectedSubscriptionPlan["subscriptionType"] ?? "1")" == "1"
            { ///Free Trial..so no need to go for payment process
                
                //Navigate to dashboard
                guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                pushViewController(dashboardClientTenderListVC)
                
            }
            else{
                //navigate for select payment method
                guard let paymentMethodSelectionVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "PaymentMethodSelectionVC") as? PaymentMethodSelectionVC else { return }
                paymentMethodSelectionVC.arrSelectCountry = arrSelectCountry
                paymentMethodSelectionVC.dicSelectedSubscriptionPlan = dicSelectedSubscriptionPlan
                paymentMethodSelectionVC.isCommingFromRegistration = isCommingFromRegistration
                pushViewController(paymentMethodSelectionVC)
            }
            
            
        }
    }
    //MARK:- btn Click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        
        var error = ""
        for title in arrSectionTitle
        {
            let arr = dicSelectedCategoryWithCountry[title] as? [Any]
            if arr?.count == 0
            {
                error = "Please select at least one category per country."
                break
            }
        }
        
        if error != ""{
            let alert = UIAlertController(title: "Tender Watch", message:error, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { _ in
                
            }
            
            alert.addAction(ok)
            self.present(alert, animated: true){}
        }
        else
        {
            tblselectedSubscriptionList.reloadData()
            viewBaseConfirmPurchase.isHidden = false
        }
    }
    
    @IBAction func btnContinueClicked(_ sender: Any) {
        var paypalInfo = [String:Any]()
        paypalInfo["planType"] = dicSelectedSubscriptionPlan["_id"]
        
        
        var dicSelections = [String:Any]()
        for countryName in arrSectionTitle
        {
            let arrSelectedCategoryData = dicSelectedCategoryWithCountry["\(countryName)"] as! [[String : Any]]
            
            var arrCategoryId = [String]()
            for dic in arrSelectedCategoryData
            {
                arrCategoryId.append("\(dic["_id"] ?? "")")
            }
            
            let countryId = dicCountryNameWithCountryId[countryName]!
            
            dicSelections[countryId] = arrCategoryId
        }
        
        paypalInfo["selections"] = dicSelections
        paypalInfo["subscriptionPackage"] = dicSelectedSubscriptionPlan["subscriptionType"]
        paypalInfo["register"] = isCommingFromRegistration ? "1":"0"
        
        dicSelectedSubscriptionPlan["paypalInfo"] = paypalInfo
        dicSelectedSubscriptionPlan["totalSubscriptionPrice"] = totalSubscriptionPrice
        
        
        if isCommingFromRegistration
        {
            self.callSignUpApi()
        }
        else
        {
            if "\(dicSelectedSubscriptionPlan["subscriptionType"] ?? "1")" == "1"
            { ///Free Trial..so no need to go for payment process
                
                //Navigate to dashboard
                guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                pushViewController(dashboardClientTenderListVC)
                
            }
            else{
                //navigate for select payment method
                guard let paymentMethodSelectionVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "PaymentMethodSelectionVC") as? PaymentMethodSelectionVC else { return }
                paymentMethodSelectionVC.arrSelectCountry = arrSelectCountry
                paymentMethodSelectionVC.dicSelectedSubscriptionPlan = dicSelectedSubscriptionPlan
                paymentMethodSelectionVC.isCommingFromRegistration = isCommingFromRegistration
                pushViewController(paymentMethodSelectionVC)
            }
        }
        
        
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        viewBaseConfirmPurchase.isHidden = true
    }
}

extension CategoryForSubScriptionVC : UITableViewDelegate,UITableViewDataSource
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
        
        if tableView == tblCategory
        {
            return dicAllCategoryWithCountry.count
        }
        else
        {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblCategory
        {
            let sectionTitle = arrSectionTitle[section]
            let arrTemp = dicAllCategoryWithCountry [sectionTitle] as? [[String:Any]]
            
            return arrTemp?.count ?? 0
        }
        else
        {
            return dicSelectedCategoryWithCountry.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblCategory
        {
            
            let sectionTitle = arrSectionTitle[indexPath.section]
            let arrSectionData = dicAllCategoryWithCountry[sectionTitle] as? [[String:Any]]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCategoryTableViewCell", for: indexPath ) as! CustomCategoryTableViewCell
            cell.imgCategory.image = base64Convert(base64String: (arrSectionData?[indexPath.row]["imgString"] as! String))
            cell.contentMode = .scaleToFill
            cell.lblCategory.text = (arrSectionData?[indexPath.row]["categoryName"] as! String)
            
            
            //show selected category
            let arrSelectedSectionData = dicSelectedCategoryWithCountry[sectionTitle] as? [[String:Any]]
            
            tempSearchCategory = ((arrSelectedSectionData?.filter { ($0["categoryName"] as! String) == (arrSectionData?[indexPath.row]["categoryName"] as! String) }.map { $0 })! )
            cell.imgSelected.isHidden = true
            cell.viewCategory.backgroundColor = UIColor.white
            if tempSearchCategory.count != 0
            {
                tempSearchCategory = []
                
                cell.imgSelected.isHidden = false
                cell.viewCategory.backgroundColor = UIColor.lightGray
                
            }
            
            return cell
            
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tblSelectedSubscriptionListCell", for: indexPath ) as! tblSelectedSubscriptionListCell
            cell.viewBase.cornerRadius = 5
            cell.viewBase.layer.borderColor = UIColor.lightGray.cgColor
            cell.viewBase.layer.borderWidth = 1
            
            cell.lblCountryName.text = arrSectionTitle[indexPath.row]
            if dicSelectedCategoryWithCountry.count > 0{
                cell.arrSelectedCategory = dicSelectedCategoryWithCountry["\(arrSectionTitle[indexPath.row])"] as! [[String : Any]]
                
                cell.constrainHeightTblSelectedCategory.constant = CGFloat(60 * cell.arrSelectedCategory.count)
            }
            cell.tblSelectedCategory.reloadData()
            
            if "\(dicSelectedSubscriptionPlan["subscriptionType"] ?? "1")" == "1"
            { ///Free Trial
                cell.lblSubscription.text = "Free"
                cell.lblPlan.text = "Free Version"
            }
            else
            { /// Freelancer or Corporate
                cell.lblSubscription.text = "\(dicSelectedSubscriptionPlan["planType"] ?? "")"
                cell.lblPlan.text = "\(dicSelectedSubscriptionPlan["planTitle"] ?? "")"
                
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if tableView == tblCategory
        {
            return arrSectionTitle[section]
        }
        else
        {
            return ""
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblCategory
        {
            
            selectedIndexPathSection = indexPath.section
            selectedIndexPathRow = indexPath.row
            
            
            let sectionTitle = arrSectionTitle[indexPath.section]
            let arrSectionData = dicAllCategoryWithCountry[sectionTitle] as? [[String:Any]]
            
            var arrSelectedSectionData = dicSelectedCategoryWithCountry[sectionTitle] as? [[String:Any]]
            
            if arrSelectedSectionData?.count ?? 0 > 0
            {
                tempSearchCategory = ((arrSelectedSectionData?.filter { ($0["categoryName"] as! String) == (arrSectionData?[indexPath.row]["categoryName"] as! String) }.map { $0 })! )
                if tempSearchCategory.count == 0
                {
                    if lblSelectedPlanTitle.text == "Trial Version" && self.countTotalNumberOfCategorySelected() == 1
                    {
                        showDefaultAlert(viewController: self, title: "Tender Watch", message: "During free trial period you can choose only 1 category")
                    }
                    else
                    {
                        arrSelectedSectionData?.append((arrSectionData?[indexPath.row])!)
                        
                        //cat id
                        let dicCategoryData = (arrSectionData?[indexPath.row])!
                        let categoryId = dicCategoryData["_id"]
                        let countryId = dicCountryNameWithCountryId[sectionTitle] ?? ""
                        
                        //Call api  to check for selected country and selected category, Does user already subscribe?
                        self.callCheckserviceAPI(countryId: countryId, categoryId: categoryId as! String)
                        
                    }
                }
                else
                {
                    arrSelectedSectionData!.remove(at: (arrSelectedSectionData?.firstIndex(where: { ($0["categoryName"] as! String) == (tempSearchCategory[0]["categoryName"] as! String)
                    })!)!)
                    
                }
            }
            else
            {
                arrSelectedSectionData = [[String:Any]]()
                arrSelectedSectionData?.append(arrSectionData![indexPath.row])
                
                
                print((arrSectionData?[indexPath.row])!)
                
                //cat id
                let dicCategoryData = (arrSectionData?[indexPath.row])!
                let categoryId = dicCategoryData["_id"]
                let countryId = dicCountryNameWithCountryId[sectionTitle] ?? ""
                
                //Call api  to check for selected country and selected category, Does user already subscribe?
                self.callCheckserviceAPI(countryId: countryId, categoryId: categoryId as! String)
                
            }
            
            dicSelectedCategoryWithCountry[sectionTitle]  = arrSelectedSectionData
            
            
            //compute and show total price for subscription
            self.showTotalValueForSubcriptionInTitle(numberOfCategrySelected: self.countTotalNumberOfCategorySelected())
            
        }
        else
        {
            
        }
    }
}
