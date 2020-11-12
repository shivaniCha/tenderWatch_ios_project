//
//  AboutTenderWatch.swift
//  TenderWatch
//
//  Created by mac2019_17 on 04/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class AboutTenderWatchVC: BaseViewController,WKNavigationDelegate,MFMailComposeViewControllerDelegate {
    
    //MARK:- outlet
    @IBOutlet weak var webViewForAboutTenderWatch: WKWebView!
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var viewBaseContainer: UIView!
    
    //MARK:- variable
    let utils = Utils()
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //hide navigation bar
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        webViewForAboutTenderWatch.navigationDelegate = self
        
        //load about in webview
        let htmlPath = Bundle.main.path(forResource: "about", ofType: "html")
        let htmlUrl = URL(fileURLWithPath: htmlPath!, isDirectory: false)
        webViewForAboutTenderWatch.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
    }
    
    
    //MARK:- setupUI
    func setupUI(){
        viewBaseContainer.roundPerticularCorners(corners: .allCorners, radius: 8.0, bordercolor: .clear, borderwidth: 0.0)
        btnCancle.cornerRadius = btnCancle.Getheight/2
        
    }
    
    //MARK:- Navigation delegate for webview
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("link")
            
            decisionHandler(WKNavigationActionPolicy.cancel)
            
            //open mail composer foe send mail to support team
            self.sendMail()
            
            return
        }
        print("no link")
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    //MARK:- send Mail
    func sendMail(){
        
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeViewController, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
        
    }
    
    func configureMailComposer() -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["support@tenderwatch.com"])
        //        mailComposeVC.setSubject(self.textFieldSubject.text!)
        //        mailComposeVC.setMessageBody(self.textViewBody.text!, isHTML: false)
        return mailComposeVC
    }
    
    //MARK:- btn click
    @IBAction func btnCancleClicked(_ sender: Any) {
        self.popViewController()
        
    }
}

