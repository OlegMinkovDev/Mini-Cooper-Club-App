import UIKit

class MCStartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func sendFirstRequest() {
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://185.86.79.24/")! as URL)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, responce, error) in
            
            if self.dataIsNotNil(data: data as NSData?) {
                
                let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                
                appDelegate.appToken = (json as! NSDictionary)["token"]! as! String
                appDelegate.appSecret = (json as! NSDictionary)["secret"]! as! String
                
                let s = appDelegate.md5(string: appDelegate.key + appDelegate.appSecret)
                appDelegate.appSecret = s
                
            } else {
                print("MCStartViewController | sendFirstRequest | data is nil")
            }
        }
        
        task.resume()
    }
    
    static func dataIsNotNil(data: NSData?) -> Bool {
        
        if data == nil {
            return false
        }
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

