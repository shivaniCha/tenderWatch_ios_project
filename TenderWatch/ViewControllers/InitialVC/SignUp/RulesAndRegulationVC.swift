//
//  RulesAndRegulationVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 29/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import WebKit
import PhoneNumberKit
class RulesAndRegulationVC: BaseViewController,ServiceManagerDelegate {
    
    //MARK:- outlet
    @IBOutlet weak var webViewRulesAndRegulation: WKWebView!
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let phoneNumberKit = PhoneNumberKit()
    let doSignUp = "do sign up"
    var dicUserDataForSignUp = [String:Any]()
    
    
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
        
        serviceManager.delegate = self
        
        //load agreement in webview
        let htmlPath = Bundle.main.path(forResource: "agreement", ofType: "html")
        let htmlUrl = URL(fileURLWithPath: htmlPath!, isDirectory: false)
        webViewRulesAndRegulation.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        
    }
    //MARK:- setupUI
    func setupUI(){
        btnNext.cornerRadius = btnNext.Getheight/2
        
    }
    
    //MARK:- setup Navigation Bar
    func setupNavigationBar()
    {
        self.addLeftBarButton()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
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
    
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doSignUp{
            self.parseSignUpApiData(response: response)
        }
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    func callSignUpApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
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
                "loginToken":"\(dicUserDataForSignUp["loginToken"] ?? "")"]
            
            
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
            
            if utils.getUserType() == USER_CONTRACTOR{
                //after succesfully register navigate to Dashboard
                guard let subscriptionPlanVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as? SubscriptionPlanVC else { return }
                subscriptionPlanVC.isCommingFromRegistration = true
                pushViewController(subscriptionPlanVC)
            }
            else
            {
                //after succesfully register navigate to Dashboard
                guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                pushViewController(dashboardClientTenderListVC)
            }
            
            
        }
    }
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAgreeClicked(_ sender: Any) {
        
        if btnAgree.image(for: .normal) == UIImage(named: "ic_check"){
            btnAgree.setImage(UIImage(named: "ic_unCheck"), for: .normal)
        }else{
            btnAgree.setImage(UIImage(named: "ic_check"), for: .normal)
        }
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        if btnAgree.image(for: .normal) == UIImage(named: "ic_check"){
            
            if utils.getUserType() == USER_CONTRACTOR{
                //navigate to select subscription plan
                guard let subscriptionPlanVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as? SubscriptionPlanVC else { return }
                subscriptionPlanVC.isCommingFromRegistration = true
                //send user data
                subscriptionPlanVC.dicUserDataForSignUp = dicUserDataForSignUp
                pushViewController(subscriptionPlanVC)
            }
            else
            {
                self.callSignUpApi()
            }
            
        }
        else
        {
            showToast(title: "Please agree rules and regulation", duration: 1.0, position: .top)
        }
    }
}
