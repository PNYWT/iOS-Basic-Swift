//
//  SearchViewController.swift
//
//  Created by Dev on 18/11/2567 BE.
//  Copyright © 2567 BE OHLALA Online. All rights reserved.
//

import UIKit
import SnapKit

class SearchViewController: BaseViewController {
    
    private lazy var searchView: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "ค้นหา"
        view.delegate = self
        view.sizeToFit()
        view.barTintColor = .lbPrimaryDetail
        return view
    }()
    
    private var allPrayViewModel = AllPrayViewModel(isSearch: true)
    private var filteredData: [AllParySection] = []
    
    private lazy var contentSubView: ContentViewWithShadowView = {
        let view = ContentViewWithShadowView(parentView: contentView)
        return view
    }()
    
    private lazy var tableSearch: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(DynamicLabelCell.self, forCellReuseIdentifier: String(describing: DynamicLabelCell.self))
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .zero
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .bgTertiary
        view.separatorStyle = .none
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 60.0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseView()
        setupTableAndSearch()
    }
    
    private func setupBaseView() {
        setupBaseView(needNav: true, isStartPage: false, titlePage: "ค้นหาบทสวด", isCurrentSearch: true)
    }
    
    private func setupTableAndSearch() {
        contentSubView.layoutSubviews()
        contentSubView.contentView.addSubview(tableSearch)
        tableSearch.tableHeaderView = searchView
        filteredData = allPrayViewModel.dataListAll
        tableSearch.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableSearch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    deinit {
        print("deinit SearchViewController")
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DynamicLabelCell.self), for: indexPath) as? DynamicLabelCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .gray
        cell.backgroundColor = .white
        let text = filteredData[indexPath.section].rows[indexPath.row]
        cell.configure(with: String(format: "%d. %@", indexPath.row + 1, text.prayTitle))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .bgTertiary
        
        let imageView = UIImageView(image: UIImage(named: "bg_search"))
        imageView.contentMode = .scaleToFill
        headerView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(50 * (815 / 136 ))
            make.height.equalTo(50)
        }
        
        let label = LabelView(color: .lbPrimaryDetail, textAlignment: .center, font: .customFont(.PrimaryDetail, size: 18))
        label.text = filteredData[section].section
        imageView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.centerY.equalToSuperview().offset(-2)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        #if DEBUG
        print("didSelectRow ->", filteredData[indexPath.section].rows[indexPath.row])
        #endif
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let vc = ReadPrayViewController(
                withTitle: filteredData[indexPath.section].rows[indexPath.row].prayTitle,
                section: filteredData[indexPath.section].section,
                model: filteredData[indexPath.section].rows[indexPath.row])
            view.pushNavigation(goWhere: vc, needTransition: false)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            filteredData = allPrayViewModel.dataListAll
            tableSearch.reloadData()
            return
        }
        filterContent(for: text, in: allPrayViewModel.dataListAll)
    }
    
    private func filterContent(for searchText: String, in data: [AllParySection]) {
        filteredData = []
        guard searchText.count >= 2 else {
            filteredData = data
            tableSearch.reloadData()
            return
        }

        filteredData = data.compactMap { section in
            let filteredRows = section.rows.filter { row in
                row.prayTitle.range(of: searchText, options: .caseInsensitive) != nil
            }
            return filteredRows.isEmpty ? nil : AllParySection(section: section.section, rows: filteredRows)
        }
        tableSearch.reloadData()
    }
}
