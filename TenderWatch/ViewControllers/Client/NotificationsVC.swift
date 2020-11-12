//
//  NotificationsVC.swift
//  TenderWatch
//
//  Created by Bhumi Joshi on 08/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire

class NotificationsVC: BaseViewController,ServiceManagerDelegate {
    
    //MARK:- Outlets
    
    @IBOutlet weak var tblNotificationList: UITableView!
    @IBOutlet weak var constrainHeightViewEditOptions: NSLayoutConstraint!
    @IBOutlet weak var lblWarning: UILabel!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let componentManager = UIComponantManager()
    let doGetNotificationForClient = "do get notification for client"
    let doReadNotification = "do read Notification"
    let doDeleteNotification = "do delete Notification"
    var arrNotification = [[String:Any]]()
    var arrSelectedNotification = [[String:Any]]()
    let refreshControl = UIRefreshControl()
    var isPullToRefreshRunning  = false
    var isRightBarButtonEdit = true
    var selectedTenderId = ""
    var selectedSenderId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        self.setupSidemenu()
        
        serviceManager.delegate = self
        componentManager.registerTableViewCell(cellName: "TblNotificationCell", to:tblNotificationList)
        
        //remove extra seperator
        tblNotificationList.tableFooterView = UIView()
        
        
        //Open side menu from side
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        
        //hide editing options
        self.constrainHeightViewEditOptions.constant = 0
        
