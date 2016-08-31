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
    public var httpHeader: [String:String]?
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
                            failedBlock:((NSError) ->Void)) ->Void {
        
        let postRequest:Request?;
        switch requstMethod {
        case .EMRequstMethod_GET:
            postRequest = request(.GET,strUrl, parameters:body, headers: httpHeader);
        case .EMRequstMethod_POST:
            postRequest = request(.POST,strUrl, parameters:body, headers: httpHeader);
        case .EMRequstMethod_PUT:
            postRequest = request(.PUT,strUrl, parameters:body, headers: httpHeader);
        case .EMRequstMethod_DELETE:
            postRequest = request(.DELETE,strUrl, parameters:body, headers: httpHeader);
            
        }
        postRequest!.responseString { (response) in
            if let resultString = response.result.value{
                successBlock(resultString)
            }
            else{
                failedBlock(response.result.error!)
            }
        }
    }
    
    public func httpPostFormRequest(strUrl:String,
                                    body :NSDictionary?,
                                    isHttps:Bool,
                                    successBlock:((String) ->Void),
                                    failedBlock:((NSError) ->Void)) ->Void {
        
        upload(.POST, strUrl, multipartFormData: { (multipartFormData) in
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
        let postRequest:Request = upload(.POST, strUrl, headers: httpHeader, data:dataValue)
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



















