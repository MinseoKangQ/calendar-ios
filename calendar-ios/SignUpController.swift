//
//  SignUpController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/5/24.
//

import UIKit

// TODO: 1) 회원가입 버튼 일단 비활성화
// TODO: 2) 모든 필드가 파란색이면 회원가입 버튼 활성화
// TODO: 3) 회원가입 누르면 "회원가입이 완료되었습니다! 로그인" 화면으로 넘어가기
// TODO: 4) 홈으로 누르면 이전 화면으로 넘어가기
// TODO: 5) textField가 아닌 다른 곳 누르면 키보드 사라지게 하기

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
    
    // ===== 각 필드들의 값이 바뀔 때 마다 API 호출 필요 =====
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        print(emailTextField.text!)
        
        // TODO: 1) (400) 이메일 형식이 맞지 않다면
        // - emailLabel "이메일 형식을 맞춰주세요."
        // - emailTextField.layer.borderColor = UIColor(hexCode: "ff3b30").cgColor -> 빨간색
        
        // TODO: 2) (409) 이메일 형식이 맞는데 중복되었다면
        // - emailLabel "사용할 수 없는 이메일입니다."
        // - emailTextField.layer.borderColor = UIColor(hexCode: "ff3b30").cgColor -> 빨간색
        
        // TODO: 3) (200) 사용 가능한 이메일이라면
        // - emailLabel "사용 가능한 이메일입니다."
        // - emailTextField.layer.borderColor = UIColor(hexCode: "007aff").cgColor -> 파란색
    }
    
    @IBAction func idEditingChanged(_ sender: UITextField) {
        print(idTextField.text!)
        
        // TODO: 1) (400) 영소문자 + 숫자 조합 7자 이상이 아니라면
        // - idLabel "아이디는 영소문자 + 숫자 조합으로 7자 이상이어야 합니다."
        // - idTextField.layer.borderColor = UIColor(hexCode: "ff3b30").cgColor -> 빨간색
        
        // TODO: 2) (409) 중복된 아이디라면
        // - idLabel "이미 사용중인 아이디입니다."
        // - idTextField.layer.borderColor = UIColor(hexCode: "ff3b30").cgColor -> 빨간색
        
        // TODO: 3) (200) 사용 가능한 이메일이라면
        // - idLabel "사용 가능한 아이디입니다."
        // - idTextField.layer.borderColor = UIColor(hexCode: "007aff").cgColor -> 파란색
        
    }
    
    @IBAction func pwEditingChanged(_ sender: UITextField) {
        print(pwTextField.text!)
        
        // API(X) => iOS에서 검증
        if let password = pwTextField.text {
            if isPasswordValid(password) {
                // 사용 가능한 비밀번호라면
                pwLabel.text = "사용 가능한 비밀번호입니다."
                pwLabel.textColor = UIColor(hexCode: "007aff")
                pwTextField.layer.borderColor = UIColor(hexCode: "007aff").cgColor
            } else {
                // 영대문자 + 특수문자 + 숫자 + 영소문자 조합에 맞지 않다면
                pwLabel.text = "비밀번호는 영대문자 + 특수문자 + 숫자 + 영소문자 조합이어야 합니다."
                pwLabel.textColor = UIColor(hexCode: "ff3b30")
                pwTextField.layer.borderColor = UIColor(hexCode: "ff3b30").cgColor
            }
        }
    }
    
    @IBAction func pwCheckEditingChanged(_ sender: UITextField) {
        print(pwCheckTextField.text!)
        
        // API(X) => iOS에서 검증
        
        if let pwCheckText = pwCheckTextField.text, let pwText = pwTextField.text {
            if pwCheckText == pwText {
                if isPasswordValid(pwCheckText) {
                    // 비밀번호가 일치하고 조건을 만족하는 경우
                    pwCheckLabel.text = "비밀번호가 일치합니다."
                    pwCheckLabel.textColor = UIColor(hexCode: "007aff")
                    pwCheckTextField.layer.borderColor = UIColor(hexCode: "007aff").cgColor
                } else {
                    // 비밀번호가 일치하지만 조건을 만족하지 않는 경우
                    pwCheckLabel.text = "비밀번호는 영대문자 + 특수문자 + 숫자 + 영소문자 조합이어야 합니다."
                    pwCheckLabel.textColor = UIColor(hexCode: "ff3b30")
                    pwCheckTextField.layer.borderColor = UIColor(hexCode: "ff3b30").cgColor
                }
            } else {
                // 비밀번호가 일치하지 않는 경우
                pwCheckLabel.text = "비밀번호가 일치하지 않습니다."
                pwCheckLabel.textColor = UIColor(hexCode: "ff3b30")
                pwCheckTextField.layer.borderColor = UIColor(hexCode: "ff3b30").cgColor
            }
        }
    }
    
    // 비밀번호 검증 메소드
    func isPasswordValid(_ password: String) -> Bool {
        // 최소 하나의 영대문자, 영소문자, 숫자, 특수문자를 포함하는 정규식
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // blue : 007aff
        // placeholder default : c7c7cd
        // red : ff3b30
        
        // ===== UI =====
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
        
        // ===== UI =====
        
        // ===== 비밀번호 관련 필드 =====
        pwTextField.isSecureTextEntry = true
        pwTextField.textContentType = .oneTimeCode
        pwCheckTextField.isSecureTextEntry = true
        pwCheckTextField.textContentType = .oneTimeCode
        // ===== 비밀번호 관련 필드 =====
        
    }

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
