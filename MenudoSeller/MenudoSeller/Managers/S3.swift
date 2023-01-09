// https://github.com/maximbilan/Swift-Amazon-S3-Uploading-Tutorial
import Foundation
import AWSS3
import AWSCore

class S3 {
    static let shared = S3()
    let accessKey = "AKIA5MKVUVW3VLLCXC4Y"
    let secretKey = "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"
    let S3BucketName = "menudo-app-kuli0394"
    
    func upload(with imageData: Data, with itemname: String, completion: @escaping (Result<String, Error>) -> Void) {

        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region:AWSRegionType.USEast1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let name = itemname + String(Int.random(in: 1..<100))
//        let remoteName = "test.jpg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
//        let image = UIImage(named: "test")
//        let data = image!.jpegData(compressionQuality: 0.9)
        do {
            try imageData.write(to: fileURL)
        }
        catch {}
 
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = name
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead

        let transferManager = AWSS3TransferManager.default()

        transferManager.upload(uploadRequest).continueWith { [weak self] (task) -> Any? in
            
            if let error = task.error {
                completion(.failure(error))
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                if let absoluteString = publicURL?.absoluteString {
                    completion(.success((absoluteString)))
                }
            }
            return nil
        }
    }
    
}
