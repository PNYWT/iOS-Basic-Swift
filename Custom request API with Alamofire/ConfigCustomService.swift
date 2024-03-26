//
//  ConfigCustomService.swift

import Foundation
import Alamofire
import AnyCodable

struct CustomServiceModel: Codable {
    var ret: Int?
    var code: String! = ""
    var version:String?
    var message:String?
    
    init(dictionary: [String: Any]) {
        if let retValue = dictionary["ret"] {
            self.ret = NSString(string: "\(retValue)").integerValue
        }
        if let codeValue = dictionary["code"] as? String {
            self.code = codeValue
        }
        if let versionValue = dictionary["version"] as? String {
            self.version = versionValue
        }
        
        if let messageValue = dictionary["message"] as? String{
            self.message = messageValue
        }
    }
}

@objc class RetType:NSObject {
    static let RET_SUCCESS = 1001
    static let RET_FAIL = 1002
    /*
     Any ret if you need to check in func checkSpecialCaseRet
     */
}

struct ConfigRetCase{
    static var foundRET_FIX_LOGOUT = false // fix race condition
}



typealias SuccessWithDictionaryBlock = (_ checkRet:CustomServiceModel,_ responseData:Data) -> Void
typealias FailureBlock = (_ withError:Error) -> Void

class ConfigCustomService {
    
    static let sharedSession: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 40
        return Session(configuration: configuration, eventMonitors: [LoggerEventMonitor()])
    }()
    
    static func centerPostService(withURL urlString:String, withParameter parameters:[AnyHashable: Any]?, isRegister:Bool = false, postSuccess:@escaping SuccessWithDictionaryBlock, postFail: @escaping FailureBlock){
        
        if ConfigRetCase.foundRET_FIX_LOGOUT {
            print("Froce Return other service using.")
            return
        }
        
        let dictParameter = ConfigParameterService.convertParameterToDict(dict: parameters ?? [:])
        var newDictParameter = dictParameter
        if !isRegister{
            newDictParameter = ConfigParameterService.appendParameter(parameter: dictParameter, urlString: urlString)
            
        }else{
            newDictParameter = ConfigParameterService.appendParameterKeyLogin(parameter: dictParameter)
        }
        //setup tssid + loginUser
        newDictParameter = ConfigParameterService.setupValidateKey(withURL: urlString, withDictParameter: newDictParameter)
        
        
        //setup URL
        let headers: HTTPHeaders = [
            "User-Agent": "Your Agent"
        ]
        let contentTypes: Set<String> = ["application/json", "text/json", "text/javascript", "text/html"]
        guard let urlPost = URL(string: urlString) else{
            print("NO URL Can't Post")
            return
        }
        
        sharedSession.request(urlPost, method: .get, parameters: newDictParameter, encoding: URLEncoding.default, headers: headers)
            .validate(contentType: contentTypes)
            .responseData { response in
                switch response.result {
                case .success(let resultData):
                    guard let responseObject = ConfigParameterService.dataToObject(data: resultData) else{
                        return
                    }
                    
                    let checkCase = CustomServiceModel(dictionary: responseObject)
                    if checkCase.ret == 3331, let code = checkCase.code{
                        ConfigCustomService.showError(code: code)
                    }else{
                        ConfigCustomService.checkSpecialCaseRet(checkCase) { success in
                            if success{
                                postSuccess(checkCase, resultData)
                            }
                        }
                    }
                case .failure(let error):
                    postFail(error)
                }
            }
    }
    
    static func showError(code:String){
        var cdeoTemp = code
        if cdeoTemp.count > 0 {
            cdeoTemp = "PERMISSION_TO_ERR"
        }
        ConfigAlert.alertYesNO(message: cdeoTemp, titleYes: "Close") { selectYesNo in
            Thread.sleep(forTimeInterval: 1.0)
            exit(0)
        }
    }
    
    static func checkSpecialCaseRet(_ dataSpecialCase: CustomServiceModel?, completion:@escaping(_ success:Bool)->Void)->Void {
        guard let responseModel = dataSpecialCase else { return }
        switch responseModel.ret {
        case 2222:
            ConfigAccount.shared = ConfigAccount()
            ConfigRetCase.foundRET_FIX_LOGOUT = true
            ConfigAlert.alertYesNO(message: "\((responseModel.code ?? ""))", titleYes: ConfigAlert.textOk) { selectYesNo in
                if selectYesNo {
                    ConfigRetCase.foundRET_FIX_LOGOUT = false
                    ConfigAccount.removeAccount()
                }
            }
            return
        case 1111:
            ConfigAlert.alertYesNO(message: "\((responseModel.code ?? ""))", titleYes: ConfigAlert.textOk) { selectYesNo in
                Thread.sleep(forTimeInterval: 1.0)
                exit(0)
            }
            break
        default:
            completion(true)
            break
        }
    }
    
    static func decode<T: Codable>(data: Data, modelType: T.Type) -> T? {
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return decodedObject
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}
