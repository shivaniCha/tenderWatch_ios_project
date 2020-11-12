//
//  ContactSupportTeamVC.swift
//  TenderWatch
//
//  Created by Bhumi Joshi on 09/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import SideMenu
import MessageUI

class ContactSupportTeamVC: BaseViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    //MARK:- Outlets
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtViewEmailMessage: UITextView!
    @IBOutlet weak var txtEmailSubject: UITextField!
    @IBOutlet weak var lblFromMailAddress: UILabel!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        self.setupSidemenu()
        self.setupui()
        txtViewEmailMessage.delegate = self
        // Do any additional setup after loading the view.
        
        //Open side menu from side
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        
        lblFromMailAddress.text = "From:  \(utils.getLoginUserEmail())"
    }
    //MARK:- setupUI
    
    func setupui()
    {
        btnSend.cornerRadius = btnSend.Getheight/2
        txtViewEmailMessage.layer.borderWidth = 1
        txtViewEmailMessage.cornerRadius = 5
    }
    
    
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        self.setNavigationBarHeaderTitle(strTitle: "Support")
        self.addLeftBarButton()
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
    //MARK:- TextView Delegate Method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter your Questions or Complain"
        {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""
        {
            textView.text = "Enter your Questions or Complain"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
    
    
    
    //MARK:- btn click
    @objc func slideMenuPressed() {
        
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    @IBAction func btnSendMailClick(_ sender: Any) {
        
        if txtEmailSubject.text != ""
        {
            if txtViewEmailMessage.text != "Enter your Questions or Complain" && txtViewEmailMessage.text != ""
            {
                let mailComposeViewController = configuredMailComposeViewController()
                
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    //            self.showSendMailErrorAlert()
                }
            }
            else
            {
                showToast(title: "Please enter Question or Complain", duration: 1.0, position: .top)
            }
        }
        else
        {
            showToast(title: "Please Enter Subject", duration: 1.0, position: .top)
            
        }
    
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["support@tenderwatch.com"])
        mailComposerVC.setSubject(txtEmailSubject.text!)
        mailComposerVC.setMessageBody(txtViewEmailMessage.text, isHTML: false)
        
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        showToast(title:"Your device could not send e-mail.  Please check e-mail configuration and try again.", duration: 1.0, position: .center)

    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
  //  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
  //  }
    */
}

