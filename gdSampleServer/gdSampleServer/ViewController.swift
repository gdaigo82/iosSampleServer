//
//  ViewController.swift
//  gdSampleServer
//
//  Copyright © 2016年 gdaigo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var FParaMainReading = 30.0
    var FparaTop = 50.0
    var FParaLeading = 30.0
    var FParaHeightSpace = 20.0
    var FParaTextHeight = 150.0
    var FParaImageHeight = 350.0
    var textLabel : UILabel? = nil
    var characterImage : UIImageView? = nil
    
    let touchTag = 1017 // 適当値
    var tinyHTTPd : TinyHTTPServer? = nil

    // サンプルでは、テキストと画像を表示しますので、それぞれリソースを作成して
    // コード上で適当に配置しています。
    func layoutView () {
        
        let deviceHeight : Double = Double(self.view.frame.size.height)
        let deviceWidth : Double = Double(self.view.frame.size.width)
        
        
        var top : Double = FparaTop
        let leading : Double = FParaLeading
        let width : Double = deviceWidth - (leading * 2.0)
        var height : Double = FParaTextHeight
        var latestHegight : Double = height
        
        self.textLabel = UILabel()
        self.textLabel?.frame = CGRect(x: leading, y: top, width: width, height: height)
        self.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
        self.textLabel?.textAlignment = NSTextAlignment.center
        self.textLabel?.numberOfLines = 0
        self.textLabel?.text = ""
        self.textLabel?.backgroundColor = UIColor.white
        self.view?.addSubview(self.textLabel!)
        latestHegight += top + FParaHeightSpace
        
        self.characterImage = UIImageView()
        top = latestHegight
        if (deviceHeight - latestHegight > FParaImageHeight)
        {
            height = FParaImageHeight
        }
        else
        {
            height = deviceHeight - latestHegight
        }
        
        self.characterImage?.frame = CGRect(x: leading, y: top, width: width, height: height)
        self.characterImage?.contentMode = UIViewContentMode.scaleAspectFit
        self.view?.addSubview(self.characterImage!)
        self.view?.tag = self.touchTag
    }
    
    // HTTPdの起動
    func startServer()
    {
        self.tinyHTTPd = TinyHTTPServer(view: self)
        self.tinyHTTPd?.start()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            if touch.view!.tag == self.touchTag && self.tinyHTTPd != nil {
                self.tinyHTTPd?.viewIPaddr()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.layoutView()
        self.startServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

