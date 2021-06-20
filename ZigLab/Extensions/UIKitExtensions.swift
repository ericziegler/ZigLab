//
//  UIKitExtensions.swift
//

import UIKit

// MARK: Global Properties

func applyApplicationAppearanceProperties() {
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont.appFontOfSize(17)], for: .normal)
    UINavigationBar.appearance().tintColor = UIColor.main
    UINavigationBar.appearance().barTintColor = UIColor.appDark
    UISearchBar.appearance().setBackgroundImage(UIImage.from(color: UIColor(hex: 0xf4f4f7)), for: .any, barMetrics: .default)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont.appFontOfSize(13), NSAttributedString.Key.foregroundColor : UIColor.appLightLight], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont.appFontOfSize(13), NSAttributedString.Key.foregroundColor : UIColor.main], for: .selected)
    UITabBar.appearance().barTintColor = UIColor.appDark
}

func navTitleTextAttributes() -> [NSAttributedString.Key : Any] {
    return [NSAttributedString.Key.font : UIFont.appSemiBoldFontOfSize(21.0), .foregroundColor : UIColor.white]
}

// MARK: - UIImage

extension UIImage {

    func maskedWithColor(_ color: UIColor) -> UIImage? {
        var result: UIImage?

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

        if let context: CGContext = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            let rect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

            // flip coordinate system or else CGContextClipToMask will appear upside down
            context.translateBy(x: 0, y: rect.size.height);
            context.scaleBy(x: 1.0, y: -1.0);

            // mask and fill
            context.setFillColor(color.cgColor)
            context.clip(to: rect, mask: cgImage);
            context.fill(rect)

        }

        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

}

// MARK: - UIImageView

let imageCache = NSCache<NSString, UIImage>()

class RemoteImageView: UIImageView {

    var imageURL: String = ""

    func load(url: URL?) {
        guard let url = url else {
            return
        }

        imageURL = url.absoluteString
        if imageCache.object(forKey: imageURL as NSString) != nil {
            self.image = imageCache.object(forKey: imageURL as NSString)
        } else {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if self?.imageURL == url.absoluteString {
                            self?.image = image
                            imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        }
                    }
                }
            }
        }
    }

}

// MARK: - UIFont

extension UIFont {

    class func appFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Regular", size: size)!
    }

    class func appSemiBoldFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-SemiBold", size: size)!
    }

    class func appBoldFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: size)!
    }

    class func appLightFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Light", size: size)!
    }

    class func debugListFonts() {
        var families = [String]()
        for family: String in UIFont.familyNames {
            families.append(family)
        }
        families.sort { $0 < $1 }

        for curFamily in families {
            print(curFamily)
            var names = [String]()
            for curName: String in UIFont.fontNames(forFamilyName: curFamily) {
                names.append(curName)
            }
            names.sort { $0 < $1 }
            for curName in names {
                print("== \(curName)")
            }
        }
    }

}

// MARK: - UILabel

class AppStyleLabel : UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        preInit();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preInit()
    }

    func preInit() {
        if let text = self.text, text.hasPrefix("^") {
            self.text = nil
        }
        self.commonInit()
    }

    func commonInit() {
        if type(of: self) === AppStyleLabel.self {
            fatalError("AppStyleLabel not meant to be used directly. Use its subclasses.")
        }
    }
}

class RegularLabel: AppStyleLabel {
    override func commonInit() {
        self.font = UIFont.appFontOfSize(self.font.pointSize)
    }
}

class SemiBoldLabel: AppStyleLabel {
    override func commonInit() {
        self.font = UIFont.appSemiBoldFontOfSize(self.font.pointSize)
    }
}

class BoldLabel: AppStyleLabel {
    override func commonInit() {
        self.font = UIFont.appBoldFontOfSize(self.font.pointSize)
    }
}

class LightLabel: AppStyleLabel {
    override func commonInit() {
        self.font = UIFont.appLightFontOfSize(self.font.pointSize)
    }
}

class TopAlignedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        if let stringText = text, let font = font {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSAttributedString.Key.font: font],
                                                                    context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }

}

extension UILabel {

    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText

