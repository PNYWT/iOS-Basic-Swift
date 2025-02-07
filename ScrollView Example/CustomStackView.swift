//
//  CustomStackView.swift
//
//  Created by Dev on 3/2/2568 BE.
//

import UIKit
import SnapKit
import MapKit
import FloatingPanel
import Combine

// MARK: ScrollStackView
class ScrollStackView: UIScrollView {
    
    struct StackModel {
        var type: NSLayoutConstraint.Axis
        var spacing: CGFloat = 8.0
        var alignment: UIStackView.Alignment = .center
    }
    
    struct StackItem {
        var itemType: StackItemType
        var sizeItem: CGSize
        var uiStyleModel: UIStyleModel?
        var cornerRadius: CornerRadiusType
        var radiusCustom: CGFloat?
    }
    
    enum StackItemType {
        case ImageView
        case NormalButton
        case Compass
        case CurrentLocation
        case SearchLocation
        case SettingMap
        case OpenCamera
        case CameraSwitch
        case CameraFlahLight
        case GroupAll
        case AddLocation
        case InviteFriend
        case SpaceView
    }
    
    // UI
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = scrollStackModel.type
        stackView.distribution = .fillProportionally
        stackView.alignment = scrollStackModel.alignment
        stackView.spacing = scrollStackModel.spacing
        return stackView
    }()
    
    // Data Source
    private var scrollStackModel: StackModel!
    private var itemStack: [StackItem]!
    
    // Event
    private var buttonActions: [UIButton: (UIButton) -> Void] = [:]
    @Published var settingMapAction = false
    @Published var searchAction = false
    @Published var generalActionWithTag: Int?
    
    @Published var openCameraAction = false
    @Published var cameraSwitchAction: Bool?
    @Published var cameraFlashAction: Bool?
    
    init(type: NSLayoutConstraint.Axis,
         spacing: CGFloat = 8,
         alignment: UIStackView.Alignment = .center,
         item: [StackItem],
         mapView: MKMapView? = nil, canScroll: Bool) {
        super.init(frame: .zero)
        scrollStackModel = .init(type: type == .vertical ? .vertical : .horizontal,
                                 spacing: spacing,
                                 alignment: alignment)
        itemStack = item
        self.alwaysBounceVertical = type == .vertical ? true : false
        self.alwaysBounceHorizontal = type == .horizontal ? true : false
        self.isScrollEnabled = canScroll
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        setupView(item: item, mapView: mapView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    private func setupView(item: [StackItem], mapView: MKMapView?) {
        for item in item {
            switch item.itemType {
            case .Compass:
                addView(item: item, mapView: mapView)
            case .CurrentLocation:
                addView(item: item, mapView: mapView)
            case .SearchLocation:
                addButton(item: item) { [weak self] sender in
                    sender.isSelected.toggle()
                    self?.searchAction = sender.isSelected
                }
            case .SettingMap:
                addButton(item: item) { [weak self] sender in
                    sender.isSelected.toggle()
                    self?.settingMapAction = sender.isSelected
                }
            case .GroupAll:
                addView(item: item)
            case .AddLocation:
                addView(item: item)
            case .InviteFriend:
                addView(item: item)
            case .ImageView:
                let imageView = UIImageView()
                stackView.addArrangedSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.width.height.equalTo(item.sizeItem.height)
                }
                imageView.backgroundColor = .blue
            case .SpaceView:
                addView(item: item)
            case .NormalButton:
                addButton(item: item) { [weak self] sender in
                    self?.actionGeneral(sender: sender, typeButton: item.itemType)
                }
            case .OpenCamera:
                addButton(item: item) { [weak self] sender in
                    sender.isSelected.toggle()
                    self?.openCameraAction = true
                }
            case .CameraSwitch:
                addButton(item: item) { [weak self] sender in
                    sender.isSelected.toggle()
                    self?.cameraSwitchAction = sender.isSelected
                }
            case .CameraFlahLight:
                addButton(item: item) { [weak self] sender in
                    sender.isSelected.toggle()
                    self?.cameraFlashAction = sender.isSelected
                }
            }
        }
        
        stackView.layoutIfNeeded()
        let size = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if stackView.axis == .vertical {
            self.snp.updateConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
        } else {
//            print("sizesizesize -> \(size)")
            self.snp.updateConstraints { make in
                make.width.equalTo(size.width)
                make.height.equalTo(size.height)
            }
        }
       
        contentSize = size
    }
    
    private func addView(item: StackItem, mapView: MKMapView? = nil) {
        let view: UIView

        switch item.itemType {
        case .Compass:
            view = MKCompassButton(mapView: mapView)
        case .CurrentLocation:
            view = MKUserTrackingButton(mapView: mapView)
        case .ImageView:
            let imageView = UIImageView()
            imageView.backgroundColor = item.uiStyleModel?.background
            view = imageView
        case .SpaceView:
            view = UIView()
            view.backgroundColor = item.uiStyleModel?.background
        default:
            view = UIView()
            view.backgroundColor = item.uiStyleModel?.background
        }
        configureView(view, with: item)
    }

    // MARK: - Helper Function
    private func configureView(_ view: UIView, with item: StackItem) {
        stackView.addArrangedSubview(view)
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(item.sizeItem.height)
        }
        
        view.createCornerRadius(with: item.cornerRadius, radius: item.radiusCustom ?? item.sizeItem.height)
    }

    private func addButton(item: StackItem, action: @escaping (UIButton) -> Void) {
        let button = UIButton()
        button.addTarget(self, action: #selector(actionButton(_:)), for: .touchUpInside)
        if let haveTitle = item.uiStyleModel?.title, !haveTitle.isEmpty {
            button.setTitle(haveTitle, for: .normal)
        }
        if let normalImage = item.uiStyleModel?.imageNormal {
            button.setImage(normalImage, for: .normal)
        }
        if let selectedImage = item.uiStyleModel?.imageSelected {
            button.setImage(selectedImage, for: .selected)
        }
        if let tagAction = item.uiStyleModel?.tagAction {
            button.tag = tagAction
        }
        button.isSelected = item.uiStyleModel?.isSelect ?? false
        button.backgroundColor = item.uiStyleModel?.background ?? .clear
        buttonActions[button] = action
        stackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(item.sizeItem.height)
            make.width.equalTo(item.sizeItem.width)
        }
        button.createCornerRadius(with: item.cornerRadius, radius: item.radiusCustom ?? item.sizeItem.height)
    }
}

// MARK: Method
extension ScrollStackView {
    @objc private func actionButton(_ sender: UIButton) {
        buttonActions[sender]?(sender)
    }
    
    private func actionGeneral(sender: UIButton, typeButton: StackItemType) {
        sender.isSelected.toggle()
        generalActionWithTag = sender.tag
    }
}
