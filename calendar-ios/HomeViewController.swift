//
//  HomeViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/13/24.
//

import UIKit
import M13Checkbox

class HomeViewController: UIViewController, CategorySelectionDelegate {

    @IBOutlet weak var remainView: UIView!

    @IBOutlet weak var remainCountTextLabel: UILabel!
    @IBOutlet weak var todayTextLabel: UILabel!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var todoItems: [TodoItem] = [] // 할 일 목록을 저장할 배열
    
    var keyboardHelperView: UIView?
    var keyboardHeight: CGFloat = 0.0
    var label: UITextField?
    var selectedCategory: String?
    var currentEditingTodoId: Int?
    var selectedDate: Date? // Date 형식의 날짜를 저장할 변수
    
    // 다른 탭에서 HomeViewController로 넘어옴
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 데이터 새로고침
        fetchTodoList()
        fetchNotDoneCount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // TableView 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        
        // 회색 줄 없애기
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // 오늘 할 일 데이터 가져오기
        fetchTodoList()
        
        // 남은 할 일 개수 가져오기
        fetchNotDoneCount()
        
    }
    
    func setupUI() {
        remainView.layer.cornerRadius = 10
        todayView.layer.cornerRadius = 10
        
        // addBtn에 액션 추가
        addBtn.addTarget(self, action: #selector(addNewTodoItem), for: .touchUpInside)
        
        // todayTextLabel 업데이트
        updateTodayTextLabel()
    }
    
    func updateTodayTextLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "M월 d일 (E)"
        
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        todayTextLabel.text = dateString
    }
    
    // API 호출
    func fetchTodoList() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        ApiService.getTodoList(for: currentDate) { [weak self] todoList in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let todoList = todoList {
                    self.todoItems = todoList
                    self.tableView.reloadData()
                    self.updateTableViewHeight()
                } else {
                    print("Failed to fetch todo list")
                }
            }
        }
    }
    
    // API 호출
    func fetchNotDoneCount() {
        ApiService.getNotDoneCount { [weak self] response in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let response = response, response.status == 200 {
                    if response.data == 0 {
                        self.remainCountTextLabel.text = "할 일을 모두 끝냈어요!"
                    }
                    else {
                        self.remainCountTextLabel.text = "\(response.data)개의 남은 할 일"
                    }
                } else {
                    self.remainCountTextLabel.text = "할 일 정보를 가져올 수 없습니다."
                }
            }
        }
    }
    
    func updateTableViewHeight() {
        view.layoutIfNeeded()
    }
    
    @objc func addNewTodoItem() {
        performSegue(withIdentifier: "addTodoBtnSegueFromHome", sender: self)
    }
    
    func convertToAPIDateFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    deinit {
        // 옵저버 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            showKeyboardHelper()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        hideKeyboardHelper()
    }
    
    func showKeyboardHelper(with text: String? = nil, category: String? = nil) {
        if keyboardHelperView == nil {
            print("showKeyboardHelper 호출")
            let accessoryHeight: CGFloat = 80
            let yOffsetAdjustment: CGFloat = 300

            let customAccessoryFrame = CGRect(x: 0, y: view.frame.height - keyboardHeight - accessoryHeight - yOffsetAdjustment, width: view.frame.width, height: accessoryHeight)
            
            keyboardHelperView = UIView(frame: customAccessoryFrame)
            keyboardHelperView?.layer.cornerRadius = 15
            keyboardHelperView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            keyboardHelperView?.layer.masksToBounds = true
            
            // 카테고리 색상 설정
            switch category ?? selectedCategory {
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
            label?.text = text // 셀의 titleLabel 값 또는 nil 설정
                        
            let arrowButton = UIButton(frame: CGRect(x: containerView.frame.width - 30, y: 0, width: 30, height: 30))
            arrowButton.setImage(UIImage(systemName: "arrow.forward.circle"), for: .normal)
            arrowButton.tintColor = .gray
            arrowButton.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)
            
            containerView.addSubview(label!)
            containerView.addSubview(arrowButton)
            
            keyboardHelperView?.addSubview(containerView)
            
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
        
        if let existingTodoId = currentEditingTodoId {
            print("수정 호출 API")
            // 수정 API 호출
            ApiService.updateTodoTitle(todoId: existingTodoId, title: text) { [weak self] success in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if success {
                        if let index = self.todoItems.firstIndex(where: { $0.todoId == existingTodoId }) {
                            self.todoItems[index].title = text
                            self.tableView.reloadData()
                        }
                        self.label?.text = ""
                    } else {
                        print("할 일 수정 실패")
                    }
                    self.hideKeyboardHelper()
                }
            }
        } else {
            // 생성 API 호출
            print("생성 호출 API")
            let apiDate = convertToAPIDateFormat(selectedDate)
            let category = selectedCategory ?? "DAILY"
        
            ApiService.addTodo(date: apiDate, title: text, category: category) { [weak self] success in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if success {
                                // 서버에서 받은 새로운 TodoItem을 사용
                                ApiService.getTodoList(for: apiDate) { [weak self] todoList in
                                    guard let self = self else { return }
                                    DispatchQueue.main.async {
                                        if let todoList = todoList {
                                            self.todoItems = todoList
                                            self.tableView.reloadData()
                                        } else {
                                            print("Failed to fetch updated todo list")
                                        }
                                    }
                                }
                                self.label?.text = ""
                            } else {
                                print("할 일 추가 실패")
                            }
                            self.hideKeyboardHelper()
                        }
                    }
        }
    }
    
    func titleLabelTapped(in cell: CustomTableViewCell, with title: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            let todoItem = todoItems[indexPath.row]
            currentEditingTodoId = todoItem.todoId
            showKeyboardHelper(with: title, category: todoItem.category)
        }
    }


    func hideKeyboardHelper() {
        keyboardHelperView?.removeFromSuperview()
        keyboardHelperView = nil
        print("사라져")
    }

    // 카테고리 선택 뷰 보여주기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTodoBtnSegueFromHome" {
            if let categoryVC = segue.destination as? CategoryViewController {
                currentEditingTodoId = nil
                categoryVC.delegate = self
            }
        }
    }
    
    func didSelectCategory(category: String) {
        print("선택된 카테고리: \(category)")
        selectedCategory = category
        selectedDate = Date() // 현재 날짜로 설정
        self.dismiss(animated: true)
        showKeyboardHelper()
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate, CustomTableViewCellDelegate {
    
    // 데이터 소스의 개수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        // delegate 설정
        cell.delegate = self
        
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
            DispatchQueue.main.async {
                if success {
                    if let index = self.todoItems.firstIndex(where: { $0.todoId == todoId }) {
                        self.todoItems[index].isDone.toggle()
                        self.tableView.reloadData()
                    }
                    // 남은 할 일 개수 업데이트
                    self.fetchNotDoneCount()
                } else {
                    print("Failed to toggle todo check status")
                }
            }
        }
    }
        
    // 셀의 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0 // 원하는 높이로 설정
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let todoItem = self.todoItems[indexPath.row]
            
            ApiService.deleteTodo(todoId: todoItem.todoId) { success in
                DispatchQueue.main.async {
                    if success {
                        // 삭제가 성공하면 할 일 목록에서 해당 항목을 제거하고 테이블 뷰를 업데이트
                        self.todoItems.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        completionHandler(true) // 액션 성공
                    } else {
                        // 실패 시 처리
                        print("할 일 삭제 실패")
                        completionHandler(false)
                    }
                }
            }
        }
        
        // 삭제 버튼 커스텀 디자인
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
        
        deleteAction.backgroundColor = .white
        deleteAction.image = deleteImage
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        // UITextField가 터치되었을 때 키보드 헬퍼를 숨기지 않도록 예외 처리
    }
}
