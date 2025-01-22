//
//  GlobalNewsViewModel.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import Foundation
import Alamofire
import Combine

class GlobalNewsViewModel: NSObject {
    
    // Data Source
    @Published var tabModel: [GlobalNewsTabModel]! = []
    
    // Data UI
    private (set) var pageCollection: PageCollection = PageCollection()
    
    // Combine
    var messageAlert = PassthroughSubject<String, Never>()
    
    // Request Tab
    public func getTabHeader(modelUI: GlobalNewsUIModel) {
        AF.request("").response { response in
            switch response.result {
            case .success(let data):
                guard let haveData = data else {
                    return
                }
                guard let object = try? JSONDecoder().decode(GlobalNewsTabDataModel.self, from: haveData) else {
                    return
                }
#if DEBUG
                print("getTabHeader Request")
                self.printDataJSON(data: haveData)
#endif
                if object.code == "101" {
                    let group = DispatchGroup()
                    group.enter()
                    DispatchQueue.main.async {
                        for item in object.data {
                            let vc = ContentVC.init(tabModel: item, modelUI: modelUI)
                            let page = Page(with: item.cat_name, _vc: vc)
                            self.pageCollection.pages.append(page)
                        }
                        group.leave()
                    }
                    group.notify(queue: DispatchQueue.main) {
                        self.tabModel = object.data
                    }
                } else {
                    self.messageAlert.send(object.message)
                }
            case .failure(let error):
#if DEBUG
                print("getTabHeader -> \(error.localizedDescription)")
#endif
                break
            }
        }
    }
}
