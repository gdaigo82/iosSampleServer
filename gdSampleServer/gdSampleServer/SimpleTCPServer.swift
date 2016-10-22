//
//  SimpleTCPServer.swift
//  gdSampleServer
//
//  Copyright © 2016年 gdaigo. All rights reserved.
//

import UIKit

// sokectを利用して、TCPサーバを実現するためのAPIです。
class SimpleTCPServer: NSObject {
    
    var port = 0 as in_port_t
    var maxPendingConnection = 0 as Int32
    var listenSocket = -1 as Int32
    var dataSocket = -1 as Int32
    var errorMessage = ""

    // 処理が失敗した際のエラーメッセージ取得
    func getErrorMessage() -> String {
        let ret = self.errorMessage
        self.errorMessage = ""
        return ret
    }

    // ソケット生成からlistenまで
    func openServer() -> Bool {
        self.listenSocket = socket(AF_INET, SOCK_STREAM, 0)
        if self.listenSocket == -1 {
            self.errorMessage = "socket error"
            return false
        }
        
        var value: Int32 = 1
        if setsockopt(self.listenSocket, SOL_SOCKET, SO_REUSEADDR, &value,
                      socklen_t(MemoryLayout<Int32>.size)) == -1
        {
            self.errorMessage = "setsockopt error"
            return false
        }
        
        var addr = sockaddr_in(sin_len: UInt8(MemoryLayout<sockaddr_in>.stride),
                               sin_family: UInt8(AF_INET),
                               sin_port: self.port.bigEndian,
                               sin_addr: in_addr(s_addr: in_addr_t(0)),
                               sin_zero:(0, 0, 0, 0, 0, 0, 0, 0))
        let bindResult = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(self.listenSocket, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }
        if bindResult == -1 {
            self.errorMessage = "bind error"
            return false
        }
        
        let listenResult = listen(self.listenSocket, maxPendingConnection)
        if listenResult == -1 {
            self.errorMessage = "listen error"
            return false
        }
        
        return true
    }
    
    // acceptを使って接続を待ちます。
    func waitForClient() -> Bool
    {
        var len: socklen_t = 0
        var addr = sockaddr()
        self.dataSocket = accept(self.listenSocket, &addr, &len)
        if self.dataSocket == -1 {
            self.errorMessage = "accept error";
            return false
        }
        return true
    }
    
    //データ受信です。UInt8のバッファに受信したデータを書き込みます。
    func recvFromClient(buffer : inout [UInt8], size : Int) -> Int {
        var temp = [UInt8](repeating: 0, count: size)
        let ret = recv(self.dataSocket, &temp, 1024, 0)
        if ret > 0 {
            Array(0..<ret).forEach { buffer[$0] = temp[$0]; }
        }
        return ret
    }
    
    //データの送信です。UInt8のバッファのデータをTCP送信します。
    func sendToClient(buffer : inout [UInt8], size : Int) -> Int {
        return write(self.dataSocket, buffer, size)
    }
    
    //shutdownで接続を切ります。
    func shutdownServer() -> Bool {
        let result = Darwin.shutdown(self.dataSocket, SHUT_RDWR)
        if result < 0 {
            self.errorMessage = "shutdown error"
            return false
        }
        return true
    }

    //closeしてリソースを開放します。
    func closeServer() {
        if self.dataSocket != -1 {
            close(self.dataSocket)
        }
        if self.listenSocket != -1 {
            close(self.listenSocket)
        }
        self.listenSocket = -1
        self.dataSocket = -1
    }

    //インスタンスを確保する際に、サーバの待受ポートを指定して下さい。
    init (port: in_port_t) {
        self.port = port
        self.maxPendingConnection = 1
        self.listenSocket = -1
        self.dataSocket = -1
    }
}
