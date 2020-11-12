
import Foundation
import SystemConfiguration
import UIKit
import SDWebImage

//MARK:- *************Extension For UIView *****************
extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addShadow(color: UIColor, opacity: Float = 0.6, offSet: CGSize, radius: CGFloat = 5.0, scale: Bool = true) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.cornerRadius = 2.0
    }
    
    
    func dropShadow(offsetX: CGFloat, offsetY: CGFloat, color: UIColor, opacity: Float, radius: CGFloat, scale: Bool = true) {
        //        layer.masksToBounds = false
        //        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        //        layer.shadowColor = color.cgColor
        //        layer.shadowOpacity = opacity
        //        layer.shadowRadius = radius
        //        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        //        layer.shouldRasterize = true
        //        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        
        
        layer.masksToBounds = false
        
        layer.shadowColor = color.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        
    }
    
    //    func roundPerticularCorners(corners: UIRectCorner, radius: CGFloat) {
    //        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    //        let mask = CAShapeLayer()
    //        mask.frame = bounds
    //        mask.path = path.cgPath
    //        layer.mask = mask
    //
    //    }
    
    func roundPerticularCorners(corners: UIRectCorner, radius: CGFloat ,bordercolor : UIColor , borderwidth : CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path // Reuse the Bezier path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = bordercolor.cgColor
        borderLayer.lineWidth = borderwidth
        
        
        layer.addSublayer(borderLayer)
        
    }
    
    
    func dashedLineWithRoundCorner(corners: UIRectCorner, radius: CGFloat ,bordercolor : UIColor , borderwidth : CGFloat)
    {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
        
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.lineDashPattern = [2, 2]
        borderLayer.fillColor = nil
        borderLayer.path = mask.path
        
        layer.addSublayer(borderLayer)
        
    }
    
    
    
    func setRoundCornerRadius() -> CGFloat {
        
        return self.frame.size.width / 2
    }
    
    func Set_Corner_image(width:CGFloat,height:CGFloat,Corners:UIRectCorner) {
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: Corners, cornerRadii: CGSize(width: width, height: height)).cgPath
        self.layer.mask = rectShape
        
    }
    
    func Set_Corner_image_withborder(width:CGFloat,height:CGFloat,Corners:UIRectCorner) {
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: Corners, cornerRadii: CGSize(width: width, height: height)).cgPath
        self.layer.mask = rectShape
        self.layer.borderWidth = 1.0
        
    }
    var Getwidth : CGFloat {
        get { return self.frame.size.width  }
        set { self.frame.size.width = newValue }
    }
    
    var Getheight : CGFloat {
        get { return self.frame.size.height  }
        set { self.frame.size.height = newValue }
    }
    
    var Getsize:       CGSize  { return self.frame.size}
    
    var Getorigin:     CGPoint { return self.frame.origin }
    var Getx : CGFloat {
        get { return self.frame.origin.x  }
        set { self.frame.origin.x = newValue }
    }
    
    var Gety : CGFloat {
        get { return self.frame.origin.y  }
        set { self.frame.origin.y = newValue }
    }
    
    
    var Getleft:       CGFloat { return self.frame.origin.x }
    var Getright:      CGFloat { return self.frame.origin.x + self.frame.size.width }
    var Gettop:        CGFloat { return self.frame.origin.y }
    var Getbottom:     CGFloat { return self.frame.origin.y + self.frame.size.height }
    
    
    
    //scale view
    func scale(by scale: CGFloat) {
        self.contentScaleFactor = scale
        for subview in self.subviews {
            subview.scale(by: scale)
        }
    }
    
    
    //get screenshot image from view
    func getImage(scale: CGFloat? = nil) -> UIImage {
        
        
        //        let newScale = scale ?? UIScreen.main.scale
        //        self.scale(by: newScale)
        //
        //        let format = UIGraphicsImageRendererFormat()
        //        format.scale = newScale
        //
        //        let renderer = UIGraphicsImageRenderer(size: self.bounds.size, format: format)
        //
        //        let image = renderer.image { rendererContext in
        //            self.layer.render(in: rendererContext.cgContext)
        //        }
        //
        //        return image
        
        
        
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
    
}


//MARK:- ************* Extension For Image *****************

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//MARK:- ************* Extension For ImageView *****************
extension UIImageView {
    
    func setImageWithActivityIndicator(imageURL : String,indicatorStyle : SDWebImageActivityIndicator,placeHolderImage:UIImage) {
        
        self.sd_imageIndicator = indicatorStyle
        self.sd_setImage(with: URL(string: imageURL), placeholderImage: placeHolderImage)
    }
    
}

//MARK:- ************* Extension For Convert HTML to String Formet *****************

