//
//  DatePrayCalendarViewController.swift
//
//  Created by Dev on 21/11/2567 BE.
//  Copyright © 2567 BE OHLALA Online. All rights reserved.
//

import UIKit
import SnapKit
import FSCalendar
import Combine

class DatePrayCalendarViewController: BaseViewController {
    
    private var datePrayCalendarViewModel: DatePrayCalendarViewModel! = DatePrayCalendarViewModel()
    private var cancelLabels = Set<AnyCancellable>()
    
    private var selectSameDate: Date! = Date()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.isScrollEnabled = true
        return view
    }()
    
    private lazy var contentSubView: ContentViewWithShadowView = {
        let view = ContentViewWithShadowView(parentView: contentView, bannerView: bannerView)
        return view
    }()
    
    // MARK: FSCalendar
    private (set) lazy var calendarView: FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        
        calendar.appearance.selectionColor = .clear
        
        calendar.appearance.weekdayTextColor = .black   // สีของวันในสัปดาห์ -> check
        
        calendar.appearance.titleDefaultColor = .black // สีของวันที่ปกติ -> check
        calendar.appearance.titleSelectionColor = .white // สีของวันที่ถูกเลือก -> check
        
        calendar.appearance.titleFont = .customFont(.SecondaryDetail, size: 14.0)  // ฟอนต์ของวันที่ -> check
        calendar.locale = Locale(identifier: "th")
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCalendarCell")
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = false
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.calendarHeaderView.collectionView.alpha = 0.0
        calendar.calendarWeekdayView.backgroundColor = .clear
        calendar.scope = .month
        calendar.backgroundColor = .clear
        return calendar
    }()
    
    private lazy var customHeaderView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "bg_headerCalendar"))
        view.addSubview(imageView)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-4.0)
            make.centerY.equalToSuperview().offset(18.0 / 2)
        }
        
        let monthLabel = LabelView(color: .black, textAlignment: .center, font: .customFont(.PrimaryDetail, size: 18.0))
        monthLabel.tag = 1
        monthLabel.backgroundColor = .clear
        view.addSubview(monthLabel)
        monthLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        view.backgroundColor = .bgTertiary
        return view
    }()
    
    private lazy var calendarFooter: UIImageView = {
        let view = UIImageView(image: UIImage(named: "MainFooter"))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: Table
    private lazy var tableMainView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(CalendarTableViewCell.self, forCellReuseIdentifier: String(describing: CalendarTableViewCell.self))
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .init(top: 0, left: 0, bottom: 34.0, right: 0)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.isScrollEnabled = false
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 75.0
        return view
    }()

    private var selectDateShowTbv: [BuddhistCalendarModel] = []

    private lazy var bannerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var getCenterModel: CenterSDKModel = {
        return centerSDKViewModel.centerSDKModel
    }()
    private var myPrayFav: Bool!
    private (set) weak var centerSDKViewModel: CenterSDKViewModel!
    private (set) weak var svAdsViewModel: SvAdsViewModel!
    private var admobViewModel: AdMobViewModel = AdMobViewModel()
    init(withTitle: String, centerSDKViewModel: CenterSDKViewModel, svAdsViewModel: SvAdsViewModel) {
        self.centerSDKViewModel = centerSDKViewModel
        self.svAdsViewModel = svAdsViewModel
        super.init(nibName: nil, bundle: nil)
        setupBaseView(needNav: true, isStartPage: false, titlePage: withTitle, isCaleandar: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
    }
    
    private func setupView() {
        setupBannerView()
        contentSubView.layoutSubviews()
        setupScrollView()
    }
    
    private func setupScrollView() {
        contentSubView.contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupCalendar()
    }
    
    private func setupCalendar() {
        scrollView.addSubview(calendarView)
        calendarView.calendarHeaderView.addSubview(customHeaderView)
        calendarView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(calendarView.snp.width).offset(120)
            make.top.centerX.equalToSuperview()
        }
        customHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(calendarFooter)
        calendarFooter.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(60.0)
            make.top.equalTo(calendarView.snp.bottom)
        }
        setupTableView()
    }
    
    private func setupTableView() {
        scrollView.addSubview(tableMainView)
        tableMainView.snp.makeConstraints { make in
            make.top.equalTo(calendarFooter.snp.bottom)
            make.bottom.equalTo(contentView.snp.bottom)
            make.width.equalToSuperview()
        }
        tableMainView.backgroundColor = .red
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = .init(width: contentSubView.contentView.bounds.width, height: calendarView.bounds.height + calendarFooter.bounds.height + tableMainView.bounds.height)
        print("tableMainView.bounds.height -> \(tableMainView.bounds.height)")
    }
    
    private func setupBinding() {
        datePrayCalendarViewModel.$holidaysByYearAndMonth
            .filter( { !$0.isEmpty } )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
//                print("holidaysByYearAndMonth -> \(datePrayCalendarViewModel.holidaysByYearAndMonth[2024]?[11])")
                calendarView.reloadData()
                updateHeader(for: calendarView.currentPage)
            }.store(in: &cancelLabels)
        datePrayCalendarViewModel.loadCalendar()
    }
    
    private func setupBannerView() {
        contentView.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
            make.height.equalTo(0.0)
        }
        if getCenterModel.showAds {
            svAdsViewModel?.getBannerSDK(pageNo: PageConfigAd.worship, parentView: bannerView, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                admobViewModel.getBannerAdmob(parentView: bannerView, withRoot: self)
            })
        }
    }
    
    public func clearWhenSelectToday() {
        let today = Date()
        calendarView.select(today, scrollToDate: true)
        calendarView.reloadData()
        selectTable(date: today)
    }
    
    deinit {
        print("DatePrayCalendarViewController deinit")
    }
}

