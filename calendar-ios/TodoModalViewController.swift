//
//  TodoModalViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit

class TodoModalViewController: UIViewController, CategorySelectionDelegate {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var clickedDate: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate: String? // 날짜를 저장할 변수
    var todoItems: [String] = [] // 할 일 목록을 저장할 배열
    
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
        
        // 샘플 데이터 추가
        todoItems = ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5"]
        
        // addBtn 액션 설정
        // TODO: 이거 수정 - 카테고리 선택 뷰 만들기
//        addBtn.addTarget(self, action: #selector(addNewTodoItem), for: .touchUpInside)
    }
    
    @objc func addNewTodoItem() {
        // 새로운 항목 추가
        todoItems.append("New Task")
        
        // 테이블 뷰 업데이트
        let newIndexPath = IndexPath(row: todoItems.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    // view 외의 곳 클릭하면 모달 닫힘
    @objc func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        baseView.layer.cornerRadius = 20
        addBtn.layer.cornerRadius = 14
    }
    
    // CategorySelectionDelegate 메서드 구현
    func didSelectCategory(category: String) {
        print("선택된 카테고리: \(category)")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTodoBtnSegue" {
            if let categoryVC = segue.destination as? CategoryViewController {
                categoryVC.delegate = self
            }
        }
    }
    
}

extension TodoModalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        // 초기 데이터
        cell.titleLabel.text = todoItems[indexPath.row]
        
        return cell
    }
    
    // 슬라이드하여 삭제 기능 추가
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 데이터 소스에서 항목 삭제
            todoItems.remove(at: indexPath.row)
            // 테이블 뷰에서 행 삭제
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // 삭제 버튼 텍스트 변경
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
}
