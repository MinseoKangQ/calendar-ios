//
//  SignUpCompleteController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/6/24.
//

import UIKit

class SignUpCompleteViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var uiView: UIView!
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue") // 007aff
    let CUSTOM_GREY = UIColor(named: "CustomGrey") // c7c7cd
    let CUSTOM_RED = UIColor(named: "CustomRed") // ff3b30

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
    }
    
    private func setupUI() {
        loginBtn.layer.cornerRadius = 14
        loginBtn.layer.borderWidth = 1
        loginBtn.backgroundColor = CUSTOM_BLUE
        loginBtn.layer.borderColor = CUSTOM_BLUE?.cgColor
        
        uiView.layer.cornerRadius = 10
        uiView.layer.borderWidth = 1
        uiView.layer.borderColor = UIColor.white.cgColor
    }

}
