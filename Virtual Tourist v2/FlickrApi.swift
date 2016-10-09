//
//  FlickrClient.swift
//  Virtual Tourist v2

///WHILE SEARCHING FOR ANY HELP ON THIS, I CHECKED OUT SOURCE CODE AVAILABLE BY OTHER STUDENTS on the Audacity forum and used it to assemble below code

import Foundation


class FlickrApi: NSObject {
    
    func getPhotos(_ latitude: Double, longitude: Double, completionHandlerForPhotos: @escaping (_ result: [String]?, _ error: String?) -> Void) {
        
        taskForGETMethod(latitude, longitude: longitude) { (results, error) in
            
            if let error = error {
                completionHandlerForPhotos(nil, error)
            } else {
                var photosURLs = [String]()
                
                let photos = results?["photos"] as! [String: AnyObject]
                
                let photo = photos["photo"] as! [[String: AnyObject]]
                
                for p in photo {
                    let farm = p["farm"]
                    let server = p["server"]
                    let id = p["id"]
                    let secret = p["secret"]
                    
                    let url = "http://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_m.jpg"
                    photosURLs.append(url)
                }
                completionHandlerForPhotos(photosURLs, nil)
            }
        }
    }
    
    func taskForGETMethod(_ latitude: Double, longitude: Double, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let page = 1
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=7eaeeb9b2a2b5fb73118f4802fa13b65&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1&per_page=21&page=\(page)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        let session = URLSession.shared
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                completionHandlerForGET(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                if ((response as? HTTPURLResponse)?.statusCode == 403) {
                    sendError("403")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        })
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    fileprivate func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: String?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            completionHandlerForConvertData(nil, "Could not parse data")
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    //class func sharedInstance() -> FlickrApi {
    //    struct Singleton {
    //        static var sharedInstance = FlickrApi()
    //    }
    //    return Singleton.sharedInstance
    //}
    
    static let sharedInstance = FlickrApi()
    private override init() {}
    
}
