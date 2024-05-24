//
//  EditProfileVM.swift
//
//  Created by Dev on 9/4/2567 BE.
//

import Foundation
import SwiftyJSON

class EditProfileVM {
    
    private var isLoading: Observable<Bool> = Observable(value: nil)
    //    private var dataSource: ProfileLogin? //<- AnyModel save to use
    private (set) var callDataProfileFirstSet: Observable<ConfigAccount> = Observable(value: nil)
    private (set) var callDataProfile: Observable<DataProfile> = Observable(value: nil)
    
    private var serviceLoginGetProfile: ServiceLogin! = ServiceLogin()
    
    //Setup this first
    public func setupBindData(tbv: UITableView, withHeader: HeaderUserChangeImage) {
        //Work when start loadProfileNow and Done loadProfileNow
        self.isLoading.bind { isLoading in
            guard let actionLoading = isLoading else {
                return
            }
            
            DispatchQueue.main.async {
                if actionLoading {
                    print("loading")
                    tbv.isUserInteractionEnabled = false
                } else {
                    print("load Done")
                    if tbv.alpha == 0 {
                        tbv.animateShowView()
                    }
                    tbv.isUserInteractionEnabled = true
                }
            }
        }
        
        //Work after loadProfileNow Done
        self.callDataProfileFirstSet.bind { _ in
            //UIViewController can use dataSource by editProfileVC.dataSource
            //So just reload UI
            DispatchQueue.main.async {
                tbv.reloadData()
                withHeader.setupHeaderView()
            }
        }
        
        self.callDataProfile.bind { _ in
            //UIViewController can use dataSource by editProfileVC.dataSource
            //So just reload UI
            DispatchQueue.main.async {
                tbv.reloadData()
                withHeader.setupHeaderView()
            }
        }
        
        withHeader.forceUpdateProfile.bind { [weak self] needUpdateService in
            if needUpdateService ?? false {
                withHeader.forceUpdateProfile.value = false
                self?.loadProfileNow(firstSet: false)
            }
        }
        
        print("EditProfileVM setupBindData First setup")
    }
    
    //for request service after setupBindData
    public func loadProfileNow(firstSet: Bool) {
        /*
         if isLoading.value ?? true {
         return
         }
         */
        isLoading.value = true
        
        if firstSet {
            isLoading.value = false
            callDataProfileFirstSet.value = ConfigAccount.shared
            return
        }
        
        //API Call and actionLoading = false when request success or fail, use [weak self] in block service
        serviceLoginGetProfile.getProfile { [weak self] dataProfile, errStr in
            self?.isLoading.value = false
            if let haveModel = dataProfile {
                //                self?.dataSource = haveModel
                self?.callDataProfile.value = haveModel.data
            }else{
                self?.callDataProfile.value = nil
                //                self?.dataSource = nil
            }
        }
    }
    
    public func presentAlertChangeName(mainContent: UIView) {
        let alertController = UIAlertController(title: "Edit Nickname", message: "Please enter your new nickname.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter you new Nickname..."
        }
        let okAction = UIAlertAction(title: ConfigAlert.textConfirm, style: .default) { _ in
            if let text = alertController.textFields?.first?.text {
                self.updateNewNametoServer(text: text)
            }
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: ConfigAlert.textCancel, style: .cancel)
        alertController.addAction(cancelAction)
        
        if let topController = mainContent.parentViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: เพิ่ม upload name ตรงนี้
    private func updateNewNametoServer(text: String) {
        print("Handling text: \(text)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.loadProfileNow(firstSet: false) //bind ไป update name อยู่แล้วถ้าค่าที่ส่งกลับมาเปลี่ยนชื่อใหม่
        }
    }
}
