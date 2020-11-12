//
//  SideMenuVC.swift
//  TenderWatch
//
//  Created by lcom on 28/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

class SideMenuVC: BaseViewController,ServiceManagerDelegate {
    //MARK:- outlet
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var tblViewSideMenu: UITableView!
    
    
    //MARK:- Variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doLogOut = "do Log out"
    var imageIconsArray = ["home", "upload", "userthree", "password", "bell", "support", "logout"]
    var namesArray = ["Home", "Upload Tender", "Edit Profile", "Change Password", "Notifications", "Contact Support Team", "Logout"]
    
    
    ///MARK:- view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if utils.getUserType() == USER_CLIENT
        {
            imageIconsArray = ["home", "upload", "userthree", "password", "bell", "support", "logout"]
            namesArray = ["Home", "Upload Tender", "Edit Profile", "Change Password", "Notifications", "Contact Support Team", "Logout"]
        }
        else
        {
            imageIconsArray = ["home", "dollar", "userthree", "password", "fav","bell", "support", "logout"]
            namesArray = ["Home", "Subscription Details", "Edit Profile", "Change Password","Favorites", "Notifications", "Contact Support Team", "Logout"]
        }
        
        
        
        //Set Corner Radius To Profile Imageview
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.size.width / 2
        imgViewProfile.clipsToBounds = true
        
        tblViewSideMenu.register(UINib(nibName: "TblSideMenuCell", bundle: nil), forCellReuseIdentifier: "TblSideMenuCell")
        
