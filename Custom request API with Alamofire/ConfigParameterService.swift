//
//  ConfigParameterSerive.swift

import Foundation
import SwiftyJSON

class ConfigParameterService:NSObject{
    
    static func convertParameterToDict(dict:[AnyHashable : Any]) -> [String : Any]{
        let originalDictionary: [AnyHashable : Any] = dict
        var newDictionary: [String : Any] = [:]

        for (key, value) in originalDictionary {
            if let stringKey = key as? String {
                newDictionary[stringKey] = value
            }
        }
        return newDictionary
    }
    
    //MARK: appendParameter to request URL General
    static func appendParameter(parameter: [String:Any], urlString:String) -> [String:Any] {
        var parameters = parameter
        parameters["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        parameters["device"] = "iOS"
        parameters["version_os"] = UIDevice.current.systemVersion
        parameters["package_name"] =  Bundle.main.bundleIdentifier
        parameters["language"] = Locale.preferredLanguages[0].split(separator: "-").first  ?? ""
        parameters["imei"] = KeyChainManager.newIMEI
        return parameters
    }
    
    static func forRead(data:Data)->Any? {
        return try? JSON(data: data)
    }
    
    static func dataToObject(data:Data)->[String:Any]? {
        guard let jsonObject = try? JSON(data: data).dictionaryObject else {
            print("dataToObject Error")
            return nil
        }
        return jsonObject
    }
    
    static func dictParamterConvertToString(_ dict: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
            var jsonString = String(data: jsonData, encoding: .utf8)
            jsonString = jsonString?.replacingOccurrences(of: " ", with: "")
            jsonString = jsonString?.replacingOccurrences(of: "\n", with: "")
            return jsonString
        } catch let error {
            print("dictParamterConvertToString \(error.localizedDescription)")
            return nil
        }
    }
    
    static func urlComponentsToDictionary(url:URL){
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                var dictionary: [String: String] = [:]
                
                for item in queryItems {
                    dictionary[item.name] = item.value
                }
                if ConfigApp.setupLogConsoleShow{
                    print("\(dictionary)\n")
                }
                return
            }
        }
        print("No Components\n")
    }
}
