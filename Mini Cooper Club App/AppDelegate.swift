import UIKit
import GoogleMaps
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let key = "c xvnto8ytgwyridokpcszxretc4e57oujywt9w7gfyvdhj cx"
    let googleMapsApiKey = "AIzaSyCtILPvUUM1sZqq-IHat1vDWKWclNsR7n0"
    let directionApiKey = "AIzaSyDMEvxjgwjYpsEzwlvSCO-iu-qz2uTnyAw"
    
    var car_namber = String()
    var appToken = String()
    var appSecret = String()
    
    var isFirstRequest = true
    var postString = String()
    let url = "http://185.86.79.24/"
    
    var requestCount = 0

    func sendPostRequest(_ post:String, completionHandler: @escaping (_ response: NSDictionary) -> ()) {
        
        self.requestCount += 1
        self.postString = "&token=" + self.appToken + "&secret=" + self.appSecret
            
        let request = NSMutableURLRequest(url: URL(string: self.url)!)
        request.httpMethod = "POST"
        self.postString += post
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            guard error == nil && data != nil else {                                                          // checkfor fundamental networking error
                print("error=\(error)")
                return
            }
                
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                
            self.appSecret = (json["secret"] as? String)!
            self.appToken = (json["token"] as? String)!
                
            let s = self.md5(string: self.key + self.appSecret)
            self.appSecret = s
            
            completionHandler(json)
        }
        task.resume()
    }
    
    // Swift 2.0, minor warning on Swift 1.2
    func md5(string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = string.data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    func goToSignInViewController(currentViewController: UIViewController) {
        
        let alertController = UIAlertController(title: "Сообщение", message: "Время сессии истекло, пожайлуста зайдите снова", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (alert) in
            
            let controller = currentViewController.storyboard?.instantiateViewController(withIdentifier: "SignIn") as! MCSignInViewController
            currentViewController.present(controller, animated: true, completion: nil)
        }
        alertController.addAction(okButton)
        currentViewController.present(alertController, animated: true, completion: nil)
    }
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(googleMapsApiKey)
        
        // change tint color of tab bar items
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:.selected)
        
        // change tint color of tab bar background
        UITabBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().barTintColor = UIColor.black
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        
        let dict:[AnyHashable: Any] = ["trigger":newStatusBarFrame]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "trigger"), object: self, userInfo: dict)
    }
}

