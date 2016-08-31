//
//  UrlMaps.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/29.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit

public class UrlMaps: NSObject {
    //单例
    public static let shareInstance = UrlMaps()
    private override init() { super.init() }
    
    private var urlMaps:NSDictionary?
    public func initMaps(dict:NSDictionary) -> Void{
        urlMaps = dict
    }
    
    public func urlWithTypeNew(type:Int) -> String {
        return urlMaps![type] as! String
    }
}
