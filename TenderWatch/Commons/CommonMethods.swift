//
//  CommonMethods.swift
//  SwiftProjectStructure
//
//  Created by Krishna Patel on 29/06/18.
//  Copyright © 2018 Krishna. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView




//MARL:- ******************** All Navigation Methods ***************

/*

func PUSH(v: UIViewController)  {
    APPDELEGATE?.navigation.pushViewController(v, animated: true)
}

func POP() {
    APPDELEGATE?.navigation.popViewController(animated: true)
}

func PRESENT_VC(v : UIViewController) {
    APPDELEGATE?.navigation .present(v, animated: true, completion: nil)
}

func DISMISS_VC() {
    APPDELEGATE?.navigation.dismiss(animated: true, completion: nil)
}
*/

//
//class TabBar: UITabBar {
//    override var traitCollection: UITraitCollection {
//        guard UIDevice.current.userInterfaceIdiom == .pad else {
//            return super.traitCollection
//        }
//
//        return UITraitCollection(horizontalSizeClass: .compact)
//    }
//}



//MARK:- ******************** NVActivityIndicatior Class *****************************

class NVActivityIndicatior : UIViewController, NVActivityIndicatorViewable
{
    
    func showLoaderwithMessage(message : String ,type : NVActivityIndicatorType ,color : UIColor) {
        
        startAnimating(CGSize(width: 60, height:60),
                       message: message,
                       messageFont: UIFont.boldSystemFont(ofSize: 12),
                       type: type,
                       color: .red,
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
    
    func RemoveLoader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.stopAnimating()
        }
        
    }
}

//MARK:- Alert
func showDefaultAlert(viewController:UIViewController,title:String,message:String)
{
    let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .cancel) { _ in
        
    }
    alert.addAction(ok)
    viewController.present(alert, animated: true){}
}

