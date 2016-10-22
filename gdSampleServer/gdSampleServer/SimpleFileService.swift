//
//  SimpleFileService.swift
//  gdSampleServer
//
//  Copyright © 2016年 gdaigo. All rights reserved.
//

import UIKit

//ファイルアクセスの際に使うAPI
class SimpleFileService: NSObject {

    //ファイルの読み込み、NSDataに入れて戻します。
    func readFile(path: String) -> NSData? {
        do {
            return try NSData(contentsOfFile: path,
                              options: NSData.ReadingOptions.mappedIfSafe)
        } catch _ {
            print("FILE READ ERROR !")
            return nil
        }
    }

    //NSDataのデータをファイルに書き込みます。
    func writeFile(path: String, data: NSData) -> Bool {
        return data.write(toFile: path, atomically: true)
    }

    //xcodeで開発中に追加したファイルを取り出す際のpathを取得します。
    func makeBundleResourcePath(name: String) -> String {
        return Bundle.main.bundlePath + "/" + name
    }
    
    //Swiftのコードで生成したファイルのpath(Documentなので残されます）を取得
    func makeDocumentPath(name: String) -> String {
        return NSHomeDirectory() as String + "/Documents/" + name
    }

    //ファイルから読み出したデータをUInt8配列データとして出力します。
    func makeContentsFromFile(path : String) -> [UInt8] {
        let data = self.readFile(path: path)
        var array =  Array<UInt8>(repeating: 0, count: (data?.length)!)
        data?.getBytes(&array, length: (data?.length)!)
        return array
    }

}
