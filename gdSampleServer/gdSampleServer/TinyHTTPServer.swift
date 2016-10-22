//
//  TinyHTTPServer.swift
//  gdSampleServer
//
//  Copyright © 2016年 gdaigo. All rights reserved.
//

import UIKit

// なんちゃってHTTPサーバです。
class TinyHTTPServer: NSObject {
    
    //コンテンツの種類の定義
    enum SampleRequestType : Int {
        case NONE = 0
        case IMG  = 1
        case LOG  = 2
    }

    // メンバ変数：設定値系
    var serverPort = 8081           // サーバポート番号
    var recvBufferSize = 2048       // リクエストデータの最大サイズ
    var fileContents = "sample.jpg" // imaが指定された際に戻すファイル名
    var logFile = "log.txt"         // 内部で生成するログファイル名

    // メンバ変数：それ以外
    var opened: Bool?
    var count = 1
    var totalSent = 0
    var image: String?
    var serif: String?
    var requestType = SampleRequestType.NONE
    var server: SimpleTCPServer?
    var fileService: SimpleFileService?
    var tool: ToolSample?
    var character: SimpleCharacter?
    
    // ファイルを読み出してレスポンスのボディ(UInt8 配列）にします。
    func makeContentsFromFile(path : String) -> [UInt8] {
        let data = self.fileService?.readFile(path: path)
        return (self.tool?.makeUI8ArrayFromNSData(data: data!))!
    }

    // ログデータを生成して、ログファリ雨に書き込みます。
    func makeLogText()
    {
        var text = (self.tool?.getNowClockString())!
        text += ": total " + self.totalSent.description + " bytes sent.\r\n"
        
        let data = self.tool?.makeNSDataFromString(text: text)
        let path = self.fileService?.makeDocumentPath(name: self.logFile)
        print("log path:", path)
        _ = self.fileService?.writeFile(path: path!, data: data!)
    }

    // HTMLを生成して、レスポンスのボディ(UInt8 配列）にします。
    func makeTextContent() -> [UInt8]  {
        var contents = "<!DOCTYPE html>"
        contents += "<html>"
        contents += "<title>iOS Sample Server</title>"
        contents += "<body><h1>"
        contents += (self.tool?.getNowClockString())!
        contents += "</h1></body></html>"
        
        return Array<UInt8>(contents.utf8)
    }

    // サーバの初期化、接続されるまでここで待つことになります。
    func initServer() -> Bool {
        var success : Bool?
        self.server = SimpleTCPServer(port: in_port_t(self.serverPort))
        success = self.server?.openServer()
        self.opened = success
        if success == true {
            success = self.server?.waitForClient()
        }
        if success == false {
            print("SERVER:" , self.server?.getErrorMessage())
        }
        return success!
    }
    
    // サーバの終了
    func closeServer() {
        if opened == false {
            return
        }
        _ = self.server?.shutdownServer()
        self.server?.closeServer()
    }

    // リクエストデータを読み出して、処理の振り分けを行います。
    func readRequest() -> Bool {
        self.requestType = SampleRequestType.NONE
        var buffer = [UInt8](repeating: 0, count: 1024)

        let transmitSize = self.server?.recvFromClient(buffer: &buffer, size: 1024)
        if transmitSize! <= 0  {
            print("disconnect?")
            self.closeServer()
            return false
        }
        
        let text = (self.tool?.makeStringFromBuffer(buffer: &buffer, size: transmitSize!))!
        if text.contains("/log") {
            self.requestType = .LOG
        }
        else if text.contains("/img") {
            self.requestType = .IMG
        }
        return true
    }

    // レスポンスデータの生成、readRequestで振り分けた内容に従って処理します。
    func makeResponse() {
        
        var contents : [UInt8]?
        var mimeType : String?
        var path : String?
        
        switch self.requestType {
        case .IMG:
            path = self.fileService?.makeBundleResourcePath(name: fileContents)
            contents = self.makeContentsFromFile(path: path!)
            mimeType = "Content-Type: image/jpeg"
            self.image = "file.png"
            self.serif = "画像データを送ったよー"
        case .LOG:
            path = self.fileService?.makeDocumentPath(name: logFile)
            contents = self.makeContentsFromFile(path: path!)
            mimeType = "Content-Type: text/html"
            self.image = "log.png"
            self.serif = "ログを送ったよー"
        default:
            contents = self.makeTextContent()
            mimeType = "Content-Type: text/html"
            self.image = "data.png"
            self.serif = "データを送ったよー"
        }
        
        var response = "HTTP/1.0 200 OK\r\n"
        response += "Content-Length: " + (contents?.count.description)! + "\r\n"
        response += mimeType! + "\r\n"
        response += "\r\n"
        var responseArray: [UInt8] = Array(response.utf8)
        responseArray += contents!;
        
        self.totalSent += responseArray.count
        _ = self.server?.sendToClient(buffer: &responseArray, size: responseArray.count)
    }

    // サーバの一連の処理（接続待ちー＞リクエストー＞レスポンスー＞終了ー＞ログ生成）
    func serverMainSequence() {
        var success = self.initServer()
        if success == true {
            success = self.readRequest()
        }
        if success == true {
            self.makeResponse()
        }
        self.closeServer()
        
        if success == true {
            makeLogText()
        }
    }

    // メイン処理
    // serverMainSequenceを呼び出し、通信が終わった際に通信内容などを表示します。
    // 表示処理が終わったら再び、serverMainSewuenceを回帰的に呼び出します。
    // 本当は
    //
    // whie(true) { serverMainSequence() reaction(text, img) }
    //
    //がしたいのですが、スレッド同期の関係でこういう記述になりました。
    func mainFunc(label : String) {
        let queue = DispatchQueue(label: label)
        queue.async { // ここでViewControlerのスレッドから切り離します。
            self.serverMainSequence()
            DispatchQueue.main.async { // ここでViewControlerのスレッドに戻ることを期待
                // 戻ったので、viewに対していろいろやらかします。
                var text = (self.tool?.getNowClockString())!
                text += " " + self.count.description + "回目\n"
                text += self.serif!
                self.character?.reaction(serif: text, image: self.image!)
                self.count += 1
                self.mainFunc(label: "gdaigo82.server")
            }
        }
    }

    // 初期画面（IP表示）
    func viewIPaddr()
    {
        let addrs = (self.tool?.getIFAddresses())!
        var Info = "URLはここです。\n"
        for addr in addrs {
            Info += addr + ":" + self.serverPort.description + "\n"
        }
        self.character?.reaction(serif: Info, image: "ready.png")
    }

    // なんちゃってHTTPd を起動
    func start()
    {
        print("TinyHTTPServer:start")
        self.viewIPaddr();
        mainFunc(label: "gdai8go2.server")
    }

    init(view : ViewController) {
        self.fileService = SimpleFileService()
        self.tool = ToolSample()
        self.character = SimpleCharacter(label: view.textLabel!, imgView: view.characterImage!)
        self.opened = false
        
    }
}
