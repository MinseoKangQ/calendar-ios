//
//  TodoModalViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit
import M13Checkbox

class TodoModalViewController: UIViewController, CategorySelectionDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var clickedDate: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var selectedDate: Date? // Date 형식의 날짜를 저장할 변수
    
    var todoItems: [TodoItem] = [] // 할 일 목록을 저장할 배열
    
    var keyboardHelperView: UIView?
    var keyboardHeight: CGFloat = 0.0
    var label: UITextField?
    var selectedCategory: String?

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
            let headerDateFormatter = DateFormatter()
            headerDateFormatter.locale = Locale(identifier: "ko_KR")
            headerDateFormatter.dateFormat = "M월 d일 (E)"
            let headerDate = headerDateFormatter.string(from: date)
            clickedDate.text = headerDate
            
            fetchTodoList(for: convertToAPIDateFormat(date))
        }
        
        // TableView 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        
        // 회색 줄 없애기
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
    }

    func convertToAPIDateFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func fetchTodoList(for date: String) {
        ApiService.getTodoList(for: date) { [weak self] todoList in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let todoList = todoList {
                    self.todoItems = todoList
                    self.tableView.reloadData()
                } else {
                    print("Failed to fetch todo list")
                }
            }
        }
    }
    
    
    @objc func addNewTodoItem() {
        // 새로운 항목 추가
        let newTodoResponse = ["todoId": 2, "title": "New Task", "category": "DAILY", "isDone": false] as [String : Any]

        if let todoId = newTodoResponse["todoId"] as? Int,
           let title = newTodoResponse["title"] as? String,
           let category = newTodoResponse["category"] as? String,
           let isDone = newTodoResponse["isDone"] as? Bool {
            let newTask = TodoItem(todoId: todoId, title: title, category: category, isDone: isDone)
            self.todoItems.append(newTask)
            
            // 테이블 뷰 업데이트
            let newIndexPath = IndexPath(row: todoItems.count - 1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
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
        selectedCategory = category
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
            keyboardHelperView?.layer.cornerRadius = 15
            keyboardHelperView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            keyboardHelperView?.layer.masksToBounds = true
            
            // 카테고리 색상 설정
            switch selectedCategory {
            case "IMPORTANT":
                keyboardHelperView?.backgroundColor = UIColor(named: "CategoryRedBtn")
            case "STUDY":
                keyboardHelperView?.backgroundColor = UIColor(named: "CategoryBlueBtn")
            case "DAILY":
                keyboardHelperView?.backgroundColor = UIColor(named: "CategoryPurpleBtn")
            case "EXERCISE":
                keyboardHelperView?.backgroundColor = UIColor(named: "CategoryYellowBtn")
            default:
                keyboardHelperView?.backgroundColor = UIColor(red: 216/255, green: 230/255, blue: 242/255, alpha: 1.0) // 기본 배경색
            }
            
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
        guard let text = label?.text, !text.isEmpty else {
            hideKeyboardHelper()
            return
        }
        
        guard let selectedDate = selectedDate else {
            hideKeyboardHelper()
            return
        }
        
        let apiDate = convertToAPIDateFormat(selectedDate)
        let category = selectedCategory ?? "DAILY"
    
        ApiService.addTodo(date: apiDate, title: text, category: category) { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.todoItems.append(TodoItem(todoId: self.todoItems.count + 1, title: text, category: category, isDone: false))
                    self.tableView.reloadData()
                    self.label?.text = ""
                } else {
                    print("할 일 추가 실패")
                }
                self.hideKeyboardHelper()
            }
        }
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
        let todoItem = todoItems[indexPath.row]
        
        // 할 일
        cell.titleLabel.text = todoItem.title
        
        // 카테고리
        switch todoItem.category {
        case "IMPORTANT":
            cell.categoryLabel.text = "중요"
        case "STUDY":
            cell.categoryLabel.text = "공부"
        case "DAILY":
            cell.categoryLabel.text = "일상"
        case "EXERCISE":
            cell.categoryLabel.text = "운동"
        default:
            cell.categoryLabel.text = ""
        }
        
        // 배경색 설정
        cell.configureBackgroundColor(category: todoItem.category)
        
        // 체크박스 상태 설정
        cell.checkBox.checkState = todoItem.isDone ? .checked : .unchecked
        
        // 체크박스 클릭 이벤트 핸들러 설정
        cell.checkBox.tag = todoItem.todoId
        cell.checkBox.addTarget(self, action: #selector(checkBoxValueChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    // 체크박스 클릭 이벤트 처리 메서드
    @objc func checkBoxValueChanged(_ sender: M13Checkbox) {
        let todoId = sender.tag
        ApiService.toggleTodoCheck(todoId: todoId) { [weak self] success in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    // 할 일 목록을 다시 불러와서 UI를 갱신
                    if let date = self.selectedDate {
                        self.fetchTodoList(for: self.convertToAPIDateFormat(date))
                    }
                }
            } else {
                print("체크 상태 변경 실패")
            }
        }
    }
    
//    // 슬라이드하여 삭제 기능 추가
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // 데이터 소스에서 항목 삭제
//            todoItems.remove(at: indexPath.row)
//            // 테이블 뷰에서 행 삭제
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
//    
//    // 삭제 버튼 텍스트 변경
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "삭제"
//    }
    
    /**
    // 삭제 커스텀
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action, view, completionHandler) in
            // 삭제 로직
            self.todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        // 커스텀 디자인
        deleteAction.backgroundColor = .red // 배경 색상
        deleteAction.image = UIImage(systemName: "trash") // 아이콘 추가
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true // 풀 스와이프 기능
        
        return configuration
    }
     **/
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action, view, completionHandler) in
            // 삭제 로직
            self.todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        // 커스텀 디자인
        let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 60))
        deleteView.backgroundColor = .red
        deleteView.layer.cornerRadius = 8
        deleteView.layer.masksToBounds = true
        
        let deleteImageView = UIImageView(image: UIImage(systemName: "trash"))
        deleteImageView.tintColor = .white
        deleteImageView.contentMode = .scaleAspectFit
        deleteImageView.frame = CGRect(x: (deleteView.frame.width - 35) / 2, y: (deleteView.frame.height - 35) / 2, width: 35, height: 35) // 이미지 크기 조정
        
        deleteView.addSubview(deleteImageView)
        
        UIGraphicsBeginImageContextWithOptions(deleteView.bounds.size, false, 0.0)
        deleteView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let deleteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        deleteAction.backgroundColor = .clear
        deleteAction.image = deleteImage
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    // 셀의 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0 // 원하는 높이로 설정
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
