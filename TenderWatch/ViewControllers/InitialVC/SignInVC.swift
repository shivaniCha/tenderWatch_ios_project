//
//  SignInVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 27/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import  GoogleSignIn
import FBSDKLoginKit

class SignInVC: BaseViewController,ServiceManagerDelegate,UITextFieldDelegate,GIDSignInDelegate {
    
    //MARK:- outlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnTogglePassword: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnCreateAnAccount: UIButton!
    @IBOutlet weak var btnSignInWithFb: UIButton!
    @IBOutlet weak var btnSignInWithGoogle: UIButton!
    
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doSignIn = "do sign in"
    let doSignInWithGoogle = "do Sign In With Google"
    let doSignInWithFacebook = "do Sign In With Facebook"
    var dicGoogleUserData = [String:Any]()
    
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
        
        btnSignIn.roundPerticularCorners(corners: .allCorners, radius: 8, bordercolor: .clear, borderwidth: 0)
        btnSignInWithFb.roundPerticularCorners(corners: .allCorners, radius: 8, bordercolor: .clear, borderwidth: 0)
        btnSignInWithGoogle.roundPerticularCorners(corners: .allCorners, radius: 8, bordercolor: .clear, borderwidth: 0)
        
        let textForgotPassword = NSAttributedString(string: "Forgot Password?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0),NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor:UIColor.black])
        btnForgotPassword.setAttributedTitle(textForgotPassword, for: .normal)
        
        let textCreateAnAccount = NSAttributedString(string: "CREATE AN ACCOUNT", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0),NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor:UIColor.black])
        btnCreateAnAccount.setAttributedTitle(textCreateAnAccount, for: .normal)
        
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
            
            print("userId = \(userId)")
            
            //after getting token store data to server
            self.callGoogleSignInApi(token: "\(userId ?? "")")
            
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
        if tagname == doSignIn{
            self.parseSignInApiData(response: response)
        }
        
        if tagname == doSignInWithGoogle{
            self.parseSGoogleSignApiData(response: response)
        }
        
        if tagname == doSignInWithFacebook{
            self.parseFacebookSignApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    func callSignInApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let dicParameters = ["email": "\(txtEmail.text ?? "")",
                "password":"\(txtPassword.text ?? "")",
                "role":utils.getUserType(),
                "androidDeviceId": "\(utils.getFcmToken())"]
            
            let webPath = "\(BASE_URL)\(SIGNIN_API)"
            serviceManager.callWebServiceWithPOST(webpath: webPath, withTag: doSignIn, params: dicParameters)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseSignInApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            
            if dicResponseData?["error"] != nil
            {
                if dicResponseData?["error"] as? String == "No such user exists!" || dicResponseData?["error"] as? String == "User email and password combination do not match"
                {
                    
                    let alert = UIAlertController(title: "Tender Watch", message:"\(dicResponseData?["error"] as! String)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel) { _ in }
                    alert.addAction(ok)
                    self.present(alert, animated: true){}
                    return
                }
            }
            
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
            
            //after succesfully login navigate to Dashboard
            guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
            pushViewController(dashboardClientTenderListVC)
        }
    }
    
    
    func callGoogleSignInApi(token:String){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let dicParameters = ["token":"\(token)",
                                 "role":utils.getUserType(),
                                 "androidDeviceId": utils.getFcmToken()]  //"cmhOqUool0M:APA91bFoHqcb9E9eYVz9652oSRxNJzTT1ED1FwepeguWW349LkrVSS3PFU2edwfSvTJtz4RhGSIbQ0by5t4YjRNW3wdb6plukq8smclRM3yNXWw5PcVyPqocMLQa_21jKX0UQeF3NsBh"
      
            print("dicPara = \(dicParameters)")
            
            let webPath = "\(BASE_URL)\(GOOGLE_SIGN_IN_API)"
            serviceManager.callWebServiceWithPOST(webpath: webPath, withTag: doSignInWithGoogle, params: dicParameters)

        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseSGoogleSignApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            print(dicResponseData)
            
             if dicResponseData?["error"] != nil
                       {
                           if dicResponseData?["error"] as? String == "No such user exists!" || dicResponseData?["error"] as? String == "User email and password combination do not match"
                           {
                               
                               let alert = UIAlertController(title: "Tender Watch", message:"\(dicResponseData?["error"] as! String)", preferredStyle: .alert)
                               let ok = UIAlertAction(title: "OK", style: .cancel) { _ in }
                               alert.addAction(ok)
                               self.present(alert, animated: true){}
                               return
                           }
                       }
                       
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
                       
                       //after succesfully login navigate to Dashboard
                       guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                       pushViewController(dashboardClientTenderListVC)        }
    }
    
    
    func callFacebookSignInApi(token:String){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            let dicParameters = ["token": token,
                                 "role":utils.getUserType(),
                                 "androidDeviceId": utils.getFcmToken()]  //"cmhOqUool0M:APA91bFoHqcb9E9eYVz9652oSRxNJzTT1ED1FwepeguWW349LkrVSS3PFU2edwfSvTJtz4RhGSIbQ0by5t4YjRNW3wdb6plukq8smclRM3yNXWw5PcVyPqocMLQa_21jKX0UQeF3NsBh"
            
            
            print("dicPara = \(dicParameters)")
            
            let webPath = "\(BASE_URL)\(FACEBOOK_SIGN_IN_API)"
            serviceManager.callWebServiceWithPOST(webpath: webPath, withTag: doSignInWithFacebook, params: dicParameters)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseFacebookSignApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            print(dicResponseData)
            
            
            if dicResponseData?["errorType"] != nil
                                  {
                                      if (dicResponseData?["errorMessage"] as? String == "No such user exists!") ||
                                         (dicResponseData?["errorMessage"] as? String == "User email and password combination do not match") || (dicResponseData?["errorMessage"] as? String == "User is not registered in app")
                                      {
                                          
                                          let alert = UIAlertController(title: "Tender Watch", message:"\(dicResponseData?["errorMessage"] as! String)", preferredStyle: .alert)
                                          let ok = UIAlertAction(title: "OK", style: .cancel) { _ in }
                                          alert.addAction(ok)
                                          self.present(alert, animated: true){}
                                          return
                                      }
                                  }
                                  
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
                                  
                                  //after succesfully login navigate to Dashboard
                                  guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                                  pushViewController(dashboardClientTenderListVC)  
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
    
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        guard let forgotPasswordVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC else { return }
        pushViewController(forgotPasswordVC)
    }
    
    @IBAction func btnSignInClicked(_ sender: Any) {
        //if all data are valid then do sign in
        if isDataValid(){
            self.callSignInApi()
        }
    }
    
    @IBAction func btnCreateAnAccountClicked(_ sender: Any) {
        guard let signUpVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC else { return }
        pushViewController(signUpVC)
    }
    
    @IBAction func btnSignInWithFbClicked(_ sender: Any) {
        
        
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
                GraphRequest(graphPath: "me",
                             
                             parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]).start(
                                
                                completionHandler: { (connection, result, error) -> Void in
                                    
                                    if (error == nil)
                                        
                                    {
                                        let dic = result as! [String:Any]
                                        
                                        print("dictionary = \(dic)")
                                        
                                        print("first_name = \(dic["first_name"] ?? "")")
                                        
                                        print("last_name = \(dic["last_name"] ?? "")")
                                        
                                        print("email = \(dic["email"] ?? "")")
                                        
                                        print("id = \(dic["id"] ?? "")")
                                        //                            self.objSocialInfo.ProfilePicUrl = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
                                        
                                        //call api to upload user data to server
                                        self?.callFacebookSignInApi(token: "\(dic["id"] ?? "")")
                                        
                                    }})
            }
        }
        //           }
    }
    
    @IBAction func btnSignInWithGoogleClicked(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        
        GIDSignIn.sharedInstance().delegate=self
        //        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
}
