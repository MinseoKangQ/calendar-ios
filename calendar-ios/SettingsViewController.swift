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
            print("로그아웃 selected")
            // Add your logout logic here
            break
        case 1:
            // Handle 회원탈퇴 action
            print("회원탈퇴 selected")
            // Add your delete account logic here
            break
        default:
            break
        }
    }
}
