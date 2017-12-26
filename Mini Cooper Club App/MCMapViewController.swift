import UIKit
import GoogleMaps

class MCMapViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - Global constants
    let UPDATE_TIME = "10"
    
    // MARK: - UI variable
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var addressL: UILabel!
    @IBOutlet weak var showTrafficB: UIButton!
    
    // MARK: - Global variable
    let locationManager = CLLocationManager()
    var appDelegate:AppDelegate = AppDelegate()
    var latitude = Double()
    var longitude = Double()
    var centerCoordinates = CLLocation()
    var zoom:Float = 10
    var contacts:[Contact] = []
    var timer = Timer()
    let group:DispatchGroup  = DispatchGroup();
    var allUsersWhoAttendedTheMap:[(car_number: String, id: String, name: String, nickname: String, x: Double, y: Double)] = []
    
    // MARK: - UIView methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        
        self.mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Карта"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        self.timer = Timer.scheduledTimer(timeInterval: Double(self.UPDATE_TIME)!, target: self, selector: #selector(MCMapViewController.updateOnlineUsers), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.zoom = self.mapView.camera.zoom
        
        /*UserDefaults.standard.set(self.centerCoordinates.coordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(self.centerCoordinates.coordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(self.zoom, forKey: "oldZoom")*/
    }
    
    // MARK: - UI methods
    @IBAction func ZoomPlus(_ sender: AnyObject) {
        
        zoom = mapView.camera.zoom
        
        if zoom <= 20 {
            zoom += 1
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: self.centerCoordinates.coordinate.latitude,
                                                          longitude: self.centerCoordinates.coordinate.longitude, zoom: self.zoom)
        mapView.camera = camera
    }
    
    
    @IBAction func ZoomMinus(_ sender: AnyObject) {
    
        zoom = mapView.camera.zoom
        
        if zoom > 2 {
            zoom -= 1
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: self.centerCoordinates.coordinate.latitude,
                                                          longitude: self.centerCoordinates.coordinate.longitude, zoom: self.zoom)
        mapView.camera = camera

    }
    
    
    @IBAction func ShowTraffic(_ sender: AnyObject) {
        
        if !self.mapView.isTrafficEnabled {
        
            DispatchQueue.main.async(execute: {
                self.mapView.isTrafficEnabled = true
                self.showTrafficB.setBackgroundImage(UIImage(named: "greenTraffic"), for: UIControlState())
            })
        
        } else {
            
            DispatchQueue.main.async(execute: {
                self.mapView.isTrafficEnabled = false
                self.showTrafficB.setBackgroundImage(UIImage(named: "redTraffic"), for: UIControlState())
            })
        }
    }
    
    // MARK: - MapView Delegate methods 
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        return self.setInfoWindow(marker.title!)
    }
    
    func setInfoWindow(_ carNumber: String) -> UIView? {
        
        let infoWindow = Bundle.main.loadNibNamed("InfoWindow", owner: self, options: nil)?[0] as? MCCustomInfoWindow
        
        let labelArray = [infoWindow!.L7,infoWindow!.L8,infoWindow!.L9]
        infoWindow?.number.text = (carNumber as NSString).substring(to: 6).lowercased()
        
        var region = ""
        if carNumber.characters.count == 8 {
            region = (carNumber as NSString).substring(with: NSRange.init(location: 6, length: 2))
        } else {
            region = (carNumber as NSString).substring(with: NSRange.init(location: 6, length: 3))
        }
        
        var index = 0
        for char in region.characters {
            
            labelArray[index]?.text = String(char)
            index += 1
        }
        
        let user = MCUserController.getUserByTitle(carNumber)
        if user!.name != "" {
            infoWindow?.nameL.text = "Имя: " + (user?.name)!
        }
        if user!.nickname != "" {
            infoWindow?.nicknameL.text = "Ник: " + (user?.nickname)!
        }
        
        return infoWindow! as UIView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let user = MCUserController.getUserByTitle(marker.title!)
        
        UserDefaults.standard.set(true, forKey: "isNewChat")
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "Nav") as! MCNavigationController
        let mcTabBarContrller = controller.topViewController as? MCTabBarController
        
        mcTabBarContrller!.user = user
        
        self.present(controller, animated: false, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        reverseGeocodeCoordinate(position.target)
        self.centerCoordinates = CLLocation.init(latitude: position.target.latitude, longitude: position.target.longitude)
    }
    
    // MARK:
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                let lines = address.lines! as [String]
                self.addressL.text = lines.joined(separator: " ")
            }
        }
    }
    
    func updateOnlineUsers() {
        
        let checkLocation = locationManager.location
        if checkLocation != nil {
        
            self.latitude = (self.locationManager.location?.coordinate.latitude)!
            self.longitude = (self.locationManager.location?.coordinate.longitude)!
        }
        
        var postString = "&x=" + String(self.latitude)
        postString += "&y=" + String(self.longitude) + "&user_limit=0&act=all"
        self.appDelegate.sendPostRequest(postString, completionHandler: { (responseFromActionAll) in
            
            let error = Error()
            if !error.exist(responseFromActionAll) {
            
                let users:NSArray = (responseFromActionAll["u"] as? [NSDictionary])! as NSArray
                
                MCUserController.crearUsers()
                for user in users {
                    
                    let car_number:String = (user as! NSDictionary)["car_number"]! as! String
                    let id:String = (user as! NSDictionary)["id"]! as! String
                    let name:String = (user as! NSDictionary)["name"]! as! String
                    let nickname = (user as! NSDictionary)["nickname"]! as! String
                    let x = (user as! NSDictionary)["x"]! as! String
                    let y = (user as! NSDictionary)["y"]! as! String
                    let online = (user as! NSDictionary)["online"]! as! Int
                    
                    MCUserController.addUserToArray(car_number, id: id, name: name, nickname: nickname, x: Double(x)!, y: Double(y)!, online: online)
                }
                
                // clear all markers
                DispatchQueue.main.async(execute: {
                    self.mapView.clear()
                })
                
                for user in MCUserController.getAllUsers() {
                    
                    if !self.isMyCar(user.car_number.lowercased()) {
                        
                        DispatchQueue.main.async(execute: {
                            self.createMarkerForUser(user)
                        })
                    }
                }
            
            } else {
                
                print("MCMapViewController | updateOnlineUsers | " + error.getDesc())
                if error.getDesc() == "Пользователь не авторизован \n" {
                    self.appDelegate.goToSignInViewController(currentViewController: self)
                }
            }
            
        })
    }
    
    func isMyCar(_ number: String) -> Bool {
        return number == self.appDelegate.car_namber
    }
    
    func createOfflineMarkerForUser(_ user: (car_number: String, id: String, name: String, nickname: String, x: Double, y: Double)) {
        
        let userIcon = UIImage(named: "offline_car@2x")!
        let position = CLLocationCoordinate2DMake(user.x, user.y)
        let car = GMSMarker(position: position)
        car.title = user.car_number
        car.icon = userIcon
        car.map = self.mapView
    }
    
    func createMarkerForUser(_ user: User) {
        
        if user.x != 0 && user.y != 0 {
        
            let userIcon = self.getCorrectIconAndSetUserColor(user)
            let position = CLLocationCoordinate2DMake(user.x, user.y)
            let car = GMSMarker(position: position)
            car.title = user.car_number
            car.icon = userIcon
            car.map = self.mapView
        }
    }
    
    func getCorrectIconAndSetUserColor(_ user: User) -> UIImage {
        
        if user.online == 1 {
            return UIImage(named: "online_car@2x")!
        }
        
        /*var carImage = UIImage(named: "online_car@2x")
        if user.name == "" && user.nickname == "" {
            carImage = UIImage(named: "online_car@2x")!
        } else if user.name == "" || user.nickname == "" {
            carImage = UIImage(named: "online_car@2x")!
        }*/
        
        return UIImage(named: "offline_car@2x")!
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? MCChatViewController {
            viewController.contacts = self.contacts
        }
    }

    // MARK:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - CLLocationManagerDelegate
extension MCMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            self.updateOnlineUsers()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            self.centerCoordinates = CLLocation.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            /*let lat = UserDefaults.standard.double(forKey: "latitude")
            let lon = UserDefaults.standard.double(forKey: "longitude")
            let oldZoom = UserDefaults.standard.float(forKey: "oldZoom")
            
            if lat != 0.0 && lon != 0.0 && oldZoom != 0.0 {
                mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: lat, longitude: lon), zoom: oldZoom, bearing: 0, viewingAngle: 0)
            } else {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: self.zoom, bearing: 0, viewingAngle: 0)
            }*/
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: self.zoom, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
}
