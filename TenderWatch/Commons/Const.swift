
//  Copyright © 2018 Proje. All rights reserved.


import Foundation
import UIKit


var utils = Utils()
var UIComponantManagers = UIComponantManager()
//var validationData = ValidationManager()
var showloader = NVActivityIndicatior()


//MARK: - CHECK FOR DEVICE
let IS_IPHONE4 = (UIScreen.main.bounds.size.height - 480) != 0.0 ? false : true
let IS_IPAD = UI_USER_INTERFACE_IDIOM() != .phone
let IS_IPHONE5s = UIScreen.main.bounds.size.height <= 568 ? true : false
let IS_IPHONEX = UIScreen.main.bounds.size.height == 812 ? true : false


//MARK: - SCREEN BOUNDS
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height


var currentFrame: CGRect = CGRect()

//MARK: - GET APPDELEGATE
let APPDELEGATE = UIApplication.shared.delegate as? AppDelegate

//MARK: - API HOST URL
let BASE_URL = "http://tenderserverapi-env.pvc4hdqjc9.ap-south-1.elasticbeanstalk.com/api/"


//MARK: - API NAMES
let SIGNIN_API  = "auth/login"
let FORGOT_PASSWORD_API = "auth/forgot"
let CHECK_MAIL_API = "auth/checkEmail"
let CHANGE_PASSWORD_API = "users/changePassword/"
let GOOGLE_SIGN_IN_API = "auth/glogin"
let FACEBOOK_SIGN_IN_API = "auth/facelogin"
let SIGNUP_API  = "auth/register"
let GET_TENDERS = "tender/getTenders"
let COUNTRY_API = "auth/country"
let TENDERCATEGORY_API = "auth/category"
let UPLOADTENDER_API = "tender"
let UPDATE_PROFILE_API  = "users/"
let REMOVE_ACCOUNT_API = "users/"
let LOGOUT_API = "users"
let GET_NOTIFICATION_API = "notification"
let TENDER_DETAIL_API = "tender/"
let INTERESTED_CONTRACTOR_API = "tender/interestedContractorForTender/"
let COMMON_VALUE_API = "auth/getCommonValues"
let UPDATE_TENDER_API = "tender/"
let READ_NOTIFICATION_API = "notification/"
let DELETE_NOTIFICATION_API = "notification/delete"
let USER_DETAIL_API  = "users/"
let REVIEW_API = "review"
let REMOVE_TENDER_API = "tender/"
let SEND_DETAIL_ABOUT_REMOVE_TENDER_API = "tender/SendDetail"
let ALL_INTERESTED_CONTRACTOR_FOR_PROFILE_API = "tender/interestedContractor/"
let SEND_DETAIL_ABOUT_REMOVE_ACCOUNT_API = "tender/SendDetailToContractor"
let GET_FAVORITE_TENDER_LIST_API = "tender/favorite/"
let ADD_OR_REMOVE_FAVORITE_TENDER_API = "tender/favorite/"
let ADD_OR_REMOVE_INTEREST_TENDER_API = "tender/interested/"
let PAYPAL_PAYMENT_API = "payments/paypal"
let PESAPAL_PAYMENT_API = "payments/pesapal"
let REMOVE_SUBSCRIPTION_API = "service/RemoveSubscription"
let CHECK_SERVICE_API = "service/checkservice"
let SUBSCRIPTION_DETAILS_API = "service/Subscription/history"


//MARK: - NOTIFICATION NAMES
let LOGOUT_NOTIFICATION           = "logoutNotification"
let Langauge_Change               = "LangaugeChange"
let UPDATE_USER_DATA_NOTIFICATION = "Update user data notification"
let NEW_NOTIFICATION_COUNT        = "New Notification Count"

//MARK: - SOME COMMON THINGS
let CHECK_INTERNET_CONNECTION   =  "Check your internet connection"
let PROBLEM_FROM_SERVER         =  "Problem Receiving Data From Server"
let SOMETHING_WENT_WRONGE       =  "Something went wrong, Try again later"



