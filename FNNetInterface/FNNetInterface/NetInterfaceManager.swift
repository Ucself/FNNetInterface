//
//  NetInterfaceManager.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/25.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit

public let KNotification_RequestFinished:String = "HttpRequestFinishedNoitfication"
public let KNotification_RequestFailed:String = "HttpRequestFailedNoitfication"
public let KNotification_AuthenticationFail:String =  "AuthenticationLogicFailNoitfication"



public class NetInterfaceManager: NSObject {
    
    //单例
    public static let shareInstance = NetInterfaceManager()
    private override init() { super.init() }
    
    private var recordUrl:String?
    private var recordBody:NSDictionary?
    private var recordRequestType:Int = 0
    private var recordRequestMothed:EMRequstMethod = .EMRequstMethod_GET
    private var controllerId:String?
    private var recordIsHttps:Bool = false
    
    public func setAuthorization(httpHeader:[String:String]) -> Void{
        NetInterface.shareInstance.setAuthorization(httpHeader)
    }
    
    //MARK: Request
    public func sendRequstWithType(type:Int,block:((params:NetParams)->Void), _ isHttps:Bool = false) -> Void{
        let params:NetParams = NetParams.init()
        
        block(params: params);
        let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type);
        if (url == nil || url!.characters.count <= 0) {
            return ;
        }
        
        var bodyDic:NSDictionary = [:];
        if params.data != nil {
            bodyDic = (params.data as? NSDictionary)!
        }
        
        self.httpRequst(params.method!, strUrl: url!, body:bodyDic, isHttps: isHttps, requestType: type)
    }
    
    
    
    public func sendFormRequstWithType(type:Int, block:((params:NetParams)->Void), _ isHttps:Bool = false) -> Void{
        let params:NetParams = NetParams.init()
        
        block(params: params);
        let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type);
        if (url == nil || url!.characters.count <= 0) {
            return ;
        }
        
        var bodyDic:NSDictionary = [:];
        if params.data != nil {
            bodyDic = (params.data as? NSDictionary)!
        }
        
        NetInterface.shareInstance.httpRequest(EMRequstMethod.EMRequstMethod_POST, strUrl: url!, body: bodyDic as! [String:AnyObject] , isHttps: true, successBlock: { (msg) in
            self.successHander(msg, reqestType: type)
            }, failedBlock: { (error) in
                self.failedHander(error, reqestType: type)
            }, true)
    
    }
    
    
    public func uploadImage(strurl:String,
                            img:UIImage,
                            body:NSDictionary?,
                            suceeseBlock:((msg:String) -> Void),
                            failedBlock:((error:NSError)->Void)) -> Void{
        NetInterface.shareInstance.uploadImage(strurl, body:body!, img: img, successBlock: suceeseBlock, failedBlock: failedBlock)
    }
    
    //MARK: Private Request
    private func httpRequst(requestMothed:EMRequstMethod,
                        strUrl:String,
                        body:NSDictionary?,
                        isHttps:Bool,
                        requestType:Int) -> Void{
        
        print("<- \(__FUNCTION__) ->\n   requstMethod:\(requestMothed)\n" + "   url:\(strUrl)\n" + "   body:\(body)\n" + "   isHttps:\(isHttps)\n");
        NetInterface.shareInstance.httpRequest(requestMothed, strUrl: strUrl, body: body as? [String : AnyObject], isHttps: isHttps, successBlock: { (msg) in
            self.successHander(msg, reqestType: requestType)
            }, failedBlock: { (error) in
                self.failedHander(error, reqestType: requestType)
            }, false)
    }
//    private func httpPostFormRequest(strUrl:String,
//                                    body:NSDictionary,
//                                    isHttps:Bool,
//                                    requestType:Int) -> Void{
//        print("<- \(__FUNCTION__) ->\n" + "   url:\(strUrl)\n" + "   body:\(body)\n" + "   isHttps:\(isHttps)\n");
//        NetInterface.shareInstance.httpRequest(.EMRequstMethod_POST, strUrl: strUrl, body: body as? [String : AnyObject], isHttps: isHttps, successBlock: { (msg) in
//            self.successHander(msg, reqestType: requestType)
//            }, failedBlock: { (error) in
//                self.failedHander(error, reqestType: requestType)
//            }, true)
//    }
    
    
    //返回成功处理
    private func successHander(msg:String, reqestType:Int) ->Void{
        print("<- \(__FUNCTION__) ->\n   msg:\(msg)\n" + "   reqestType:\(reqestType)");
        var error:NSError?
        let data:NSData = msg.dataUsingEncoding(NSUTF8StringEncoding)!
        let dict:NSDictionary?
        do{
            dict = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as! NSDictionary
        }
        catch{
            dict = ["":""]
        }
        let result:ResultDataModel = ResultDataModel.initWithDictionary(dict, reqestType: reqestType)
        if result.code == EMResultCode.EmCode_Success.rawValue {
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(KNotification_RequestFinished, object: result)
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(KNotification_AuthenticationFail, object: result)
            }
        }
    
    }
    //返回失败处理
    private func failedHander(error:NSError, reqestType:Int) ->Void{
        print("<- \(__FUNCTION__) ->\n   error:\(error)\n" + "   reqestType:\(reqestType)");
        dispatch_async(dispatch_get_main_queue()) {
            let result:ResultDataModel = ResultDataModel.initWithErrorInfo(error, reqestType: reqestType)
            if result.code == EMResultCode.EmCode_TokenOverdue.rawValue{
                NSNotificationCenter.defaultCenter().postNotificationName(KNotification_AuthenticationFail, object: result)
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(KNotification_RequestFailed, object: result)
            }
        }
        
    }
    
    
    //MARK: recod
    private func recodRequest(strUrl:String, body:NSDictionary, isHttps:Bool, requestType:Int, mothed:EMRequstMethod){
        //记录一次请求数据
        recordUrl           = strUrl;
        recordBody          = body;
        recordRequestType   = requestType;
        recordRequestMothed = mothed;
        recordIsHttps = isHttps;
    }
    
    private func reloadRecordData()->Void{
        if (recordUrl != nil && recordBody != nil) {
            self.httpRequst(recordRequestMothed, strUrl: recordUrl!, body: recordBody!, isHttps:recordIsHttps,  requestType: recordRequestType)
        }
    }
    
    public func setReqControllerId(cId:String) -> Void{
        controllerId = cId;
    }
    
    public func getReqControllerId()->String{
        return controllerId!;
    }
}











