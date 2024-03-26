//
//  LoggerEventMonitor.swift

import Foundation
import Alamofire
import SwiftyJSON

class LoggerEventMonitor: EventMonitor {
    
    private var timeStamp:String {
        get{
            return getCurrentTime()
        }
    }
    
    let queue = DispatchQueue(label: "networklogger.queue")
    func requestDidFinish(_ request: Request) {
        guard let urlRequest = request.request else { return }
        
        // Log the request details
        logRequest(urlRequest)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        // Log the response details
        logResponse(response.response, data: response.data, error: response.error)
    }
    
    //MARK: Service Log
    func logRequest(_ request: URLRequest) {
        var saveLog = "logRequest ---> API Request "
        if let url = request.url {
            if ConfigApp.setupLogConsoleShow{
                print(String(format: "\(timeStamp) API SEND ------------------------------> %@%@", url.host ?? "", url.path))
                ConfigParameterService.urlComponentsToDictionary(url: url)
            }
            saveLog.append("URL -> \(url.host ?? "")\(url.path) ")
        }
        if let method = request.httpMethod {
            saveLog.append("Method -> \(method) ")
        }
        DispatchQueue.main.async {
            if let page = UIApplication.currentVisibleViewController(){
                saveLog.append("Stay Page : \(page.classForCoder))\n")
            }
            LogAnalysis.shared.startSaveLog(logMsg: saveLog)
        }
    }
    
    func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        var saveLog = "logResponse <--- API Response "
        if let url = response?.url {
            if ConfigApp.setupLogConsoleShow {
                print(String(format: "\(timeStamp) API Response <------------------------------ %@%@", url.host ?? "", url.path))
                ConfigParameterService.urlComponentsToDictionary(url: url)
            }
            saveLog.append("URL -> \(url.host ?? "")\(url.path) ")
        }
        if let data = data, let bodyString = try? JSON(data: data) {
            if ConfigApp.setupLogConsoleShow {
                print("\(bodyString)")
            }
            saveLog.append("ret -> \(bodyString["ret"]) ")
            saveLog.append("code -> \(bodyString["code"])")
        }
        if let error = error {
            if ConfigApp.setupLogConsoleShow {
                print(String.init(format: "\(timeStamp) API Response failure <------------------------------ %@\n%@", response?.url?.host ?? "", response?.url?.path ?? "", "\(error.localizedDescription)"))
            }
            saveLog.append("error -> \(error.localizedDescription)\n")
        }
        LogAnalysis.shared.startSaveLog(logMsg: saveLog)
    }
    
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        formatter.locale = .current
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(abbreviation: "ICT")
        return formatter.string(from: Date())
    }
}
