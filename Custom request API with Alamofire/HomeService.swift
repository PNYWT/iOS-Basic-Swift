//
//  HomeService.swift

import Foundation

enum TypeHomeLoading{
    case HomeList
    case HomeBanner
}

class HomeService{
    
    var onGetHomeBanner: ((_ dataBanner:[HomeBanner]?) -> Void)?
    var onGetHomeList: ((_ dataHomeList:[HomeDataList]?) -> Void)?
    
    var loadingisDone: ((_ isDone:TypeHomeLoading) -> Void)? //return status loading
    
    func loadAllHome(){
        loadBannerList(completion: {
            self.loadListEp()
        })
    }
    
    func loadListEp(){
        ConfigCustomService.centerPostService(withURL: "HomeList URL", withParameter: nil) { [weak self] checkRet, responseData in
            if checkRet.ret == RetType.RET_SUCCESS{
                guard let model:HomeDataListEPFrist = ConfigCustomService.decode(data: responseData, modelType: HomeDataListEPFrist.self) else{
                    self?.onGetHomeList?(nil)
                    self?.loadingisDone?(.HomeList)
                    return
                }
                self?.loadHistory { success in
                    if success{
                        self?.onGetHomeList?(model.data?.list)
                        self?.loadingisDone?(.HomeList)
                    }
                }
            }else{
                self?.onGetHomeList?(nil)
                self?.loadingisDone?(.HomeList)
            }
        } postFail: { withError in
            self.onGetHomeList?(nil)
            self.loadingisDone?(.HomeList)
        }
    }
    
    func loadBannerList(completion:@escaping()->Void)->Void{
        let parameters:[String:Any] = [:]
        ConfigCustomService.centerPostService(withURL: "Home Banner List URL", withParameter: parameters) { [weak self] checkRet, responseData in
            if checkRet.ret == RetType.RET_SUCCESS{
                guard let model:HomeDataBanner = ConfigCustomService.decode(data: responseData, modelType: HomeDataBanner.self) else{
                    self?.onGetHomeBanner?(nil)
                    self?.loadingisDone?(.HomeBanner)
                    completion()
                    return
                }
                
                self?.onGetHomeBanner?(model.data)
                self?.loadingisDone?(.HomeBanner)
                completion()
            }else{
                self?.onGetHomeBanner?(nil)
                self?.loadingisDone?(.HomeBanner)
                completion()
            }
        } postFail: { withError in
            self.onGetHomeBanner?(nil)
            self.loadingisDone?(.HomeBanner)
            completion()
        }
    }
}
