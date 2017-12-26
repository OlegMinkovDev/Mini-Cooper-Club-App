import UIKit

class MCUserController: NSObject {

    static var users:[User] = []
    
    static func addUserToArray(_ car_number:String, id:String, name:String, nickname:String, x:Double, y:Double, online: Int) {
        
        let user = User()
        user.car_number = car_number
        user.id = id
        user.name = name
        user.nickname = nickname
        user.x = x
        user.y = y
        user.online = online
        
        self.users.append(user)
    }
    
    static func getUserByTitle(_ title:String) -> User? {
        
        for user in self.users {
            
            if user.car_number == title {
                return user
            }
        }
        
        return nil
    }
    
    static func getAllUsers() -> [User] {
        return users
    }
    
    static func crearUsers() {
        self.users = []
    }
}
