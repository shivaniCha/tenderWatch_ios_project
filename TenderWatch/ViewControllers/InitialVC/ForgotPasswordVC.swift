 //
 //  ForgotPasswordVC.swift
 //  TenderWatch
 //
 //  Created by mac2019_17 on 28/04/20.
 //  Copyright © 2020 mac2019_17. All rights reserved.
 //
 
 import UIKit
 
 class ForgotPasswordVC: BaseViewController,ServiceManagerDelegate,UITextFieldDelegate{
    //MARK:- outlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doForgotPassword = "do forgot password"
    
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
       
    }
    
    //MARK:- setupUI
    func setupUI(){
        btnSubmit.cornerRadius = btnSubmit.Getheight/2
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
        
        if Validation.isStringEmpty(txtEmail.text ?? ""){
            strError = "Enter email"
        }
        else if !Validation.isValidEmail(emailString: txtEmail.text ?? ""){
            strError = "Enter valid email"
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
        if tagname == doForgotPassword{
            self.parseForgotPasswordApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    func callForgotPasswordApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let dicParameters = ["email": "\(txtEmail.text ?? "")",
                "role":utils.getUserType()]
            
            let webPath = "\(BASE_URL)\(FORGOT_PASSWORD_API)"
            serviceManager.callWebServiceWithPOST(webpath: webPath, withTag: doForgotPassword, params: dicParameters)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseForgotPasswordApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            
            if dicResponseData?["message"] != nil{
                showDefaultAlert(viewController: self, title: "TenderWatch", message: "\(dicResponseData?["message"] ?? "")")
            }
            else
            {
                showDefaultAlert(viewController: self, title: "TenderWatch", message: "Your password has been sent to your registered Email ID")
            }
            
        }
    }
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        //if all data are valid then do forgot password
        if isDataValid(){
            self.callForgotPasswordApi()
        }
    }
    
 }
