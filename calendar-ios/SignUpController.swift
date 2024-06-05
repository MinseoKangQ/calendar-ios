//
//  SignUpController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/5/24.
//

import UIKit

class SignUpController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwCheckTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var pwLabel: UILabel!
    @IBOutlet weak var pwCheckLabel: UILabel!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // blue : 007aff
        // placeholder default : c7c7cd
        
        // UI
        emailTextField.layer.cornerRadius = 14
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor(hexCode: "c7c7cd").cgColor
        emailTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        emailTextField.leftViewMode = .always
        
        idTextField.layer.cornerRadius = 14
        idTextField.layer.borderWidth = 1
        idTextField.layer.borderColor = UIColor(hexCode: "c7c7cd").cgColor
        idTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        idTextField.leftViewMode = .always
        
        pwTextField.layer.cornerRadius = 14
        pwTextField.layer.borderWidth = 1
        pwTextField.layer.borderColor = UIColor(hexCode: "c7c7cd").cgColor
        pwTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        pwTextField.leftViewMode = .always
        
        pwCheckTextField.layer.cornerRadius = 14
        pwCheckTextField.layer.borderWidth = 1
        pwCheckTextField.layer.borderColor = UIColor(hexCode: "c7c7cd").cgColor
        pwCheckTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        pwCheckTextField.leftViewMode = .always
        
        // 버튼
        signUpBtn.layer.cornerRadius = 14
        signUpBtn.layer.borderWidth = 1
        signUpBtn.backgroundColor = UIColor(hexCode: "007aff")
        signUpBtn.layer.borderColor = UIColor(hexCode: "007aff").cgColor
        
        homeBtn.layer.cornerRadius = 14
        homeBtn.layer.borderWidth = 1
        homeBtn.layer.borderColor = UIColor(hexCode: "007aff").cgColor
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// Hex
extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
