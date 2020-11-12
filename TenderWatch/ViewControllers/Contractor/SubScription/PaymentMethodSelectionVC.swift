//
//  PaymentMethodSelectionVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 02/06/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import Braintree
import Alamofire

class PaymentMethodSelectionVC:  BaseViewController,ServiceManagerDelegate {
    
    //MARK:- outlet
    
    //MARK:- variable
    let utils = Utils()
    let componentManager = UIComponantManager()
    let serviceManager = ServiceManager()
    let doFetchUrlForPaypalPayment = "do get url for paypal payment"
    var clientToken = "CLIENT_TOKEN_FROM_SERVER"
    var braintreeClient: BTAPIClient?
    
    var arrSelectCountry : [[String:Any]] = []
    var dicSelectedSubscriptionPlan = [String:Any]()
    var isCommingFromRegistration = false
    
    //MARK:- view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupNavigationBar()
        serviceManager.delegate = self
    }
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.addLeftBarButton()
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
    
    
    
    //MARK:- button click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPaypalClicked(_ sender: Any) {
    
        self.callGetPaypalPaymentUrlAPI()
    }
    
    @IBAction func btnPesaPalClicked(_ sender: Any) {
        self.callGetPesapalPaymentUrlAPI()
    }
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        
        if tagname == doFetchUrlForPaypalPayment{
            self.parseGetPaypalPaymentUrlApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- API Calling
    //MARK: paypal
    
    func callGetPaypalPaymentUrlAPI()
    {
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Content-Type" : "application/json;charset=UTF-8",
                 "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let desc:String = "PayPal Payment"
            
            let dicParameter = ["desc":"\(desc)",
                "amount":"\(dicSelectedSubscriptionPlan["totalSubscriptionPrice"] ?? "")",
                "email" :"\(utils.getLoginUserEmail()  )",
                "paypalInfo":dicSelectedSubscriptionPlan["paypalInfo"]!] 
            
            
            let webPath = "\(BASE_URL)\(PAYPAL_PAYMENT_API)"
            
            
            /// NOTE:- Here encoding type is different that's why I have used seperate method for API calling instead of using ServiceManager
            
            Alamofire.request(URL(string: webPath)!, method: .post, parameters: dicParameter, encoding: JSONEncoding.default, headers: headers).response { (response) in
                
                //hide loader
                self.hideLoader()
                
                if response.data != nil {
                    
                    let rawData = response.data!
                    
                    var dicResponse : [String : AnyObject] = [:]
                    do {
                        
                        dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                        print(dicResponse)
                        //if response is not [String:AnuObject] form then try to convert it in another form
                        if dicResponse.count == 0
                        {
                            let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                            
                            //Parse response
                            self.parseGetPaypalPaymentUrlApiData(response: dicResponse1)
                        }
                        else{
                            //Parse response
                            self.parseGetPaypalPaymentUrlApiData(response: dicResponse)
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
                else{
                    
                    self.showToast(title: "\(response.error?.localizedDescription ?? "")", duration: 1.0, position: .top)
                    
                }
            }
            
        }
        else{
            //show error
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseGetPaypalPaymentUrlApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as! [String:Any]
            let url = "\(dicResponseData["URL"] ?? "")"
            
            //navigate for  payment process
            
            guard let paymentProcessVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "PaymentProcessVC") as? PaymentProcessVC else { return }
            paymentProcessVC.arrSelectCountry = arrSelectCountry
            paymentProcessVC.dicSelectedSubscriptionPlan = dicSelectedSubscriptionPlan
            paymentProcessVC.isCommingFromRegistration = isCommingFromRegistration
            paymentProcessVC.urlForPayment = url
            paymentProcessVC.PaymentMehod = PAYPAL
            pushViewController(paymentProcessVC)
            
        }
    }
    
    //MARK: Pesapal
    
    func callGetPesapalPaymentUrlAPI()
       {
           if utils.connected(){
               //show loader
               showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
               
               var autoraizationToken = ""
               let userData = utils.getLoginUserData()
               if userData != nil
               {
                   autoraizationToken = userData!["token"] as! String
               }
               
               let headers = [
                   "Content-Type" : "application/json;charset=UTF-8",
                    "Authorization": "Bearer \(autoraizationToken)"
               ]
               
               let desc:String = "Pesapal Payment"
               
               let dicParameter = ["desc":"\(desc)",
                   "amount":"\(dicSelectedSubscriptionPlan["totalSubscriptionPrice"] ?? "")",
                   "email" :"\(utils.getLoginUserEmail()  )",
                   "pesapalInfo":dicSelectedSubscriptionPlan["paypalInfo"]!]
               
               
               let webPath = "\(BASE_URL)\(PESAPAL_PAYMENT_API)"
               
               
               /// NOTE:- Here encoding type is different that's why I have used seperate method for API calling instead of using ServiceManager
               
               Alamofire.request(URL(string: webPath)!, method: .post, parameters: dicParameter, encoding: JSONEncoding.default, headers: headers).response { (response) in
                   
                   //hide loader
                   self.hideLoader()
                   
                   if response.data != nil {
                       
                       let rawData = response.data!
                       
                       var dicResponse : [String : AnyObject] = [:]
                       do {
                           
                           dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                           print(dicResponse)
                           //if response is not [String:AnuObject] form then try to convert it in another form
                           if dicResponse.count == 0
                           {
                               let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                               
                               //Parse response
                               self.parseGetPesaPalPaymentUrlApiData(response: dicResponse1)
                           }
                           else{
                               //Parse response
                               self.parseGetPesaPalPaymentUrlApiData(response: dicResponse)
                           }
                       } catch let error as NSError {
                           print(error)
                       }
                   }
                   else{
                       
                       self.showToast(title: "\(response.error?.localizedDescription ?? "")", duration: 1.0, position: .top)
                       
                   }
               }
               
           }
           else{
               //show error
               showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
           }
       }
       
    
    func parseGetPesaPalPaymentUrlApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as! [String:Any]
            let url = "\(dicResponseData["URL"] ?? "")"
            
            //navigate for  payment process
            
            guard let paymentProcessVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "PaymentProcessVC") as? PaymentProcessVC else { return }
            paymentProcessVC.arrSelectCountry = arrSelectCountry
            paymentProcessVC.dicSelectedSubscriptionPlan = dicSelectedSubscriptionPlan
            paymentProcessVC.isCommingFromRegistration = isCommingFromRegistration
            paymentProcessVC.urlForPayment = url
            paymentProcessVC.PaymentMehod = PESAPAL
            pushViewController(paymentProcessVC)
            
        }
    }
    
    //MARK:- paypal method
    func setupPaypal()
    {
        braintreeClient = BTAPIClient(authorization: "")
    }
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            DispatchQueue.main.async {
                
            }
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            self.clientToken = clientToken!
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            self.startCheckout()
            
        }.resume()
    }
    
    func startCheckout() {
        // Example: Initialize BTAPIClient, if you haven't already
        braintreeClient = BTAPIClient(authorization: clientToken)!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self // Optional
        
        // Specify the transaction amount here. "2.32" is used in this example.
        let request = BTPayPalRequest(amount: "2.32")
        request.currencyCode = "USD" // Optional; see BTPayPalRequest.h for more options
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                
                // Access additional information
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone
                
                // See BTPostalAddress.h for details
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
            } else if let error = error {
                // Handle error here...
            } else {
                // Buyer canceled payment approval
            }
        }
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        // Update URL with your server
        let paymentURL = URL(string: "https://your-server.example.com/payment-methods")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            if (error != nil) {
                print("ERROR")
            }
            else if response != nil {
                
            }
        }.resume()
    }
}

extension PaymentMethodSelectionVC : BTViewControllerPresentingDelegate {
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
extension PaymentMethodSelectionVC : BTAppSwitchDelegate {
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        showLoadingUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingUI), name: NSNotification.Name.NSExtensionHostDidBecomeActive, object: nil)
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        hideLoadingUI()
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    // MARK: - Private methods
    
    func showLoadingUI() {
        // ...
    }
    
    @objc func hideLoadingUI() {
        NotificationCenter
            .default
            .removeObserver(self, name: NSNotification.Name.NSExtensionHostDidBecomeActive, object: nil)
        // ...
    }
}
