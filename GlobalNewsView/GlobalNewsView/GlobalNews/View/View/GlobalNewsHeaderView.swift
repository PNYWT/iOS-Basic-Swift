//
//  GlobalNewsHeaderView.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import SnapKit
import Combine
import SkeletonView

class GlobalNewsHeaderView: UIView {
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16.0
        return view
    }()
    
    // UI Source
    private var modelSetupView: GlobalNewsUIModel! = GlobalNewsUIModel.init()
    
    // Data Source
    private var tabModel: [GlobalNewsTabModel]! = []
    var sendEventTag = PassthroughSubject<Int, Never>()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = modelSetupView.underlineColor
        return view
    }()
    
    init(uiModel: GlobalNewsUIModel) {
        modelSetupView = uiModel
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = modelSetupView.globalNewsViewBackground
        scrollView.backgroundColor = modelSetupView.globalNewsViewBackground
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        self.isSkeletonable = true
        self.showAnimatedGradientSkeleton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(scrollView.snp.centerY)
            make.leading.equalTo(scrollView.snp.leading).offset(8.0)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-8.0)
            make.height.equalTo(scrollView.snp.height).dividedBy(1.5)
        }
    }
    
    // MARK: renderUI
    @MainActor
    public func renderUI(tabModelDatasource: [GlobalNewsTabModel]) {
        tabModel = tabModelDatasource
        for (index, item) in self.tabModel.enumerated() {
            self.stackView.addArrangedSubview(createButtonItem(index: index, item: item))
        }
        
        if let (index, model) = tabModel.enumerated().first(where: { $0.element.cat_default }) {
            if model.cat_default {
                stackView.layoutIfNeeded()
                setUnderline(index: index)
                stackView.addSubview(underlineView)
            }
        }

        
        stopSkeletonAnimation()
        hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        
        scrollView.layoutIfNeeded()
        if let haveDefault = tabModel.firstIndex(where: {
            $0.cat_default
        }) {
            scrollToCurrentButton(at: haveDefault, animated: true)
        }
    }
    
    private func setUnderline(index: Int) {
        let height = 1.0
        let targetView = stackView.arrangedSubviews[index]
        let underlineWidth: CGFloat = 20.0
        // let underlineWidth: CGFloat = targetView.frame.width - 32, จะให้ Dynamic ตามความยาวก็ใช้ code ที่ comment ไว้
        let underlineX: CGFloat = targetView.frame.origin.x + (targetView.frame.width - underlineWidth) / 2
        underlineView.frame = .init(
            x: underlineX,
            y: targetView.frame.origin.y + targetView.frame.height + height,
            width: underlineWidth,
            height: height
        )
    }
    
    public func scrollToCurrentButton(at index: Int, animated: Bool) {
        guard let stackView = scrollView.subviews.first(where: { $0 is UIStackView }) as? UIStackView else {
            return
        }
        guard index < stackView.arrangedSubviews.count else {
            return
        }
        let targetView = stackView.arrangedSubviews[index]
        let targetFrame = targetView.convert(targetView.bounds, to: scrollView)
        let offsetX = max(0, targetFrame.midX - scrollView.bounds.width / 2)
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        let finalOffsetX = min(offsetX, maxOffsetX)
        scrollView.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: animated)
    }
    
    @MainActor
    private func createButtonItem(index: Int, item: GlobalNewsTabModel) -> UIView {
        let view = UIView()
        view.tag = index
        view.backgroundColor = .clear
        view.layer.cornerRadius = (bounds.size.height / 1.5) / 2.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = modelSetupView.buttonSelectColor.cgColor
        view.layer.masksToBounds =  true
        
        let button = CustomButton(
            colorSelect: modelSetupView.buttonSelectColor,
            colorNormal: modelSetupView.buttonNonSelectColor,
            titleColorNormal: modelSetupView.buttonTitleColorNormal,
            titleColorSelect: modelSetupView.buttonTitleColorSelect,
            isHighlighted: false, isSelected: item.cat_default)
        button.setTitle(String(format: "%@", item.cat_name), for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        if item.cat_default {
            isNowSelect = index
        }
        button.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }
    
    private (set) var isNowSelect: Int!
    @objc private func selectAction(_ sender: UIButton) {
        if isNowSelect == sender.tag {
            return
        }
        if let view = stackView.subviews.first(where:
                                                { $0.tag == isNowSelect
        }) {
            if let button = view.subviews.first(where:
                                                    { $0.tag == isNowSelect
            }) as? CustomButton {
                button.isSelected.toggle()
            }
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {
                return
            }
            setUnderline(index: sender.tag)
        }
        isNowSelect = sender.tag
        sender.isSelected.toggle()
        sendEventTag.send(sender.tag)
        scrollToCurrentButton(at: sender.tag, animated: true)
    }
    
    public func selectAtButtonByIndexPage(index: Int) {
        if isNowSelect == index {
            return
        }
        if let view = stackView.subviews.first(where:
                                                { $0.tag == index
        }) {
            if let button = view.subviews.first(where:
                                                    { $0.tag == index
            }) as? CustomButton {
                selectAction(button)
            }
        }
    }
}
