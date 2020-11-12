//
//  SubscriptionVC.swift
//  TenderWatch
//
//  Created by lcom on 01/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import SideMenu
import MXSegmentedControl

class SubscriptionVC: BaseViewController,ServiceManagerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var tblViewSubscription: UITableView!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var lblNoDataWarning: UILabel!
    @IBOutlet weak var segmentControl: MXSegmentedControl!
    
    //MARK:- Variables
    let utils = Utils()
    let componentManager = UIComponantManager()
    let serviceManager = ServiceManager()
    let doFetchSubscriptionInfo = "do Fetch Subscription Info for SubScriptionVC"
    var arrSubscriptionDetail = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        callSubscriptionDataAPI()
        tblViewSubscription.register(UINib(nibName: "TblSubscriptionCell", bundle: nil), forCellReuseIdentifier: "TblSubscriptionCell")
        
        //Custom SegmentControl UI
        segmentControl.append(title: "Subscription's")
        segmentControl.append(title: "Pending")
        segmentControl.textColor = lightGreenColor
        segmentControl.selectedTextColor = darkGreenColor
        segmentControl.indicatorColor = darkGreenColor
        segmentControl.indicatorHeight = 2.0
        segmentControl.font = UIFont.systemFont(ofSize: 17.0)
        
        pendingView.isHidden = true
        serviceManager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupNavigationBar()
    }
    
    //MARK:- Servicemanager Delegate Methods
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        
        if tagname == doFetchSubscriptionInfo{
            self.parseCategoryApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        print(error as Any)
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    func callSubscriptionDataAPI()
    {
        if utils.connected(){
            //show loader
            //                  showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
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
            
            let webPath = "\(BASE_URL)\(SUBSCRIPTION_DETAILS_API)"
            serviceManager.callWebServiceWithGetWithHeaders(webpath: webPath, withTag: doFetchSubscriptionInfo, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCategoryApiData(response:Any?){
        
        if response != nil
        {
            let dicResponseData = response as! [[String:Any]]
            print("=========")
            print(dicResponseData)
            arrSubscriptionDetail = dicResponseData
            
            
            tblViewSubscription.reloadData()
        }
    }
    
    
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = appColor
        self.setNavigationBarHeaderTitle(strTitle: "Subscription Detail")
        self.addLeftBarButton()
        self.addRightBarButton()
    }
    func setNavigationBarHeaderTitle(strTitle:String)
    {
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21)]
        
        SetNavigationBarTitle(string: strTitle)
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
    
    func addLeftBarButton() {
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
    
    // Navigation Bar : Right Bar Button
    func addRightBarButton() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: "plus_white"), for: .normal)
        button.addTarget(self, action: #selector(plusBtnPressed), for: UIControl.Event.touchUpInside)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.addSubview(button)
        let barButton = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    //MARK:- btn click
    @objc func slideMenuPressed() {
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    @objc func plusBtnPressed() {
        print("Plus Button Pressed")
        guard let subscriptionPlanVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as? SubscriptionPlanVC else { return }
        pushViewController(subscriptionPlanVC)
    }
    
    @IBAction func segmentIndexChanged(_ sender: Any) {
        switch segmentControl.selectedIndex {
        case 0:
            tblViewSubscription.isHidden = false
            pendingView.isHidden = true
            
            lblNoDataWarning.text = "Currently there are not found any subscription for this account"
            
            break
        case 1:
            tblViewSubscription.isHidden = true
            pendingView.isHidden = false
            lblNoDataWarning.text = "No Pending transaction's"
            break
        default:
            break
        }
    }
}


//MARK: - TableView Delegate & Datasource Methods
extension SubscriptionVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSubscriptionDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewSubscription.dequeueReusableCell(withIdentifier: "TblSubscriptionCell", for: indexPath) as! TblSubscriptionCell
        var tempDict = [String:Any]();
        tempDict = arrSubscriptionDetail[indexPath.row]
        cell.categoryArray = tempDict["categoryId"] as! [[String : Any]]
        tempDict = tempDict["countryId"] as! [String : Any]
        cell.imgViewCountry.image = base64Convert(base64String: (tempDict["imageString"] as! String) )
        cell.lblCountryName.text = (tempDict["countryName"] as! String)
        tempDict = arrSubscriptionDetail[indexPath.row]
        cell.HeightConstraintTblCategory.constant = CGFloat(cell.categoryArray.count * 50)
        if (tempDict["subscriptionTime"] as! String) == "1"
        {
            cell.lblSubscriptionTime.text = "Subscription Free"
        }
        else if (tempDict["subscriptionTime"] as! String)  == "2"
        {
            cell.lblSubscriptionTime.text = "Subscription Monthly"
        }
        else
        {
            cell.lblSubscriptionTime.text = "Subscription Yearly"
        }
        cell.tblViewCategoryList.reloadData()
        
        let expiryDate = tempDict["expiredAt"] as! String
        let strDate = expiryDate.components(separatedBy: "T")[0]
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        let date: Date? = dateFormatterGet.date(from: (strDate))
        
        
        
        cell.lblExpiryDate.text = "Expiration \n \(dateFormatterPrint.string(from: date!))"
        tempDict = tempDict["planType"] as! [String : Any]
        cell.lblPlanType.text = "Plan \n" + (tempDict["name"] as! String)
        return cell
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


