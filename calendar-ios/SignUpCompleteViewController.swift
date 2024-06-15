//
//  SignUpCompleteController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/6/24.
//

import UIKit

class SignUpCompleteViewController: UIViewController {

    // Outlets
    @IBOutlet weak var resultTextView: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var uiView: UIView!

    // 로그인 화면으로 이동
    @IBAction func goToLogin(_ sender: UIButton) {
        self.dismiss(animated: true) // 일단 현재 화면 닫음
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // UI 설정
    private func setupUI() {
        uiView.layer.cornerRadius = 10
        uiView.layer.borderWidth = 1
        uiView.layer.borderColor = UIColor.white.cgColor
    }

}
