//
//  LoginViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/6/24.
//

import UIKit

class LoginViewController: UIViewController {

    // Outlets
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    // 아이디 입력 변경 시 호출
    @IBAction func idEditingChanged(_ sender: UITextField) {
        if let id = idTextField.text {
            idTextField.layer.borderColor = id.isEmpty ? CUSTOM_GREY?.cgColor : CUSTOM_BLUE?.cgColor
        }
    }
    
    // 비밀번호 입력 변경 시 호출
    @IBAction func pwEditingChanged(_ sender: UITextField) {
        if let pw = pwTextField.text {
            pwTextField.layer.borderColor = pw.isEmpty ? CUSTOM_GREY?.cgColor : CUSTOM_BLUE?.cgColor
        }
    }
    
    // 로그인 버튼 클릭 시 호출
    @IBAction func loginBtnAction(_ sender: UIButton) {
        guard let userId = idTextField.text, let password = pwTextField.text else {
            return
        }
        
        // 로그인 API 호출
        ApiService.signIn(userId: userId, password: password) { statusCode in
            DispatchQueue.main.async {
                self.handleLoginResponse(statusCode)
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        
        // 키보드
        setupKeyboardNotifications()
        idTextField.delegate = self
        pwTextField.delegate = self
    }
    
    // 회원가입 화면 전환
    @objc func signUpBtnTapped() {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // 로그인 응답 처리
    func handleLoginResponse(_ statusCode: Int) {
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
        
    // 로그인 실패 시 뜨는 Alert 창
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // RootViewController 변경
    func changeRootViewController(_ viewControllerToPresent: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewControllerToPresent
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        } else {
            viewControllerToPresent.modalPresentationStyle = .overFullScreen
            self.present(viewControllerToPresent, animated: true, completion: nil)
        }
    }
    
    // 옵저버 제거
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 옵저버 등록
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 보이기
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            // 필요한 경우 키보드 높이를 이용해 추가 동작 수행 가능
        }
    }
    
    // 키보드 숨기기
    @objc func keyboardWillHide(notification: NSNotification) {
    }
    
    // 화면 터치 시 키보드 숨기기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // UI 설정
    private func setupUI() {
        configureTextField(idTextField)
        configureTextField(pwTextField, isSecure: true)
        loginBtn.isEnabled = true
        signUpBtn.isEnabled = true
    }
    
    // 텍스트 필드 설정
    private func configureTextField(_ textField: UITextField, isSecure: Bool = false) {
        textField.layer.cornerRadius = 14
        textField.layer.borderWidth = 1
        textField.layer.borderColor = CUSTOM_GREY?.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .always
        if isSecure {
            textField.isSecureTextEntry = true
            textField.textContentType = .oneTimeCode
        }
    }
    
    // GestureRecognizer 설정
    private func setupGestureRecognizers() {
        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), for: .touchUpInside)
        let keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTapGesture)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Return 키를 눌렀을 때 키보드가 사라지게 함
        return true
    }
}
