//
//  SignUpVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 28/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import  GoogleSignIn
import FBSDKLoginKit

class SignUpVC: BaseViewController,ServiceManagerDelegate,UITextFieldDelegate,GIDSignInDelegate{
    
    //MARK:- outlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnTogglePassword: UIButton!
    @IBOutlet weak var btnToggleConfirmPassword: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnSignUpWithFacebook: UIButton!
    @IBOutlet weak var btnSignupWithGoogle: UIButton!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doCheckMail = "do check mail"
    var dicUserDataForSignUp = [String:Any]()
    var selectedLoginToken = ""
    
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
        btnNext.roundPerticularCorners(corners: .allCorners, radius: 8, bordercolor: .clear, borderwidth: 0)
        btnSignUpWithFacebook.roundPerticularCorners(corners: .allCorners, radius: 8, bordercolor: .clear, borderwidth: 0)
        btnSignupWithGoogle.roundPerticularCorners(corners: .allCorners, radius: 8, bordercolor: .clear, borderwidth: 0)
        
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
    
    //MARK:- Google Delegate Method
       
       func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
           if (error == nil) {
               // Perform any operations on signed in user here.
               let userId = user.userID                  // For client-side use only!
               let idToken = user.authentication.idToken // Safe to send to the server
               let fullName = user.profile.name
               let givenName = user.profile.givenName
               let familyName = user.profile.familyName
               let email = user.profile.email
               
              //set email to text
             self.txtEmail.text = email
            
            //store token for sending in api
            selectedLoginToken = userId ?? ""
               
           } else {
               print("\(String(describing: error))")
           }
       }
       
       func signInWillDispatch(_ signIn: GIDSignIn!, error: Error!) {
       }
       
       func signIn(_ signIn: GIDSignIn!,
                   presentViewController viewController: UIViewController!) {
           self.present(viewController, animated: true, completion: nil)
       }
       
       func signIn(_ signIn: GIDSignIn!,
                   dismissViewController viewController: UIViewController!) {
           self.dismiss(animated: true, completion: nil)
       }
    
      
    
    //MARK:- Validate Data
    func isDataValid() -> Bool{
        var strError = ""
        
        if !Validation.isPassWordMatch(pass: txtPassword.text ?? "", confPass: txtConfirmPassword.text ?? "")
        {
            strError = "Password and confirm password should be same"
        }
        
        if Validation.isStringEmpty(txtConfirmPassword.text ?? ""){
            strError = "Enter confirm password"
        }
        else if (txtConfirmPassword.text ?? "").length < 5{
            strError = "Enter confirm password with 5 characters or more"
        }
        
        if Validation.isStringEmpty(txtPassword.text ?? ""){
            strError = "Enter password"
        }
        else if (txtPassword.text ?? "").length < 5{
            strError = "Enter password with 5 characters or more"
        }
        
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
        if tagname == doCheckMail{
            self.parseCheckMailApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    func callCheckMailApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let dicParameters = ["email": "\(txtEmail.text ?? "")",
                "role":utils.getUserType(),
            ] 
            let webPath = "\(BASE_URL)\(CHECK_MAIL_API)"
            serviceManager.callWebServiceWithPOST(webpath: webPath, withTag: doCheckMail, params: dicParameters)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCheckMailApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            
            guard let  message = dicResponseData?["message"] as? String  else {return}
            if message == "This email is not registered on TenderWatch "{
                
                //temporary store user data To sign up
                dicUserDataForSignUp["email"] = txtEmail.text
                dicUserDataForSignUp["password"] = txtPassword.text
                dicUserDataForSignUp["loginToken"] = selectedLoginToken
                
                //navigate to Signup Detail page
                guard let signUpDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SignUpDetailVC") as? SignUpDetailVC else { return }
                signUpDetailVC.isCommingForUpdateProfile = false
                //pass user data to upload on server
                signUpDetailVC.dicUserDataForSignUp = dicUserDataForSignUp
                pushViewController(signUpDetailVC)
            }
            else
            {
                showDefaultAlert(viewController: self, title: "TenderWatch", message: message)
                
            }
        }
    }
    
    
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTogglePasswordClicked(_ sender: Any) {
        
        let txt = txtPassword.text
        //toggle secure entry
        txtPassword.isSecureTextEntry.toggle()
        txtPassword.text = txt
        
        //set image according to secure entry status
        if txtPassword.isSecureTextEntry{
            btnTogglePassword.setImage(UIImage(named: "ic_passwordHide"), for: .normal)
        }
        else
        {
            btnTogglePassword.setImage(UIImage(named: "ic_passwordShow"), for: .normal)
        }
        
    }
    
    @IBAction func btnToggleConfirmPasswordClicked(_ sender: Any) {
        
        let txt = txtConfirmPassword.text
        //toggle secure entry
        txtConfirmPassword.isSecureTextEntry.toggle()
        txtConfirmPassword.text = txt
        
        //set image according to secure entry status
        if txtConfirmPassword.isSecureTextEntry{
            btnToggleConfirmPassword.setImage(UIImage(named: "ic_passwordHide"), for: .normal)
        }
        else
        {
            btnToggleConfirmPassword.setImage(UIImage(named: "ic_passwordShow"), for: .normal)
        }
    }
    @IBAction func btnNextClicked(_ sender: Any) {
        //if all data are valid then do verifyEmail
        if isDataValid(){
            self.callCheckMailApi()
        }
        
    }
    
    @IBAction func btnSignUpWithFacebookClicked(_ sender: Any) {
        
        
             // 1
             let loginManager = LoginManager()
             
             //           if let _ = AccessToken.current {
             // Access token available -- user already logged in
             // Perform log out
             
             // 2
             loginManager.logOut()
             
             
             //           } else {
             // Access token not available -- user already logged out
             // Perform log in
             
             // 3
             loginManager.logIn(permissions: [], from: self) { [weak self] (result, error) in
                 
                 // 4
                 // Check for error
                 guard error == nil else {
                     // Error occurred
                     print(error!.localizedDescription)
                     return
                 }
                 
                 // 5
                 // Check for cancel
                 guard let result = result, !result.isCancelled else {
                     print("User cancelled login")
                     return
                 }
                 
                 // Successfully logged in
                 // 6
                 
                 
                 // 7
                 if let _ = AccessToken.current {
                     GraphRequest(graphPath: "/me",
                                  
                                  parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]).start(
                                     
                                     completionHandler: { (connection, result, error) -> Void in
                                         
                                         if (error == nil)
                                             
                                         {
                                             let dic = result as! [String:Any]
                                             
                                             print("first_name = \(dic["first_name"] ?? "")")
                                             
                                             print("last_name = \(dic["last_name"] ?? "")")
                                             
                                             print("email = \(dic["email"] ?? "")")
                                             
                                             print("id = \(dic["id"] ?? "")")
                                             //                            self.objSocialInfo.ProfilePicUrl = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
                                             
                                            
                                            //set email to text box
                                            self?.txtEmail.text = "\(dic["email"] ?? "")"
                                            
                                            if (self?.txtEmail.text == "")
                                            {
                                                let alert = UIAlertController(title: "Tender Watch", message:"Don't able to get email Id, Please enter manually", preferredStyle: .alert)
                                                let ok = UIAlertAction(title: "OK", style: .cancel) { _ in }
                                                alert.addAction(ok)
                                                self?.present(alert, animated: true){}
                                            }
                                            
                                            
                                            
                                            //store token for sending in api
                                            self?.selectedLoginToken = "\(dic["id"] ?? "")"
                                            
                                             
                                         }})
                 }
             }
       
        
        
    }
    
    @IBAction func btnSignUpWithGoogleClicked(_ sender: Any) {
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
               
               
               GIDSignIn.sharedInstance().delegate=self
               //        GIDSignIn.sharedInstance().uiDelegate=self
               GIDSignIn.sharedInstance().signIn()
    }
}
