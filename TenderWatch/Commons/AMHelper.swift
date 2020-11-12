
import UIKit
import AVFoundation

class AMHelper: NSObject {

    //MARK:- Create Instance of Class
    class var sharedInstance: AMHelper {
        
        struct Static {
            static let instance = AMHelper()
        }
        return Static.instance
    }
    
    //MARK:- Adding UIComponent
    
    //Add Label
    func addLabel(frame: CGRect, textAlignment: NSTextAlignment, text: String, font: UIFont,textColor: UIColor, backGroundColor: UIColor) -> UILabel {
        
        let label                = UILabel(frame: frame)
        label.textAlignment      = textAlignment
        label.text               = text
        label.textColor          = textColor
        label.font               = font
        label.backgroundColor    = backGroundColor
        
        return label
    }
    
    func addButton(frame: CGRect, text: String, font: UIFont, textColor: UIColor, backGroundColor: UIColor, tintColor : UIColor) -> UIButton {
        
        let button: UIButton     = UIButton(frame: frame)
        button.backgroundColor   = backGroundColor
        button.titleLabel?.font  = font
        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        
        return button
    }
    
    //MARK:- Set Layout
    
    //Set Button Layout
    func setButtonLayout(button: UIButton, cornerRadius: CGFloat , BorderColor: UIColor, borderWidth: CGFloat) {
        
        button.layer.cornerRadius  = cornerRadius
        button.layer.borderColor   = BorderColor.cgColor
        button.layer.borderWidth   = borderWidth
        button.layer.masksToBounds = true
    }
    
    //Set ImageView Layout
    func setImageViewLayout(imaView: UIImageView, cornerRadius: CGFloat , BorderColor: UIColor, borderWidth: CGFloat) {
        
        imaView.layer.cornerRadius  = cornerRadius
        imaView.layer.borderColor   = BorderColor.cgColor
        imaView.layer.borderWidth   = borderWidth
        imaView.layer.masksToBounds = true
    }
    
    //Set Label Layout
    func setLabelLayout(label: UILabel, cornerRadius: CGFloat , BorderColor: UIColor, borderWidth: CGFloat) {
        
        label.layer.cornerRadius  = cornerRadius
        label.layer.borderColor   = BorderColor.cgColor
        label.layer.borderWidth   = borderWidth
        label.layer.masksToBounds = true
    }
    
    //Set View Layout
    func setViewLayout(view: UIView, cornerRadius: CGFloat , BorderColor: UIColor, borderWidth: CGFloat) {
        
        view.layer.cornerRadius  = cornerRadius
        view.layer.borderColor   = BorderColor.cgColor
        view.layer.borderWidth   = borderWidth
        view.layer.masksToBounds = true
    }
    
    //Set View Layout
    func setTextFieldLayout(textfield: UITextField, cornerRadius: CGFloat , BorderColor: UIColor, borderWidth: CGFloat) {
        
        textfield.layer.cornerRadius  = cornerRadius
        textfield.layer.borderColor   = BorderColor.cgColor
        textfield.layer.borderWidth   = borderWidth
        textfield.layer.masksToBounds = true
    }
    
    //Set TextField Property
    func setTextFieldProperty(textfield: UITextField, keyboardType: UIKeyboardType, returnKey: UIReturnKeyType, secureTextEntry: Bool)  {
        
        textfield.keyboardType             = keyboardType
        textfield.returnKeyType            = returnKey
        textfield.isSecureTextEntry        = secureTextEntry
        textfield.autocorrectionType       = .no
        textfield.spellCheckingType        = .no
    }
    
    
    //MARK:- Set Property
    