        let lengthForVisibleString: Int = self.visibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font!])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }

    var visibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }

}

// MARK: - UIButton

class AppStyleButton : UIButton {

    var isPulsing = false
//    var pulseAnimation: PulseAnimation?
    var cornerRadius: CGFloat = 0
    private var pulseView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        if type(of: self) === AppStyleButton.self {
            fatalError("AppStyleButton not meant to be used directly. Use its subclasses.")
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = (isEnabled == true) ? 1.0 : 0.5
        }
    }

    func startPulsing(radius: CGFloat = 20, speed: TimeInterval = 0.65) {
        if isPulsing == true {
            return
        }

        // add a view to be animated behind the button
        let pulsingView = UIView(frame: self.frame)
        pulsingView.backgroundColor = self.backgroundColor
        pulsingView.clipsToBounds = true
        pulsingView.layer.cornerRadius = self.layer.cornerRadius
        self.superview?.insertSubview(pulsingView, belowSubview: self)

        // based on the padding, determine the scale
        // this calculates the final scale for x scaling. it will be
        // recalculated for y scaling below
        var finalScale: Float = Float(self.bounds.width + radius) / Float(self.bounds.width)

        // setup x scaling
        let scaleXAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        scaleXAnimation.fromValue = NSNumber(value: 1)
        scaleXAnimation.toValue = NSNumber(value: finalScale)
        scaleXAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleXAnimation.duration = speed

        // setup y scaling
        finalScale = Float(self.bounds.height + radius) / Float(self.bounds.height)
        let scaleYAnimation = CABasicAnimation(keyPath: "transform.scale.y")
        scaleYAnimation.fromValue = NSNumber(value: 1)
        scaleYAnimation.toValue = NSNumber(value: finalScale)
        scaleYAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleYAnimation.duration = speed

        // setup fading
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = NSNumber(value: 0.8)
        fadeAnimation.toValue = NSNumber(value: 0)
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fadeAnimation.duration = speed

        // add all animations to a group. add the animation group to the pulse layer
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleXAnimation, scaleYAnimation, fadeAnimation]
        // add time to the duration of the animation group (0.5) to make sure that there is a delay between animation repeats
        animationGroup.duration = speed + 0.5
        animationGroup.repeatCount = .infinity
        pulsingView.layer.add(animationGroup, forKey: "pulseTest")

        pulseView = pulsingView
        isPulsing = true
    }

    func stopPulsing() {
        guard let pulseView = self.pulseView else {
            isPulsing = false
            return
        }

        DispatchQueue.main.async {
            pulseView.layer.removeAllAnimations()
            pulseView.removeFromSuperview()
            self.pulseView = nil
            self.isPulsing = false
        }
    }
    
}

class RegularButton: AppStyleButton {
    override func commonInit() {
        if let font = self.titleLabel?.font {
            self.titleLabel?.font = UIFont.appFontOfSize(font.pointSize)
        }
    }
}

class SemiBoldButton: AppStyleButton {
    override func commonInit() {
        if let font = self.titleLabel?.font {
            self.titleLabel?.font = UIFont.appSemiBoldFontOfSize(font.pointSize)
        }
    }
}

class BoldButton: AppStyleButton {
    override func commonInit() {
        if let font = self.titleLabel?.font {
            self.titleLabel?.font = UIFont.appBoldFontOfSize(font.pointSize)
        }
    }
}

class LightButton: AppStyleButton {
    override func commonInit() {
        if let font = self.titleLabel?.font {
            self.titleLabel?.font = UIFont.appLightFontOfSize(font.pointSize)
        }
    }
}

class ActionButton: SemiBoldButton {
    override func commonInit() {
        super.commonInit()
        self.layer.cornerRadius = 6
        updateAlpha()
    }

    override var isEnabled: Bool {
        didSet {
            updateAlpha()
        }
    }

    private func updateAlpha() {
        if isEnabled == true {
            self.alpha = 1
        } else {
            self.alpha = 0.5
        }
    }
}

class RecordButton: RegularButton {

    let recordCircle = UIView(frame: .zero)
    let stopSquare = UIView(frame: .zero)

