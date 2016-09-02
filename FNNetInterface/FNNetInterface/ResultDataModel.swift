//
//  ResultDataModel.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/30.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit

public enum EMResultCode:Int{
    case EmCode_Success    = 1            //成功
    case EmCode_Unkown     = 100          //未知
    case EmCode_ParamError = 101          //参数不正确
    case EmCode_AuthError  = 102          //鉴权失败
    case EmCode_SysError   = 103          //系统资源不足
    case EmCode_RefreshTokenError   = 400 //刷新token失败
    case EmCode_TokenOverdue   = 401      //token过期
    
}

public class ResultDataModel: NSObject {
    //请求接口类型
    public var type:Int = -1
    //返回码
    public var code:Int = -1
    //消息内容
    public var message:String?
    //响应数据
    public var data:AnyObject?
    
    //MARK: serialization
    public static func initWithDictionary(dict:NSDictionary?, reqestType:Int) -> ResultDataModel{
        let resultDataModelObject:ResultDataModel = ResultDataModel();
        if (dict == nil || (dict?.isKindOfClass(NSNull))!) {
            return resultDataModelObject
        }
        if !(dict?.isKindOfClass(NSDictionary))! {
            return resultDataModelObject;
        }
        
        resultDataModelObject.code = dict!["code"] != nil ? dict!["code"]!.integerValue : EMResultCode.EmCode_Success.rawValue;
        resultDataModelObject.data = dict!["data"] != nil ? dict!["data"] : dict!;
        resultDataModelObject.message = dict!["message"] as? String ?? ""
        resultDataModelObject.type = reqestType
        
        if resultDataModelObject.code != EMResultCode.EmCode_Success.rawValue {
            resultDataModelObject.message = "授权失败, 请重新登录"
        }
        
        return resultDataModelObject;
    }
    public static func initWithErrorInfo(dict:NSDictionary?, error:NSError?, reqestType:Int) -> ResultDataModel{
        let resultDataModelObject:ResultDataModel = ResultDataModel();
        
        resultDataModelObject.type = reqestType
        resultDataModelObject.code = error!.code
        if (error?.userInfo["StatusCode"])! as! NSObject == 400 {
            resultDataModelObject.message = dict!["error_description"] as! String ?? ""
        }
        else{
            switch resultDataModelObject.code {
            case NSURLErrorNotConnectedToInternet:
                resultDataModelObject.message = "亲，你的网络不给力，请检查网络!"
            default:
                resultDataModelObject.message = "亲，数据获取失败，请重试!"
            }
        }
        return resultDataModelObject;
    }
    
}


















