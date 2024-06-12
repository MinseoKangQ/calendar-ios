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
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"

        calendarView.delegate = self
        calendarView.dataSource = self
        
        // 캘린더뷰 모서리 둥글게
        calendarView.layer.cornerRadius = 10
        calendarView.layer.borderWidth = 1
        calendarView.layer.borderColor = UIColor.white.cgColor
        calendarView.backgroundColor = UIColor.white
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
        
        // 오늘
        calendarView.appearance.todayColor = CALENDAR_TODAY
        
        // 선택된 날짜 배경 색상 없애기
        calendarView.appearance.selectionColor = .clear
        calendarView.appearance.borderSelectionColor = .clear
        
    }

}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 선택됨")
        
        // Modal 띄우기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyboard.instantiateViewController(withIdentifier: "TodoModalViewController") as? TodoModalViewController {
            
            // selectedDate를 Date 객체로 설정
            newViewController.selectedDate = date
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
        
        // 오늘 날짜인지 확인
        if Calendar.current.isDate(date, inSameDayAs: today) {
            return .white // 오늘 날짜인 경우 흰색 유지
        }
        
        return .black // 선택된 날짜의 텍스트 색상 유지
    }
    
    // 기본 날짜 텍스트 색상 변경
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let today = Date()
        
        // 오늘 날짜인지 확인
        if calendar.isDate(date, inSameDayAs: today) {
            return .white // 오늘 날짜인 경우 흰색 유지
        }
        
        if let weekday = components.weekday {
            switch weekday {
            case 1: // 일요일
                return CALENDAR_RED
            case 7: // 토요일
                return CALENDAR_BLUE
            default:
                return .black
            }
        }
        return .black
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

}
