//
//  HomeViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/13/24.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var remainView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var todayTextLabel: UILabel!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        remainView.layer.cornerRadius = 10
        todayView.layer.cornerRadius = 10
        addBtn.layer.cornerRadius = 14
    }

}
