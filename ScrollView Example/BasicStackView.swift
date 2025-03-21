//
//  BasicStackView.swift
//
//  Created by Dev on 3/2/2568 BE.
//

struct UIModel {
    var title: String!
}


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

@MainActor
public func renderUI(uiData: [UIModel]) {
    for (index, item) in uiData.enumerated() {
        self.stackView.addArrangedSubview(createButtonItem(index: index, item: item))
    }
    scrollView.layoutIfNeeded()
}

@MainActor
private func createButtonItem(index: Int, item: UIModel) -> UIView {
    let view = UIView()
    view.tag = index
    view.backgroundColor = .clear
    view.layer.cornerRadius = (view.bounds.size.height / 1.5) / 2.0
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.red.cgColor
    view.layer.masksToBounds =  true
    
    let button = UIButton()
    button.setTitle(String(format: "%@", item.title), for: .normal)
    button.tag = index
    button.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
    button.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    view.addSubview(button)
    button.snp.makeConstraints { make in
        make.edges.equalToSuperview()
    }
    return view
}

@objc private func selectAction(_ sender: UIButton) {
    
}
