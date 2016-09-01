//
//  ViewController.swift
//  FNProject
//
//  Created by lbj@feiniubus.com on 16/8/29.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit
import FNNetInterface

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mainDataTable: UITableView!
    let dataSource = ["GET","HTTPS->POST","HTTPS->Form","DELETE","UPLOADE"]
    
    
    override func viewDidLoad() {
        //初始化数据
        self.initWithMap();
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(httpRequestFinished), name: KNotification_RequestFinished, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(httpRequestFailed), name: KNotification_RequestFailed, object: nil)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: DataSouceDelegte
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell.init();
        }
        cell?.textLabel?.text = dataSource[indexPath.row];
        return cell!;
    }
    //MARK: Delegte
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        let text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        
        //上传文件
        if text == "GET" {
            //GET 测试 网址：http://dev.feiniubus.com:9042/api/common/Fence
            NetInterfaceManager.shareInstance.sendRequstWithType(requsetType.GETTest.rawValue, block: { (params) in
                params.method = .EMRequstMethod_GET
            })
        }
        else if text == "HTTPS->POST"{
            //GET 测试 网址：https://console.feiniubus.com:8500/passenger/common/token
            NetInterfaceManager.shareInstance.sendRequstWithType(requsetType.POSTTest.rawValue, block: { (params) in
                params.method = .EMRequstMethod_POST
                params.data = ["phone":"18081003937",
                               "vcode":"123805",
                               "grant_type":"totp",
                               "client_id":"0791b17234b14946bf8c6e5406e0bf9e",
                               "client_secret":"33_4gOkGBiZgUwhQUdUVxi-QCIqPkQMYvcYZ3e3ao4s",
                               "registration_id":"E87DB0BA1F76428",
                               "terminal_type":"android"]
            },true)
        }
        else if text == "HTTPS->Form"{
            NetInterfaceManager.shareInstance.sendFormRequstWithType(requsetType.HTTPSFromTest.rawValue, block: { (params) in
                params.method = .EMRequstMethod_POST
                params.data = ["phone":"18081003937",
                    "vcode":"9876541",
                    "grant_type":"totp",
                    "client_id":"0791b17234b14946bf8c6e5406e0bf9e",
                    "client_secret":"33_4gOkGBiZgUwhQUdUVxi-QCIqPkQMYvcYZ3e3ao4s",
                    "registration_id":"E87DB0BA1F76428",
                    "terminal_type":"android"]
                }, true)
        }
        else if text == "DELETE"{
        }
        else if text == "UPLOADE"{
        }
        
        
    }
    
    //MARK:......
    enum requsetType:Int {
        case GETTest = 10001,POSTTest,HTTPSFromTest,PUTTest,DELETETest,UPLOADETest
    }
    
    func initWithMap() -> Void {
//        UrlMaps.shareInstance.initMaps([requsetType.GETTest.rawValue:"http://dev.feiniubus.com:9042/api/common/Fence"])
        //https://www.baidu.com/
        UrlMaps.shareInstance.initMaps([requsetType.GETTest.rawValue:"http://dev.feiniubus.com:9042/api/common/Fence",
                                        requsetType.POSTTest.rawValue:"https://console.feiniubus.com:8500/passenger/api/common/token",
                                        requsetType.HTTPSFromTest.rawValue:"https://console.feiniubus.com:8500/passenger/api/common/token"
                                       ])
    }
    
    func httpRequestFinished(notification:NSNotification) -> Void {
        let resultData:ResultDataModel = notification.object as! ResultDataModel
        let alert:UIAlertController = UIAlertController.init(title: "返回成功", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.message = "详情看打印日志" + resultData.message!;
        let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true) { }
    }
    func httpRequestFailed(notification:NSNotification) -> Void {
        let resultData:ResultDataModel = notification.object as! ResultDataModel
        let alert:UIAlertController = UIAlertController.init(title: "返回失败", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.message = "详情看打印日志" + resultData.message!;
        let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true) { }
        
    }
}

