//
//  ToolSample.swift
//  gdSampleServer
//
//  Copyright © 2016年 gdaigo. All rights reserved.
//

import UIKit

// 本サーバを実現するにあたり、作ったAPI、他で使うことがあるかも。。
class ToolSample: NSObject {

    // 現在時刻の文字列を取得
    func getNowClockString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let now = Date()
        return formatter.string(from: now)
    }
    
    // UInt8の配列データ（中身は文字列）をStringにする。
    func makeStringFromBuffer(buffer : inout [UInt8], size : Int) -> String {
        buffer[size] = 0
        return NSString(bytes: buffer, length:size + 1, encoding: String.Encoding.ascii.rawValue) as! String
    }
    
    // StringデータをUInt8の配列データにする。
    func makeNSDataFromString(text: String) -> NSData{
        return (text.data(using: String.Encoding.utf8) as NSData?)!
    }
    
    // NSDataをUInt8の配列データにする。
    func makeUI8ArrayFromNSData(data: NSData) -> [UInt8] {
        var array =  Array<UInt8>(repeating: 0, count: (data.length))
        data.getBytes(&array, length: (data.length))
        return array
    }
    
    // 自分のIPアドレスを取得。文字列の配列（複数ある場合も考慮）で出します。
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }

}
