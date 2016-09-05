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
    
    public func setAuthorization(httpHeader:[String:String]) -> Void{
        NetInterface.shareInstance.setAuthorization(httpHeader)
    }
    
    //MARK: Request
    public func sendRequstWithType(type:Int,block:((params:NetParams)->Void)) -> Void{
        
        let params:NetParams = NetParams.init()
        block(params: params);
        guard let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type) else {return}
        
        let bodyDic:NSDictionary? = params.data as? NSDictionary
        NetInterface.shareInstance.httpRequest(params.method!, strUrl:url!, body:bodyDic as? [String:AnyObject], successBlock: { (msg) in
            self.successHander(msg, reqestType: type)
            }, failedBlock: { (msg, error) in
                self.failedHander(msg, error: error, reqestType: type)
        })
        
        
    }
    
    public func sendFormRequstWithType(type:Int, block:((params:NetParams)->Void)) -> Void{
        
        let params:NetParams = NetParams.init()
        block(params: params);
        guard let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type) else {return}
        
        let bodyDic:NSDictionary? = params.data as? NSDictionary
        NetInterface.shareInstance.httpFormRequest(EMRequstMethod.EMRequstMethod_POST, strUrl:url!, body:bodyDic as? [String:AnyObject], successBlock: { (msg) in
                self.successHander(msg, reqestType: type)
            }, failedBlock: { (msg, error) in
                self.failedHander(msg, error: error, reqestType: type)
            })
    
    }
    
    
    public func uploadImage(strurl:String,
                            img:UIImage,
                            body:NSDictionary?,
                            successBlock:((String) ->Void),
                            failedBlock:((String, NSError) ->Void))->Void{
        NetInterface.shareInstance.uploadImage(strurl, body: body!, img: img, successBlock: successBlock, failedBlock: failedBlock)
    }
    
    //MARK: Private
    //返回成功处理
    private func successHander(msg:String, reqestType:Int) ->Void{
        let data:NSData = msg.dataUsingEncoding(NSUTF8StringEncoding)!
        let dict:NSDictionary?
        do{
            dict = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as! NSDictionary
        }
        catch{
            dict = [:]
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
    private func failedHander(msg:String, error:NSError, reqestType:Int) ->Void{
        let data:NSData = msg.dataUsingEncoding(NSUTF8StringEncoding)!
        let dict:NSDictionary?
        do{
            dict = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as! NSDictionary
        }
        catch{
            dict = [:]
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            let result:ResultDataModel = ResultDataModel.initWithErrorInfo(dict!, error: error, reqestType: reqestType)
            if result.code == EMResultCode.EmCode_TokenOverdue.rawValue{
                NSNotificationCenter.defaultCenter().postNotificationName(KNotification_AuthenticationFail, object: result)
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(KNotification_RequestFailed, object: result)
            }
        }
        
    }
    
    
    //MARK: recod
    private func recodRequest(strUrl:String, body:NSDictionary, requestType:Int, mothed:EMRequstMethod){
        //记录一次请求数据
        recordUrl           = strUrl;
        recordBody          = body;
        recordRequestType   = requestType;
        recordRequestMothed = mothed;
    }
    
    private func reloadRecordData()->Void{
        if (recordUrl != nil && recordBody != nil) {
            NetInterface.shareInstance.httpFormRequest(recordRequestMothed, strUrl:recordUrl!, body:recordBody! as! [String : AnyObject], successBlock: { (msg) in
                    self.successHander(msg, reqestType:self.recordRequestType)
                }, failedBlock: { (msg, error) in
                    self.failedHander(msg, error: error, reqestType:self.recordRequestType)
            })
        }
    }
    
    public func setReqControllerId(cId:String) -> Void{
        controllerId = cId;
    }
    
    public func getReqControllerId()->String{
        return controllerId!;
    }
}











