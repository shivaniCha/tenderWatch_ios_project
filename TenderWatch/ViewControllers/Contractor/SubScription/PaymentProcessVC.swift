//
//  PaymentProcessVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 02/06/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import WebKit

class PaymentProcessVC: BaseViewController,WKNavigationDelegate,ServiceManagerDelegate {
    
    //MARK:- outlet
    
    @IBOutlet weak var webview: WKWebView!
    
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    //MARK:- variable
    let utils = Utils()
    let componentManager = UIComponantManager()
    let serviceManager = ServiceManager()
    var arrSelectCountry : [[String:Any]] = []
    var dicSelectedSubscriptionPlan = [String:Any]()
    var isCommingFromRegistration = false
    var urlForPayment = ""
    let doUploadDetailOfPaypalPurchase = "do upload Details of Paypal purchase"
    let doUploadDetailOfPesapalPurchase = "do upload Details of Pesapal purchase"
    let doFetchUserDetail = "do fetch user Detail for Payment Process"
    let doRemoveSubscription = "do remove subscription"
    var dicQueryParams = [String:String]()
    var PaymentMehod = ""
    
    
    //MARK:- view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //show indicator view
        self.showIndicatorView()
        
        serviceManager.delegate = self
        
        self.setupNavigationBar()
        self.setupData()
        
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
    
    
    //MARK:- setup data
    func setupData()
    {   webview.navigationDelegate = self
        webview.load(URLRequest(url: URL(string: urlForPayment)!))
    }
    
    //MARK:- hide show view
    func showIndicatorView(){
        self.loader.startAnimating()
        self.viewLoader.isHidden = false
    }
    
    func hideIndicatorView(){
        self.loader.stopAnimating()
        self.viewLoader.isHidden = true
    }
    
    
    //MARK:- webview navigation delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        let url = webview.url
        print("detected url = \(url!)")
        
        if url != nil
        {
            ///PAYPAL
            if  (url?.absoluteString.contains("paymentId="))! && (url?.absoluteString.contains("PayerID="))!
            {
                guard let queryParameters = url?.queryParameters else { return  }
                
                let dic = ["paymentId":queryParameters["paymentId"],
                           "token":queryParameters["token"],
                           "payerID":queryParameters["PayerID"]]
                
                dicQueryParams = dic as! [String : String]
                
            }
            
            
            ///PESAPAL
            
            if  (url?.absoluteString.contains("pesapal_transaction_tracking_id="))! && (url?.absoluteString.contains("pesapal_merchant_reference="))!
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    //here we need to upload  pesapal details on server, but currently there is no api available so skipping uploading Pesapal info to server.
                    if "\(self.dicSelectedSubscriptionPlan["subscriptionId"] ?? "")" != ""
                       {
                           //after getting data of user call api for renew subscription ( here api name is Remove subscription)
                           self.callRemoveSubscriptionAPI()
                       }
                       else
                       {
                           let alert = UIAlertController(title: "Tender Watch", message:"Payment Successful !!!", preferredStyle: .alert)
                           
                           let ok = UIAlertAction(title: "OK", style: .default) { _ in
                               
                               // navigate to dash board
                               guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                               self.pushViewController(dashboardClientTenderListVC)
                               
                           }
                           
                           alert.addAction(ok)
                           self.present(alert, animated: true){}
                       }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish  navigation: WKNavigation!)
    {
        
        //hide indicator view
        self.hideIndicatorView()
        
        let url = webView.url?.absoluteString
        print("---Hitted URL--->\(url!)") // here you are getting URL
        
        if dicQueryParams.count > 0
        {
            //hide indicator view
            self.showIndicatorView()
            //After successfully payment,Call api for upload data to server
            if PaymentMehod == PAYPAL
            {  //paypal
                self.callUploadPaypalPurchaseDetailApi(dicParameter: self.dicQueryParams )
            }
            else
            {  //pesapal
                self.callUploadPesapalPurchaseDetailApi(dicParameter: self.dicQueryParams)
                
            }
        }
    }
    
    
    //MARK:- button click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Service manager delegate
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        
        if tagname == doUploadDetailOfPaypalPurchase{
            self.parseUploadPaypalPurchaseDetailApiData(response: response)
        }
        
        
        if tagname == doUploadDetailOfPesapalPurchase{
            self.parseUploadPesapalPurchaseDetailApiData(response: response)
        }
        
        
        if tagname == doFetchUserDetail{
            self.parseUserDetailApiData(response: response)
        }
        if tagname == doRemoveSubscription{
            self.parseRemoveSubscriptionApiData(response: response)
        }
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    
    //MARK:- API Calling
    
