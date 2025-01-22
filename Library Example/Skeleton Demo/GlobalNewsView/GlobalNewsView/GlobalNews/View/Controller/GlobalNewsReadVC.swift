//
//  GlobalNewsReadVC.swift
//  GlobalNewsView
//
//  Created by Dev on 15/1/2568 BE.
//

import UIKit
import SnapKit
import WebKit

class GlobalNewsReadVC: CenterUIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    private lazy var abMobBannerView: AbMobBannerView = {
        let view = AbMobBannerView(rootView: self)
        view.backgroundColor = .clear
        return view
    }()
    
    private var pathURL: String = ""
    init(title: String, urlWebString: String, is_ck: Bool = false) {
        super.init(uiNavModel: CenterUIVCModel.init(
                        typeNav: .News,
                        backgroundColor: .blue,
                        fontColor: .white,
                        showDataWith: .init(imageLogo: .icNEWS,
                                            titleShow: title,
                                            imageButton: UIImage(systemName: "chevron.left")!)))
        self.addParamisCK(urlWebString: urlWebString, is_ck: is_ck)
    }
    
    /*
     is_ck = false ไม่โชว์
     is_ck = true โชว์
     */
    private func addParamisCK(urlWebString: String, is_ck: Bool) {
        var urlsPathString = urlWebString
        if urlsPathString.contains("?") {
            urlsPathString.append("&is_ck=\(is_ck)")
        } else {
            urlsPathString.append("?is_ck=\(is_ck)")
        }
        if let encodedURLString = urlsPathString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            pathURL = encodedURLString
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }

    private func setupView() {
        if !pathURL.isEmpty, let completeURL = URL(string: pathURL) {
            view.addSubview(webView)
            #if DEBUG
            print("completeURL -> \(completeURL)")
            #endif
            let urlRequest = URLRequest(url: completeURL)
            webView.load(urlRequest)
        }
        contentView.addSubview(webView)
        contentView.addSubview(abMobBannerView)
        abMobBannerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.0)
        }
        abMobBannerView.loadBanner()
        webView.snp.makeConstraints { make in
            make.width.top.centerX.equalToSuperview()
            make.bottom.equalTo(abMobBannerView.snp.top).offset(-4.0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        abMobBannerView.clearData()
    }
    
    deinit {
        #if DEBUG
        print("GlobalNewsReadVC deinit")
        #endif
    }
}
