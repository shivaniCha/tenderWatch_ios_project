//
//  ServiceManager.swift
//  SwiftProjectStructure
//
//  Created by Krishna Patel on 20/06/18.
//  Copyright © 2018 Krishna. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

@objc protocol ServiceManagerDelegate:NSObjectProtocol{
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?)
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?)
}

class ServiceManager: NSObject {
    
    var delegate:ServiceManagerDelegate?
    
    
    //MARK:- GET Service Calling
    func callWebServiceWithGET(webpath: String?, withTag tagname: String?) {
        
        Alamofire.request(webpath!, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).authenticate(user: "", password: "").responseSwiftyJSON(completionHandler:{ (response) in
            
            //            print(response.request)
            //            print(response.result.value)
            
            if let json = response.result.value {
                
                /*
                 guard !json["data"].isEmpty else{
                 
                 return
                 }
                 
                 */
                guard let rawData = try? json.rawData() else {
                    return
                }
                
                var dicResponse : [String : AnyObject] = [:]
                do {
                    
                    dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                    
                    //if response is not [String:AnuObject] form then try to convert it in another form
                    if dicResponse.count == 0
                    {
                        let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                        
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse1, forTag: tagname)
                        }
                        
                    }
                    else
                    {
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                        }
                    }
                    
                    
                    //                    print(dicResponse)
                } catch let error as NSError {
                    print(error)
                }
                
                
            }
            else{
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.result.error, forTag: tagname)
                }
                
            }
            
        })
    }
    
    
    func callWebServiceWithGetWithHeaders(webpath: String?, withTag tagname: String?,headers :[String:String]) {
        
        Alamofire.request(webpath!, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: headers).authenticate(user: "", password: "").responseSwiftyJSON(completionHandler:{ (response) in
            
            //            print(response.request)
            //            print(response.result.value)
            
            if let json = response.result.value {
                
                /*
                 guard !json["data"].isEmpty else{
                 
                 return
                 }
                 
                 */
                guard let rawData = try? json.rawData() else {
                    return
                }
                
                var dicResponse : [String : AnyObject] = [:]
                do {
                    
                    dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                    
                    //if response is not [String:AnuObject] form then try to convert it in another form
                    if dicResponse.count == 0
                    {
                        let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                        
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse1, forTag: tagname)
                        }
                        
                    }
                    else
                    {
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                        }
                    }
                    
                    
                    //                    print(dicResponse)
                } catch let error as NSError {
                    print(error)
                }
                
                
            }
            else{
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.result.error, forTag: tagname)
                }
                
            }
            
        })
    }
    
    //MARK:- POST Service Calling
    func callWebServiceWithPOST(webpath: String?, withTag tagname: String?, params: Parameters) {
        
        Alamofire.request(webpath!, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: nil).authenticate(user: "", password: "").responseSwiftyJSON(completionHandler:{ (response) in
            
            print(response.request)
            print(response.result)
            
            if let json = response.result.value {
                /*  guard !json["data"].isEmpty else{
                 return
                 }*/
                guard let rawData = try? json.rawData() else {
                    return
                }
                
                print(response)
                
                var dicResponse : [String : AnyObject] = [:]
                do {
                    dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject])!
                    print(dicResponse)
                } catch let error as NSError {
                    print(error)
                }
                
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                    self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                }
                
            }
            else{
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.result.error, forTag: tagname)
                }
            }
            
        })
    }
    
    func callWebServiceWithPOSTWithHeaders(webpath: String?, withTag tagname: String?, params: Parameters,headers :[String:String]) {
        
        Alamofire.request(webpath!, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers).authenticate(user: "", password: "").responseSwiftyJSON(completionHandler:{ (response) in
            
            print(response.request)
            print(response.result)
            
            if let json = response.result.value {
                /*  guard !json["data"].isEmpty else{
                 return
                 }*/
                guard let rawData = try? json.rawData() else {
                    return
                }
                
                print(response)
                
                var dicResponse : [String : AnyObject] = [:]
                do {
                    
                    dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                    print(dicResponse)
                    //if response is not [String:AnuObject] form then try to convert it in another form
                    if dicResponse.count == 0
                    {
                        let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse1, forTag: tagname)
                        }
                    }
                    else{
                        
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            else{
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.result.error, forTag: tagname)
                }
            }
            
        })
    }
    
    func callWebServiceWithPOSTWithHeaders_withNoJsonFormate(webpath: String?, withTag tagname: String?, params: Parameters,headers :[String:String]) {
        
        Alamofire.request(webpath!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { (response) in
            if let json = response.response
            {
                if json.statusCode == 200 || json.statusCode == 202 || json.statusCode == 400
                {
                    let dic = ["data":1]
                    //                    let response = JSONSerialization.jsonObject(with: json., options: []) as? [String:AnyObject] ?? [String:AnyObject]()
                    //                      dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                    
                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
                    }
                }
                else
                {
                    let dic = ["data":0]
                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
                    }
                }
            }
            else
            {
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.error, forTag: tagname)
                }
            }
            
        }
        
        
        //        Alamofire.request(webpath!, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers).response(completionHandler:{ (response) in
        //
        //            if let json = response.response
        //            {
        //                if json.statusCode == 200 || json.statusCode == 202 || json.statusCode == 400
        //                {
        //                    let dic = ["data":1]
        ////                    let response = JSONSerialization.jsonObject(with: json., options: []) as? [String:AnyObject] ?? [String:AnyObject]()
        ////                      dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
        //
        //                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
        //                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
        //                    }
        //                }
        //                else
        //                {
        //                    let dic = ["data":0]
        //                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
        //                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
        //                    }
        //                }
        //            }
        //            else
        //            {
        //                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
        //                    self.delegate?.webServiceCallFailure(response.error, forTag: tagname)
        //                }
        //            }
        //
        //        })
        
    }
    
    func callWebServiceWithPOST(webpath: String?, withTag tagname: String?, params: Parameters, imgArray:[AttachmentViewModel])  {
        let unit64:UInt64 = 10_000_000
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for model in imgArray  {
                
                let imgData = model.Image.jpegData(compressionQuality: 0.7)
                //                let imgData = UIImageJPEGRepresentation(model.Image, 0.7)
                multipartFormData.append(imgData!, withName: model.ImageFileName, fileName: model.ImageFileName, mimeType: "image/png")
            }
            
            //               for (key, value) in params {
            //                   multipartFormData.append((value as AnyObject).data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue).rawValue)!, withName: key)
            //               }
            
            
            for (key, value) in params {
                
                if value  is String {
                    multipartFormData.append((value as AnyObject).data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue).rawValue)!, withName: key)
                }
                if value is Array<Any>
                {
                    guard let arrData = self.stringArrayToData(stringArray: value as! [String]) else {return}
                    multipartFormData.append(arrData, withName: key)
                }
                if value is Int
                {
                    var myInt = value as! Int
                    let myIntData = Data(bytes: &myInt,
                                         count: MemoryLayout.size(ofValue: myInt))
                    
                    multipartFormData.append(myIntData, withName: key)
                    
                }
                
                 if value is Dictionary<String, Any>
                    {
                 if let dataExample: Data = NSKeyedArchiver.archivedData(withRootObject: value)
                 {
                     multipartFormData.append(dataExample, withName: key)
                        }
                }
                
