//
//  CalendarViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/7/24.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: FSCalendar!
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue")
    let CUSTOM_GREY = UIColor(named: "CustomGrey")
    let CUSTOM_RED = UIColor(named: "CustomRed")
    let CUSTOM_WEEK_GREY = UIColor(named: "CustomWeekGrey")
    let CALENDAR_BLUE = UIColor(named: "CalendarBlue")
    let CALENDAR_RED = UIColor(named: "CalendarRed")
    let CALENDAR_TODAY = UIColor(named: "CalendarToday")
    let VIEW_BACKGROUND = UIColor(named: "ViewBackground")
    let BLACK_WHITE = UIColor(named: "BlackWhite")
    let WHITE_WHITE = UIColor(named: "WhiteWhite")
    let EVENT_DONE_COLOR = UIColor(named: "EventGreen") ?? UIColor.green
    let EVENT_NOT_DONE_COLOR = UIColor(named: "EventGrey") ?? UIColor.gray
    
    let dateFormatter = DateFormatter()
    var todoData: [String: TodoDayData] = [:]
    
    // 다른 탭에서 CalendarViewContoller로 넘어옴
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 데이터 새로고침
        fetchTodoData(for: calendarView.currentPage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTodoData(for: calendarView.currentPage)
    }
    
    func setupUI() {
        dateFormatter.dateFormat = "yyyy-MM-dd"

        calendarView.delegate = self
        calendarView.dataSource = self
        
        // 캘린더뷰 모서리 둥글게
        calendarView.layer.cornerRadius = 10
        calendarView.layer.masksToBounds = true
        
        // 달력 한글화
        calendarView.locale = Locale(identifier: "ko_KR")
        
        // 헤더
        calendarView.appearance.headerDateFormat = "YYYY년 M월" // 형식
        calendarView.appearance.headerTitleAlignment = .center // 헤더 글씨 중앙에 보이게
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0 // 안보이게 함
        calendarView.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 16)
        
        // 요일 텍스트 색상 설정
        calendarView.appearance.weekdayTextColor = CUSTOM_WEEK_GREY
        
    }
    
    func fetchTodoData(for date: Date) {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "yyyy-MM"
        let monthString = monthFormatter.string(from: date)
        
        ApiService.getOneMonthTodoList(for: monthString) { response in
            guard let response = response else {
                print("서버와 연결 불가능")
                return
            }
            
            if response.status == 200 {
                print("데이터 출력: \(response.data)")
                self.todoData = response.data
                DispatchQueue.main.async {
                    self.calendarView.reloadData()
                }
            } else {
                print("200이 아닌 상태코드 반환: \(response.message)")
            }
        }
    }

}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    // 현재 페이지가 변경될 때 호출
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("페이지 변경됨: \(calendar.currentPage)")
        fetchTodoData(for: calendar.currentPage)
        calendar.reloadData() // UI 새로 로드
    }
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 선택됨")
        
        // Modal 띄우기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyboard.instantiateViewController(withIdentifier: "TodoModalViewController") as? TodoModalViewController {
            
            // selectedDate를 Date 객체로 설정
            newViewController.selectedDate = date
            newViewController.delegate = self  // Delegate 설정
            self.present(newViewController, animated: true, completion: nil)
        }
        
        calendarView.reloadData() // 선택 상태 업데이트
    }
    
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 해제됨")
        calendarView.reloadData() // 선택 해제 상태 업데이트
    }
    
    // 선택된 날짜의 텍스트 색상 유지
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        let today = Date()
        let calendar = Calendar.current
        
        // 오늘 날짜인지 확인
        if calendar.isDate(date, inSameDayAs: today) {
            return WHITE_WHITE // 오늘 날짜인 경우 흰색 유지
        }
        
        // 현재 달이 아닌 경우 회색으로 설정
        if calendar.compare(date, to: calendarView.currentPage, toGranularity: .month) != .orderedSame {
            return CUSTOM_GREY
        }
        
        return .black // 선택된 날짜의 텍스트 색상 유지
    }

    // 기본 날짜 텍스트 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let isDarkMode = (UITraitCollection.current.userInterfaceStyle == .dark)
        let today = Date()
        
        if calendar.isDate(date, inSameDayAs: today) {
            return WHITE_WHITE // 오늘 날짜인 경우 흰색 유지
        }
        
        if let weekday = components.weekday {
            switch weekday {
            case 1: // 일요일
                return isDarkMode ? CALENDAR_RED : CALENDAR_RED
            case 7: // 토요일
                return isDarkMode ? CALENDAR_BLUE : CALENDAR_BLUE
            default:
                return isDarkMode ? BLACK_WHITE : BLACK_WHITE
            }
        }
        return isDarkMode ? BLACK_WHITE : BLACK_WHITE
    }
    
    // 특정 날짜의 배경색 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        let today = Date()
        
        // 오늘 날짜인지 확인
        if Calendar.current.isDate(date, inSameDayAs: today) {
            return CALENDAR_TODAY // 오늘 날짜인 경우 특정 색상 유지
        }
        
        return .clear // 다른 날짜는 배경색 없음
    }
    
    // 이벤트 개수 반환
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let day = Calendar.current.component(.day, from: date)
        let dayString = String(day)
        if let todoDayData = todoData[dayString] {
            if todoDayData.doneCount > 0 && todoDayData.notDoneCount > 0 {
                return 2
            } else if todoDayData.doneCount > 0 || todoDayData.notDoneCount > 0 {
                return 1
            }
        }
        return 0
    }
    
    // 이벤트 색상 설정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let day = Calendar.current.component(.day, from: date)
        let dayString = String(day)
        if let todoDayData = todoData[dayString] {
            if todoDayData.doneCount > 0 && todoDayData.notDoneCount > 0 {
                return [EVENT_DONE_COLOR, EVENT_NOT_DONE_COLOR]
            } else if todoDayData.doneCount > 0 {
                return [EVENT_DONE_COLOR]
            } else if todoDayData.notDoneCount > 0 {
                return [EVENT_NOT_DONE_COLOR]
            }
        }
        return nil
    }
    
    // 이벤트 색상 설정 (선택된 날짜에도 동일하게 적용)
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return self.calendar(calendar, appearance: appearance, eventDefaultColorsFor: date)
    }

}

extension CalendarViewController: TodoModalViewControllerDelegate {
    func didUpdateTodo() {
        fetchTodoData(for: calendarView.currentPage)
    }
}
