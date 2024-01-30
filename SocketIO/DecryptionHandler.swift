//
//  DecryptionHandler.swift
//  SPONENT
//
//  Created by StarsDev on 30/01/2024.
//

import CommonCrypto
import Foundation
class DecryptionHandler : NSObject{
    static  func decryptionAESModeECB(messageData: String, key: String) -> String? {
        
        let key = key + "-00000"
        let dataKey = Data(messageData.utf8)
        guard let messageString = String(data: dataKey, encoding: .utf8) else { return nil }
        guard let data = Data(base64Encoded: messageString, options: .ignoreUnknownCharacters) else { return nil }
        guard let keyData = key.data(using: String.Encoding.utf8) else { return nil }
        guard let cryptData = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) else { return nil }
        
        let keyLength               = size_t(kCCKeySizeAES128)
        let operation:  CCOperation = UInt32(kCCDecrypt)
        let algoritm:   CCAlgorithm = UInt32(kCCAlgorithmAES)
        let options:    CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
        let iv:         String      = ""
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  (keyData as NSData).bytes, keyLength,
                                  iv,
                                  (data as NSData).bytes, data.count,
                                  cryptData.mutableBytes, cryptData.length,
                                  &numBytesEncrypted)
        if cryptStatus < 0 {
            return nil
            
        }else {
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                var str = String(decoding : cryptData as Data, as: UTF8.self)
                
                if str.isEmpty {
                    return messageData
                }else {
                    str = str.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    return str
                }
                
            } else {
                return messageData
            }
        }
    }
}
