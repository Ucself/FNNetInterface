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
    public static let shareInstance = NetInterface().passCertificate()
    private override init() { super.init() }
    
    //httpHeader鉴权字典
    public var httpHeader: [String:String] = [:]
    //设置鉴权字符串
    public func setAuthorization(httpHeader:[String:String]) {
        self.httpHeader = httpHeader;
    }

    //MARK: Request
    //普通数据提交
    public func httpRequest(requstMethod:EMRequstMethod,
                            strUrl:String,
                            body :[String: AnyObject]?,
                            successBlock:((String) ->Void),
                            failedBlock:((String, NSError) ->Void)) ->Void {
        var  alamofireRequestMethod:Method = .GET
        httpHeader["Content-Type"] = "text/html"
        switch requstMethod {
        case .EMRequstMethod_GET:
            alamofireRequestMethod = .GET
        case .EMRequstMethod_POST:
            alamofireRequestMethod = .POST
        case .EMRequstMethod_PUT:
            alamofireRequestMethod = .PUT
        case .EMRequstMethod_DELETE:
            alamofireRequestMethod = .DELETE
        }
        let requestObj:Request = Manager.sharedInstance.request(alamofireRequestMethod,strUrl, parameters:body, headers: httpHeader);
        //处理响应数据
        self.responseOperation(requestObj, successBlock: successBlock, failedBlock: failedBlock)
    }
    //From提交
    public func httpFormRequest(requstMethod:EMRequstMethod,
                            strUrl:String,
                            body :[String: AnyObject]?,
                            successBlock:((String) ->Void),
                            failedBlock:((String, NSError) ->Void)) ->Void {
        var  alamofireRequestMethod:Method = .POST
        httpHeader["Content-Type"] = "application/x-www-form-urlencoded"
        let requestObj:Request = Manager.sharedInstance.request(alamofireRequestMethod,strUrl, parameters:body, headers: httpHeader);
        //处理响应数据
        self.responseOperation(requestObj, successBlock: successBlock, failedBlock: failedBlock)
    }
    //上传图片
    public func uploadImage(strUrl:String,
                            body:NSDictionary?,
                            img:UIImage,
                            successBlock:((String) ->Void),
                            failedBlock:((String, NSError) ->Void))->Void{
        let dataValue : NSData = UIImageJPEGRepresentation(img, 0.5)!
        httpHeader["Content-Type"] = "image/jpeg"
        let requestObj:Request = Manager.sharedInstance.upload(.POST, strUrl, headers: httpHeader, data:dataValue)
        //处理响应数据
        self.responseOperation(requestObj, successBlock: successBlock, failedBlock: failedBlock)
    }
    
    //MARK: Private
    //处理响应数据
    private func responseOperation(requestObj:Request,
                                   successBlock:((String) ->Void),
                                   failedBlock:((String, NSError) ->Void)) ->Void{
        print("-----> \(requestObj.debugDescription)\n")
        //数据返回
        requestObj.validate(statusCode: 200..<300)
            .responseData { (response) in
                let responseData = response.data
                let responseString:String = NSString(data: responseData!, encoding: NSUTF8StringEncoding)! as String
                switch response.result {
                case .Success:
                    successBlock(responseString)
                    print("-----> success:\(responseString)\n")
                case .Failure(let error):
                    failedBlock(responseString, error)
                    print("-----> error:\(error)\n")
                }
        }
    }
    
    //绕过证书
    private func passCertificate() -> Self  {
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
        
        return self;
    }
}



















