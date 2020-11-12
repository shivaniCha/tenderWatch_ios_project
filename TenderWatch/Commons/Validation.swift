//
//  NSObject.swift
//  Print_Photo_App
//
//  Created by Prakash on 04/02/19.
//  Copyright © 2019 des. All rights reserved.
//

import Foundation

class Validation: NSObject {
    
    //MARK:- ********************** CREATE INSTANCE OF CLASS **********************

    class var sharedInstance: Validation {
        
        struct Static {
            
            static let instance = Validation()
        }
        
        return Static.instance
    }
    
    //MARK:- ********************** CHECK EMAIL VALIDATION **********************

    class func isValidEmail(emailString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
    
    //MARK:- ********************** CHECK PHONE NUMBER VALIDATION **********************

    class func isValidPhoneNumber(phoneNumber: String) -> Bool {
        
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phoneNumber == filtered
    }
    
    // CHECK PASSWORD AND CONFIRM PASSWORD MATCH OR NOT
    
    class func isPassWordMatch(pass: String, confPass: String) -> Bool{
        
        if(pass == confPass) {
            return true
        }
        else{
            return false
        }
    }
    
    // CHECK STRING IS EMPTY OR NOT
    
    class func isStringEmpty(_ str: String) -> Bool{
        
        if str.trim().count == 0 {
            return true
        }
        return false
    }
}
