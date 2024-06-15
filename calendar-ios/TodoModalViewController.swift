//
//  TodoModalViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit
import M13Checkbox

class TodoModalViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var clickedDate: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var todoItems: [TodoItem] = [] // 할 일 목록을 저장할 배열
    var keyboardHelperView: UIView? // 할 일을 입력받을 때 보이는 View
    var textField: UITextField? // 할 일을 입력받을 때 보이는 View 에 포함되는 TextField
    var selectedCategory: String? // 사용자가 선택한 카테고리를 저장하고 있는 변수
    var currentEditingTodoId: Int? // 현재 수정중인 todo의 PK값
    var selectedDate: Date? // Date 형식의 날짜를 저장할 변수
    var keyboardHeight: CGFloat = 0.0

    weak var delegate: TodoModalViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        setupSelectedDateLabel()
        setupTodoTableView()
        setupKeyboardNotifications()
    }
    
    // UI 설정
    func setupUI() {
        baseView.layer.cornerRadius = 20
    }
    
    // TapGestureRecognizer 등록
    func setupGestureRecognizers() {
        
        // 전체 뷰에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        self.view.addGestureRecognizer(tapGesture)
        
        // baseView는 탭 제스처에 반응하지 않도록 설정
        let baseTapGesture = UITapGestureRecognizer()
        baseView.addGestureRecognizer(baseTapGesture)
    }
    
    // 선택된 날짜 설정
    func setupSelectedDateLabel() {
        
        // selectedDate 값을 clickedDate 레이블에 설정
        if let date = selectedDate {
            let headerDateFormatter = DateFormatter()
            headerDateFormatter.locale = Locale(identifier: "ko_KR")
            headerDateFormatter.dateFormat = "M월 d일 (E)"
            let headerDate = headerDateFormatter.string(from: date)
            clickedDate.text = headerDate
            
            fetchTodoList(for: convertToAPIDateFormat(date))
        }
    }
    
    // TableView 설정
    func setupTodoTableView() {
        tableView.dataSource = self // dataSource 등록
        tableView.delegate = self // delegate 등록
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell") // cell 등록
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none // 셀 구분선 없애기
    }
    
    // Observer 설정
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Observer 제거
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // TableView 높이 업데이트
    func updateTableViewHeight() {
        view.layoutIfNeeded()
    }
    
    // 날짜를 API 형식으로 변환
    func convertToAPIDateFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // 할 일 목록 가져오기
    func fetchTodoList(for date: String) {
        
        // 할 일 목록 API 호출
        ApiService.getTodoList(for: date) { [weak self] todoList in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let todoList = todoList {
                    self.todoItems = todoList
                    self.tableView.reloadData()
                } else {
                    print("[TodoModalController] fetchTodoList API 호출 실패")
                }
            }
        }
    }
    
    // view 외의 곳 클릭하면 모달 닫힘
    @objc func dismissModal() {
        delegate?.didUpdateTodo()
        self.dismiss(animated: true, completion: nil)
    }

    // 카테고리 선택 뷰 보여주기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTodoBtnSegue" {
            if let categoryVC = segue.destination as? CategoryViewController {
                currentEditingTodoId = nil
                categoryVC.delegate = self
            }
        }
    }
    
    // 키보드 보이기
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            updateKeyboardHelperViewPosition()
        }
    }
    
    // 키보드 숨기기
    @objc func keyboardWillHide(notification: NSNotification) {
        hideKeyboardHelper()
    }
    
    // keyboardHelper 위치 조정
    func updateKeyboardHelperViewPosition() {
        guard let keyboardHelperView = keyboardHelperView else { return }
        let accessoryHeight: CGFloat = 60
        let yOffsetAdjustment: CGFloat = 0 // 키보드 바로 위
        let newY = view.frame.height - keyboardHeight - accessoryHeight - yOffsetAdjustment
        var frame = keyboardHelperView.frame
        frame.origin.y = newY
        keyboardHelperView.frame = frame
    }
    
    // keyboardHelper 보이기
    func showKeyboardHelper(with text: String? = nil, category: String? = nil) {
        if keyboardHelperView != nil {
            updateKeyboardHelperViewPosition() // 위치 업데이트
            return
        }
        
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
            keyboardHelperView?.backgroundColor = UIColor(named: "KeyboardRed")
        case "STUDY":
            keyboardHelperView?.backgroundColor = UIColor(named: "KeyboardBlue")
        case "DAILY":
            keyboardHelperView?.backgroundColor = UIColor(named: "KeyboardPurple")
        case "EXERCISE":
            keyboardHelperView?.backgroundColor = UIColor(named: "KeyboardYellow")
        default:
            keyboardHelperView?.backgroundColor = UIColor(red: 216/255, green: 230/255, blue: 242/255, alpha: 1.0)
        }
        
        let containerView = UIView(frame: CGRect(x: 10, y: 10, width: customAccessoryFrame.width - 20, height: 30))
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: containerView.frame.width - 30, height: 30))
        textField?.placeholder = "할 일을 입력하세요"
        textField?.textAlignment = .left
        textField?.textColor = UIColor(named: "KeyboardText")
        textField?.delegate = self // UITextFieldDelegate 설정
        textField?.text = text
                    
        let arrowButton = UIButton(frame: CGRect(x: containerView.frame.width - 30, y: 0, width: 30, height: 30))
        arrowButton.setImage(UIImage(systemName: "arrow.forward.circle"), for: .normal)
        arrowButton.tintColor = .gray
        arrowButton.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)
        
        containerView.addSubview(textField!)
        containerView.addSubview(arrowButton)
        
        keyboardHelperView?.addSubview(containerView)
        
        view.addSubview(keyboardHelperView!)
        
        textField?.becomeFirstResponder()
    }
    
    // keyboardHelper 숨기기
    func hideKeyboardHelper() {
        keyboardHelperView?.removeFromSuperview()
        keyboardHelperView = nil
    }
    
    // 할 일 추가 버튼 클릭
     @objc func addNewTodoItem() {
         performSegue(withIdentifier: "addTodoBtnSegueFromHome", sender: self)
     }

    // 할 일 텍스트 작성 완료 후 arrow 버튼 클릭
    @objc func arrowButtonTapped() {
        guard let text = textField?.text, !text.isEmpty else {
            hideKeyboardHelper()
            return
        }
        
        guard let selectedDate = selectedDate else {
            hideKeyboardHelper()
            return
        }
        
        // 할 일 수정 API 호출하는 경우
        if let existingTodoId = currentEditingTodoId {
            
            // 할 일 수정 API 호출
            ApiService.updateTodoTitle(todoId: existingTodoId, title: text) { [weak self] success in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if success {
                        if let index = self.todoItems.firstIndex(where: { $0.todoId == existingTodoId }) {
                            self.todoItems[index].title = text
                            self.tableView.reloadData()
                        }
                        self.textField?.text = ""
                    } else {
                        print("[TodoModalController] updateTodoTitle API 호출 실패")
                    }
                    self.hideKeyboardHelper()
                }
            }
        } else { // 할 일 생성 API 호출하는 경우
            let apiDate = convertToAPIDateFormat(selectedDate)
            let category = selectedCategory ?? "DAILY"
            
            ApiService.addTodo(date: apiDate, title: text, category: category) { [weak self] success in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if success {
                        ApiService.getTodoList(for: apiDate) { [weak self] todoList in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                if let todoList = todoList {
                                    self.todoItems = todoList
                                    self.tableView.reloadData()
                                } else {
                                    print("[HomeViewController] getTodoList API 호출 실패")
                                }
                            }
                        }
                        self.textField?.text = ""
                    } else {
                        print("할 일 추가 실패")
                    }
                    self.hideKeyboardHelper()
                }
            }
        }
    }
    
    // titleLabel 탭
    func titleLabelTapped(in cell: CustomTableViewCell, with title: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            let todoItem = todoItems[indexPath.row]
            currentEditingTodoId = todoItem.todoId // 수정하고자 하는 todo PK 저장
            showKeyboardHelper(with: title, category: todoItem.category)
        }
    }
    
}