extension Data {
    
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

//MARK:- ************* Extension For Cheack valid Dictionary or JSON *****************

extension Dictionary {
    
    var json: String {
        
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    var jsonwithRawdata : String {
        
        let cookieHeader = (self.compactMap({ (key, value) -> String in
            return "\"\(key)\":\"\(value)\""
        }) as Array).joined(separator: ",")
        
        let contentString = "{" + cookieHeader + "}"
        
        return contentString
    }
    
    
    func printJson() {
        
        print(jsonwithRawdata)
    }
}
//MARK:- ************* Extension For URL *****************
extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

//MARK:- ************* Extension For String (Localization,Cheack Only Number, Index of and Other All..)*****************
extension String {
    
    
    var expression: NSExpression {
        return NSExpression(format:self)
    }
    
    //    func localized(withComment comment: String? = nil) -> String
    //    {
    //        return NSLocalizedString(self, comment: comment ?? "")
    //    }
    
    func localized() -> String
    {
        var defaultLanguage = String()
        if UserDefaults.standard.value(forKey: "getSelectedLanguage") == nil
        {
            defaultLanguage = "en"
        }
        else
        {
            defaultLanguage = "\(UserDefaults.standard.value(forKey: "getSelectedLanguage")!)"
        }
        print(defaultLanguage)
        guard let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj") else {return ""}
        print(path)
        let bundle = Bundle(path: path)
        print(bundle!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    
    func strikeThrough()->NSAttributedString{
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    
    func isContainsNumbers() -> Bool {
        
        let numberRegEx  = ".*[0-9]+.*"
        let testCase     = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return testCase.evaluate(with: self)
    }
    
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    
    var length:Int {
        
        return self.count
    }
    
    func indexOf(target: String) -> Int? {
        
        let range = (self as NSString).range(of: target)
        
        guard Range.init(range) != nil else{
            return nil
        }
        
        return range.location
        
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    var isNumeric: Bool {
        
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    /*
     var md5: String? {
     guard let data = self.data(using: String.Encoding.utf8) else { return nil }
     
     let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
     var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
     CC_MD5(bytes, CC_LONG(data.count), &hash)
     return hash
     }
     let lastdata = NSData(bytes: hash, length: hash.count)
     
     return lastdata.base64EncodedString()
     }
     */
    func isNullOrWhiteSpace() -> Bool {
        
        if self.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
            return false
        }
        
        return true
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    
    func getHeightForString(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func getWidthForString(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    
    func base64ToImage() -> UIImage{
        if (self.isEmpty) {
               return #imageLiteral(resourceName: "ic_AppIcon")
           }else {
               // !!! Separation part is optional, depends on your Base64String !!!
               //          let temp = base64String?.components(separatedBy: ",")
               let dataDecoded : Data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)!
               let decodedimage = UIImage(data: dataDecoded)
               return decodedimage!
           }
       }
}


//MARK:- ************* Extension For Date(Date Formatter and Other All Formets) *****************

extension Date {
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
    
    /// Convert Date into specified formate
    func formateDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
/*
 extension UISearchBar {
 sss
 func changeSearchBarColor() {
 
 if let textfield = self.value(forKey: "searchField") as? UITextField {
 
 textfield.font = UIComponantManager.setSystenFontOfSize(15.0, fontweight: SystemFontWeight.reguler)
 
 if let backgroundview = textfield.subviews.first {
 
 backgroundview.backgroundColor = UIColor.white
 backgroundview.layer.cornerRadius = 10;
 backgroundview.clipsToBounds = true;
 }
 }
 }
 }
 */

//MARK:- ************* Extension For NSAttributed String *****************

extension NSAttributedString {
    
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

extension UIViewController {
    
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
    
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

func getCurrentViewController()-> UIViewController{
    
    return UIApplication.shared.topMostViewController()!
}





//MARK:- *************IBDesignable For Buttons for Corner Redius *****************

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}





//MARK:- ******************** IBDesignable Class For Textfield ************************
@IBDesignable
public class DesignableTextfield : UITextField {
    
    // MARK: - IBInspectable properties
    /// Applies border to the text view with the specified width
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor
        }
    }
    
    /// Sets the color of the border
    @IBInspectable public var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    /// Make the corners rounded with the specified radius
    @IBInspectable public var cornerRadiustext: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    /// Applies underline to the text view with the specified width
    @IBInspectable public var underLineWidth: CGFloat = 0.0 {
        didSet {
            updateUnderLineFrame()
        }
    }
    
    /// Sets the underline color
    @IBInspectable public var underLineColor: UIColor = .groupTableViewBackground {
        didSet {
            updateUnderLineUI()
        }
    }
    
    /// Sets the placeholder color
    @IBInspectable public var placeholderColor: UIColor = .lightGray {
        didSet {
            let placeholderStr = placeholder ?? ""
            attributedPlaceholder = NSAttributedString(string: placeholderStr, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        }
    }
    
    public override var placeholder: String? {
        didSet {
            let placeholderStr = placeholder ?? ""
            attributedPlaceholder = NSAttributedString(string: placeholderStr, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        }
    }
    
    /// Sets left margin
    @IBInspectable public var leftMargin: CGFloat = 10.0 {
        didSet {
            setMargins()
        }
    }
    
    /// Sets right margin
    @IBInspectable public var rightMargin: CGFloat = 10.0 {
        didSet {
            setMargins()
        }
    }
    
    // MARK: - init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        applyStyles()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyStyles()
    }
    
    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateUnderLineFrame()
        updateAccessoryViewFrame()
    }
    
    // MARK: - Styles
    private func applyStyles() {
        applyUnderLine()
        setMargins()
    }
    
    // MARK: - Underline
    private var underLineLayer = CALayer()
    private func applyUnderLine() {
        // Apply underline only if the text view's has no borders
        if borderStyle == UITextField.BorderStyle.none {
            underLineLayer.removeFromSuperlayer()
            updateUnderLineFrame()
            updateUnderLineUI()
            layer.addSublayer(underLineLayer)
            layer.masksToBounds = true
        }
    }
    
    private func updateUnderLineFrame() {
        var rect = bounds
        rect.origin.y = bounds.height - underLineWidth
        rect.size.height = underLineWidth
        underLineLayer.frame = rect
    }
    
    private func updateUnderLineUI() {
        underLineLayer.backgroundColor = underLineColor.cgColor
    }
    
    // MARK: - Margins
    private var leftAcessoryView = UIView()
    private var rightAcessoryView = UIView()
    private func setMargins() {
        // Left Margin
        leftView = nil
        leftViewMode = .never
        if leftMargin > 0 {
            if nil == leftView {
                leftAcessoryView.backgroundColor = .clear
                leftView = leftAcessoryView
                leftViewMode = .always
            }
        }
        updateAccessoryViewFrame()
        
        // Right Margin
        rightView = nil
        rightViewMode = .never
        if rightMargin > 0 {
            if nil == rightView {
                rightAcessoryView.backgroundColor = .clear
                rightView = rightAcessoryView
                rightViewMode = .always
            }
            updateAccessoryViewFrame()
        }
    }
    
    private func updateAccessoryViewFrame() {
        // Left View Frame
        var leftRect = bounds
        leftRect.size.width = leftMargin
        leftAcessoryView.frame = leftRect
        // Right View Frame
        var rightRect = bounds
        rightRect.size.width = rightMargin
        rightAcessoryView.frame = rightRect
    }
    
}



//MARK:- *****************************  IBDesignableclass For UIview ***************************

public class DesignableView : UIView
{
    @IBInspectable var cornerRadiusview: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
    @IBInspectable var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
}


//MARK:- *****************************  IBDesignableclass For UIlable Edges ***************************

@IBDesignable class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        
        let insetRect = bounds.inset(by: textInsets)
        //        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        
        return textRect.inset(by: invertedInsets)
        
        //        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        
        super.drawText(in: rect.inset(by: textInsets))
        //        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}

extension EdgeInsetLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}



//MARK:- *****************************  IBDesignableclass For Round UISegemented Control ***************************


//@IBDesignable
class RoundSegmented: UISegmentedControl {
    
    @IBInspectable var background: UIColor = UIColor.clear {
        didSet {
            backgroundColor = background
        }
    }
    
    @IBInspectable var tint: UIColor = UIColor.clear {
        didSet {
            tintColor = tint
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setupUI()
    }
    
    func setupUI() {
        layer.cornerRadius =  Getheight / 2 //CGRectGetHeight(bounds) / 2
        setDividerImage(UIImage(), forLeftSegmentState: UIControl.State.normal, rightSegmentState: UIControl.State.normal, barMetrics: UIBarMetrics.default)
        trimEdges()
    }
    
    func trimEdges() {
        let mask = CAShapeLayer()
        mask.frame = CGRect(x: 1, y: 1, width:  bounds.size.width - 4, height:  bounds.size.height - 4)//CGRectMake(1, 1, bounds.size.width - 4, bounds.size.height - 4)
        mask.path = UIBezierPath(roundedRect: mask.frame, cornerRadius: Getheight / 2).cgPath
        layer.mask = mask
    }
}


//MARK:- ************************ IBDesignable Class For UILable *********************************

