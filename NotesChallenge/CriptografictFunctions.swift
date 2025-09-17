import CryptoKit
import Foundation

public func md5(from string: String) -> Int {
    let data = Data(string.utf8)
    let digest = Insecure.MD5.hash(data: data)
    return digest.hashValue
}
