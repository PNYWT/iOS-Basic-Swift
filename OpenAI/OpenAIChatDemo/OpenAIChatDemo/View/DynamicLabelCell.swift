//
//  DynamicLabelCell.swift
//  OpenAIChatDemo
//
//  Created by Dev on 18/12/2567 BE.
//

import UIKit
import SnapKit
import OpenAISwift

class DynamicLabelCell: UITableViewCell {
    
    static let reuseIdentifier =  "DynamicLabelCell"
    
    private lazy var labelChat: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.numberOfLines = 0
        lb.textColor = .black
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(labelChat)
        setupConstraints()
    }
    
    private func setupConstraints() {
        labelChat.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.bottom.trailing.equalToSuperview().offset(-16)
        }
    }
    
    public func configure(with chatMessage: ChatMessage) {
        print("chatMessage -> \(chatMessage)")
        switch chatMessage.role {
        case .assistant, .system:
            labelChat.text = String(format: "%@: %@", chatMessage.role.rawValue.uppercased(), chatMessage.content)
            labelChat.textAlignment = .left
        case .user:
            labelChat.text = chatMessage.content
            labelChat.textAlignment = .right
        }
    }
}