//                if value is Dictionary<String, Any>
//                {
//                    var dicResult = [Any:Any]()
//                    
//                    for (key1, value1) in value as! [String:Any] {
//                        if value1 is Array<Any>
//                        {
//                            guard let arrData = self.stringArrayToData(stringArray: value1 as! [String]) else {return}
//                            
//                            guard let key1InDataForm = key1.data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue))  else {return}
//                            
//                            dicResult[key1InDataForm] = arrData
//                            
//                            
//                            multipartFormData.append(arrData, withName: key1InDataForm)
//                        }
//                        
//                    }
//                    
//                    guard let arrData = self.stringArrayToData(stringArray: value as! [String]) else {return}
//                    multipartFormData.append(arrData, withName: key)
//                }
                
                
            }
            
        }, usingThreshold: unit64, to: webpath!, method: .post, headers: nil, encodingCompletion: { (encodingResult) in
            print("encoding result:\(encodingResult)")
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                    //send progress using delegate
                })
                upload.responseSwiftyJSON(completionHandler: { (response) in
                    print("response:==>\(response)")
                    
                    if let json = response.result.value {
                        //                        guard !json["data"].isEmpty else{
                        //                            return
                        //                        }
                        guard let rawData = try? json.rawData() else {
                            return
                        }
                        
                        var dicResponse : [String : AnyObject] = [:]
                        do {
                            dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject])!
                            print(dicResponse)
                        } catch let error as NSError {
                            print(error)
                        }
                        
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                        }
                    }
                })
                
            case .failure(let encodingError):
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(encodingError, forTag: tagname)
                }
            }
        })
    }
    
    func callWebServiceWithPostWithHeaders(webpath: String?, withTag tagname: String?, params: Parameters, imgArray:[AttachmentViewModel],headers :[String:String])  {
        let unit64:UInt64 = 10_000_000
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for model in imgArray  {
                
                let imgData = model.Image.jpegData(compressionQuality: 0.7)
                //                let imgData = UIImageJPEGRepresentation(model.Image, 0.7)
                if imgData != nil
                {
                    multipartFormData.append(imgData!, withName: model.ImageFileName, fileName: model.ImageFileName, mimeType: "image/png")
                }
            }
            
            for (key, value) in params {
                
                if value  is String {
                    multipartFormData.append((value as AnyObject).data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue).rawValue)!, withName: key)
                }
                if value is Array<Any>
                {
                    guard let arrData = self.stringArrayToData(stringArray: value as! [String]) else {return}
                    multipartFormData.append(arrData, withName: key)
                }
                if value is Int
                {
                    var myInt = value as! Int
                    let myIntData = Data(bytes: &myInt,
                                         count: MemoryLayout.size(ofValue: myInt))
                    
                    multipartFormData.append(myIntData, withName: key)
                    
                }
            }
            
        }, usingThreshold: unit64, to: webpath!, method: .post, headers: headers, encodingCompletion: { (encodingResult) in
            print("encoding result:\(encodingResult)")
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                    //send progress using delegate
                })
                upload.responseSwiftyJSON(completionHandler: { (response) in
                    print("response:==>\(response)")
                    
                    if let json = response.result.value {
                        //                        guard !json["data"].isEmpty else{
                        //                            return
                        //                        }
                        guard let rawData = try? json.rawData() else {
                            return
                        }
                        
                        var dicResponse : [String : AnyObject] = [:]
                        do {
                            dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                            
                            //if response is not [String:AnuObject] form then try to convert it in another form
                            if dicResponse.count == 0
                            {
                                let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                                
                                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                                    self.delegate?.webServiceCallSuccess(dicResponse1, forTag: tagname)
                                }
                                
                            }
                            else
                            {
                                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                                    self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                                }
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                        
                    }
                })
                
            case .failure(let encodingError):
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(encodingError, forTag: tagname)
                }
            }
        })
    }
    
    
    //MARK:- Delete Service Calling
    func callWebServiceWithDELETE(webpath: String?, withTag tagname: String?, params: Parameters) {
        
        Alamofire.request(webpath!, method: .delete, parameters: params, encoding: URLEncoding.httpBody, headers: nil).authenticate(user: "", password: "").responseSwiftyJSON(completionHandler:{ (response) in
            
            print(response.request)
            print(response.result)
            
            if let json = response.result.value {
                /*  guard !json["data"].isEmpty else{
                 return
                 }*/
                guard let rawData = try? json.rawData() else {
                    return
                }
                
                print(response)
                
                var dicResponse : [String : AnyObject] = [:]
                do {
                    dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject])!
                    print(dicResponse)
                } catch let error as NSError {
                    print(error)
                }
                
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                    self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                }
                
            }
            else{
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.result.error, forTag: tagname)
                }
            }
            
        })
    }
    
    func callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: String?, withTag tagname: String?, params: Parameters,headers :[String:String]) {
        
        Alamofire.request(webpath!, method: .delete, parameters: params, encoding: URLEncoding.httpBody, headers: headers).response(completionHandler:{ (response) in
            
            if let json = response.response
            {
                if json.statusCode == 200 || json.statusCode == 202
                {
                    let dic = ["data":1]
                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
                    }
                }
                else
                {
                    let dic = ["data":0]
                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
                    }
                }
            }
            else
            {
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.error, forTag: tagname)
                }
            }
            
        })
    }
    
    //MARK:- PUT Service Calling
    
    func callWebServiceWithPutWithHeaders(webpath: String?, withTag tagname: String?, params: Parameters,headers :[String:String]) {
        
        Alamofire.request(webpath!, method: .put, parameters: params, encoding: URLEncoding.httpBody, headers: headers).authenticate(user: "", password: "").responseSwiftyJSON(completionHandler:{ (response) in
            
            print(response.request)
            print(response.result)
            
            if let json = response.result.value {
                /*  guard !json["data"].isEmpty else{
                 return
                 }*/
                guard let rawData = try? json.rawData() else {
                    return
                }
                
                print(response)
                
                var dicResponse : [String : AnyObject] = [:]
                do {
                    
                    dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                    print(dicResponse)
                    //if response is not [String:AnuObject] form then try to convert it in another form
                    if dicResponse.count == 0
                    {
                        let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse1, forTag: tagname)
                        }
                    }
                    else{
                        
                        if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                            self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            else{
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.result.error, forTag: tagname)
                }
            }
            
        })
    }
    
    func callWebServiceWithPutWithHeaders_withNoJsonFormate(webpath: String?, withTag tagname: String?, params: Parameters,headers :[String:String]) {
        
        Alamofire.request(webpath!, method: .put, parameters: params, encoding: URLEncoding.httpBody, headers: headers).response(completionHandler:{ (response) in
            
            if let json = response.response
            {
                if json.statusCode == 200 || json.statusCode == 202 || json.statusCode == 400
                {
                    let dic = ["data":1]
                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
                    }
                }
                else
                {
                    let dic = ["data":0]
                    if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                        self.delegate?.webServiceCallSuccess(dic, forTag: tagname)
                    }
                }
            }
            else
            {
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(response.error, forTag: tagname)
                }
            }
            
        })
    }
    func callWebServiceWithPutWithHeaders(webpath: String?, withTag tagname: String?, params: Parameters, imgArray:[AttachmentViewModel],headers :[String:String])  {
        let unit64:UInt64 = 10_000_000
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for model in imgArray  {
                
                let imgData = model.Image.jpegData(compressionQuality: 0.7)
                //                let imgData = UIImageJPEGRepresentation(model.Image, 0.7)
                multipartFormData.append(imgData!, withName: model.ImageFileName, fileName: model.ImageFileName, mimeType: "image/png")
            }
            
            for (key, value) in params {
                
                if value  is String {
                    multipartFormData.append((value as AnyObject).data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue).rawValue)!, withName: key)
                }
                if value is Array<Any>
                {
                    guard let arrData = self.stringArrayToData(stringArray: value as! [String]) else {return}
                    multipartFormData.append(arrData, withName: key)
                }
                if value is Int
                {
                    var myInt = value as! Int
                    let myIntData = Data(bytes: &myInt,
                                         count: MemoryLayout.size(ofValue: myInt))
                    
                    multipartFormData.append(myIntData, withName: key)
                    
                }
            }
            
        }, usingThreshold: unit64, to: webpath!, method: .put, headers: headers, encodingCompletion: { (encodingResult) in
            print("encoding result:\(encodingResult)")
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                    //send progress using delegate
                })
                upload.responseSwiftyJSON(completionHandler: { (response) in
                    print("response:==>\(response)")
                    
                    if let json = response.result.value {
                        //                        guard !json["data"].isEmpty else{
                        //                            return
                        //                        }
                        guard let rawData = try? json.rawData() else {
                            return
                        }
                        
                        var dicResponse : [String : AnyObject] = [:]
                        do {
                            dicResponse =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:AnyObject] ?? [String:AnyObject]())
                            
                            //if response is not [String:AnuObject] form then try to convert it in another form
                            if dicResponse.count == 0
                            {
                                let  dicResponse1 =  (try JSONSerialization.jsonObject(with: rawData, options: []) as? [AnyObject])
                                
                                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                                    self.delegate?.webServiceCallSuccess(dicResponse1, forTag: tagname)
                                }
                                
                            }
                            else
                            {
                                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallSuccess(_:forTag:))))! {
                                    self.delegate?.webServiceCallSuccess(dicResponse, forTag: tagname)
                                }
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                        
                    }
                })
                
            case .failure(let encodingError):
                if (self.delegate?.responds(to: #selector(self.delegate?.webServiceCallFailure(_:forTag:))))! {
                    self.delegate?.webServiceCallFailure(encodingError, forTag: tagname)
                }
            }
        })
    }
    
    //MARK:- array to data
    func stringArrayToData(stringArray: [String]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
    }
    
}

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}


