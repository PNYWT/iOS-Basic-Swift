//
//  TypeDateTableViewCell.swift
//  TestApp
//
//  Created by Dev on 21/1/2568 BE.
//

import UIKit
import SnapKit

class TypeDateTableViewCell: UITableViewCell {
    static let cellIndentifier = "TypeDateTableView"
    
    private var sizeColor = 30.0
    
    private lazy var colorView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.image = nil
        return view
    }()

    private lazy var lbNameTpye: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = #colorLiteral(red: 0.1125999954, green: 0.3446161656, blue: 1, alpha: 1)
        view.font = .systemFont(ofSize: 18)
        view.textAlignment = .left
        return view
    }()
    
    private lazy var switchView: UISwitch = {
        let sw = UISwitch()
        sw.backgroundColor = .clear
        sw.addTarget(self, action: #selector(swiftOnOff), for: .valueChanged)
        sw.isOn = true
        return sw
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(colorView)
        contentView.addSubview(lbNameTpye)
        contentView.addSubview(switchView)
        
        colorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(11)
            make.width.height.equalTo(sizeColor)
            make.centerY.equalToSuperview()
            colorView.layer.cornerRadius = sizeColor / 2.0
            colorView.layer.masksToBounds = true
        }
        lbNameTpye.snp.makeConstraints { make in
            make.leading.equalTo(colorView.snp.trailing).offset(4.0)
            make.centerY.equalToSuperview()
        }
        
        switchView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-11)
            make.centerY.equalToSuperview()
        }
    }
    
    public func setupContent(indexPath: IndexPath) {
        switchView.tag = indexPath.row
        lbNameTpye.text = "\(indexPath.row)"
    }
    
    @objc private func swiftOnOff(sender: UISwitch) {
        if sender.isOn {
            print("Switch is ON -> Tag: \(sender.tag)")
            // ดำเนินการเมื่อ Switch ถูกเปิด
        } else {
            print("Switch is OFF -> Tag: \(sender.tag)")
            // ดำเนินการเมื่อ Switch ถูกปิด
        }
    }
}

