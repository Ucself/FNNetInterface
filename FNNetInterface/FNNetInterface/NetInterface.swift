//
//  NetInterface.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/22.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit


public class NetInterface: NSObject {
    //单例 
    public static let shareInstance = NetInterface()
    private override init() { super.init() }
    
    //httpHeader鉴权字典
    public var httpHeader: [String:String] = [:]
    //设置鉴权字符串
    public func setAuthorization(httpHeader:[String:String]) {
        self.httpHeader = httpHeader;
    }

    //MARK: Request
    public func httpRequest(requstMethod:EMRequstMethod,
                            strUrl:String,
                            body :[String: AnyObject]?,
                            isHttps:Bool,
                            successBlock:((String) ->Void),
                            failedBlock:((NSError) ->Void),
                            _ isForm: Bool) ->Void {
        //证书绕过验证
        if isHttps {
            let manager = Manager.sharedInstance
            manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
                var credential: NSURLCredential?
                
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    disposition = NSURLSessionAuthChallengeDisposition.UseCredential
                    credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
                } else {
                    if challenge.previousFailureCount > 0 {
                        disposition = .CancelAuthenticationChallenge
                    } else {
                        credential = manager.session.configuration.URLCredentialStorage?.defaultCredentialForProtectionSpace(challenge.protectionSpace)
                        
                        if credential != nil {
                            disposition = .UseCredential
                        }
                    }
                }
                return (disposition, credential)
            }
        }
        if isForm {
            httpHeader["Content-Type"] = "application/x-www-form-urlencoded"
        }
        else{
            httpHeader.removeValueForKey("Content-Type")
        }
        let postRequest:Request?;
        switch requstMethod {
        case .EMRequstMethod_GET:
            postRequest = Manager.sharedInstance.request(.GET,strUrl, parameters:body, headers: httpHeader);
        case .EMRequstMethod_POST:
            postRequest = Manager.sharedInstance.request(.POST,strUrl, parameters:body, headers: httpHeader);
        case .EMRequstMethod_PUT:
            postRequest = Manager.sharedInstance.request(.PUT,strUrl, parameters:body, headers: httpHeader);
        case .EMRequstMethod_DELETE:
            postRequest = Manager.sharedInstance.request(.DELETE,strUrl, parameters:body, headers: httpHeader);
            
        }
        
        postRequest!.responseString { (response) in
            if let resultString = response.result.value{
                successBlock(resultString)
            }
            else{
                failedBlock(response.result.error!)
            }
        }
        postRequest!.validate()
                    .responseJSON { response in
                        switch response.result {
                        case .Success:
                            successBlock(response.result.value as! String)
                        case .Failure(let error):
                            failedBlock(error)
                        }
        }
        
    
    }
    
    public func httpPostFormRequest(strUrl:String,
                                    body :NSDictionary?,
                                    isHttps:Bool,
                                    successBlock:((String) ->Void),
                                    failedBlock:((NSError) ->Void)) ->Void {
        
        //证书绕过验证
        if isHttps {
            let manager = Manager.sharedInstance
            manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
                var credential: NSURLCredential?
                
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    disposition = NSURLSessionAuthChallengeDisposition.UseCredential
                    credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
                } else {
                    if challenge.previousFailureCount > 0 {
                        disposition = .CancelAuthenticationChallenge
                    } else {
                        credential = manager.session.configuration.URLCredentialStorage?.defaultCredentialForProtectionSpace(challenge.protectionSpace)
                        
                        if credential != nil {
                            disposition = .UseCredential
                        }
                    }
                }
                return (disposition, credential)
            }
        }
        
        Manager.sharedInstance.upload(.POST, strUrl, multipartFormData: { (multipartFormData) in
            for (key,value) in body!{
                let dataValue : NSData = NSKeyedArchiver.archivedDataWithRootObject(value)
                multipartFormData.appendBodyPart(data: dataValue, name: key as! String)
            }
            
            }) { (encodingResult) in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if let error = response.result.error {
                            failedBlock(error)
                        }
                        else{
                            successBlock(response.result.value as! String)
                        }
                    }
                case .Failure(let encodingError):
                    failedBlock(encodingError as NSError)
                }
        }
        
    }

    public func uploadImage(strUrl:String,
                            body:NSDictionary?,
                            img:UIImage,
                            successBlock:((String) ->Void),
                            failedBlock:((NSError) ->Void))->Void{
        let dataValue : NSData = UIImageJPEGRepresentation(img, 0.5)!
        let postRequest:Request = Manager.sharedInstance.upload(.POST, strUrl, headers: httpHeader, data:dataValue)
        //数据返回
        postRequest.responseString { (response) in
            if let resultString = response.result.value{
                successBlock(resultString)
            }
            else{
                failedBlock(response.result.error!)
            }
        }
    }
    
}



















