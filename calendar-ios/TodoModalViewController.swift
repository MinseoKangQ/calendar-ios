//
//  TodoModalViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit

class TodoModalViewController: UIViewController, CategorySelectionDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var clickedDate: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate: String? // 날짜를 저장할 변수
    var todoItems: [String] = [] // 할 일 목록을 저장할 배열
    
    var keyboardHelperView: UIView?
    var keyboardHeight: CGFloat = 0.0
    var label: UITextField?


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
        
        // 키보드 노티피케이션 관찰자 설정
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
    
    func didSelectCategory(category: String) {
        print("선택된 카테고리: \(category)")
        self.dismiss(animated: true)
        self.showKeyboardHelper()
        
    }

    
    // 카테고리 선택 뷰 보여주기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTodoBtnSegue" {
            if let categoryVC = segue.destination as? CategoryViewController {
                categoryVC.delegate = self
            }
        }
    }
    
    // 키보드가 올라올 때
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            showKeyboardHelper()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        hideKeyboardHelper()
    }

    func showKeyboardHelper() {
        if keyboardHelperView == nil {
            let accessoryHeight: CGFloat = 80
            let yOffsetAdjustment: CGFloat = 330

            let customAccessoryFrame = CGRect(x: 0, y: view.frame.height - keyboardHeight - accessoryHeight - yOffsetAdjustment, width: view.frame.width, height: accessoryHeight)
            
            keyboardHelperView = UIView(frame: customAccessoryFrame)
            keyboardHelperView?.backgroundColor = UIColor(red: 216/255, green: 230/255, blue: 242/255, alpha: 1.0) // #D8E6F2 배경
            keyboardHelperView?.layer.cornerRadius = 15
            keyboardHelperView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            keyboardHelperView?.layer.masksToBounds = true
            
            let containerView = UIView(frame: CGRect(x: 10, y: 10, width: customAccessoryFrame.width - 20, height: 30))
            
            label = UITextField(frame: CGRect(x: 0, y: 0, width: containerView.frame.width - 30, height: 30))
            label?.placeholder = "할 일을 입력하세요"
            label?.textAlignment = .left
            label?.textColor = .darkGray
            label?.delegate = self // UITextFieldDelegate 설정
                        
            let arrowButton = UIButton(frame: CGRect(x: containerView.frame.width - 30, y: 0, width: 30, height: 30))
            arrowButton.setImage(UIImage(systemName: "arrow.forward.circle"), for: .normal)
            arrowButton.tintColor = .gray
            arrowButton.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)
            
            containerView.addSubview(label!)
            containerView.addSubview(arrowButton)
            
            keyboardHelperView?.addSubview(containerView)
            
            // 아이콘 추가
            let iconSize: CGFloat = 24
            let yOffset: CGFloat = 50 // 아이콘 버튼들이 위치할 y 좌표
            let spacing: CGFloat = 40 // 아이콘 사이의 간격
            let xOffset: CGFloat = 20 // 첫 번째 아이콘의 x 좌표
            
            let calendarIcon = UIButton(frame: CGRect(x: xOffset, y: yOffset, width: iconSize, height: iconSize))
            calendarIcon.setImage(UIImage(systemName: "calendar"), for: .normal)
            calendarIcon.tintColor = .gray
            keyboardHelperView?.addSubview(calendarIcon)
            
            let bellIcon = UIButton(frame: CGRect(x: xOffset + spacing, y: yOffset, width: iconSize, height: iconSize))
            bellIcon.setImage(UIImage(systemName: "bell"), for: .normal)
            bellIcon.tintColor = .gray
            keyboardHelperView?.addSubview(bellIcon)
            
            let clipboardIcon = UIButton(frame: CGRect(x: xOffset + 2 * spacing, y: yOffset, width: iconSize, height: iconSize))
            clipboardIcon.setImage(UIImage(systemName: "doc.text"), for: .normal)
            clipboardIcon.tintColor = .gray
            keyboardHelperView?.addSubview(clipboardIcon)
            
            view.addSubview(keyboardHelperView!)
            
            label?.becomeFirstResponder()
        }
            
    }
    
    @objc func arrowButtonTapped() {
        if let text = label?.text, !text.isEmpty {
            todoItems.append(text)
            tableView.reloadData()
            label?.text = ""
        }
        hideKeyboardHelper()
    }

    func hideKeyboardHelper() {
        keyboardHelperView?.removeFromSuperview()
        keyboardHelperView = nil
        print("사라져")
    }
    
    // UITextFieldDelegate 메서드 추가
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        // UITextField가 터치되었을 때 키보드 헬퍼를 숨기지 않도록 예외 처리
    }
    
    deinit {
        // 옵저버 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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

// UITapGestureRecognizerDelegate 채택 및 구현
extension TodoModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치된 뷰가 UITextField인 경우, 탭 제스처가 실행되지 않도록 함
        if let touchedView = touch.view, touchedView is UITextField {
            return false
        }
        return true
    }
}
