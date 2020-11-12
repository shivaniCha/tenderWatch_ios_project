//
//  Utils.swift
//  SwiftProjectStructure
//
//  Created by Krishna Patel on 19/06/18.
//  Copyright © 2018 Krishna. All rights reserved.
//

import UIKit
import MBProgressHUD
import Reachability
import Contacts


class Utils: NSObject{
    
    
    //MARK:- Device related
    func isIphoneWithNotch() -> Bool
    {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                return false
            case 1334:
                return false
            case 1920, 2208:
                return false
            case 2436:
                return true
            case 2688:
                return true
            case 1792:
                return true
            default:
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    
    // MARK: - Common
    func connected() -> Bool {
        let reachability = Reachability.forInternetConnection()
        let status : NetworkStatus = reachability!.currentReachabilityStatus()
        if status == .NotReachable{
            return false
        }
        else
        {
            return true
        }
    }
    
    func makeCircular(view : UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
        view.layer.masksToBounds = true
    }
    
    func getAppDelegate() -> Any? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func drawBorder(view: UIView?, color borderColor: UIColor?, width: Float, radius: Float) {
        view?.layer.borderColor = borderColor?.cgColor
        view?.layer.borderWidth = CGFloat(width)
        view?.layer.cornerRadius = CGFloat(radius)
        view?.layer.masksToBounds = true
    }
    func getThemeColor() -> UIColor {
        return UIColor(hexString: THEME_COLOR)
    }
    
    func doLogOut() {
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if(key == FCM_TOKEN){}
            else {
                userDefaults.removeObject(forKey: key)
            }
        }
        userDefaults.synchronize()
    }
    
    func getUdId() -> String {
            return UIDevice.current.identifierForVendor!.uuidString
       }
    
    func callNumber(phoneNumber:String) {

        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
        }
    }
    
    //MARK: - UserDefaults related Methods
    
    func setFcmToken(fcmToken : String) {
        UserDefaults.standard.set(fcmToken, forKey: FCM_TOKEN)
    }
    func getFcmToken() -> String {
        if UserDefaults.standard.value(forKey: FCM_TOKEN) != nil
        {
//            return "cmhOqUool0M:APA91bFoHqcb9E9eYVz9652oSRxNJzTT1ED1FwepeguWW349LkrVSS3PFU2edwfSvTJtz4RhGSIbQ0by5t4YjRNW3wdb6plukq8smclRM3yNXWw5PcVyPqocMLQa_21jKX0UQeF3NsBh"
            
            return UserDefaults.standard.value(forKey: FCM_TOKEN) as! String
        }
        else
        {
            return ""
        }
    }
    
    func setUserType(userType : String) {
           UserDefaults.standard.set(userType, forKey: USER_ROLL)
       }
    
    func getUserType() -> String {
        
        if UserDefaults.standard.value(forKey: USER_ROLL) != nil
        {
            return UserDefaults.standard.value(forKey: USER_ROLL) as! String
        }
        else{
            return ""
        }
    }
    
    func setLoginUserEmail(email : String) {
           UserDefaults.standard.set(email, forKey: LOGIN_USER_EMAIL)
       }
    
    func getLoginUserEmail() -> String {
        
        if UserDefaults.standard.value(forKey: LOGIN_USER_EMAIL) != nil
        {
            return UserDefaults.standard.value(forKey: LOGIN_USER_EMAIL) as! String
        }
        else{
            return ""
        }
    }
    
    func setLoginUserId(id : String) {
        UserDefaults.standard.set(id, forKey: LOGIN_USER_ID)
    }
    
    func getLoginUserId() -> String {
        
        if UserDefaults.standard.value(forKey: LOGIN_USER_ID) != nil
        {
            return UserDefaults.standard.value(forKey: LOGIN_USER_ID) as! String
        }
        else{
            return ""
        }
    }
    
    
    func setLoginUserData(data : [String:Any]?) {
        UserDefaults.standard.set(data, forKey: LOGIN_USER_DATA)
    }
    
    func getLoginUserData() -> [String:Any]? {
        
        if UserDefaults.standard.value(forKey: LOGIN_USER_DATA) != nil
        {
            return (UserDefaults.standard.value(forKey: LOGIN_USER_DATA) as! [String:Any])
        }
        else{
            return nil
        }
    }
    
    
    func setNewNotificationCount(Count : Int) {
           UserDefaults.standard.set(Count, forKey: NEW_NOTIFICATIONS)
       }
    
    func getNewNotificationCount() -> Int? {
        
        if UserDefaults.standard.value(forKey: NEW_NOTIFICATIONS) != nil
        {
            return (UserDefaults.standard.value(forKey: NEW_NOTIFICATIONS) as! Int)
        }
        else{
            return nil
        }
    }
    
    //MARK:- Document directory
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func getImageFromDocumentDirectory(imageName : String)-> UIImage{
        let fileManager = FileManager.default
        // Here using getDirectoryPath method to get the Directory path
        let imagePath = (utils.getDirectoryPath() as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            print("No Image available")
            return UIImage.init(named: "")! // Return placeholder image here
        }
    }
    
    func deleteImageFromDocumentDirectory(imageName : String) -> Bool
        
    { let fileManager = FileManager.default
        // Here using getDirectoryPath method to get the Directory path
        let imagePath = (utils.getDirectoryPath() as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            
            //delete image
            do {
                try fileManager.removeItem(atPath: imagePath)
                return true
            } catch  {
                print("Error in delete image from document directory")
                return false
            }
            
        }else{
            print("No Image available")
            return false
            
        }
    }
    
    
    //MARK:- NVActivityIndicatior
    
    func createBlankFooterView() -> UIView? {
        let blankFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0))
        blankFooterView.backgroundColor = UIColor.clear
        return blankFooterView
    }
    
    func createFooterView() -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30.0))
        footerView.backgroundColor = UIColor.clear
        let actInd = UIActivityIndicatorView(style: .whiteLarge)
        actInd.tag = 10
        actInd.color = getThemeColor()
        actInd.tintColor = getThemeColor()
        actInd.frame = CGRect(x: UIScreen.main.bounds.size.width / 2, y: 0, width: 10.0, height: 10.0)
        actInd.hidesWhenStopped = true
        footerView.addSubview(actInd)
        return footerView
    }
     
}

