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
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue")
    let CUSTOM_GREY = UIColor(named: "CustomGrey")
    let CUSTOM_RED = UIColor(named: "CustomRed")
    let CUSTOM_WHITE = UIColor(named: "CustomWhite")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
//        resetLoginUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // textField 외의 곳을 터치하면 키보드 사라짐
        let keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTapGesture)
        
    }
    
    // 회원가입 화면 전환
    @objc func signUpBtnTapped() {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        guard let userId = idTextField.text, let password = pwTextField.text else {
            return
        }
        
        ApiService.signIn(userId: userId, password: password) { statusCode in
            DispatchQueue.main.async {
                switch statusCode {
                case 201:
                    let newStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = newStoryboard.instantiateViewController(identifier: "TabBarController")
                    self.changeRootViewController(newViewController)
                case 404:
                    self.showAlert(message: "존재하지 않는 아이디입니다.")
                case 400:
                    self.showAlert(message: "비밀번호가 일치하지 않습니다.")
                default:
                    self.showAlert(message: "알 수 없는 오류가 발생했습니다.")
                }
            }
        }
    }
        
    // 로그인 실패 시 뜨는 Alert 창
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changeRootViewController(_ viewControllerToPresent: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewControllerToPresent
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        } else {
            viewControllerToPresent.modalPresentationStyle = .overFullScreen
            self.present(viewControllerToPresent, animated: true, completion: nil)
        }
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
        
        // 회원가입 버튼 누르면 화면 전환
        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), for: .touchUpInside)
        
        // 텍스트 필드 초기화
        idTextField.text = ""
        pwTextField.text = ""
        
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
        loginBtn.isEnabled = true
        signUpBtn.isEnabled = true

        // ===== 비밀번호 관련 필드 =====
        pwTextField.isSecureTextEntry = true
        pwTextField.textContentType = .oneTimeCode
    }

}