    //MARK:- Paypal
    func callUploadPaypalPurchaseDetailApi(dicParameter:[String:String]){
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
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(PAYPAL_PAYMENT_API)"
            
            print(webPath)
            print(headers)
            print(dicQueryParams)
            
            serviceManager.callWebServiceWithPutWithHeaders(webpath: webPath, withTag: doUploadDetailOfPaypalPurchase, params: dicParameter, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    func parseUploadPaypalPurchaseDetailApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            if dicResponseData?.count ?? 0 > 0
            {
                if dicResponseData!["message"] != nil
                {
                    self.showToast(title: "\(dicResponseData?["message"] ?? "")", duration: 1.0, position: .top)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    if "\(self.dicSelectedSubscriptionPlan["subscriptionId"] ?? "")" != ""
                       {
                           //after getting data of user call api for renew subscription ( here api name is Remove subscription)
                           self.callRemoveSubscriptionAPI()
                       }
                       else
                       {
                           let alert = UIAlertController(title: "Tender Watch", message:"Payment Successful !!!", preferredStyle: .alert)
                           
                           let ok = UIAlertAction(title: "OK", style: .default) { _ in
                               
                               // navigate to dash board
                               guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                               self.pushViewController(dashboardClientTenderListVC)
                               
                           }
                           
                           alert.addAction(ok)
                           self.present(alert, animated: true){}
                       }
                    
                    
                }
            }
        }
    }
    
    
    //MARK:- Pesapal
    func callUploadPesapalPurchaseDetailApi(dicParameter:[String:String]){
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
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(PESAPAL_PAYMENT_API)"
            
            print(webPath)
            print(headers)
            print(dicQueryParams)
            
            serviceManager.callWebServiceWithPutWithHeaders(webpath: webPath, withTag: doUploadDetailOfPesapalPurchase, params: dicParameter, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseUploadPesapalPurchaseDetailApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as? [String:Any]
            if dicResponseData?.count ?? 0 > 0
            {
                if dicResponseData!["message"] != nil
                {
                    self.showToast(title: "\(dicResponseData?["message"] ?? "")", duration: 1.0, position: .top)
                }
                
                if "\(dicSelectedSubscriptionPlan["subscriptionId"] ?? "")" != ""
                    {
                        //after getting data of user call api for renew subscription ( here api name is Remove subscription)
                        self.callRemoveSubscriptionAPI()
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Tender Watch", message:"Payment Successful !!!", preferredStyle: .alert)
                        
                        let ok = UIAlertAction(title: "OK", style: .default) { _ in
                            
                            // navigate to dash board
                            guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                            self.pushViewController(dashboardClientTenderListVC)
                            
                        }
                        
                        alert.addAction(ok)
                        self.present(alert, animated: true){}
                    }
                
                
            }
        }
    }
    
    func callUserDetailDataAPI()
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
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(USER_DETAIL_API)\(utils.getLoginUserId())"
            serviceManager.callWebServiceWithGetWithHeaders(webpath: webPath, withTag: doFetchUserDetail, headers: headers)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseUserDetailApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as! [String:Any]
            print(dicResponseData)
            
            if "\(dicSelectedSubscriptionPlan["subscriptionId"] ?? "")" != ""
            {
                //after getting data of user call api for renew subscription ( here api name is Remove subscription)
                self.callRemoveSubscriptionAPI()
            }
            else
            {
                let alert = UIAlertController(title: "Tender Watch", message:"Payment Successful !!!", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK", style: .default) { _ in
                    
                    // navigate to dash board
                    guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                    self.pushViewController(dashboardClientTenderListVC)
                    
                }
                
                alert.addAction(ok)
                self.present(alert, animated: true){}
            }
        }
    }
    
    
    func callRemoveSubscriptionAPI()
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
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(REMOVE_SUBSCRIPTION_API)"
            
            let dicParameter  = ["_id":"\(dicSelectedSubscriptionPlan["subscriptionId"] ?? "")"]
            
            serviceManager.callWebServiceWithPutWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doRemoveSubscription, params: dicParameter, headers: headers)
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseRemoveSubscriptionApiData(response:Any?){
        //hide loader
        hideLoader()
        
        if response != nil
        {
            let dicResponseData = response as! [String:Any]
            print(dicResponseData)
            
            let alert = UIAlertController(title: "Tender Watch", message:"Payment Successful !!!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default) { _ in
                
                // navigate to dash board
                guard let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as? DashboardClientTenderListVC else { return }
                self.pushViewController(dashboardClientTenderListVC)
                
            }
            
            alert.addAction(ok)
            self.present(alert, animated: true){}
        }
    }
    
}

