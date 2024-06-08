//
//  TodoModalViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit

class TodoModalViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var clickedDate: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 전체 뷰에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        self.view.addGestureRecognizer(tapGesture)
        
        // baseView는 탭 제스처에 반응하지 않도록 설정
        let baseTapGesture = UITapGestureRecognizer()
        baseView.addGestureRecognizer(baseTapGesture)
    }
    
    // view 외의 곳 클릭하면 모달 닫힘
    @objc func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        
        baseView.layer.cornerRadius = 20
        addBtn.layer.cornerRadius = 14
    }
    
}

