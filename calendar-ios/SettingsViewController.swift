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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appSettingsTableView.dataSource = self
        appSettingsTableView.delegate = self
        
        modeView.layer.cornerRadius = 5
        modeView.layer.masksToBounds = true
        
        appSettingsTableView.layer.cornerRadius = 5
        appSettingsTableView.layer.masksToBounds = true
        
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appSettingsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = appSettingsData[indexPath.row]
        cell.textLabel?.textColor = UIColor(named: "AppSettingsText")
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // Handle 로그아웃 action
            showLogoutConfirmation()
            break
        case 1:
            // Handle 회원탈퇴 action
            print("회원탈퇴 selected")
            // Handle 회원탈퇴 action
             showDeleteAccountConfirmation()
        default:
            break
        }
    }
    
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

    func logout() {
        ApiService.authToken = nil
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true, completion: nil)
    }

    func showDeleteAccountConfirmation() {
        let alertController = UIAlertController(title: "회원탈퇴", message: "정말로 탈퇴하시겠습니까? 탈퇴하시면 모든 정보가 사라집니다. 동의하시면 아래에 \"동의합니다\" 라고 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "동의합니다"
        }
        
        let confirmAction = UIAlertAction(title: "네", style: .destructive) { _ in
            if let input = alertController.textFields?.first?.text, input == "동의합니다" {
                self.deleteAccount()
            } else {
                let errorAlert = UIAlertController(title: "오류", message: "입력된 내용이 올바르지 않습니다.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func deleteAccount() {
        ApiService.deleteUser { success in
            DispatchQueue.main.async {
                if success {
                    let successAlert = UIAlertController(title: "회원탈퇴", message: "회원탈퇴가 완료되었습니다!", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                        ApiService.authToken = nil
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                        loginViewController.modalPresentationStyle = .fullScreen
                        self.present(loginViewController, animated: true, completion: nil)
                    })
                    self.present(successAlert, animated: true, completion: nil)
                } else {
                    let errorAlert = UIAlertController(title: "오류", message: "회원탈퇴에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
