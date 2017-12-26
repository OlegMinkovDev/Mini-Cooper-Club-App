import UIKit
import AVFoundation

class MCTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var car_number = String()
    var chat:Chat = Chat()
    var user:User? = User()
    
    var mcSearchViewController = MCSearchViewController()
    var mcMapViewController = MCMapViewController()
    var mcContactsViewController = MCContactsViewController()
    var mcChatViewController = MCChatViewController()
    var bombSoundEffect: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        //self.mcSearchViewController = self.viewControllers![0] as! MCSearchViewController
        self.mcMapViewController = self.viewControllers![0] as! MCMapViewController
        self.mcContactsViewController = self.viewControllers![1] as! MCContactsViewController
        self.mcChatViewController = self.viewControllers![2] as! MCChatViewController
        mcChatViewController.chat = self.chat
        mcChatViewController.user = self.user
        
        if !UserDefaults.standard.bool(forKey: "isNewChat") && !UserDefaults.standard.bool(forKey: "isNewGroup") {
            self.selectedViewController = mcMapViewController
        } else { self.selectedViewController = mcChatViewController }
        
        self.setTabBarItems()
    }
    
    func setTabBarItems() {
        
        mcSearchViewController.tabBarItem = UITabBarItem(title: "Поиск", image: UIImage(named: "mapSearch")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "mapSearchTap")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        mcMapViewController.tabBarItem = UITabBarItem(title: "Карта", image: UIImage(named: "mapPlaceholder")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "mapPlaceholderTap")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        mcContactsViewController.tabBarItem = UITabBarItem(title: "Контакты", image: UIImage(named: "mapContact")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "mapContactTap")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        mcChatViewController.tabBarItem = UITabBarItem(title: "Чат", image: UIImage(named: "mapSpeech")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "mapSpeechTap")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.playSound(soundName: "SndMENU_section_item.mp3")
    }
    
    func playSound(soundName: String) {
        
        let path = Bundle.main.path(forResource: soundName, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            sound.play()
        } catch {
            // couldn't load file :(
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
