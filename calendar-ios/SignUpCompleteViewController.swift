//
//  SignUpCompleteController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/6/24.
//

import UIKit

class SignUpCompleteViewController: UIViewController {

    @IBOutlet weak var resultTextView: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var uiView: UIView!
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue")
    let CUSTOM_GREY = UIColor(named: "CustomGrey")
    let CUSTOM_RED = UIColor(named: "CustomRed")

    @IBAction func goToLogin(_ sender: UIButton) {
        print("goToLogin called")
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        uiView.layer.cornerRadius = 10
        uiView.layer.borderWidth = 1
        uiView.layer.borderColor = UIColor.white.cgColor
    }

}
