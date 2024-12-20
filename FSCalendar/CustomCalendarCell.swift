//
//  CustomCalendarCell.swift
//
//  Created by Dev on 21/11/2567 BE.
//  Copyright © 2567 BE OHLALA Online. All rights reserved.
//

import Foundation
import FSCalendar
import UIKit
import SnapKit

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

class CustomCalendarCell: FSCalendarCell {
    
    private (set) lazy var dateLabel: LabelView = {
        let view = LabelView(color: .lbBlack, textAlignment: .center, font: .customFont(.NewsDetail, size: 12))
        return view
    }()
    
    private lazy var datelbDetail: LabelView = {
        let view = LabelView(color: .lbBlack, textAlignment: .center, font: .customFont(.NewsDetail, size: 8))
        view.numberOfLines = 2
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var imageDay: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
//    private lazy var selectionLayer: CAShapeLayer = {
//        let view = CAShapeLayer()
//        view.fillColor = UIColor.black.cgColor
//        view.actions = ["hidden": NSNull()]
//        return view
//    }()
    
    private (set) lazy var currentDateView: UIView = {
        let view = UIView()
        view.backgroundColor = .calendarCurrentDate
        return view
    }()
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel.isHidden = true // ซ่อน deualt FSCalendarCell
        self.imageView.isHidden = true  // ซ่อน deualt FSCalendarCell
        self.shapeLayer.isHidden = true
        
        contentView.addSubview(currentDateView)
        currentDateView.addSubview(dateLabel)
        contentView.addSubview(imageDay)
        contentView.addSubview(datelbDetail)
        contentView.backgroundColor = .white
        setupConstraints()
        
//        currentDateView.layer.insertSublayer(selectionLayer, at: 0)
//        self.selectionLayer = selectionLayer
    }
    
    //MARK: configureCalendar
    public func configureCalendar(calendarView: FSCalendar, for date: Date, at position: FSCalendarMonthPosition, detailCalendar: [BuddhistCalendarModel]?) {
        let gregorian = Calendar(identifier: .gregorian)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let day = calendar.component(.day, from: date)
        let currentDate = gregorian.isDateInToday(date) // เป็นวันที่วันนี้
        
        dateLabel.text = "\(day)"
        datelbDetail.text = ""
        imageDay.image = nil
//        print("calendarView -> \(calendarView.currentPage), currentDate -> \(currentDate)")
        
        if !isSameDay(date1: date, date2: Date()), let selectDate = calendarView.selectedDate {
            if selectDate == date {
                if calendar.component(.month, from: calendarView.currentPage) == calendar.component(.month, from: date) {
                    currentDateView.backgroundColor = .calendarSelectDate
                    dateLabel.textColor = .white
                    contentView.alpha = 1.0
                }
            } else {
                setDefaultCell(calendarView: calendarView, calendar: calendar, date: date, currentDate: currentDate)
            }
        } else {
            setDefaultCell(calendarView: calendarView, calendar: calendar, date: date, currentDate: currentDate)
        }
        if weekday == 1 || weekday == 7 {
            dateLabel.textColor = .red
        }
        checkShowDataDate(detailCalendar: detailCalendar, date: date)
    }
    
    private func setDefaultCell(calendarView: FSCalendar, calendar: Calendar, date: Date, currentDate: Bool) {
        if calendar.component(.month, from: calendarView.currentPage) == calendar.component(.month, from: date) { // เทียบเดือนเดียวกัน
            currentDateView.backgroundColor = .calendarCurrentDate
            if currentDate {
                contentView.alpha = 1.0
                dateLabel.textColor = .white
            } else {
                contentView.alpha = 1.0
                currentDateView.backgroundColor = .clear
                dateLabel.textColor = .lbBlack
            }
        } else {  // สีจางสำหรับวันที่ไม่ใช่ของเดือนนี้
            currentDateView.backgroundColor = .clear
            dateLabel.textColor = .lightGray
            contentView.alpha = 0.5
            if currentDate {
                dateLabel.textColor = .white
                currentDateView.backgroundColor = .calendarCurrentDate
            }
        }
    }

    private func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func checkShowDataDate(detailCalendar: [BuddhistCalendarModel]?, date: Date) {
        if let model = detailCalendar?.first(where: { $0.buddhist_calendar_date == date.getDateToCheckDetail() }) {
            datelbDetail.text = model.holiday_name
            
            if let buddhist_day = model.buddhist_day, buddhist_day {
                imageDay.image = UIImage(named: "buddhist_day")
            }
            
            if let fullmoon_1 = model.lunar_calendar_status, fullmoon_1 == "fullmoon_1" {
                imageDay.image = UIImage(named: "fullmoon_1")
            }
            
            if let holiday = model.holiday, holiday {
                dateLabel.textColor = .red
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(2)
            make.trailing.bottom.equalToSuperview().offset(-2)
        }
        
        currentDateView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
            make.width.height.equalTo(25)
            currentDateView.makeCornerRadius(radius: 25/2, needMasksToBounds: true)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-2)
        }
        
        imageDay.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.leading.equalToSuperview().offset(2)
            make.width.height.equalTo(15)
        }
        
        datelbDetail.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-4)
            make.top.equalTo(currentDateView.snp.bottom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
