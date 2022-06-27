import UIKit
import CryptoKit
import CommonCrypto

func hmacSHA256(message: String, secret: String, salt: String) throws -> String {
    let saltedMessage = "\(message)\(salt)"
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), secret, secret.count, saltedMessage, saltedMessage.count, &digest)
    let data = Data(digest)
    return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
}

print(try hmacSHA256(message: "", secret: "", salt: ""))
