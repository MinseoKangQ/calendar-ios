//
//  CalendarViewController.swift
//  calendar-ios
//
//  Created by 강민서 on 6/7/24.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var calendarView: FSCalendar!
    
    let CUSTOM_BLUE = UIColor(named: "CustomBlue") // 007aff
    let CUSTOM_GREY = UIColor(named: "CustomGrey") // c7c7cd
    let CUSTOM_RED = UIColor(named: "CustomRed") // ff3b30
    let CUSTOM_WEEK_GREY = UIColor(named: "CustomWeekGrey") // 717175
    let CALENDAR_BLUE = UIColor(named: "CalendarBlue")
    let CALENDAR_RED = UIColor(named: "CalendarRed")
    let CALENDAR_TODAY = UIColor(named: "CalendarToday")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.delegate = self
        calendarView.dataSource = self
        
        // 달력 한글화
        calendarView.locale = Locale(identifier: "ko_KR")
        
        // 헤더
        calendarView.appearance.headerDateFormat = "YYYY년 MM월" // 형식
        calendarView.appearance.headerTitleAlignment = .center // 헤더 글씨 중앙에 보이게
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0 // 안보이게 함
        calendarView.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 16)
        
        // 요일 텍스트 색상 설정
        calendarView.appearance.weekdayTextColor = CUSTOM_WEEK_GREY
        
        // 오늘
        calendarView.appearance.todayColor = CALENDAR_TODAY
        
        // 선택된 날짜 배경 색상 설정
        calendarView.appearance.selectionColor = .black
        
        
    }

}
