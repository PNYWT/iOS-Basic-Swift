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
    
    private var pageRequest: Int = 0
    @Published var dataSource: GlobaleNewsData = .init(list_news: [], pin_news: [])
    
    private var store_listNews = [GlobaleListNews]()
    private var store_removeIndexNative = [Int]()
    
    private (set) var isRemoveNative: Bool?
    private (set) var updateAtIndex: IndexPath?
    
    public func clearDataSource() {
        dataSource = .init(list_news: [], pin_news: [])
    }
    
    // Request News
    public func getBodyList(model: GlobalNewsTabModel!, refresh: Bool = true) {
        if refresh {
            pageRequest = 0
        } else {
            pageRequest += 1
        }
        var urlRequest = ""
        if !model.app.isEmpty {
            // list ข่าว app
            urlRequest = ""
        } else {
            // list ข่าว หมวด
            urlRequest = ""
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
                            self.store_removeIndexNative = []
                            if !haveData.pin_news.isEmpty {
                                self.dataSource.pin_news = haveData.pin_news
                            }
                            
                            if !haveData.list_news.isEmpty {
                                self.store_listNews = haveData.list_news
                            }
                        } else {
                            if !haveData.pin_news.isEmpty {
                                self.dataSource.pin_news.append( contentsOf: haveData.pin_news)
                            }
                            
                            if !haveData.list_news.isEmpty {
                                self.store_listNews.append(contentsOf: haveData.list_news)
                            }
                        }
                        
                        var newArray = [GlobaleListNews]()
                        if self.store_listNews.count >= 10 { // 10
                            for (index, item) in self.store_listNews.enumerated() {
                                if index != 0 && index % 10 == 0 { // 10
                                    if !self.store_removeIndexNative.contains(index) {
                                        var itemNew = item
                                        itemNew.isNative = true
                                        newArray.append(itemNew)
                                    }
                                }
                                var sameItem = item
                                sameItem.isNative = false
                                newArray.append(sameItem)
                            }
                        } else {
                            for (_, item) in self.store_listNews.enumerated() {
                                var sameItem = item
                                sameItem.isNative = false
                                newArray.append(sameItem)
                            }
                        }
                        self.dataSource.list_news = newArray
                    } else {
                        if refresh {
                            self.dataSource.pin_news = []
                            self.dataSource.list_news = []
                            self.store_listNews = []
                        }
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
    
    public func updateTotalView(indexPath: IndexPath) {
        updateAtIndex = indexPath
//        dataSource.list_news[indexPath.row].total_view += 1
        if let index = store_listNews.firstIndex(where: { $0.title == dataSource.list_news[indexPath.row].title }) {
            store_listNews[index].total_view += 1
            dataSource.list_news[indexPath.row].total_view = store_listNews[index].total_view
        }
    }
    
    public func clearIndexUpdate() {
        updateAtIndex = nil
        isRemoveNative = false
    }
    
    public func removeNativeCell(atIndex: IndexPath) {
        isRemoveNative = true
        store_removeIndexNative.append(atIndex.row)
        dataSource.list_news.remove(at: atIndex.row)
    }
}
