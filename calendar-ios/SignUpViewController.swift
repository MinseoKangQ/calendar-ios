//
//  SignUpController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/5/24.
//

import UIKit


class SignUpViewController: UIViewController  {

    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwCheckTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var pwLabel: UILabel!
    @IBOutlet weak var pwCheckLabel: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue")
    let CUSTOM_GREY = UIColor(named: "CustomGrey")
    let CUSTOM_RED = UIColor(named: "CustomRed")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        setupSignUpButton()
        
        // 키보드
        setupKeyboardNotifications()
        emailTextField.delegate = self
        idTextField.delegate = self
        pwTextField.delegate = self
        pwCheckTextField.delegate = self
    }
    
    // 다시 로그인 화면으로 돌아가기
    // https://eunoia3jy.tistory.com/210 참고함
    @IBAction func unwindToVC(_ segue: UIStoryboardSegue) {
        self.navigationController?.popViewController(animated: true)
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
            _ = keyboardFrame.cgRectValue.height
        }
    }
    
    // 키보드 숨기기
    @objc func keyboardWillHide(notification: NSNotification) {
    }
    
    // 화면 터치 시 키보드 숨기기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 이메일 입력 변경 시 호출
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        guard let email = emailTextField.text else { return }
        ApiService.checkEmailDuplicated(email: email) { statusCode in
            DispatchQueue.main.async {
                self.updateEmailValidationStatus(statusCode: statusCode)
            }
        }
    }
    
    // 아이디 입력 변경 시 호출
    @IBAction func idEditingChanged(_ sender: UITextField) {
        guard let userId = idTextField.text else { return }
        ApiService.checkUserIdDuplicated(userId: userId) { statusCode in
            DispatchQueue.main.async {
                self.updateUserIdValidationStatus(statusCode: statusCode)
            }
        }
    }
    
    // 비밀번호 입력 변경 시 호출
    @IBAction func pwEditingChanged(_ sender: UITextField) {
        if let password = pwTextField.text {
            validatePassword(password)
        }
    }
    
    // 비밀번호 확인 입력 변경 시 호출
    @IBAction func pwCheckEditingChanged(_ sender: UITextField) {
        if let pwCheckText = pwCheckTextField.text, let pwText = pwTextField.text {
            validatePasswordCheck(pwCheckText, against: pwText)
        }
    }
    
    // 회원가입 버튼 클릭 시 호출
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let userId = idTextField.text,
              let password = pwTextField.text else { return }
        
        ApiService.signUp(userId: userId, email: email, password: password) { statusCode in
            DispatchQueue.main.async {
                if statusCode == 201 { // 회원가입 성공
                    print("회원가입 성공")
                } else { // 회원가입 실패
                    print("회원가입 실패")
                }
            }
        }
    }
    
    // 이메일 유효성 상태 업데이트
    func updateEmailValidationStatus(statusCode: Int) {
        switch statusCode {
        case 200:
            setEmailLabel(text: "사용 가능한 이메일입니다.", color: CUSTOM_BLUE)
        case 400:
            setEmailLabel(text: "이메일 형식을 맞춰주세요.", color: CUSTOM_RED)
        case 409:
            setEmailLabel(text: "사용할 수 없는 이메일입니다.", color: CUSTOM_RED)
        default:
            break
        }
        updateSignUpButtonState()
    }
    
    // 아이디 유효성 상태 업데이트
    func updateUserIdValidationStatus(statusCode: Int) {
        switch statusCode {
        case 200:
            setIdLabel(text: "사용 가능한 아이디입니다.", color: CUSTOM_BLUE)
        case 400:
            setIdLabel(text: "아이디는 영소문자 + 숫자 조합으로 7자 이상이어야 합니다.", color: CUSTOM_RED)
        case 409:
            setIdLabel(text: "이미 사용중인 아이디입니다.", color: CUSTOM_RED)
        default:
            break
        }
        updateSignUpButtonState()
    }
    
    
    // 비밀번호 유효성 검사
    func validatePassword(_ password: String) {
        if isPasswordValid(password) {
            setPwLabel(text: "사용 가능한 비밀번호입니다.", color: CUSTOM_BLUE)
        } else {
            setPwLabel(text: "비밀번호는 영대문자 + 특수문자 + 숫자 + 영소문자 조합이어야 합니다.", color: CUSTOM_RED)
        }
        updateSignUpButtonState()
    }
    
    // 비밀번호 확인 유효성 검사
    func validatePasswordCheck(_ pwCheckText: String, against pwText: String) {
        if pwCheckText == pwText {
            if isPasswordValid(pwCheckText) {
                setPwCheckLabel(text: "비밀번호가 일치합니다.", color: CUSTOM_BLUE)
            } else {
                setPwCheckLabel(text: "비밀번호는 영대문자 + 특수문자 + 숫자 + 영소문자 조합이어야 합니다.", color: CUSTOM_RED)
            }
        } else {
            setPwCheckLabel(text: "비밀번호가 일치하지 않습니다.", color: CUSTOM_RED)
        }
        updateSignUpButtonState()
    }
    
    // 비밀번호 유효성 검사
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // 회원가입 버튼 활성화 상태 업데이트
    func updateSignUpButtonState() {
        let isEmailValid = emailLabel.textColor == CUSTOM_BLUE
        let isUserIdValid = idLabel.textColor == CUSTOM_BLUE
        let isPasswordValid = pwLabel.textColor == CUSTOM_BLUE
        let isPasswordCheckValid = pwCheckLabel.textColor == CUSTOM_BLUE
        
        signUpBtn.isEnabled = isEmailValid && isUserIdValid && isPasswordValid && isPasswordCheckValid
    }
    
    // UI 설정
    private func setupUI() {
        configureTextField(emailTextField)
        configureTextField(idTextField)
        configureTextField(pwTextField, isSecure: true)
        configureTextField(pwCheckTextField, isSecure: true)
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
    
    // 회원가입 버튼 설정
    private func setupSignUpButton() {
        signUpBtn.isEnabled = false
    }
    
    // GestureRecognizer 설정
    private func setupGestureRecognizers() {
        let keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTapGesture)
    }
    
    // 이메일 라벨 설정
    private func setEmailLabel(text: String, color: UIColor?) {
        emailLabel.text = text
        emailLabel.textColor = color
        emailTextField.layer.borderColor = color?.cgColor
    }
    
    // 아이디 라벨 설정
    private func setIdLabel(text: String, color: UIColor?) {
        idLabel.text = text
        idLabel.textColor = color
        idTextField.layer.borderColor = color?.cgColor
    }
    
    // 비밀번호 라벨 설정
    private func setPwLabel(text: String, color: UIColor?) {
        pwLabel.text = text
        pwLabel.textColor = color
        pwTextField.layer.borderColor = color?.cgColor
    }
    
    // 비밀번호 확인 라벨 설정
    private func setPwCheckLabel(text: String, color: UIColor?) {
        pwCheckLabel.text = text
        pwCheckLabel.textColor = color
        pwCheckTextField.layer.borderColor = color?.cgColor
    }
    
    // 회원가입 성공 알림창 표시
    private func showSignUpSuccessAlert() {
        let alert = UIAlertController(title: "회원가입 성공", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.unwindToVC(UIStoryboardSegue(identifier: "unwindToVC", source: self, destination: self))
        })
        present(alert, animated: true, completion: nil)
    }
    
    // 회원가입 실패 알림창 표시
    private func showSignUpFailureAlert() {
        let alert = UIAlertController(title: "회원가입 실패", message: "회원가입에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 회원가입 UI 초기화
    private func resetSignUpUI() {
        // 텍스트 필드 초기화
        emailTextField.text = ""
        idTextField.text = ""
        pwTextField.text = ""
        pwCheckTextField.text = ""

        // 텍스트 필드 테두리 색 초기화
        emailTextField.layer.borderColor = CUSTOM_GREY?.cgColor
        idTextField.layer.borderColor = CUSTOM_GREY?.cgColor
        pwTextField.layer.borderColor = CUSTOM_GREY?.cgColor
        pwCheckTextField.layer.borderColor = CUSTOM_GREY?.cgColor

        // 라벨 초기화
        emailLabel.text = "이메일 형식을 맞춰주세요."
        emailLabel.textColor = CUSTOM_GREY
        idLabel.text = "아이디는 영소문자 + 숫자 조합으로 7자 이상이어야 합니다."
        idLabel.textColor = CUSTOM_GREY
        pwLabel.text = "비밀번호는 영대문자 + 특수문자 + 숫자 + 영소문자 조합이어야 합니다."
        pwLabel.textColor = CUSTOM_GREY
        pwCheckLabel.text = "Label"
        pwCheckLabel.textColor = CUSTOM_GREY

        // 버튼 상태 초기화
        signUpBtn.isEnabled = true
        signUpBtn.backgroundColor = CUSTOM_GREY
        signUpBtn.setTitleColor(.white, for: .normal)
    }
}

// UITextFieldDelegate 확장
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Return 키를 눌렀을 때 키보드가 사라지게 함
        return true
    }
}