// UITableViewDataSource 확장
extension TodoModalViewController: UITableViewDataSource {
    // TableView 행 개수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self // delegate 등록
        let todoItem = todoItems[indexPath.row] // 초기 데이터
        cell.titleLabel.text = todoItem.title // 할 일
        
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

        cell.configureBackgroundColor(category: todoItem.category) // 배경색 설정
        cell.checkBox.checkState = todoItem.isDone ? .checked : .unchecked // 체크박스 상태 설정
        cell.checkBox.tag = todoItem.todoId // todo PK 저장
        cell.checkBox.addTarget(self, action: #selector(checkBoxValueChanged(_:)), for: .valueChanged) // 체크박스 클릭
        
        return cell
    }
}

// UITableViewDelegate 확장
extension TodoModalViewController: UITableViewDelegate {
    // 삭제 기능
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let todoItem = self.todoItems[indexPath.row]
            
            // 할 일 삭제 API 호출
            ApiService.deleteTodo(todoId: todoItem.todoId) { success in
                DispatchQueue.main.async {
                    if success {
                        // 삭제가 성공하면 할 일 목록에서 해당 항목을 제거하고 테이블 뷰를 업데이트
                        self.todoItems.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        completionHandler(true) // 성공
                    } else {
                        // 실패 시 처리
                        print("[TodoModalController] deleteTodo API 호출 실패")
                        completionHandler(false)
                    }
                }
            }
        }
        
        // 삭제 버튼 커스텀 디자인
        let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 60))
        deleteView.backgroundColor = UIColor(named: "TrashBackground")
        deleteView.layer.cornerRadius = 8
        deleteView.layer.masksToBounds = true
        
        let deleteImageView = UIImageView(image: UIImage(systemName: "trash"))
        deleteImageView.tintColor = .red
        deleteImageView.contentMode = .scaleAspectFit
        deleteImageView.frame = CGRect(x: (deleteView.frame.width - 35) / 2, y: (deleteView.frame.height - 35) / 2, width: 35, height: 35)
        
        deleteView.addSubview(deleteImageView)
        
        UIGraphicsBeginImageContextWithOptions(deleteView.bounds.size, false, 0.0)
        deleteView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let deleteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        deleteAction.backgroundColor = UIColor(named: "TrashBackground")
        deleteAction.image = deleteImage
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    // 셀 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
}

// CustomTableViewCellDelegate 확장
extension TodoModalViewController: CustomTableViewCellDelegate {
    // 체크박스 클릭
    @objc func checkBoxValueChanged(_ sender: M13Checkbox) {
        let todoId = sender.tag
        
        // 할 일 상태 변경 API 호출
        ApiService.toggleTodoCheck(todoId: todoId) { [weak self] success in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    if let date = self.selectedDate {
                        self.fetchTodoList(for: self.convertToAPIDateFormat(date))
                    }
                }
            } else {
                print("[TodoModalController] toggleTodoCheck API 호출 실패")
            }
        }
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

// CategorySelectionDelegate 확장
extension TodoModalViewController: CategorySelectionDelegate {
    
    func didSelectCategory(category: String) {
        selectedCategory = category // 선택한 카테고리 저장
        self.dismiss(animated: true) // 창 닫기
        self.showKeyboardHelper() // keyboardHelper 보이기
    }
}

// UITextFieldDelegate 확장
extension TodoModalViewController: UITextFieldDelegate {
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        // UITextField가 터치되었을 때 키보드 헬퍼를 숨기지 않도록 예외 처리
    }
}

protocol TodoModalViewControllerDelegate: AnyObject {
    func didUpdateTodo()
}
