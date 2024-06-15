//
//  ViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/5/24.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var appSettingsTableView: UITableView!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var modeView: UIView!
    
    let appSettingsData = ["로그아웃", "회원탈퇴"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDarkMode()
    }
    
    // 다크 모드 업데이트
    func updateDarkMode() {
        let darkModeEnabled = darkModeSwitch.isOn
        view.window?.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSettingsTableView()
        setupModeView()
        setupDarkModeSwitch()
    }
    
    // TableView 설정
    func setupSettingsTableView() {
        appSettingsTableView.dataSource = self // dataSource 등록
        appSettingsTableView.delegate = self // delegate 등록
        appSettingsTableView.layer.cornerRadius = 5
        appSettingsTableView.layer.masksToBounds = true
    }
    
    // 모드 뷰 UI 설정
    func setupModeView() {
        modeView.layer.cornerRadius = 5
        modeView.layer.masksToBounds = true
    }
    
    // 다크 모드 스위치 설정
    func setupDarkModeSwitch() {
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        updateDarkMode()
        darkModeSwitch.addTarget(self, action: #selector(darkModeSwitchChanged(_:)), for: .valueChanged)
    }
    
    // 다크 모드 스위치 변경 시 호출
    @objc func darkModeSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")
        updateDarkMode()
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    // TableView 행 개수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appSettingsData.count
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = appSettingsData[indexPath.row]
        cell.textLabel?.textColor = UIColor(named: "AppSettingsText")
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    // 행 선택 시 호출
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: // Handle 로그아웃 action
            showLogoutConfirmation()
            break
        case 1: // Handle 회원탈퇴 action
             showDeleteAccountConfirmation()
        default:
            break
        }
    }
    
    // 로그아웃 확인 창 표시
    func showLogoutConfirmation() {
        let alertController = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "예", style: .destructive) { _ in
            self.logout()
        }
        
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // 로그아웃 처리
    func logout() {
        // 헤더 값 삭제
        ApiService.authToken = nil
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true, completion: nil)
    }

    // 회원탈퇴 확인 창 표시
    func showDeleteAccountConfirmation() {
        let alertController = UIAlertController(title: "회원탈퇴", message: "정말로 탈퇴하시겠습니까? 탈퇴하시면 모든 정보가 사라집니다. 동의하시면 아래에 \"동의합니다\" 라고 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "동의합니다"
        }
        
        let confirmAction = UIAlertAction(title: "네", style: .destructive) { _ in
            if let input = alertController.textFields?.first?.text, input == "동의합니다" {
                self.deleteAccount()
            } else {
                self.showErrorAlert(message: "입력된 내용이 올바르지 않습니다.")
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // 회원탈퇴 처리
    func deleteAccount() {
        func deleteAccount() {
           
            // 회원탈퇴 API 호출
            ApiService.deleteUser { success in
                DispatchQueue.main.async {
                    if success {
                        self.showSuccessAlert()
                    } else {
                        self.showErrorAlert(message: "회원탈퇴에 실패했습니다. 다시 시도해주세요.")
                    }
                }
            }
        }
    }
    
    // 성공 알림창 표시
    func showSuccessAlert() {
        let successAlert = UIAlertController(title: "회원탈퇴", message: "회원탈퇴가 완료되었습니다!", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            // 헤더 값 삭제
            ApiService.authToken = nil
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: true, completion: nil)
        })
        present(successAlert, animated: true, completion: nil)
    }

    // 오류 알림창 표시
    func showErrorAlert(message: String) {
        let errorAlert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
}
