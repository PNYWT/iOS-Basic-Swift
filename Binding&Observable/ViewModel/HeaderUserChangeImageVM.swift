//
//  HeaderUserChangeImageVM.swift
//  PlayPlayPlus
//
//  Created by Dev on 10/4/2567 BE.
//

import Foundation
import UIKit
import YPImagePicker

class HeaderUserChangeImageVM: NSObject {
    
    //Observable
    private var isLoading: Observable<Bool> = Observable(value: nil)
    private var callImage: Observable<UIImage> = Observable(value: nil)
    
    //variable bind
    private var uiImageChange = UIImageView()
    private var mainContent: HeaderUserChangeImage!
    
    //non-bind
    //    private var dataOriginalImage: String? = nil
    
    private var config = YPImagePickerConfiguration()
    private (set) var imageManager = ImageLocalManagement()
    
    override init() {
        super.init()
        self.configYPI()
        self.setupBindData()
    }
    
    init(mainContent: HeaderUserChangeImage, withImageUI: UIImageView) {
        self.uiImageChange = withImageUI
        self.mainContent = mainContent
        super.init()
        self.configYPI()
        self.setupBindData()
    }
    
    private func setupBindData() {
        
        self.isLoading.bind { isLoading in
            guard let actionLoading = isLoading else {
                return
            }
            DispatchQueue.main.async {
                if actionLoading {
                    print("loading")
                    ConfigAlert.showProgrssAnimationNeedDismiss(with: "Upload" ,animationType: .circleStrokeSpin)
                } else {
                    ConfigAlert.showProgressSuccess()
                    print("load Done")
                }
            }
        }
        
        self.callImage.bind { [weak self] image in
            guard let actionLoading = self?.isLoading.value, actionLoading, let imageChange = image else {
                return
            }
            DispatchQueue.main.async {
                self?.imageManager.saveImageAndGetPath(image: imageChange, completion: { imageLocalPath in
                    self?.uiImageChange.image = imageChange
                    self?.uploadImageToServer()
                })
            }
        }
    }
    
    private func uploadImageToServer() {
        //MARK: เพิ่ม upload image ตรงนี้
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isLoading.value = false
            self?.mainContent.forceUpdateProfile.value = true
        }
    }
    
    private func configYPI() {
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = true
        config.showsVideoTrimmer = true
        config.shouldSaveNewPicturesToAlbum = true
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = .original
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.maxCameraZoomFactor = 1.0
        config.colors.tintColor = .white
        config.preferredStatusBarStyle = .lightContent
    }
    
    public func actionChangeImage(sender:UIButton) {
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if let photo = items.singlePhoto {
                if !cancelled && self.uiImageChange.image != photo.image {
                    self.callImage.value = photo.image
                    self.isLoading.value = true
                }
            }
            picker.dismiss(animated: true, completion: {
                sender.isEnabled = true
            })
        }
        
        guard let vc = sender.parentViewController else {
            sender.isEnabled = true
            return
        }
        vc.present(picker, animated: true, completion: nil)
    }
}
