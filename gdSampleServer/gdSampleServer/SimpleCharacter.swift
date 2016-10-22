//
//  SimpleCharacter.swift
//  gdSampleServer
//
//  Copyright © 2016年 gdaigo. All rights reserved.
//

import UIKit

// イメージファイルと表示文字列を渡すと、表示するだけのものです・・
// Viewが持つUILabelとUIImageViewのインスタンスが必要です。
class SimpleCharacter: NSObject {

    var label: UILabel?
    var imageView: UIImageView?

    func reaction(serif: String, image: String)
    {
        self.label?.text = serif
        let imageObject = UIImage(named:image)!
        self.imageView?.image = imageObject
    }
    
    init(label: UILabel, imgView: UIImageView)
    {
        self.label = label
        self.imageView = imgView
    }

}