        self.UserDataIsUpdated()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserDataIsUpdated), name:  Notification.Name(UPDATE_USER_DATA_NOTIFICATION), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newNotificationCountUpdated(_:)), name:  Notification.Name(NEW_NOTIFICATION_COUNT), object: nil)
        
        serviceManager.delegate = self
        
    }
    
    @objc func UserDataIsUpdated() {
        
        let dicLoginUserData = utils.getLoginUserData()
        imgViewProfile.setImageWithActivityIndicator(imageURL: "\(dicLoginUserData?["profilePhoto"] ?? "")", indicatorStyle: .gray, placeHolderImage: UIImage(named: "ic_avtar")!)
        lblEmailId.text = utils.getLoginUserEmail()
        
    }
    
    @objc func newNotificationCountUpdated(_ notification: NSNotification) {
        
        if let notificationCount = notification.userInfo?["notification"] as? Int {
            // do something with your image
        }
        
        tblViewSideMenu.reloadData()
        
    }
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doLogOut{
            self.parseLogOutApiData(response: response)
        }
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    
    //MARK:- API Calling
    func callLogOutApi(){
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
                "Authorization": "Bearer \(autoraizationToken)",
                
            ]
            
            let dicParameters = ["role":utils.getUserType(),
                                 "androidDeviceId": "\(utils.getFcmToken())"]
            
            let webPath = "\(BASE_URL)\(LOGOUT_API)"
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doLogOut, params: dicParameters, headers: headers)
            
            //            serviceManager.callWebServiceWithDeleteWithHeader(webpath: webPath, withTag: doLogOut, params: dicParameters, headers: headers)
            //            self.restRequest(url: webPath, method: "DELETE", params: dicParameters, headers: headers, completion: { (result) in
            //                 print("result = \(result)")
            //            })
            
            //            DispatchQueue.main.async {
            //                self.deleteRequest(url: webPath, params: dicParameters, headers: headers) { (result) in
            //
            //                          }
            //            }
            //
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    func parseLogOutApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            print(dicResponseData)
            
            //remove all Login user data
            utils.setLoginUserData(data: nil)
            utils.setLoginUserId(id: "")
            utils.setLoginUserEmail(email: "")
            utils.setNewNotificationCount(Count: 0)
            
            //back to User Selection
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let userSelectionVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UserSelectionVC") as! UserSelectionVC
                self.pushViewController(userSelectionVC)
                
            }
            
        }
    }
    
    func deleteRequest(url:String, params: [String: String],headers:[String:String], completion: @escaping ([AnyObject])->() ){
        let parameters = params
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        //        request.addValue(["application/x-www-form-urlencoded","application/json; charset=utf-8"], forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")  // the request is JSON
        
        request.addValue("\(headers["Authorization"] ?? "")", forHTTPHeaderField: "Authorization")
        
        
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject:parameters, options: []) else { return }
        request.httpBody = httpBody
        //        request.setValue((httpBody.count), forHTTPHeaderField: "Content-Length")
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            //hide loader
            self.hideLoader()
            
            if let data = data {
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
        
    }
    
    
    func restRequest(url:String, method: String, params: [String: String],headers:[String:String], completion: @escaping ([AnyObject])->() ){
        if let nsURL = NSURL(string:url) {
            let request = NSMutableURLRequest(url: nsURL as URL)
            if method == "POST" {
                // convert key, value pairs into param string
                let postString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                request.httpMethod = "POST"
                request.httpBody = postString.data(using: String.Encoding.utf8)
            }
            else if method == "GET" {
                let postString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                request.httpMethod = "GET"
            }
            else if method == "PUT" {
                let putString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                request.httpMethod = "PUT"
                request.httpBody = putString.data(using: String.Encoding.utf8)
            }
            else if method == "DELETE" {
                let putString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                request.allHTTPHeaderFields = headers
                request.httpMethod = "DELETE"
                request.httpBody = putString.data(using: String.Encoding.utf8)
            }
            // Add other verbs here
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                (data, response, error) in
                do {
                    
                    // what happens if error is not nil?
                    // That means something went wrong.
                    
                    // Make sure there really is some data
                    if let data = data {
                        let response = try JSONSerialization.jsonObject(with: data, options:  JSONSerialization.ReadingOptions.mutableContainers)
                        completion(response as! [AnyObject])
                    }
                    else {
                        // Data is nil.
                    }
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
        else{
            // Could not make url. Is the url bad?
            // You could call the completion handler (callback) here with some value indicating an error
        }
    }
    
}


//MARK: - TableView Delegate & Datasource Methods
extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewSideMenu.dequeueReusableCell(withIdentifier: "TblSideMenuCell", for: indexPath) as! TblSideMenuCell
        cell.lblName.text = namesArray[indexPath.row]
        cell.imgViewIcon.image = UIImage(named: imageIconsArray[indexPath.row])
        
        DispatchQueue.main.async {
              cell.lblNewNotificationCount.cornerRadius = cell.lblNewNotificationCount.Getheight / 2
            self.view.layoutIfNeeded()
        }
      
        
        if cell.lblName.text == "Notifications" && utils.getNewNotificationCount() ?? 0 > 0
        {
            cell.constrainWidthLblNewNotificationCount.constant = 30
            cell.lblNewNotificationCount.text = "\(utils.getNewNotificationCount() ?? 0)"
            
        }
        else
        {
            cell.constrainWidthLblNewNotificationCount.constant = 0
            cell.lblNewNotificationCount.text = "0"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if utils.getUserType() == USER_CLIENT
        {
            /// CLIENT
            switch indexPath.row {
            case 0:// Home
                guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                pushViewController(dashboardClientTenderListVC)
                break
                
            case 1:// Upload Tender
                guard let uploadTenderVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UploadTenderVC") as? UploadTenderVC else { return }
                uploadTenderVC.isComingForEditTender = false
                pushViewController(uploadTenderVC)
                break
                
            case 2:// Edit Profile
                guard let signUpDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SignUpDetailVC") as? SignUpDetailVC else { return }
                signUpDetailVC.isCommingForUpdateProfile = true
                pushViewController(signUpDetailVC)
                break
                
            case 3:// Change Password
                guard let changePasswordVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC else { return }
                pushViewController(changePasswordVC)
                break
                
            case 4:// Notifications
                
                guard let notificationsVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "NotificationsVC") as? NotificationsVC else { return }
                pushViewController(notificationsVC)
                
                break
                
            case 5:// Contact Support Team
                
                guard let contactSupportTeamVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ContactSupportTeamVC") as? ContactSupportTeamVC else { return }
                pushViewController(contactSupportTeamVC)
                
                break
                
            case 6:// Logout
                
                let alert = UIAlertController(title: "Alert", message:"Are you sure want to logout ?", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Yes", style: .default) { _ in
                    //call api for logout
                    self.callLogOutApi()
                    
                }
                let cancle = UIAlertAction(title: "No", style: .cancel) { _ in }
                
                alert.addAction(cancle)
                alert.addAction(ok)
                self.present(alert, animated: true){}
                
                
                break
                
            default:
                break
            }
            
        }
        else
        { ///CONTRACTOR
            switch indexPath.row {
            case 0:// Home
                guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                pushViewController(dashboardClientTenderListVC)
                break
                
            case 1:// Subscription Details
                guard let subscriptionVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionVC") as? SubscriptionVC else { return }
                pushViewController(subscriptionVC)
                
                break
                
            case 2:// Edit Profile
                guard let signUpDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SignUpDetailVC") as? SignUpDetailVC else { return }
                signUpDetailVC.isCommingForUpdateProfile = true
                pushViewController(signUpDetailVC)
                break
                
            case 3:// Change Password
                guard let changePasswordVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC else { return }
                pushViewController(changePasswordVC)
                break
            case 4: // Favorites
                guard let favoriteVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "FavoriteVC") as? FavoriteVC else { return }
                               pushViewController(favoriteVC)
                
                break
            case 5:// Notifications
                
                guard let notificationsVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "NotificationsVC") as? NotificationsVC else { return }
                pushViewController(notificationsVC)
                
                break
                
            case 6:// Contact Support Team
                
                guard let contactSupportTeamVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ContactSupportTeamVC") as? ContactSupportTeamVC else { return }
                pushViewController(contactSupportTeamVC)
                
                break
                
            case 7:// Logout
                
                let alert = UIAlertController(title: "Alert", message:"Are you sure want to logout ?", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Yes", style: .default) { _ in
                    //call api for logout
                    self.callLogOutApi()
                    
                }
                let cancle = UIAlertAction(title: "No", style: .cancel) { _ in }
                
                alert.addAction(cancle)
                alert.addAction(ok)
                self.present(alert, animated: true){}
                
                
                break
                
            default:
                break
            }
        }
    }
}
