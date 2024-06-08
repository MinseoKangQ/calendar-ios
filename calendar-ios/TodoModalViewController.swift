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
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate: String? // 날짜를 저장할 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 전체 뷰에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        self.view.addGestureRecognizer(tapGesture)
        
        // baseView는 탭 제스처에 반응하지 않도록 설정
        let baseTapGesture = UITapGestureRecognizer()
        baseView.addGestureRecognizer(baseTapGesture)
        
        // selectedDate 값을 clickedDate 레이블에 설정
        if let date = selectedDate {
            clickedDate.text = date
        }
        
        // TableView 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
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

extension TodoModalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // 샘플 데이터 수
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        // 여기서 cell을 설정할 수 있습니다.
        // 예를 들어, cell.textLabel?.text = "Some text"
        
        return cell
    }
}