//MARK:- application
var APPLICATION_NAME = "TenderWatch"

//MARK:- ADVERTISE
var is_AdsDisplay = true
var Purchase_flag = false
var ApiData_flag = false

let banner_ID  = ""
let int_ID     = ""
var Product_Id = ""
var IAPProductPrice = ""



//MARK:- Photo Gallary
let ALBUM_NAME = ""

//MARK: - SOME ACCOUNT KEYS, e.g google, gmail, paypal, facebook, twittesr

let GOOGLE_CLIENT_ID = "153589139177-4nna1du2g6gqv2tmgbevrji5hik74u3v.apps.googleusercontent.com"
let PAYPAL_CLIENT_ID = "AdYtcg05haUBRoc5ljmkM-tBorYLNvLem5Iy6UD6Sf-8wAV_uUpKkOwvXeuIn3-m1lkfmAHzLchxod_r"

//MARK: - iTUNES
let iTunesURL = ""
let APPSTORE_APPID  = ""
let SHARE_APP_LINK = ""
let RATE_APP_LINK = ""
let MORE_APP_LINK = ""


//MARK: - FONT NAMES
let HELVETICA          = "Helvetica"
let HELVETICA_BOLD     = "Helvetica Bold"


//MARK: - USER TYPE IF MORE USER
let USER_CLIENT = "client"
let USER_CONTRACTOR = "contractor"


//MARK: - PAYMENT METHOD
let PAYPAL = "Paypal"
let PESAPAL = "Pesapal"

//MARK: - USERDEFAULT RELATED
let FCM_TOKEN                     = "FCM_TOKEN"
let USER_ROLL                     = "UserRoll"
let LOGIN_USER_EMAIL              = "Login user email"
let LOGIN_USER_DATA               = "Login user data"
let LOGIN_USER_ID                 = "Login user id"
let UDID                          = "UDID"
let NEW_NOTIFICATIONS             = "New Notifications"

//MARK: - SET APP COLOR
let THEME_COLOR        = ""  
let STATUS_BAR_COLOR   = ""
let FONT_DARK_COLOR    = ""
let FONT_LIGHT_COLOR   = ""
let BADGE_COLOR        = ""
let FONT_RED_COLOR     = ""
let FONT_GREEN_COLOR   = ""
let SEPERATOR_COLOR    = ""


//MARK:- APPLICATION NAME

let WhatsApp  = "WhatsApp"
let Telegram  = "Telegram"
let Messenger = "Messenger"
let GoogleAllo = "Google Allo"
let Twitter   = "Twitter"
let WeChat    = "WeChat"
let Line      = "Line"
let Hike      = "Hike"



//MARK:-********************** COLOR CONSTANT **********************

let appColor                           = hexStringToUIColor(hex: "#00BCD4")//UIColor(red: 19/255.0, green: 4/255.0, blue: 166/255.0, alpha: 1.0)
let statusBarColor                     = hexStringToUIColor(hex: "#ffffff")
let blackColor                         = UIColor.black
let darkGrayColor                      = UIColor.darkGray
let lightGrayColor                     = UIColor.lightGray
let blueColor                          = UIColor.blue
let redColor                           = UIColor.red
let clearColor                         = UIColor.clear
let whiteColor                         = UIColor.white
let buttonBorderColor                  = UIColor.black
let lineBackgroundColor                = UIColor(red: 50.0/255.0, green: 90.0/255.0, blue: 170.0/255.0, alpha: 1.0)
let segmentBackgroundColor             = UIColor(red: 237.0/255.0, green: 241.0/255.0, blue: 247.0/255.0, alpha: 1.0)
let lightGreenColor                    = UIColor(red: 129.0/255.0, green: 199.0/255.0, blue: 132.0/255.0, alpha: 1.0)
let darkGreenColor                     = UIColor(red: 16.0/255.0, green: 139.0/255.0, blue: 76.0/255.0, alpha: 1.0)