// MARK: FSCalendarDataSource, FSCalendarDelegate
extension DatePrayCalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCalendarCell", for: date, at: position) as? CustomCalendarCell else {
            return FSCalendarCell()
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        guard let haveCell = cell as? CustomCalendarCell else {
            return
        }
        configure(calendar: calendar, diyCell: haveCell, for: date, at: position)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateHeader(for: calendar.currentPage)
        calendar.reloadData()
    }
    
    private func updateHeader(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "th_TH")
        dateFormatter.calendar = Calendar(identifier: .buddhist)
        dateFormatter.dateFormat = "MMMM yyyy"
        
        if let monthLabel = customHeaderView.viewWithTag(1) as? UILabel {
            monthLabel.text = dateFormatter.string(from: date)
        }
    }
    
    // MARK: Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        if !isSameMonth(date1: date, date2: calendar.currentPage) {
            calendar.setCurrentPage(date, animated: true)
        }
        setupSelect(calendar: calendar)
        
        // Select date show in Tableview
        selectTable(date: date)
    }
    
    private func selectTable(date: Date) {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let components = gregorianCalendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month,
                let dataList = datePrayCalendarViewModel.holidaysByYearAndMonth[year]?[month] else {
            selectDateShowTbv = []
            tableMainView.reloadData()
            return
        }
        let selectedDateString = date.getDateToCheckDetail()
//        print("date.getDateToCheckDetail() -> \(date.getDateToCheckDetail())")
        let filteredDataList = dataList.filter { $0.buddhist_calendar_date == selectedDateString
        }
        let aaaaa = filteredDataList
        let bbbbb = filteredDataList
        selectDateShowTbv = filteredDataList + aaaaa + bbbbb + aaaaa + bbbbb + aaaaa + bbbbb + aaaaa + bbbbb + aaaaa + bbbbb + aaaaa + bbbbb
        #if DEBUG
        print("selectDateShowTbv -> \(selectDateShowTbv)")
        #endif

        DispatchQueue.main.async { [weak self] in
            
            self?.tableMainView.reloadData()
        }
    }
    
    private func isSameMonth(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month], from: date1)
        let components2 = calendar.dateComponents([.year, .month], from: date2)
        return components1.year == components2.year && components1.month == components2.month
    }
    
    private func setupSelect(calendar: FSCalendar) {
        calendar.visibleCells().forEach { cell in
            guard let haveCell = cell as? CustomCalendarCell else {
                return
            }
            let date = calendar.date(for: haveCell)
            let position = calendar.monthPosition(for: haveCell)
            self.configure(calendar: calendar, diyCell: haveCell, for: date!, at: position)
        }
    }
    
    private func configure(calendar: FSCalendar, diyCell: CustomCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let components = gregorianCalendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year, let month = components.month else {
            return
        }
        diyCell.configureCalendar(calendarView: calendar, for: date, at: position, detailCalendar: datePrayCalendarViewModel.holidaysByYearAndMonth[year]?[month])
    }
}

// MARK: TableViewDelegate
extension DatePrayCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectDateShowTbv.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CalendarTableViewCell.self), for: indexPath) as? CalendarTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.setupContent(model: selectDateShowTbv[indexPath.row])
        return cell
    }
}
