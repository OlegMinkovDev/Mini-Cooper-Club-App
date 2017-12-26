import UIKit

class MCNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
