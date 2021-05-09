import UIKit
import VGSShowSDK

@objc(VgsShowReactNativeViewManager)
class VgsShowReactNativeViewManager: RCTViewManager {
    
    override func view() -> (VgsShowReactNativeView) {
        return VgsShowReactNativeView()
    }
    
    @objc(revealData:path:method:payload:resolver:rejecter:) func revealData(_ node: NSNumber, path: String, method: String, payload: VGSJSONData, resolver resolve: @escaping RCTPromiseResolveBlock,
                                                                             rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let component = self.bridge.uiManager.view(
                forReactTag: node
            ) as! VgsShowReactNativeView
            component.revealData(path: path, method: method, payload: payload, resolve: resolve, reject: reject)
        }
    }
}

class VgsShowReactNativeView : UIView, VGSLabelDelegate {
    var vgsShow: VGSShow?;
    let attributeLabel = VGSLabel()
    
    @objc var initParams: NSDictionary = NSDictionary() {
        didSet {
            let vaultId = initParams["vaultId"] as! String;
            let environment = initParams["environment"] as! String;
            let customHeaders = initParams.object(forKey: "customHeaders") != nil ? initParams["customHeaders"] as! Dictionary<String, String> : [:];
            
            if (vaultId != nil && environment != nil) {
                if (environment == "live") {
                    vgsShow = VGSShow(id: vaultId, environment: .live);
                    vgsShow!.subscribe(attributeLabel)
                } else if (environment == "sandbox") {
                    vgsShow = VGSShow(id: vaultId, environment: .sandbox);
                    vgsShow!.subscribe(attributeLabel)
                }
                
                if (vgsShow != nil) {
                    vgsShow?.customHeaders = customHeaders;
                }
            }
        }
    }
    
    @objc var textColor: String = "" {
        didSet {
            let color = hexStringToUIColor(hex: textColor);
            attributeLabel.textColor = color;
            attributeLabel.placeholderStyle.color = color;
        }
    }

    
    @objc var placeholderColor: String = "" {
        didSet {
            attributeLabel.placeholderStyle.color = hexStringToUIColor(hex: placeholderColor)
        }
    }
    
    @objc var bgColor: String = "" {
        didSet {
            attributeLabel.backgroundColor = hexStringToUIColor(hex: bgColor)
        }
    }
    
    @objc var borderColor: String = "" {
        didSet {
            attributeLabel.borderColor = hexStringToUIColor(hex: borderColor)
        }
    }
    
    @objc var placeholder: String = "" {
        didSet {
            attributeLabel.placeholder = placeholder;
        }
    }
    
    @objc var contentPath: String = "" {
        didSet {
            attributeLabel.contentPath = contentPath;
        }
    }
    
    @objc var fontFamily: String = "" {
        didSet {
            let font = UIFont.init(name: fontFamily, size: fontSize);
            attributeLabel.font = font;
            attributeLabel.placeholderStyle.font = font;
        }
    }
    
    @objc var fontSize: CGFloat = 16 {
        didSet {
            var font: UIFont?;
            
            if (fontFamily == "") {
                font = UIFont.systemFont(ofSize: fontSize);
            } else {
                font = UIFont.init(name: fontFamily, size: fontSize);
            }
            
            attributeLabel.font = font;
            attributeLabel.placeholderStyle.font = font;
        }
    }
    
    @objc var characterSpacing: CGFloat = 0.83 {
        didSet {
            attributeLabel.characterSpacing = characterSpacing;
        }
    }
    
    @objc var borderRadius: CGFloat = 0 {
        didSet {
            attributeLabel.layer.cornerRadius = borderRadius;
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createVgsShow();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createVgsShow() {
        let stackView = UIStackView.init(arrangedSubviews: [attributeLabel])
        stackView.axis = .vertical
        
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
        
        attributeLabel.delegate = self
    }
    
    @objc func revealData(path: String, method: String, payload: VGSJSONData,
                          resolve: @escaping RCTPromiseResolveBlock,
                          reject: @escaping RCTPromiseRejectBlock) {
        if (vgsShow == nil) {
            return;
        }
        
        print("vgsshow revealData, path: \(path), method= \(method), payload = \(payload)")
        
        vgsShow!.request(path: path,
                         method: method == "post" ? .post : .get,
                         payload: method == "post" ? payload : nil) { (requestResult) in
            
            switch requestResult {
            case .success(let code):
                print("vgsshow success, code: \(code)")
                
                resolve(code);
            case .failure(let code, let error):
                print("vgsshow failed, code: \(code), error: \(error)")
                reject("error", error?.localizedDescription, error)
            }
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.hasPrefix("TRANSPARENT")) {
            return UIColor.clear;
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
