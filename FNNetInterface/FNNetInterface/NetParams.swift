//
//  NetParams.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/29.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit


public enum EMRequstMethod:Int {
    case EMRequstMethod_GET = 0, EMRequstMethod_POST, EMRequstMethod_PUT, EMRequstMethod_DELETE
}

public class NetParams: NSObject {
    
    public var method:EMRequstMethod?;  //请求方式
    public var data:AnyObject?;          //请求数据
    public override init() {
        super.init();
        method = .EMRequstMethod_GET;
        data = nil;
    }
}
