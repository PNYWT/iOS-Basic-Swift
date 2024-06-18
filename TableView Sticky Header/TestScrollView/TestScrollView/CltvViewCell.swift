//
//  CltvViewCell.swift
//  TestScrollView
//
//  Created by Dev on 18/6/2567 BE.
//

import UIKit
import SnapKit

class CltvViewCell: UICollectionViewCell {
    static let identifierCell = "CltvViewCell"
    
    private lazy var tableView: UITableView! = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self,forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .blue
        return tableView
    }()
    
    private lazy var headerView: CustomHeaderView! = {
        let view = CustomHeaderView(frame: .zero, title: "ABC")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var topTableConstraint: Constraint!
    private var maxSpaceTop: CGFloat = 200
    private var minimumSpaceTop: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setUpHeader()
        setUpTableView()
    }
    
    private func setUpHeader() {
        contentView.addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.height.equalTo(maxSpaceTop)
        }
    }
    
    private func setUpTableView() {
        contentView.layoutIfNeeded()
        contentView.addSubview(tableView)
        tableView.backgroundColor = .red
        tableView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(maxSpaceTop)
            make.width.centerX.height.equalTo(contentView)
        }
        tableView.layer.cornerRadius = 15
        // Top Left Corner: .layerMinXMinYCorner
        // Top Right Corner: .layerMaxXMinYCorner
        // Bottom Left Corner: .layerMinXMaxYCorner
        // Bottom Right Corner: .layerMaxXMaxYCorner
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

extension CltvViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            tableView.snp.updateConstraints { make in
                make.top.equalTo(contentView.snp.top).offset(maxSpaceTop)
            }
        } else if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= maxSpaceTop {
            tableView.snp.updateConstraints { make in
                make.top.equalTo(contentView.snp.top).offset(maxSpaceTop - abs(scrollView.contentOffset.y))
            }
        } else if scrollView.contentOffset.y > maxSpaceTop {
            tableView.snp.updateConstraints { make in
                make.top.equalTo(contentView.snp.top).offset(minimumSpaceTop)
            }
        }
    }
}

extension CltvViewCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",   for: indexPath as IndexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = "Article \(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