        self.callGetNotificationForClientApi()
    }
    
    //MARK:- setup Navigation Bar
    func setupNavigationBar() {
        self.setNavigationBarHeaderTitle(strTitle: "Notifications")
        self.addLeftBarButton()
        self.addRightBarButtonEdit()
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
    
    func addRightBarButtonEdit() {
        
        isRightBarButtonEdit = true
        
        //your custom view
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        
        let saveTitle = UILabel(frame: CGRect(x: 25, y: 5, width: 80, height: 30))
        saveTitle.text = "EDIT"
        saveTitle.textColor = UIColor.white
        view.addSubview(saveTitle)
        
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(editBtnPressed))
        view.addGestureRecognizer(saveTap)
        
        let rightBarButtonItem = UIBarButtonItem(customView: view )
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    func addRightBarButtonCancle() {
        
        isRightBarButtonEdit = false
        
        //your custom view
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        
        let saveTitle = UILabel(frame: CGRect(x: 25, y: 5, width: 80, height: 30))
        saveTitle.text = "CANCEL"
        saveTitle.textColor = UIColor.white
        view.addSubview(saveTitle)
        
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(editBtnPressed))
        view.addGestureRecognizer(saveTap)
        
        let rightBarButtonItem = UIBarButtonItem(customView: view )
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    
    //MARK:- btn click
    @objc func slideMenuPressed() {
        
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @objc func editBtnPressed() {
        if isRightBarButtonEdit {
            //Edit Button is present, Convert it in CANCEL button
            
            self.addRightBarButtonCancle()
            
            //show wdit option
            self.constrainHeightViewEditOptions.constant = 47
        }
        else
        {
            //CANCEL Button is present, Convert it in Edit button
            
            self.addRightBarButtonEdit()
            
            //hide edit option
            self.constrainHeightViewEditOptions.constant = 0
            
            //deselect all
            if arrSelectedNotification.count > 0
            {
                arrSelectedNotification.removeAll()
            }
            
        }
        
        tblNotificationList.reloadData()
        
        self.view.layoutIfNeeded()
        
        
        
    }
    
    @IBAction func btnSelectAllClicked(_ sender: Any) {
        
        if arrSelectedNotification.count == arrNotification.count
        {
            //deselect all
            if arrSelectedNotification.count > 0{
                arrSelectedNotification.removeAll()
            }
        }
        else
        {//select all
            arrSelectedNotification = arrNotification
        }
        tblNotificationList.reloadData()
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        
        if arrSelectedNotification.count > 0
        {
            self.callDeleteNotificationApi()
        }
        else
        {
            self.showToast(title: "Please select atleast one notification", duration: 1.0, position: .top)
        }
    }
    
    
    @objc func btnCheckClicked(_ sender: UIButton){
        
        let notification = arrNotification[sender.tag]
        
        let  arrTempToFindExistance = arrSelectedNotification.filter { ($0["_id"] as! String) == (notification["_id"] as! String) }.map { $0 }
        
        if arrTempToFindExistance.count == 0{
            arrSelectedNotification.append(notification)
            
        }
        else{
            
            let index =  arrSelectedNotification.firstIndex(where: { ($0["_id"] as! String) == (notification["_id"] as! String) })
            
            if arrSelectedNotification.count > 0
            {
                arrSelectedNotification.remove(at: index!)
            }
        }
        
        
        tblNotificationList.reloadData()
        
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
        if tagname == doGetNotificationForClient{
            self.parseGetNotificationForClientApiData(response: response)
        }
        
        if tagname == doReadNotification{
            self.parseReadNotificationApiData(response: response)
        }
        
        if tagname == doDeleteNotification{
            self.parseDeleteNotificationApiData(response: response)
        }
        
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        
        //reset flag
        isPullToRefreshRunning = false
        
        //stop pull to refresh
        refreshControl.endRefreshing()
        
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    
    //MARK:- API Calling
    func callGetNotificationForClientApi(){
        if utils.connected(){
            
            if !isPullToRefreshRunning {
                //show loader
                showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            }
            
            let webPath = "\(BASE_URL)\(GET_NOTIFICATION_API)"
            print(webPath)
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            serviceManager.callWebServiceWithGetWithHeaders(webpath: webPath, withTag: doGetNotificationForClient, headers: headers)
            
        }
        else{
            //reset flag
            isPullToRefreshRunning = false
            
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseGetNotificationForClientApiData(response:Any?){
        //reset flag
        isPullToRefreshRunning = false
        
        //stop pull to refresh
        refreshControl.endRefreshing()
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let arrResponseData = response as? [[String:Any]] else {return}
            arrNotification = arrResponseData
            
            arrSelectedNotification = [[String:Any]]()
            self.tblNotificationList.reloadData()
            
            var newNotificationCount = 0
            if arrNotification.count>0
            {
                //Count new Notification
                for dic in arrNotification
                {
                    if !((dic["read"]) as! Bool)
                    {
                        newNotificationCount += 1
                    }
                }
                
                //store notification count in preference
                utils.setNewNotificationCount(Count: newNotificationCount)
                //fire notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NEW_NOTIFICATION_COUNT), object: nil, userInfo: nil)
                
                //show table
                self.tblNotificationList.isHidden = false
                self.lblWarning.isHidden = true
            }
            else
            {
                //show warning
                self.tblNotificationList.isHidden = true
                self.lblWarning.isHidden = false
            }
        }
    }
    
    func callReadNotificationApi(notificationId:String){
        
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
            
            let webPath = "\(BASE_URL)\(READ_NOTIFICATION_API)\(notificationId)"
            
            serviceManager.callWebServiceWithPutWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doReadNotification, params: [:], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseReadNotificationApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            
            print(dicResponseData)
            if dicResponseData["data"] as? Int == 1
            {
                
                if utils.getUserType() == USER_CONTRACTOR
                {
                    if selectedTenderId != ""
                    {
                        guard let clientTenderDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ClientTenderDetailVC") as? ClientTenderDetailVC else { return }
                        clientTenderDetailVC.tenderDetailId  =  selectedTenderId
                        pushViewController(clientTenderDetailVC)
                    }
                    
                }
                else
                {
                    //Navigate to User Detail Screen
                    guard let userDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UserDetailVC") as? UserDetailVC else { return }
                    userDetailVC.selectedSenderId = selectedSenderId
                    pushViewController(userDetailVC)
                }
                
            }
            else{
                showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
            }
            
            //Call Get notification api for refresh List
            self.callGetNotificationForClientApi()
        }
    }
    
    
    func callDeleteNotificationApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var arrSelectedNotifiationIds = [String]()
            for dic in arrSelectedNotification
            {
                arrSelectedNotifiationIds.append("\(dic["_id"] ?? "")")
            }
            
            let dicParamerter = ["notification":"\(arrSelectedNotifiationIds.joined(separator: ",") )"]
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(DELETE_NOTIFICATION_API)"
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doDeleteNotification, params: dicParamerter, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseDeleteNotificationApiData(response:Any?){
        
        //hide loader
        hideLoader()
        guard let dicResponseData = response as? [String:Any] else {return}
        
        print(dicResponseData)
        if dicResponseData["data"] as? Int == 1
        {
            //deleted successfully
            print("notification deleted successfully")
            
        }
        else{
            //            showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
        }
        
        
        
        //Call Get notification api for refresh List
        self.callGetNotificationForClientApi()
    }
    
   
    
}

extension NotificationsVC : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotification.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblNotificationCell", for: indexPath) as! TblNotificationCell
        
        cell.btnCheck.tag = indexPath.row
        cell.btnCheck.addTarget(self, action: #selector(self.btnCheckClicked(_:)), for: .touchUpInside)
        
        DispatchQueue.main.async {
            if self.isRightBarButtonEdit {
                cell.constrainWidthBtnCheck.constant = 0
                cell.constrainLeadingImageViewProfile.constant = 0
            }
            else
            {
                cell.constrainWidthBtnCheck.constant = 30
                cell.constrainLeadingImageViewProfile.constant = 8
            }
            
            self.view.layoutIfNeeded()
        }
        
        if arrNotification.count > 0
        {
            
            let dicNotification = arrNotification[indexPath.row]
            
            if ((dicNotification["read"]) as! Bool)
            {
                cell.viewNotification.backgroundColor = UIColor.white
            }
            else
            {
                cell.viewNotification.backgroundColor = UIColor.lightGray
            }
            
            let  tenderPhoto = dicNotification["tenderPhoto"] as? String
            
            if tenderPhoto != "" && tenderPhoto != "no image"
            {
                cell.imageviewProfile.setImageWithActivityIndicator(imageURL: "\(tenderPhoto ?? "")", indicatorStyle: .gray, placeHolderImage: UIImage(named: "ic_avtar")!)
            }
            
            
            let expiryDate = dicNotification["createdAt"] as? String
            let strDate = expiryDate?.components(separatedBy: "T")[0]
            cell.txtNotificationDate.text = strDate
            
            let message = dicNotification["message"] as? String
            ///Modify color of string
            
            if message != nil
            {
                //seperate string which is in between ""
                let regex = try! NSRegularExpression(pattern:"\"(.*?)\"", options: [])
                var results = [String]()
                regex.enumerateMatches(in: message!, options: [], range: NSMakeRange(0, message!.utf16.count)) { result, flags, stop in
                    if let r = result?.range(at: 1), let range = Range(r, in: message!) {
                        results.append(String(message![range]))
                    }
                }
                print("res = \(results)")
                
                let attributedString = NSMutableAttributedString(string: message!,attributes: [NSAttributedString.Key.foregroundColor : UIColor.black] )
                
                //set color for string which is between ""
                for string in results
                {
                    let range = (message! as NSString).range(of: string)
                    
                    attributedString.setAttributes([NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "#00BCD4")], range: range)
                }
                //set color for email
                if let dicSender = dicNotification["sender"] as? [String:Any]
                {
                    let email = dicSender["email"] as? String
                    if email != nil{
                        let range = (message! as NSString).range(of: email ?? "")
                        attributedString.setAttributes([NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "#00BCD4")], range: range)
                    }
                }
                
                cell.txtNotificationTitle.attributedText = attributedString
                
            }
            
            // if value is in selected array then show tick
            let  arrTempToFindExistance = arrSelectedNotification.filter { ($0["_id"] as! String) == (dicNotification["_id"] as! String) }.map { $0 }
            
            if arrTempToFindExistance.count == 0{
                //Uncheck
                cell.btnCheck.setImage(UIImage(named: "ic_circleUnCheck"), for: .normal)
                //set tint color
                cell.btnCheck.tintColor = UIColor.gray
            }
            else
            {
                //check
                cell.btnCheck.setImage(UIImage(named: "ic_circleCheck"), for: .normal)
                //set tint color
                cell.btnCheck.tintColor = hexStringToUIColor(hex: "#4174B9")
            }
        }
        
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isRightBarButtonEdit
        {
            let dicNotification = arrNotification[indexPath.row]
            
            if let tenderId = dicNotification["tender"] as? String
            {
                selectedTenderId = "\(tenderId)"
                
                let dicUser = dicNotification["sender"] as? [String:Any]
                selectedSenderId = dicUser?["_id"] as! String
            }
            else
            {
                selectedTenderId = ""
                selectedSenderId = ""
            }
            
            self.callReadNotificationApi(notificationId: dicNotification["_id"] as? String ?? "")
            
        }
        
    }
    
}