    private var recordCircleWidthConstraint: NSLayoutConstraint!
    private var recordCircleHeightConstraint: NSLayoutConstraint!

    override func commonInit() {
        super.commonInit()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.backgroundColor = UIColor(hex: 0xeeeeee)
        addRecordCircle()
        addStopSquare()
    }

    private func addRecordCircle() {
        self.addSubview(recordCircle)
        recordCircle.backgroundColor = UIColor(hex: 0xff3e3e)
        recordCircle.translatesAutoresizingMaskIntoConstraints = false
        recordCircle.isUserInteractionEnabled = false
        self.addConstraint(NSLayoutConstraint(item: recordCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: recordCircle, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        recordCircleWidthConstraint = NSLayoutConstraint(item: recordCircle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.frame.size.width * 0.2)
        self.addConstraint(recordCircleWidthConstraint)
        recordCircleHeightConstraint = NSLayoutConstraint(item: recordCircle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.frame.size.height * 0.2)
        self.addConstraint(recordCircleHeightConstraint)
        recordCircle.layer.cornerRadius = recordCircleHeightConstraint.constant / 2
        recordCircle.clipsToBounds = true
    }

    private func addStopSquare() {
        self.addSubview(stopSquare)
        stopSquare.backgroundColor = UIColor.white
        stopSquare.translatesAutoresizingMaskIntoConstraints = false
        stopSquare.isUserInteractionEnabled = false
        self.addConstraint(NSLayoutConstraint(item: stopSquare, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stopSquare, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stopSquare, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.3, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stopSquare, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.3, constant: 0))
        stopSquare.alpha = 0
    }

    func startRecording() {
        recordCircleWidthConstraint.constant = self.frame.size.width
        recordCircleHeightConstraint.constant = self.frame.size.height
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
            self.stopSquare.alpha = 1
        }
    }

    func stopRecording() {
        recordCircleWidthConstraint.constant = self.frame.size.width * 0.2
        recordCircleHeightConstraint.constant = self.frame.size.height * 0.2
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
            self.stopSquare.alpha = 0
        }
    }

}

class CircleButton: RegularButton {
    override func commonInit() {
        super.commonInit()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
}

// MARK: - UIColor

extension UIColor {

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 08) / 255.0
        let b = CGFloat((hex & 0x0000FF) >> 00) / 255.0
        self.init(red:r, green:g, blue:b, alpha:alpha)
    }

    convenience init(intRed red: Int, green: Int, blue: Int, alpha: Int = 255) {
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        let a = CGFloat(alpha) / 255.0
        self.init(red:r, green:g, blue:b, alpha:a)
    }

    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }

    class var main: UIColor {
        return UIColor(hex: 0xEF3340)
    }

    class var appLightLight: UIColor {
        return UIColor(hex: 0xd9d9d9)
    }

    class var appLight: UIColor {
        return UIColor(hex: 0x969696)
    }

    class var appBorder: UIColor {
        return UIColor(hex: 0x242424)
    }

    class var appDarkDark: UIColor {
        return UIColor(hex: 0x050505)
    }

    class var appDark: UIColor {
        return UIColor(hex: 0x121212)
    }

}

// MARK: - UITextField

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }

    func addButtonOnKeyboardWithText(buttonText: String, onRightSide: Bool = true) -> UIBarButtonItem
    {
        let buttonToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        buttonToolbar.barStyle = UIBarStyle.default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let buttonItem: UIBarButtonItem = UIBarButtonItem(title: buttonText, style: UIBarButtonItem.Style.done, target: self, action: nil)

        var items = [UIBarButtonItem]()
        if onRightSide == true {
            items.append(flexSpace)
            items.append(buttonItem)
        } else {
            items.append(buttonItem)
            items.append(flexSpace)
        }

        buttonToolbar.items = items
        buttonToolbar.sizeToFit()

        self.inputAccessoryView = buttonToolbar

        return buttonItem
    }

}

