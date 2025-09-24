import CryptoKit
import Foundation

class CryptoWorker {
    public static func md5(from string: String) -> Int {
        let data = Data(string.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.hashValue
    }
}
