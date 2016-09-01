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
                            failedBlock:((String, NSError) ->Void),
                            _ isForm: Bool = false) ->Void {
        //证书绕过验证
        if isHttps {
            self.passCertificate();
        }
        if isForm {
            httpHeader["Content-Type"] = "application/x-www-form-urlencoded"
        }
        else{
            httpHeader["Content-Type"] = "text/html"
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
        postRequest!.validate(statusCode: 200..<300)
                    .responseData { (response) in
                        let responseData = response.data
                        let responseString:String = NSString(data: responseData!, encoding: NSUTF8StringEncoding)! as String
                        switch response.result {
                        case .Success:
                            successBlock(responseString)
                        case .Failure(let error):
                            failedBlock(responseString, error)
                        }
                    }
    }
    public func uploadImage(strUrl:String,
                            body:NSDictionary?,
                            img:UIImage,
                            successBlock:((String) ->Void),
                            failedBlock:((NSString, NSError) ->Void))->Void{
        let dataValue : NSData = UIImageJPEGRepresentation(img, 0.5)!
        httpHeader["Content-Type"] = "image/jpeg"
        let postRequest:Request = Manager.sharedInstance.upload(.POST, strUrl, headers: httpHeader, data:dataValue)
        //数据返回
        postRequest.validate(statusCode: 200..<300)
                   .responseData { (response) in
                        let responseData = response.result.value
                        let responseString:String = NSString(data: responseData!, encoding: NSUTF8StringEncoding)! as String
                        switch response.result {
                        case .Success:
                            successBlock(responseString)
                        case .Failure(let error):
                            failedBlock(responseString, error)
                        }
                }
    }
    
    //MARK:  manager set
    private func passCertificate() -> Void {
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
}



