//MARK:-********************** FONT CONSTANT **********************

public struct SystemFontWeight {
    
    static let reguler    = UIFont.Weight.regular
    static let medium     = UIFont.Weight.medium
    static let semibold   = UIFont.Weight.semibold
    static let bold       = UIFont.Weight.bold
    static let light       = UIFont.Weight.light
}
enum proximanova: String {
    
    case Reguler   = "ProximaNovaRegular"  //ttf
    case SemiBold  = "proximanova-semibold-webfont"    //ttf
    case Bold      = "proximanova-bold-webfont"   //ttf
    case light     = "ProximaNova-Light"        //otf
}
enum SFUIText: String {
    
    case Reguler = ".SFUIText-Regular"
    case Medium  = ".SFUIText-Medium"
    case Bold    = ".SFUIText-Bold"
}
//Font Name
let proximanova_Regular               = proximanova.Reguler.rawValue
let proximanova_SemiBold              = proximanova.SemiBold.rawValue
let proximanova_Bold                  = proximanova.Bold.rawValue
let proximanova_Light                 = proximanova.light.rawValue

let FONT_SFUIText_Reguler              = SFUIText.Reguler.rawValue
let FONT_SFUIText_Medium               = SFUIText.Medium.rawValue
let FONT_SFUIText_Bold                 = SFUIText.Bold.rawValue

//Constant Font Size
let titleLabelFontSize                  : CGFloat = (DeviceType.IS_IPAD ? 27.0 : (DeviceType.IS_IPHONE_5 ? 21 : 23))
let largeButtonTitleFontSize            : CGFloat = (DeviceType.IS_IPAD ? 21.0 : (DeviceType.IS_IPHONE_5 ? 15 : 17))
let smallButtonTitleFontSize            : CGFloat = (DeviceType.IS_IPAD ? 20.0 : (DeviceType.IS_IPHONE_5 ? 14 : 16))


//********************** NOTIFICATION CONSTANT **********************

let notificationCenter                           = NotificationCenter.default
let notificationAppWillEnterInForeGround         = Notification.Name("AppWillEnterInForeGround")
let notificationInAppPurchaseDoneSuccessfully    = Notification.Name("InAppPurchaseDoneSuccessfully")
let notificationAppDidEnterInBackGround          = Notification.Name("AppDidEnterBackground")

//let keyboardWillShowNotificationName   = UIResponder.keyboardWillShowNotification
//let keyboardWillHideNotificationName   = UIResponder.keyboardWillHideNotification

//MARK:-********************** UI CONSTANT **********************

let MAIN_STORYBOARD                     = UIStoryboard(name: "Main", bundle: nil)

var defaultHeaderHeight                : CGFloat       = DeviceType.IS_IPHONE_X == true ? 88.0 : 64.0
let buttonInsets                       = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)


var largeButtonCornerRadius           : CGFloat       = 8.0
var smallButtonCornerRadius           : CGFloat       = 3


//MARK:- ********************** DEVICE INFORMATION **********************
struct ScreenSize {
    
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    
    static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_7          = IS_IPHONE_6
    static let IS_IPHONE_7P         = IS_IPHONE_6P
    static let IS_IPHONE_8          = IS_IPHONE_7
    static let IS_IPHONE_8P         = IS_IPHONE_7P
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH >= 812.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO_9_7      = IS_IPAD
    static let IS_IPAD_PRO_12_9     = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    static let IS_TV                = UIDevice.current.userInterfaceIdiom == .tv
    static let IS_CAR_PLAY          = UIDevice.current.userInterfaceIdiom == .carPlay
}

struct Version {
    
    static let SYS_VERSION_FLOAT    = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7                 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8                 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9                 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    static let iOS10                = (Version.SYS_VERSION_FLOAT >= 10.0 && Version.SYS_VERSION_FLOAT < 11.0)
    static let iOS11                = (Version.SYS_VERSION_FLOAT >= 11.0 && Version.SYS_VERSION_FLOAT < 12.0)
}



