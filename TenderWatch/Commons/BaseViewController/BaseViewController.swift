//
//  AMBaseViewController.swift
//  SwiftProjectStructure
//
//  Created by des on 30/01/19.
//  Copyright © 2019 Krishna. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift
import MZFormSheetPresentationController



class BaseViewController: UIViewController,NVActivityIndicatorViewable
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = appColor
        self.navigationController?.navigationBar.isTranslucent = false
  
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
//         self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
   
    func SetNavigationBarTitle(string : String)
    {
        self.navigationItem.title = string
    }
    
    func showLoaderwithMessage(message : String ,type : NVActivityIndicatorType ,color : UIColor) {
        
        startAnimating(CGSize(width: 60, height:60),
                       message: message,
                       messageFont: UIFont.boldSystemFont(ofSize: 12),
                       type: type,
                       color: whiteColor,
                       padding: 10,
                       displayTimeThreshold: nil,
                       minimumDisplayTime: nil,
                       backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.6),
                       textColor: whiteColor)
        
    }
    
    func removeLoaderWithMessage(message : String)  {
        
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.stopAnimating()
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.stopAnimating()
        }
        
    }
    
    //MARK:- Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK Set TabBar ViewContrller
//    func setTabBarViewContrller() {
//        UserDefaults.standard.synchronize()
//
//        UIView.transition(with: appDelegate.window!, duration: 0.3, options: .transitionCrossDissolve
//
//            , animations: {() -> Void in
//
//                let tabBarController = mainStoryBoard.instantiateViewController(withIdentifier: "AMTabBarViewController") as! AMTabBarViewController
//                appDelegate.window?.rootViewController = tabBarController
//                appDelegate.window!.makeKeyAndVisible()
//
//        }) { _ in }
//    }
    
    
    //MARK:-  Navigation Controller Animation based Transition
    
    func pushViewController(_ viewController: UIViewController) {
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentViewController(_ viewController: UIViewController) {
        
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func popViewController() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismissViewController() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func PopToViewController(specificVC:AnyClass)
    {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: specificVC) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    
  
    func showToast(title:String,duration:TimeInterval,position:ToastPosition)
    {
        // toast with a specific duration and position
        self.view!.makeToast(title, duration:duration, position: position)
    
    }

    
    //MARK:- show custom alert
    func showCustomAlert(viewAlertDetail:UIView)
    {
        let TFPopup = MZFormSheetPresentationViewController.init(contentView: viewAlertDetail)
        TFPopup.presentationController?.shouldCenterVertically = true
        TFPopup.presentationController?.shouldDismissOnBackgroundViewTap = false
        self.present(TFPopup, animated: true)
    }
    
    
}

