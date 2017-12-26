import UIKit
import GoogleMaps
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MCGetDirectionViewController: UIViewController, GMSMapViewDelegate {

    // MARK: - UI variable
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var showTrafficB: UIButton!
    
    // MARK: - Global variable
    let locationManager = CLLocationManager()
    var appDelegate:AppDelegate = AppDelegate()
    var polyline = GMSPolyline()
    var latitude = Double()
    var longitude = Double()
    var centerCoordinates = CLLocationCoordinate2D()
    var zoom:Float = 10
    var origin = String()
    var destination = String()
    
    // MARK: - UIView methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        self.mapView.isMyLocationEnabled = false
        self.mapView.settings.myLocationButton = false
        self.mapView.settings.compassButton = true
        
        self.mapView.delegate = self
    }
    
    // MARK: - MapView Delegate methods
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.centerCoordinates = position.target
    }
    
    // MARK: - UI methods
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
    @IBAction func ZoomPlus(_ sender: AnyObject) {
        
        zoom = mapView.camera.zoom
        
        if zoom <= 20 {
            zoom += 1
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: self.centerCoordinates.latitude,
                                                          longitude: self.centerCoordinates.longitude, zoom: self.zoom)
        mapView.camera = camera
    }
    
    
    @IBAction func ZoomMinus(_ sender: AnyObject) {
        
        zoom = mapView.camera.zoom
        
        if zoom > 2 {
            zoom -= 1
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: self.centerCoordinates.latitude,
                                                          longitude: self.centerCoordinates.longitude, zoom: self.zoom)
        mapView.camera = camera
        
    }
    
    @IBAction func Back(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:
    func getDirection(_ origin:String, destination:String) {
        
        /*var urlString : NSString = "https://maps.googleapis.com/maps/api/directions/json?origin=" + origin + "&destination=" + destination + "&key=" + appDelegate.directionApiKey
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed())!
        
        let request = NSMutableURLRequest(url: URL(string: urlString as String)!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil && data != nil else {                                                          // checkfor fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
            
            let routes = json["routes"] as? NSArray
            
            if routes?.count > 0 {
            
                let start_lat = json["routes"]![0]["legs"]!![0]["start_location"]!!["lat"] as! Double
                let start_lng = json["routes"]![0]["legs"]!![0]["start_location"]!!["lng"] as! Double
                let end_lat = json["routes"]![0]["legs"]!![0]["end_location"]!!["lat"] as! Double
                let end_lng = json["routes"]![0]["legs"]!![0]["end_location"]!!["lng"] as! Double
                
                let startLocation = CLLocationCoordinate2DMake(start_lat, start_lng)
                let endLocation = CLLocationCoordinate2DMake(end_lat, end_lng)
                
                self.addMarkers(startLocation, endLocation: endLocation)
                
                DispatchQueue.main.async(execute: {
                    
                    let encodedString:String = json["routes"]![0]["overview_polyline"]!!["points"] as! String
                    let encodedPath = GMSPath(fromEncodedPath: encodedString)
                    self.polyline = GMSPolyline(path: encodedPath)
                    self.polyline.strokeWidth = 7
                    self.polyline.strokeColor = UIColor.green
                    self.polyline.map = self.mapView
                })
            
            } else {
                
                let alertController = UIAlertController(title: "Ошибка", message: "Невозможно проложить маршрут", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }) 
        task.resume()*/
    }
    
    func addMarkers(_ startLocation:CLLocationCoordinate2D, endLocation:CLLocationCoordinate2D) {
        
        DispatchQueue.main.async(execute: {
        
            let startMarker = GMSMarker(position: startLocation)
            startMarker.title = "Начальная точка"
            startMarker.icon = UIImage(named: "markerA")
            startMarker.map = self.mapView

            let endMarker = GMSMarker(position: endLocation)
            endMarker.title = "Конечная точка"
            endMarker.icon = UIImage(named: "markerB")
            endMarker.map = self.mapView
        })
    }
    
    func reverseGeocodeCoordinate(_ location: CLLocationCoordinate2D, isOrigin: Bool) {
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { response, error in
            if let addr = response?.firstResult() {
                
                let lines = addr.lines! as [String]
                
                if isOrigin {
                    self.origin = lines.joined(separator: " ")
                } else { self.destination = lines.joined(separator: " ") }
                
                self.origin = self.origin.replacingOccurrences(of: " ", with: "")
                self.destination = self.destination.replacingOccurrences(of: " ", with: "")
                
                self.getDirection(self.origin, destination: self.destination)
            }
        }
    }
    
    // MARK:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - CLLocationManagerDelegate
extension MCGetDirectionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            self.locationManager.startUpdatingLocation()
            
            self.mapView.isMyLocationEnabled = false
            self.mapView.settings.myLocationButton = false
            self.mapView.settings.compassButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            // reverse current location to address
            if self.origin == "Current location" {
                self.reverseGeocodeCoordinate(location.coordinate, isOrigin: true)
            } else if self.destination == "Current location" {
                self.reverseGeocodeCoordinate(location.coordinate, isOrigin: false)
            } else {
                
                // remove spaces from adresses
                self.origin = self.origin.replacingOccurrences(of: " ", with: "")
                self.destination = self.destination.replacingOccurrences(of: " ", with: "")
                
                self.getDirection(self.origin, destination: self.destination)
            }
            
            locationManager.stopUpdatingLocation()
        }
        
    }
}
