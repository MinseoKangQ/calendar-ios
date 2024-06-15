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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTodoData(for: calendarView.currentPage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTodoData(for: calendarView.currentPage)
    }
    
    func setupUI() {
        dateFormatter.dateFormat = "yyyy-MM-dd"

        calendarView.delegate = self // delegate 등록
        calendarView.dataSource = self // datasource 등록
        
        // 캘린더뷰 모서리 둥글게
        calendarView.layer.cornerRadius = 10
        calendarView.layer.masksToBounds = true
        
        calendarView.locale = Locale(identifier: "ko_KR") // 달력 한글화
        calendarView.appearance.headerDateFormat = "YYYY년 M월" // 헤더 형식
        calendarView.appearance.headerTitleAlignment = .center // 헤더 글씨 중앙에 보이게
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0 // 헤더 양옆 글씨 안보이게 함
        calendarView.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 16) // 헤더 글씨체
        calendarView.appearance.weekdayTextColor = CUSTOM_WEEK_GREY // 요일 텍스트 색상 설정
    }
    
    // 할 일 데이터 가져오기
    func fetchTodoData(for date: Date) {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "yyyy-MM"
        let monthString = monthFormatter.string(from: date)
        
        // 한 달 조회 API 호출
        ApiService.getOneMonthTodoList(for: monthString) { response in
            guard let response = response else { return }
            
            if response.status == 200 {
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

// FSCalendarDelegate 확장
extension CalendarViewController: FSCalendarDelegate {
    
    // 현재 페이지가 변경될 때 호출
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        fetchTodoData(for: calendar.currentPage)
        calendar.reloadData() // UI 새로 로드
    }
    
    // 날짜 선택 시 호출
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // Modal 띄우기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyboard.instantiateViewController(withIdentifier: "TodoModalViewController") as? TodoModalViewController {
            newViewController.selectedDate = date // selectedDate를 Date 객체로 설정
            newViewController.delegate = self  // Delegate 설정
            self.present(newViewController, animated: true, completion: nil)
        }
        
        calendarView.reloadData() // 선택 상태 업데이트
    }
    
    // 날짜 선택 해제 호출
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendarView.reloadData() // 선택 해제 상태 업데이트
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
}

// FSCalendarDataSource 확장
extension CalendarViewController: FSCalendarDataSource {
    // 특정 날짜의 배경색 설정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        let today = Date()
        
        // 오늘 날짜인지 확인
        if Calendar.current.isDate(date, inSameDayAs: today) {
            return CALENDAR_TODAY // 오늘 날짜인 경우 특정 색상 유지
        }
        
        return .clear // 다른 날짜는 배경색 없음
    }
}

// FSCalendarDelegateAppearance 확장
extension CalendarViewController: FSCalendarDelegateAppearance {
    
    // 선택된 날짜의 텍스트 색상 설정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        let today = Date()
        let calendar = Calendar.current
        
        // 오늘 날짜인지 확인
        if calendar.isDate(date, inSameDayAs: today) {
            return WHITE_WHITE // 오늘 날짜인 경우 흰색 유지
        }
        
        // 현재 달이 아닌 경우
        if calendar.compare(date, to: calendarView.currentPage, toGranularity: .month) != .orderedSame {
            return CUSTOM_GREY // 회색으로 설정
        }
        
        return BLACK_WHITE // 선택된 날짜의 텍스트 색상 유지
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

// TodoModalViewControllerDelegate 확장
extension CalendarViewController: TodoModalViewControllerDelegate {
    func didUpdateTodo() {
        fetchTodoData(for: calendarView.currentPage)
    }
}
