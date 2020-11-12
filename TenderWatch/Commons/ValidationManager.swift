
import Foundation
import UIKit

//class ValidationManager: NSObject {

    //MARK:- Create Instance of Class
//    class var sharedInstance: ValidationManager {
//
//        struct Static {
//
//            static let instance = ValidationManager()
//        }
//
//        return Static.instance
//    }
    
    
    //MARK:- ************* IsValidEmail *****************
    func isValidEmail(emailString: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
    
    //MARK:- ************* isValidPhoneNumber *****************
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phoneNumber == filtered
    }
    
    //MARK:- ************* isPasswordmatch *****************
    func isPassWordMatch(pass: String, confPass: String) -> Bool{
        
        if(pass == confPass) {
            return true
        }
        else{
            return false
        }
    }
    
    //MARK:- ************* isStringEmpty *****************
    func isStringEmpty(_ str: String) -> Bool{
        
        if str.trim().count == 0 {
            return true
        }
        return false
    }
//}
