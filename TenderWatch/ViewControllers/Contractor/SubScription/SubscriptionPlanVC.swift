//
//  SubscriptionPlanVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 26/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class SubscriptionPlanVC: BaseViewController,ServiceManagerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    //MARK:- outlet
    
    @IBOutlet weak var lblSelectedPlanTitle: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblCountryList: UITableView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var constrainBottomBtnNext: NSLayoutConstraint!
    @IBOutlet var viewBaseSubscription: UIView!
    @IBOutlet weak var viewSubscription: UIView!
    @IBOutlet weak var viewFreeTrial: UIView!
    @IBOutlet weak var constrainHeightViewFreeTrial: NSLayoutConstraint!
    @IBOutlet weak var viewFreelancer: UIView!
    @IBOutlet weak var ConstrainTopViewFreelancer: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightViewFreelancerPlans
    : NSLayoutConstraint!
    
    @IBOutlet weak var constrainBottonViewFreelancerPlan: NSLayoutConstraint!
    @IBOutlet weak var viewFreelancerMonthlyPlan: UIView!
    @IBOutlet weak var lblFreelancerMonthlyPlan: UILabel!
    @IBOutlet weak var viewFreelancerYearlyPlan: UIView!
    @IBOutlet weak var lblFreelancerYearlyPlan: UILabel!
    
    
    @IBOutlet weak var viewCorporate: UIView!
    
    @IBOutlet weak var constrainHeightViewCorporatePlans: NSLayoutConstraint!
    @IBOutlet weak var constrainBottonViewCorporatePlan: NSLayoutConstraint!
    
    @IBOutlet weak var viewCorporateMonthlyPlan: UIView!
    @IBOutlet weak var lblCorporateMonthlyPlan: UILabel!
    
    @IBOutlet weak var viewCorporateYearlyPlan: UIView!
    
    @IBOutlet weak var lblCorporateYearlyPlan: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doFetchCountryList = "do fetch country list for SubscriptionPlanVC"
    let componentManager = UIComponantManager()
    var delegate : SelectCountyDelegate?
    var arrCountry = [[String:Any]]()
    var arrSectionTitle = [String]()
    var dicCountryList = [String:Any]()
    var dicFilterCountryList = [String:Any]()
    var dicSelectedCountry = [String:Any]()
    
    var tempSearchCountry : [[String:Any]] = []
    var selectCountry : [[String:Any]] = []
    var arrComonValues = [[String:Any]]()
    let doFetchCommonValues = "do Fetch Common Value Info for SubscriptionPlanVC"
    var isCommingFromRegistration = false
    var dicSelectedSubscriptionPlan = [String:Any]()
    var dicUserDataForSignUp = [String:Any]()
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        
        componentManager.registerTableViewCell(cellName: "CustomCountryTableViewCell", to: tblCountryList)
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        serviceManager.delegate = self
        searchBar.delegate = self
        
        //call api to get country data
        self.callCountryDataAPI()
        
        //call api to get subscription plan
        self.callCommonValueAPI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.showSubsriptionPlan()
     
    }
    
    //MARK:- setupUI
    func setupUI(){
        btnNext.cornerRadius = btnNext.Getheight/2
        btnCancel.cornerRadius = btnCancel.Getheight/2
        viewSubscription.cornerRadius = 8
        self.giveGrayBorder(view: viewFreeTrial)
        self.giveGrayBorder(view: viewFreelancer)
        self.giveGrayBorder(view: viewCorporate)
        self.giveGreenBorder(view: viewFreelancerMonthlyPlan)
        self.giveGreenBorder(view: viewFreelancerYearlyPlan)
        self.giveGreenBorder(view: viewCorporateMonthlyPlan)
        self.giveGreenBorder(view: viewCorporateYearlyPlan)
        
        //set observer to get height of keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    
        
        if isCommingFromRegistration
        {//show free trial
            
            self.showViewFreeTrial()
        }
        else{
            //hide free trial
            self.hideViewFreeTrial()
            
        }
    }
    
    func giveGrayBorder(view:UIView)
    {
        view.cornerRadius = 8
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.gray.cgColor
    }
    
    func giveGreenBorder(view:UIView)
    {
        view.cornerRadius = 8
        view.layer.borderWidth = 1.5
        view.layer.borderColor = hexStringToUIColor(hex: "#116327").cgColor
    }
    
    //MARK:- setup Navigation Bar
    func setupNavigationBar()
    {
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
    
    //MARK:- setup data
    func setupData()
    {
        if arrComonValues.count > 0
        {
            let dicFreelancer = arrComonValues[0]
            let dicPriceFreelancer = dicFreelancer["prices"]  as? [String:Any]
            lblFreelancerMonthlyPlan.text = "Monthly Subscription (\(dicPriceFreelancer?["monthly"] ?? "")$/Month)"
            lblFreelancerYearlyPlan.text = "Yearly Subscription (\(dicPriceFreelancer?["yearly"] ?? "")$/Year)"
            
            let dicCorporate = arrComonValues[1]
            let dicPriceCorporate = dicCorporate["prices"]  as? [String:Any]
            lblCorporateMonthlyPlan.text = "Monthly Subscription (\(dicPriceCorporate?["monthly"] ?? "")$/Month)"
            lblCorporateYearlyPlan.text = "Yearly Subscription (\(dicPriceCorporate?["yearly"] ?? "")$/Year)"
            
        }
    }
    
    //MARK:- select plan
    func selectPlan(btnTag:Int)
    {
        switch btnTag {
        case 1:
            let dicFreelancer = arrComonValues[0]
            let dicPriceFreelancer = dicFreelancer["prices"]  as? [String:Any]
            let price = "\(dicPriceFreelancer?["monthly"] ?? "")"
            lblSelectedPlanTitle.text = "\(price)$/Month"
            
            //store selected plan
            dicSelectedSubscriptionPlan["version"] = lblSelectedPlanTitle.text
            dicSelectedSubscriptionPlan["amount"] = price
            dicSelectedSubscriptionPlan["vat"] = "\(dicFreelancer["vat"] ?? "")"
            dicSelectedSubscriptionPlan["subscriptionType"] = "2"
            dicSelectedSubscriptionPlan["planType"] = "Monthly"
            dicSelectedSubscriptionPlan["planTitle"] = "Freelancer"
            dicSelectedSubscriptionPlan["_id"] = "\(dicFreelancer["_id"] ?? "")"
            
            break
            
        case 2:
            
            let dicFreelancer = arrComonValues[0]
            let dicPriceFreelancer = dicFreelancer["prices"]  as? [String:Any]
            let price = "\(dicPriceFreelancer?["yearly"] ?? "")"
            lblSelectedPlanTitle.text = "\(price)$/Year"
            
            //store selected plan
            dicSelectedSubscriptionPlan["version"] = lblSelectedPlanTitle.text
            dicSelectedSubscriptionPlan["amount"] = price
            dicSelectedSubscriptionPlan["vat"] = "\(dicFreelancer["vat"] ?? "")"
            dicSelectedSubscriptionPlan["subscriptionType"] = "3"
            dicSelectedSubscriptionPlan["planType"] = "Yearly"
            dicSelectedSubscriptionPlan["planTitle"] = "Freelancer"
            dicSelectedSubscriptionPlan["_id"] = "\(dicFreelancer["_id"] ?? "")"
            
            break
        case 3:
            
            let dicCorporate = arrComonValues[1]
            let dicPriceCorporate = dicCorporate["prices"]  as? [String:Any]
            let price = "\(dicPriceCorporate?["monthly"] ?? "")"
            lblSelectedPlanTitle.text = "\(price)$/Month"
            
            //store selected plan
            dicSelectedSubscriptionPlan["version"] = lblSelectedPlanTitle.text
            dicSelectedSubscriptionPlan["amount"] = price
            dicSelectedSubscriptionPlan["vat"] = "\(dicCorporate["vat"] ?? "")"
            dicSelectedSubscriptionPlan["subscriptionType"] = "2"
            dicSelectedSubscriptionPlan["planType"] = "Monthly"
            dicSelectedSubscriptionPlan["planTitle"] = "corporate"
            dicSelectedSubscriptionPlan["_id"] = "\(dicCorporate["_id"] ?? "")"
            
            break
            
        case 4:
            
            let dicCorporate = arrComonValues[1]
            let dicPriceCorporate = dicCorporate["prices"]  as? [String:Any]
            let price = "\(dicPriceCorporate?["yearly"] ?? "")"
            lblSelectedPlanTitle.text = "\(price)$/Year"
            
            //store selected plan
            dicSelectedSubscriptionPlan["version"] = lblSelectedPlanTitle.text
            dicSelectedSubscriptionPlan["amount"] = price
            dicSelectedSubscriptionPlan["vat"] = "\(dicCorporate["vat"] ?? "")"
            dicSelectedSubscriptionPlan["subscriptionType"] = "3"
            dicSelectedSubscriptionPlan["planType"] = "Yearly"
            dicSelectedSubscriptionPlan["planTitle"] = "corporate"
            dicSelectedSubscriptionPlan["_id"] = "\(dicCorporate["_id"] ?? "")"
            
            break
        default:
            break
        }
        
        
        print("selected plan data = \(dicSelectedSubscriptionPlan)")
        
    }
    
    //MARK:- view hide show
    
    func showSubsriptionPlan()
    {
        self.viewBaseSubscription.isHidden = false
        self.hideViewFreelancerPlan()
        self.hideViewCorporatePlan()
    }
    
    func hideSubsriptionPlan()
    {
        self.viewBaseSubscription.isHidden = true
        self.hideViewFreelancerPlan()
        self.hideViewCorporatePlan()
    }
    
    
    func showViewFreeTrial()
    {
        constrainHeightViewFreeTrial.constant = 41
        ConstrainTopViewFreelancer.constant = 8
        self.view.layoutIfNeeded()
    }
    func hideViewFreeTrial()
    {
        constrainHeightViewFreeTrial.constant = 0
        ConstrainTopViewFreelancer.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func showViewFreelancerPlan()
    {
        constrainHeightViewFreelancerPlans.constant = 90
        constrainBottonViewFreelancerPlan.constant = 8
        self.view.layoutIfNeeded()
    }
    
    func hideViewFreelancerPlan()
    {
        constrainHeightViewFreelancerPlans.constant = 0
        constrainBottonViewFreelancerPlan.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func showViewCorporatePlan()
    {
        constrainHeightViewCorporatePlans.constant = 90
        constrainBottonViewCorporatePlan.constant = 8
        self.view.layoutIfNeeded()
    }
    func hideViewCorporatePlan()
    {
        constrainHeightViewCorporatePlans.constant = 0
        constrainBottonViewCorporatePlan.constant = 0
        self.view.layoutIfNeeded()
    }
    
    
    //MARK:- keyboard event
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        DispatchQueue.main.async {
            self.constrainBottomBtnNext.constant = 20
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboard height = \(keyboardRect.height)")
            
            let safeAreaBottomInset = self.view.safeAreaInsets.bottom
            
            DispatchQueue.main.async {
                self.constrainBottomBtnNext.constant = (keyboardRect.size.height - safeAreaBottomInset + 20);
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK:- search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // This method updates filteredData based on the text in the Search Box
        
        if searchText == ""
        {
            dicFilterCountryList = dicCountryList
        }
        else
        {
            //empty previously loaded value
            dicFilterCountryList = [String:Any]()
            
            //load all Names for perticular Character ...for ex. if first character is "A" then load all country which names start from "A"
            let firstCharacter = String(searchText.prefix(1))
            let arrTemp = dicCountryList[firstCharacter] as? [[String:Any]]
            dicFilterCountryList[firstCharacter] = arrTemp
            
            //then search more from array value
            var arrTemp1 = dicFilterCountryList[firstCharacter] as? [[String:Any]]
            arrTemp1 = arrTemp1?.filter { ($0["countryName"] as! String).lowercased().contains(searchText.lowercased()) }.map { $0 }
            
            dicFilterCountryList[firstCharacter] = arrTemp1
        }
        
        //make section title list
        arrSectionTitle = dicFilterCountryList.map({ $0.key}).sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        self.tblCountryList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    //MARK:- Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return dicFilterCountryList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionTitle = arrSectionTitle[section]
        let arrSection = dicFilterCountryList [sectionTitle] as? [[String:Any]]
        
        return arrSection?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCountryTableViewCell", for: indexPath ) as! CustomCountryTableViewCell
        
        let sectionTitle = arrSectionTitle[indexPath.section]
        let arrSection = dicFilterCountryList[sectionTitle] as? [[String:Any]]
        
        cell.countryImg.image = (arrSection?[indexPath.row]["imageString"] as! String).base64ToImage()
        cell.contentMode = .scaleToFill
        cell.countryNameTxt.text = (arrSection?[indexPath.row]["countryName"] as! String)
        
        //hide show selection image
        //        if (arrSection?[indexPath.row]["countryName"] as? String) == (dicSelectedCountry["countryName"] as? String)
        //        {
        //            cell.imgSelected.isHidden = false
        //        }
        //        else
        //        {
        //            cell.imgSelected.isHidden = true
        //        }
        
        tempSearchCountry = selectCountry.filter { ($0["countryName"] as! String) == (arrSection?[indexPath.row]["countryName"] as! String) }.map { $0 }
        cell.imgSelected.isHidden = true
        
        if tempSearchCountry.count != 0
        {
            tempSearchCountry = []
            
            cell.imgSelected.isHidden = false
            
        }
        else
        {
            cell.imgSelected.isHidden = true
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return arrSectionTitle[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return arrSectionTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sectionTitle = arrSectionTitle[indexPath.section]
        let arrSection = dicFilterCountryList[sectionTitle] as? [[String:Any]]
        dicSelectedCountry = arrSection?[indexPath.row] ?? [String:Any]()
        self.tblCountryList.reloadData()
        
        tempSearchCountry = selectCountry.filter { ($0["countryName"] as! String) == (arrSection?[indexPath.row]["countryName"] as! String) }.map { $0 }
        if tempSearchCountry.count == 0
        {
            if lblSelectedPlanTitle.text == "Trial Version" && selectCountry.count == 1
            {
                showDefaultAlert(viewController: self, title: "Tender Watch", message: "During free trial period you can choose only 1 country")
            }
            else
            {
                 selectCountry.append(((arrSection?[indexPath.row])!))
            }
            
            
        }
        else
        {
            
            selectCountry.remove(at: selectCountry.firstIndex(where: { ($0["countryName"] as! String) == (tempSearchCountry[0]["countryName"] as! String)
            })!)
        }
        tblCountryList.reloadData()
    }
    
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doFetchCountryList{
            self.parseCountryApiData(response: response)
        }
        
        if tagname == doFetchCommonValues{
            self.parseCommonValueApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- Calling API
    
    func callCountryDataAPI()
    {
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let webPath = "\(BASE_URL)\(COUNTRY_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCountryList)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCountryApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let arrResponseData = response as! [[String:Any]]
            arrCountry = arrResponseData
            
            for dicCountryData in arrCountry{
                let countryName = dicCountryData["countryName"] as! String
                var firstCharacter = String(countryName.prefix(1))
                
                if firstCharacter == "Ã"
                {
                    firstCharacter = "A"
                }
                
                if dicCountryList[firstCharacter] != nil {
                    // now val is not nil and the Optional has been unwrapped, so use it
                    var arrTemp = dicCountryList[firstCharacter]  as? [[String:Any]]
                    arrTemp?.append(dicCountryData)
                    
                    //sort array according to "countryName"
                    arrTemp = (arrTemp! as NSArray).sortedArray(using: [NSSortDescriptor(key: "countryName", ascending: true)]) as? [[String:Any]]
                    
                    dicCountryList[firstCharacter] = arrTemp
                }
                else
                {
                    var arrTemp = [[String:Any]]()
                    arrTemp.append(dicCountryData)
                    dicCountryList[firstCharacter] = arrTemp
                }
            }
            
            dicFilterCountryList = dicCountryList
            //make section title list
            arrSectionTitle = dicCountryList.map({ $0.key}).sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            tblCountryList.reloadData()
            
        }
    }
    
    
    func callCommonValueAPI()
    {
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let webPath = "\(BASE_URL)\(COMMON_VALUE_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCommonValues)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseCommonValueApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let arrResponseData = response as! [[String:Any]]
            arrComonValues = arrResponseData
        }
        
        //setup data
        self.setupData()
        
    }
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnSelectedPlan(_ sender: Any) {
        self.showSubsriptionPlan()
    }
    @IBAction func btnNextClicked(_ sender: Any) {
        //sort array according to "countryName"
        selectCountry = (selectCountry as NSArray).sortedArray(using: [NSSortDescriptor(key: "countryName", ascending: true)]) as? [[String:Any]] ?? [[String:Any]]()
        
        if dicSelectedCountry.count == 0
        {
            let alert = UIAlertController(title: "Tender Watch", message:"Please choose one country", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { _ in }
            
            alert.addAction(ok)
            self.present(alert, animated: true){}
        }
            else  if selectCountry.count > 1 && lblSelectedPlanTitle?.text == "Trial Version"
                       {
                           showDefaultAlert(viewController: self, title: "Tender Watch", message: "During free trial period you can choose only 1 country")
                       }
        else
        {
            guard let categoryForSubScriptionVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "CategoryForSubScriptionVC") as? CategoryForSubScriptionVC else { return }
            categoryForSubScriptionVC.arrSelectCountry = selectCountry
            categoryForSubScriptionVC.dicSelectedSubscriptionPlan = dicSelectedSubscriptionPlan
            categoryForSubScriptionVC.isCommingFromRegistration = isCommingFromRegistration
            categoryForSubScriptionVC.dicUserDataForSignUp = dicUserDataForSignUp
            pushViewController(categoryForSubScriptionVC)
        }
    }
    
    @IBAction func btnFreeTrialClicked(_ sender: Any) {
        lblSelectedPlanTitle.text = "Trial Version"
        self.hideSubsriptionPlan()
        
        //store selected plan
        dicSelectedSubscriptionPlan["version"] = lblSelectedPlanTitle.text
        dicSelectedSubscriptionPlan["amount"] = "0"
        dicSelectedSubscriptionPlan["vat"] = "0"
        dicSelectedSubscriptionPlan["subscriptionType"] = "1"
        dicSelectedSubscriptionPlan["planType"] = "Free"
        dicSelectedSubscriptionPlan["planTitle"] = "Free Trial"
        
        print("selected plan data = \(dicSelectedSubscriptionPlan)")
    }
    
    @IBAction func btnFreelancerClicked(_ sender: Any) {
        
        self.hideViewCorporatePlan()
        
        if constrainHeightViewFreelancerPlans.constant == 0
        {
            self.showViewFreelancerPlan()
        }
        else
        {
            self.hideViewFreelancerPlan()
        }
    }
    
    @IBAction func btnFreelancerMonthlyPlanClicked(_ sender: UIButton) {
        self.selectPlan(btnTag: sender.tag)
        self.hideSubsriptionPlan()
    }
    
    @IBAction func btnFreelancerYearlyPlanClicked(_ sender: UIButton) {
        self.selectPlan(btnTag: sender.tag)
        self.hideSubsriptionPlan()
    }
    
    @IBAction func btnCorporateClicked(_ sender: Any) {
        self.hideViewFreelancerPlan()
        
        if constrainHeightViewCorporatePlans.constant == 0
        {
            self.showViewCorporatePlan()
        }
        else
        {
            self.hideViewCorporatePlan()
        }
    }
    
    @IBAction func btnCorporateMonthlyPlanClicked(_ sender: UIButton) {
        
        self.selectPlan(btnTag: sender.tag)
        self.hideSubsriptionPlan()
    }
    
    @IBAction func btnCorporateYearlyPlanClicked(_ sender: UIButton) {
        self.selectPlan(btnTag: sender.tag)
        self.hideSubsriptionPlan()
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.popViewController()
    }
    
}
