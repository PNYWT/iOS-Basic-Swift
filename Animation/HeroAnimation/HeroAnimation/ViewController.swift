//
//  ViewController.swift
//  HeroAnimation
//
//  Created by Dev on 7/2/2568 BE.
//

import UIKit
import Hero
import SnapKit

struct UIModel {
    var title: String!
}

class ViewController: UIViewController {
    
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
    
    // MARK: Match Zoom out
    private lazy var blueView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.isHidden = true
        view.cornerRadius = 8
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBlueView))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    // MARK: Match Cross ViewController
    private lazy var redCrossView: UIView = { // ต้อง id match กับ ViewController2
        let view = UIView()
        view.hero.id = "redCrossView"
        view.backgroundColor = .red
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRedCross))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var yellowView: UIView = {
        let view = UIView()
        view.hero.id = "yellowView"
        view.backgroundColor = .yellow
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moveView))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    private var isMovedRight = false
    private var yellowViewLeadingConstraint: Constraint? // เก็บ Constraint ของ SnapKit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(blueView)
        view.addSubview(redCrossView)
        
        renderUI(uiData: [.init(title: "TestViewController"), .init(title: "BlueView")])
        setupYellowView()
    }
    
    private func setupYellowView() {
        view.addSubview(yellowView)
        yellowView.snp.makeConstraints { make in
            yellowViewLeadingConstraint = make.leading.equalToSuperview().offset(50).constraint
            make.top.equalToSuperview().offset(200)
            make.width.height.equalTo(100)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(100.0)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.height.equalToSuperview()
        }
        
        redCrossView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
    }
}

// MARK: Create Stack
extension ViewController {
    @MainActor
    public func renderUI(uiData: [UIModel]) {
        for (index, item) in uiData.enumerated() {
            self.stackView.addArrangedSubview(createButtonItem(index: index, item: item))
            if index == 1 {
                blueView.snp.makeConstraints { make in
                    make.center.equalTo(self.stackView.arrangedSubviews[index])
                    make.width.height.equalTo(100)
                }
            }
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
        button.setTitleColor(.blue, for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }
}

// MARK: Method
extension ViewController {
    @objc private func selectAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            // MARK: PresentAnimation
            goToSecondVC()
        case 1:
            // MARK: Show BlueView
            blueView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.blueView.hero.modifiers = [.scale(1), .opacity(1)]
                self.blueView.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                self.view.layoutIfNeeded()
            })
            
        default:
            break
        }
    }
    @objc func hideBlueView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.blueView.hero.modifiers = [.scale(0.1), .opacity(0)]
            self.blueView.snp.remakeConstraints { make in
                make.center.equalTo(self.stackView.arrangedSubviews[1])
                make.width.height.equalTo(100)
            }
            self.view.layoutIfNeeded()
        }) { _ in
            self.blueView.isHidden = true
            
        }
    }
    
    // MARK: RedCross
    @objc func handleRedCross(_ sender: UITapGestureRecognizer) {
        goToSecondVC(isMatch: true)
    }
    
    // MARK: Yellow
    @objc func moveView() {
        let moveDistance: CGFloat = 200 // ระยะที่ต้องการให้เลื่อน
        
        // 🔹 อัปเดต Constraints เพื่อให้ SnapKit คำนวณใหม่
        yellowViewLeadingConstraint?.update(offset: isMovedRight ? 50 : 50 + moveDistance)
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        isMovedRight.toggle() // สลับสถานะการเลื่อน
    }
    
    @objc func goToSecondVC(isMatch: Bool = false) {
        let vc = ViewController2()
        if isMatch {
            presentHeroWith(controller: vc, presenting: nil, dismissing: nil)
        } else {
            presentHeroWith(controller: vc, presenting: .fade, dismissing: .pull(direction: .down))
        }
    }
}

