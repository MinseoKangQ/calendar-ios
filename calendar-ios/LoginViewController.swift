//
//  LoginViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/6/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBAction func idEditingChanged(_ sender: UITextField) {
        
        if let id = idTextField.text {
            if id != "" {
                idTextField.layer.borderColor = CUSTOM_BLUE?.cgColor
            } else {
                idTextField.layer.borderColor = CUSTOM_GREY?.cgColor
            }
        }
    }
    
    @IBAction func pwEditingChanged(_ sender: UITextField) {
        
        if let pw = pwTextField.text {
            if pw != "" {
                pwTextField.layer.borderColor = CUSTOM_BLUE?.cgColor
            } else {
                pwTextField.layer.borderColor = CUSTOM_GREY?.cgColor
            }
        }
    }
    
    var isShowKeyboard = false
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue") // 007aff
    let CUSTOM_GREY = UIColor(named: "CustomGrey") // c7c7cd
    let CUSTOM_RED = UIColor(named: "CustomRed") // ff3b30
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        // textField 외의 곳을 터치하면 키보드 사라짐
        // ===== (start) Tap Gesture Recognizer 추가 =====
        let keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTapGesture)
        // ===== (end) Tap Gesture Recognizer 추가 =====
        
        
        // 회원가입 버튼 누르면 화면 전환
        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), for: .touchUpInside)
        
    }
    
    // 회원가입 화면 전환
    @objc func signUpBtnTapped() {
//        present(viewControllerToPresent: )
//        performSegue(withIdentifier: "gotoSignUp", sender: self)
    }
    
    // 키보드
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // 키보드
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 키보드가 나타날 때 실행 함수 등록
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { notification in
            
            // 이 함수는 키보드가 나타날 때 2번 연속으로 호출될 수 잇음
            if self.isShowKeyboard == false {
                self.isShowKeyboard = true
            }
        }
        
        // 키보드가 사라질 때 실행 함수 등록
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { notification in
            
            self.isShowKeyboard = false
        }
    }
    
    // 키보드
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // keyboardWillShowNotification 등록 해지
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object:nil)
        
        // keyboardWillHideNotification 등록 해지
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object:nil)
    }
    
    private func setupUI() {
        
        // ===== textField 관련 필드 =====
        idTextField.layer.cornerRadius = 14
        idTextField.layer.borderWidth = 1
        idTextField.layer.borderColor = CUSTOM_GREY?.cgColor
        idTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        idTextField.leftViewMode = .always
        
        pwTextField.layer.cornerRadius = 14
        pwTextField.layer.borderWidth = 1
        pwTextField.layer.borderColor = CUSTOM_GREY?.cgColor
        pwTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        pwTextField.leftViewMode = .always
        
        // ===== btn 관련 필드 =====
        loginBtn.layer.cornerRadius = 14
        loginBtn.layer.borderWidth = 1
        loginBtn.backgroundColor = CUSTOM_BLUE
        loginBtn.layer.borderColor = CUSTOM_BLUE?.cgColor
        
        signUpBtn.layer.cornerRadius = 14
        signUpBtn.layer.borderWidth = 1
        signUpBtn.layer.borderColor = CUSTOM_BLUE?.cgColor
        
        // ===== 비밀번호 관련 필드 =====
        pwTextField.isSecureTextEntry = true
        pwTextField.textContentType = .oneTimeCode
    }

}
