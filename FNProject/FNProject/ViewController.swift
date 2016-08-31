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
    let dataSource = ["GET","POST","PUT","DELETE","UPLOADE"]
    
    
    override func viewDidLoad() {
        //初始化数据
        self.initWithMap();
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(httpRequestFinished), name: KNotification_RequestFinished, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(httpRequestFailed), name: KNotification_AuthenticationFail, object: nil)
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
        else if text == "POST"{
        }
        else if text == "PUT"{
        }
        else if text == "DELETE"{
        }
        else if text == "UPLOADE"{
        }
        
        
    }
    
    //MARK:......
    enum requsetType:Int {
        case GETTest = 10001,POSTTest,PUTTest,DELETETest,UPLOADETest
    }
    
    func initWithMap() -> Void {
        UrlMaps.shareInstance.initMaps([requsetType.GETTest.rawValue:"http://dev.feiniubus.com:9042/api/common/Fence"])
    }
    
    func httpRequestFinished(notification:NSNotification) -> Void {
        let resultData:ResultDataModel = notification.object as! ResultDataModel
        let alert:UIAlertView = UIAlertView.init();
        alert.title = "返回成功";
        alert.message = resultData.message;
        alert.show()
    }
    func httpRequestFailed(notification:NSNotification) -> Void {
        let resultData:ResultDataModel = notification.object as! ResultDataModel
        let alert:UIAlertView = UIAlertView.init();
        alert.title = "返回失败";
        alert.message = resultData.message;
        alert.show()
        
    }
}

