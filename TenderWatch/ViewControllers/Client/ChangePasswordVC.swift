//
//  ChangePasswordVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 30/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import SideMenu

class ChangePasswordVC:  BaseViewController,ServiceManagerDelegate,UITextFieldDelegate {
    
    //MARK:- outlet
    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnChange: UIButton!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doChangePassword = "do change password"
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Open side menu from side
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        //show navigation bar
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        DispatchQueue.main.async {
            self.setupUI()
        }
        serviceManager.delegate = self
    }
    
    
    //MARK:- setupUI
    func setupUI(){
        btnChange.cornerRadius = btnChange.Getheight/2
        
    }
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        self.setNavigationBarHeaderTitle(strTitle: "Change Password")
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
    
    
    //MARK:- touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK:- text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- Validate Data
    func isDataValid() -> Bool{
        var strError = ""
        
        if !Validation.isPassWordMatch(pass: txtNewPassword.text ?? "", confPass: txtConfirmPassword.text ?? "")
        {
            strError = "Password and confirm password should be same"
        }
        
        if Validation.isStringEmpty(txtConfirmPassword.text ?? ""){
            strError = "Enter confirm password"
        }
        else if (txtConfirmPassword.text ?? "").length < 5{
            strError = "Enter confirm password with 5 characters or more"
        }
        
        if Validation.isStringEmpty(txtNewPassword.text ?? ""){
            strError = "Enter new password"
        }
        else if (txtNewPassword.text ?? "").length < 5{
            strError = "Enter new password with 5 characters or more"
        }
        
        if Validation.isStringEmpty(txtOldPassword.text ?? ""){
            strError = "Enter old password"
        }
        else if (txtOldPassword.text ?? "").length < 5{
            strError = "Enter old password with 5 characters or more"
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
        if tagname == doChangePassword{
            self.parseChangePasswordApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    func callChangePasswordApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let dicParameters = ["oldPassword":"\(txtOldPassword.text ?? "")",
                "newPassword":"\(txtNewPassword.text ?? "")"]
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            
            let webPath = "\(BASE_URL)\(CHANGE_PASSWORD_API)\(utils.getLoginUserId())"
            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doChangePassword, params: dicParameters, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseChangePasswordApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            if dicResponseData?["message"] != nil
            {
                self.showToast(title: "\(dicResponseData?["message"] ?? "")", duration: 1.5, position: .top)
                
                if "\(dicResponseData?["message"] ?? "")" == "Password changed successfully!!!"
                {
                    txtOldPassword.text = ""
                    txtNewPassword.text = ""
                    txtConfirmPassword.text = ""
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.PopToViewController(specificVC: DashboardClientTenderListVC.self)
                    }
                }
                
            }
        }
    }
    
    //MARK:- btn click
    @objc func slideMenuPressed() {
        
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    @IBAction func btnChangeClicked(_ sender: Any) {
        
        if isDataValid()
        {
            self.callChangePasswordApi()
        }
        
    }
}
