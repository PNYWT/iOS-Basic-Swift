//
//  GlobalRequestNewsViewModel.swift
//  GlobalNewsView
//
//  Created by Dev on 10/1/2568 BE.
//

import Foundation
import Alamofire
import Combine

class GlobalRequestNewsViewModel: NSObject {
    
    private var pageRequest: Int = 1
    @Published var dataSource: GlobaleNewsData = .init(list_news: [], pin_news: [])
    
    public func clearDataSource() {
        dataSource = .init(list_news: [], pin_news: [])
    }
    
    // Request News
    public func getBodyList(model: GlobalNewsTabModel!, refresh: Bool = true) {
        if refresh {
            pageRequest = 1
        } else {
            pageRequest += 1
        }
        var urlRequest = ""
        if !model.app.isEmpty {
            // list ข่าว app
            urlRequest = "\(model.app ?? "")\(pageRequest)"
        } else {
            // list ข่าว หมวด
            urlRequest = "\(model.app ?? "")\(pageRequest)"
        }
        AF.request(urlRequest).response { response in
            switch response.result {
            case .success(let data):
                guard let haveData = data else {
                    return
                }
#if DEBUG
                print("Request URL -> \(urlRequest)")
                self.printDataJSON(data: haveData)
#endif
                do {
                    let object = try JSONDecoder().decode(GlobalNewsDetailDataModel.self, from: haveData)
                    if object.code == "101", let haveData = object.data {
                        if refresh {
                            if !haveData.pin_news.isEmpty {
                                self.dataSource.pin_news = haveData.pin_news
                            }
                            
                            if !haveData.list_news.isEmpty {
                                self.dataSource.list_news = haveData.list_news
                            }
                        } else {
                            if haveData.pin_news.isEmpty {
                                self.dataSource.pin_news.append( contentsOf: haveData.pin_news)
                            }
                            
                            if !haveData.list_news.isEmpty {
                                self.dataSource.list_news.append( contentsOf: haveData.list_news)
                            }
                        }
                    } else {
                        self.dataSource.pin_news = []
                        self.dataSource.list_news = []
                    }
                } catch let error {
                    print("catch -> \(error.localizedDescription)")
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