class AppTextField : UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        self.backgroundColor = UIColor.white
        self.borderStyle = .none
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftViewMode = .always
        styleField()
    }

    func styleField(borderColor: UIColor = UIColor(hex: 0xcccccc), textColor: UIColor = UIColor.appDark, placeholderColor: UIColor = UIColor(hex: 0x999999), cornerRadius: CGFloat = 3, borderWidth: CGFloat = 1, font: UIFont = UIFont.appFontOfSize(13)) {
        self.font = font
        self.placeholderColor = placeholderColor
        self.textColor = textColor
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
    }
}

class StyledTextField : UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        self.borderStyle = .none
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftViewMode = .always
        styleBorderWithColor()
    }

    func styleBorderWithColor(color: UIColor = UIColor(hex: 0xdddddd), cornerRadius: CGFloat = 10, borderWidth: CGFloat = 1.5) {
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
    }
}

// MARK: - UITextView

class StyledTextView : UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        styleBorderWithColor()
    }

    func styleBorderWithColor(color: UIColor = UIColor(hex: 0xdddddd), cornerRadius: CGFloat = 10, borderWidth: CGFloat = 1.5) {
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
    }
}

// MARK: - UISegmentedControl

extension UISegmentedControl {
    // Tint color doesn't have any effect on iOS 13.
    func ensureiOS12Style() {
        if #available(iOS 13, *) {
            let tintColorImage = tintColor.image()
            // Must set the background image for normal to something (even clear) else the rest won't work
            let controlBackgroundColor: UIColor = backgroundColor ?? .clear
            setBackgroundImage(controlBackgroundColor.image(), for: .normal, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            let highlightedBackgroundColor: UIColor = tintColor.withAlphaComponent(0.2)
            setBackgroundImage(highlightedBackgroundColor.image(), for: .highlighted, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
            setTitleTextAttributes([.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
            setTitleTextAttributes([.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
        }
    }
}

// MARK: - UICollectionViewLayoutAttributes

extension UICollectionViewLayoutAttributes {

    func leftAlignWith(insets: UIEdgeInsets) {
        var frame = self.frame
        frame.origin.x = insets.left
        self.frame = frame
    }

}

// MARK: - UIView

extension UIView {

    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

    func fillInParentView(parentView: UIView) {
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false

        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: 0)
        parentView.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }

    static func createTableHeaderWith(title: String, tableView: UITableView, bgColor: UIColor? = UIColor.lightGray, titleColor: UIColor? = UIColor.black, font: UIFont? = UIFont.boldSystemFont(ofSize: 20)) -> UIView {
        let bg = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height))
        bg.backgroundColor = bgColor
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = title
        titleLabel.textColor = titleColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = font
        bg.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: bg, attribute: .leading, multiplier: 1, constant: 10)
        let trailingConstraint = NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: bg, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: bg, attribute: .top, multiplier: 1, constant: 10)
        let bottomConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: bg, attribute: .bottom, multiplier: 1, constant: 0)
        bg.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        return bg
    }

    var snapshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if (image != nil) {
            return image!
        }
        return UIImage()
    }

    static func snapshotAsView(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let snapshot : UIView = UIImageView(image: image)
        return snapshot
    }

    func rotate360Degrees(duration: CFTimeInterval = 0.4, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = duration

        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }

    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = CGAffineTransform(rotationAngle: radians)
        self.transform = rotation
    }

}

class GradientView: UIView {

    func updateGradientWith(firstColor: UIColor, secondColor: UIColor, vertical: Bool = true) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        if vertical == true {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

        // remove any previous gradient
        if let _ = layer.sublayers {
            layer.sublayers = nil
        }

        layer.insertSublayer(gradientLayer, at: 0)
    }

}

// MARK: - UISearchBar

extension UISearchBar {

    func getTextField() -> UITextField? {
        return value(forKey: "searchField") as? UITextField

    }

    func updateFieldColor(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.layer.borderWidth = 0.5
            textField.layer.cornerRadius = 6
        case .prominent, .default:
            textField.backgroundColor = color
        @unknown default: break
        }
    }

}

// MARK: - UISlider

class SnappingSlider: UISlider {

    override var value: Float {
        set { super.value = newValue }
        get {
            return round(super.value * 1.0) / 1.0
        }
    }

}
