//
//  CategoryViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/10/24.
//

import UIKit

class CategoryViewController: UIViewController {

    @IBOutlet weak var categoryView: UIView!

    @IBOutlet weak var importantView: UIView!
    @IBOutlet weak var studyView: UIView!
    @IBOutlet weak var dailyView: UIView!
    @IBOutlet weak var exerciseView: UIView!
    
    weak var delegate: CategorySelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        // 전체에 적용
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        self.view.addGestureRecognizer(tapGesture)
        
        // categoryView는 탭 제스처에 반응하지 않도록 설정
        let categoryTapGesture = UITapGestureRecognizer()
        categoryView.addGestureRecognizer(categoryTapGesture)
        
        // 각각의 뷰에 탭 제스처 추가
        let importantTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImportant))
        importantView.addGestureRecognizer(importantTapGesture)
        
        let studyTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectStudy))
        studyView.addGestureRecognizer(studyTapGesture)
        
        let dailyTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectDaily))
        dailyView.addGestureRecognizer(dailyTapGesture)
        
        let exerciseTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectExercise))
        exerciseView.addGestureRecognizer(exerciseTapGesture)
        
    }
    
    // view 외의 곳 클릭하면 모달 닫힘
    @objc func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        categoryView.layer.cornerRadius = 14
        importantView.layer.cornerRadius = 10
        studyView.layer.cornerRadius = 10
        dailyView.layer.cornerRadius = 10
        exerciseView.layer.cornerRadius = 10
    }
    
    @objc func selectImportant() {
        delegate?.didSelectCategory(category: "중요")
    }
    
    @objc func selectStudy() {
        delegate?.didSelectCategory(category: "공부")
    }
    
    @objc func selectDaily() {
        delegate?.didSelectCategory(category: "일상")
    }
    
    @objc func selectExercise() {
        delegate?.didSelectCategory(category: "운동")
    }

}

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(category: String)
}
