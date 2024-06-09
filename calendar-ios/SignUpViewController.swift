//
//  SignUpController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/5/24.
//

import UIKit



// pw : Aa1!aaaa

class SignUpViewController: UIViewController  {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwCheckTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var pwLabel: UILabel!
    @IBOutlet weak var pwCheckLabel: UILabel!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    var isShowKeyboard = false
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue") // 007aff
    let CUSTOM_GREY = UIColor(named: "CustomGrey") // c7c7cd
    let CUSTOM_RED = UIColor(named: "CustomRed") // ff3b30
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // textField 외의 곳을 터치하면 키보드 사라짐
        let keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardDismissTapGesture)
        
        setupUI()
        
        // 회원가입 버튼 비활성화
        signUpBtn.isEnabled = false
//        signUpBtn.backgroundColor = CUSTOM_GREY
        
    }
    
    // 다시 로그인 화면으로 감
    // https://eunoia3jy.tistory.com/210 참고함
    @IBAction func unwindToVC(_ segue: UIStoryboardSegue) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // ===== 각 필드들의 값이 바뀔 때 마다 API 호출 필요 =====
    @IBAction func emailEditingChanged(_ sender: UITextField) {
//        print(emailTextField.text!)
        guard let email = emailTextField.text else { return }
        ApiService.checkEmailDuplicated(email: email) { statusCode in
            DispatchQueue.main.async {
                self.updateEmailValidationStatus(statusCode: statusCode)
            }
        }
    }
    
    @IBAction func idEditingChanged(_ sender: UITextField) {
//        print(idTextField.text!)
        guard let userId = idTextField.text else { return }
        ApiService.checkUserIdDuplicated(userId: userId) { statusCode in
            DispatchQueue.main.async {
                self.updateUserIdValidationStatus(statusCode: statusCode)
            }
        }
    }
    
    @IBAction func pwEditingChanged(_ sender: UITextField) {
        print(pwTextField.text!)
        
        // API(X) => iOS에서 검증
        if let password = pwTextField.text {
            if isPasswordValid(password) {
                // 사용 가능한 비밀번호라면
                pwLabel.text = "사용 가능한 비밀번호입니다."
                pwLabel.textColor = CUSTOM_BLUE
                pwTextField.layer.borderColor = CUSTOM_BLUE?.cgColor
            } else {
                // 영대문자 + 특수문자 + 숫자 + 영소문자 조합에 맞지 않다면
                pwLabel.text = "비밀번호는 영대문자 + 특수문자 + 숫자 + 영소문자 조합이어야 합니다."
                pwLabel.textColor = CUSTOM_RED
                pwTextField.layer.borderColor = CUSTOM_RED?.cgColor
            }
            updateSignUpButtonState()
        }
    }
    
    @IBAction func pwCheckEditingChanged(_ sender: UITextField) {
        print(pwCheckTextField.text!)
        
        // API(X) => iOS에서 검증
        if let pwCheckText = pwCheckTextField.text, let pwText = pwTextField.text {
            if pwCheckText == pwText {
                if isPasswordValid(pwCheckText) {
                    pwCheckLabel.text = "비밀번호가 일치합니다."
                    pwCheckLabel.textColor = CUSTOM_BLUE
                    pwCheckTextField.layer.borderColor = CUSTOM_BLUE?.cgColor
                } else {
                    pwCheckLabel.text = "비밀번호는 영대문자 + 특수문자 + 숫자 + 영소문자 조합이어야 합니다."
                    pwCheckLabel.textColor = CUSTOM_RED
                    pwCheckTextField.layer.borderColor = CUSTOM_RED?.cgColor
                }
            } else {
                pwCheckLabel.text = "비밀번호가 일치하지 않습니다."
                pwCheckLabel.textColor = CUSTOM_RED
                pwCheckTextField.layer.borderColor = CUSTOM_RED?.cgColor
            }
            updateSignUpButtonState()
        }
    }
    
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let userId = idTextField.text,
              let password = pwTextField.text else { return }
        
        ApiService.signUp(userId: userId, email: email, password: password) { statusCode in
            DispatchQueue.main.async {
                if statusCode == 201 {
                    // 회원가입 성공
                    print("회원가입 성공")
                } else { // TODO: 여기 어떻게 처리?
                    // 회원가입 실패
                    print("회원가입 실패")
                }
            }
        }
    }
    
    func updateEmailValidationStatus(statusCode: Int) {
        switch statusCode {
        case 200:
            emailLabel.text = "사용 가능한 이메일입니다."
            emailLabel.textColor = CUSTOM_BLUE
            emailTextField.layer.borderColor = CUSTOM_BLUE?.cgColor
        case 400:
            emailLabel.text = "이메일 형식을 맞춰주세요."
            emailLabel.textColor = CUSTOM_RED
            emailTextField.layer.borderColor = CUSTOM_RED?.cgColor
        case 409:
            emailLabel.text = "사용할 수 없는 이메일입니다."
            emailLabel.textColor = CUSTOM_RED
            emailTextField.layer.borderColor = CUSTOM_RED?.cgColor
        default:
            break
        }
        updateSignUpButtonState()
    }
    
    func updateUserIdValidationStatus(statusCode: Int) {
        switch statusCode {
        case 200:
            idLabel.text = "사용 가능한 아이디입니다."
            idLabel.textColor = CUSTOM_BLUE
            idTextField.layer.borderColor = CUSTOM_BLUE?.cgColor
        case 400:
            idLabel.text = "아이디는 영소문자 + 숫자 조합으로 7자 이상이어야 합니다."
            idLabel.textColor = CUSTOM_RED
            idTextField.layer.borderColor = CUSTOM_RED?.cgColor
        case 409:
            idLabel.text = "이미 사용중인 아이디입니다."
            idLabel.textColor = CUSTOM_RED
            idTextField.layer.borderColor = CUSTOM_RED?.cgColor
        default:
            break
        }
        updateSignUpButtonState()
    }
    
    // 비밀번호 검증 메소드
    func isPasswordValid(_ password: String) -> Bool {
        // 최소 하나의 영대문자, 영소문자, 숫자, 특수문자를 포함하는 정규식
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    // 회원가입 활성화 버튼
    func updateSignUpButtonState() {
        let isEmailValid = emailLabel.textColor == CUSTOM_BLUE
        let isUserIdValid = idLabel.textColor == CUSTOM_BLUE
        let isPasswordValid = pwLabel.textColor == CUSTOM_BLUE
        let isPasswordCheckValid = pwCheckLabel.textColor == CUSTOM_BLUE
        
        signUpBtn.isEnabled = isEmailValid && isUserIdValid && isPasswordValid && isPasswordCheckValid
//        signUpBtn.backgroundColor = signUpBtn.isEnabled ? CUSTOM_BLUE : CUSTOM_GREY
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
        emailTextField.layer.cornerRadius = 14
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = CUSTOM_GREY?.cgColor
        emailTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        emailTextField.leftViewMode = .always
        
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
        
        pwCheckTextField.layer.cornerRadius = 14
        pwCheckTextField.layer.borderWidth = 1
        pwCheckTextField.layer.borderColor = CUSTOM_GREY?.cgColor
        pwCheckTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        pwCheckTextField.leftViewMode = .always
        
        // 버튼
        signUpBtn.layer.cornerRadius = 14
        signUpBtn.layer.borderWidth = 1
        signUpBtn.backgroundColor = CUSTOM_BLUE
        signUpBtn.layer.borderColor = CUSTOM_BLUE?.cgColor
        
        // ===== 비밀번호 관련 필드 =====
        pwTextField.isSecureTextEntry = true
        pwTextField.textContentType = .oneTimeCode
        pwCheckTextField.isSecureTextEntry = true
        pwCheckTextField.textContentType = .oneTimeCode
    }
    
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