    //Set Font
    func setSystenFontOfSize(_ size: CGFloat , fontweight weight: UIFont.Weight) -> UIFont {
        
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    func setFontWithName(_ name: String, fontSize size: CGFloat) -> UIFont {
        
        return UIFont(name: name, size: size)!
    }
    
    //Set Image
    func setImage(imgView : UIImageView, WithImageName imageName : String) {
        
        imgView.image = UIImage(named: imageName)
    }
    
    //Set Placeholder Color...
    func setPlaceholderColor(_ textfield:UITextField, placeholderText : String, placeHolderColor : UIColor) {
        
        textfield.attributedPlaceholder = NSAttributedString(string:placeholderText,
                                                             attributes:[NSAttributedString.Key.foregroundColor:placeHolderColor])
    }
    
    //MARK:- Set & Get UI Property
    func getAttributedTitle(title : String) -> NSMutableAttributedString {
        
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: title as String, attributes: [NSAttributedString.Key.font:UIFont(name: FONT_SFUIText_Medium, size: 18.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: appColor, range: NSRange(location:0,length:title.count))
        
        return myMutableString
    }
    
    //Get Attributed String
    func getAttributedString(fromString: String, toString: String, withColor: UIColor)  -> NSMutableAttributedString {
        
        let main = fromString.lowercased()
        let sub = toString.lowercased()
        
        let range = (main as NSString).range(of: sub)
        let attribute = NSMutableAttributedString.init(string: fromString)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: withColor , range: range)
        
        return attribute
    }
    
    //MARK:- Get height & Width
    
    //Get Label Height
    func heightForLabel(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    //Get Label size
    func sizeForLabel(text: String, font: UIFont) -> CGSize {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.size
    }
    
    //Get Label Width
    func widthForLabel(text:String, font: UIFont, height: CGFloat) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.width
    }
    
    //Get Random String
    func getRandomString(ofNumber n: Int) -> String {
        
        let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" //String may change
        var s = ""
        
        for _ in 0..<n  {
            
            let r = Int(arc4random_uniform(UInt32(a.count)))
            s += String(a[a.index(a.startIndex, offsetBy: r)])
        }
        
        return s
    }
    
    //MARK:- Get String to Array
    func stringToArray(separateString : String, separatorBy separator: String) -> NSMutableArray {
        
        let array = NSMutableArray()
        let arr = separateString.components(separatedBy: separator)
        array.addObjects(from: arr)
        return array
    }
    
    //MARK:- String To Dictionary
    func stringToDictionary(text: String) -> [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //MARK:- Get UDID
    func getDiviceUDID() -> String {
        
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    //MARK:- Remove HTML ag
    func stringByStrippingHTML(string: String) -> String {
        
        let str = string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let stra = str.replacingOccurrences(of: "\n", with: "\n\n", options: .regularExpression, range: nil)
        return stra
    }
    
    
    //MARK:- Get Image Size
    func getframe(baseFrame: CGRect, containerFrame: CGRect) -> CGSize {
        
        let containerViewFrame = containerFrame
        var newSize = CGSize()
        
        let ratio = (baseFrame.width) / (baseFrame.height)
        
        if Int(baseFrame.width) >= Int(baseFrame.height) {
            
            let newHeight = containerViewFrame.width / ratio
            newSize = CGSize(width: containerViewFrame.width, height: newHeight)
        }
        else {
            
            if Int(baseFrame.width) <= Int(UIScreen.main.bounds.size.width) {
                
                let newHeight = containerViewFrame.width / ratio
                newSize = CGSize(width: UIScreen.main.bounds.size.width, height: newHeight)
            }
            else {
                
                let newWidth = UIScreen.main.bounds.size.width
                let newHeight = (baseFrame.height*newWidth)/baseFrame.width
                newSize = CGSize(width: newWidth, height: newHeight)
            }
        }
        
        print("Original Size \(baseFrame)")
        print("New Size : \(newSize)")
        
        return newSize
    }
    
    //MARK:- Get Video Frame Size
    func getVideoFrameSize(urlString: String) -> CGSize {
        
        var videoTrack: AVAssetTrack? = nil
        let asset : AVURLAsset? = (AVAsset(url: URL(string: urlString)!) as! AVURLAsset)
        var videoTracks: [Any]? = asset?.tracks(withMediaType: AVMediaType.video)
        
        if (videoTracks?.count)! > 0 {
            
            videoTrack = videoTracks?[0] as? AVAssetTrack
        }
        
        var trackDimensions = CGSize()
        trackDimensions.width = 0.0
        trackDimensions.height = 0.0
        trackDimensions = (videoTrack?.naturalSize)!
        
        let width: Int = Int(trackDimensions.width)
        let height: Int = Int(trackDimensions.height)
        print("Resolution = \(width) X \(height)")
        
        return trackDimensions
    }
    
    //MARK:- Register NIB
    
    //Register TableViewCell
    func registerTableViewCell(cellName : String , to tableView: UITableView) {
        
        let cellNIB = UINib(nibName: cellName, bundle: nil)
        tableView.register(cellNIB, forCellReuseIdentifier: cellName)
    }
    
    //Register CollectionViewCell
    func registerCollectionViewCell(cellName: String , to collectionView: UICollectionView)  {
        
        let cellNIB = UINib(nibName: cellName, bundle: nil)
        collectionView.register(cellNIB, forCellWithReuseIdentifier: cellName)
    }
    
    //MARK:- Date Conversation Methods
    func getStringFromDate(date : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        let dateString = dateFormatter.string(from: date as Date)
        return dateString
    }
    
    func getdateFromString(dateString : String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let dateObj = dateFormatter.date(from: dateString)
        return dateObj!
    }
    
//    func getdateFromStringforOrder(dateString : String) -> Date {
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//        let dateObj = dateFormatter.date(from: dateString)
//        return dateObj!
//    }
    
}
//

/*
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

*/
