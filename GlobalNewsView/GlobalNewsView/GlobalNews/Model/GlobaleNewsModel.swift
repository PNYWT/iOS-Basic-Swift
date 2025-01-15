//
//  GlobaleNewsModel.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import Foundation
import UIKit

// MARK: UI
struct GlobalNewsUIModel {
    var globalNewsViewBackground: UIColor! = #colorLiteral(red: 0.8093395829, green: 0.8442677855, blue: 0.8780124784, alpha: 1)
    var headerBackgroundColor: UIColor! = .clear
    var detailTabBackgroundColor: UIColor! = .clear
    var buttonSelectColor: UIColor! = #colorLiteral(red: 0.2245355844, green: 0.5801904202, blue: 0.9987623096, alpha: 1)
    var buttonNonSelectColor: UIColor! = .clear
}

struct Page {
    var name = ""
    var vc = UIViewController()
    init(with _name: String, _vc: UIViewController) {
        name = _name
        vc = _vc
    }
}

struct PageCollection {
    var pages = [Page]()
}

// MARK: Tab
struct GlobalNewsTabDataModel: Codable {
    var code: String!
    var message: String!
    var data: [GlobalNewsTabModel] = []
}

struct GlobalNewsTabModel: Codable {
    var cat_name: String!
    var cat: String!
    var cat_default: Bool!
    var app: String!
}

// MARK: Body
struct GlobalNewsDetailDataModel: Codable {
    var code: String!
    var message: String!
    var data: GlobaleNewsData?
}

struct GlobaleNewsData: Codable {
    var list_news: [GlobaleListNews] = []
    var pin_news: [GlobaleListNews] = []
}

struct GlobaleListNews: Codable {
    var title: String! = ""
    var image: String! = ""
    var webview: String! = ""
    var total_view: Int! = 0
    var article_date: String! = ""
}


struct GlobalTopPinModel {
    var title: String!
    var image: String!
    var webview: String!
    var total_view: Int!
    var pin: Bool!
}

// Custom use in Section
enum SectionNews {
    case Pin
    case List
}

struct GlobaleSectionNews {
    var section: SectionNews
    var items: [GlobaleListNews] = []
}

