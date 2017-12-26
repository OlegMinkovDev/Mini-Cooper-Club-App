//
//  Error.swift
//  Mini Cooper Club App
//
//  Created by Олег Минков on 26.08.16.
//  Copyright © 2016 Oleg Minkov. All rights reserved.
//

import UIKit

class Error: NSObject {
    
    var errorDescription = ""
    
    func exist(_ response: NSDictionary) -> Bool {
        
        let errors = response["e"] as? [Int]
        
        if errors != nil {
            
            for error in errors! {
                
                switch error {
                case 0:
                    errorDescription += "Пустой запрос \n"
                case 1:
                    errorDescription += "Неправильный запрос \n"
                case 2:
                    errorDescription += "Не заполнено обязательное поле \n"
                case 3:
                    errorDescription += "Поле ФИО должно быть более 3х и менее 255и символов \n"
                case 4:
                    errorDescription += "Недопусимые символы в поле ФИО \n"
                case 5:
                    errorDescription += "Некорректный номер авто \n"
                case 6:
                    errorDescription += "Пользователь с таким именем уже зарегистрирован \n"
                case 7:
                    errorDescription += "Пользователь с таким номером уже зарегистрирован \n"
                case 8:
                    errorDescription += "Не удалось зарегистрировать пользователя \n"
                case 9:
                    errorDescription += "Нет связи \n"
                case 10:
                    errorDescription += "Нет такого пользователя или неверный логин или пароль \n"
                case 11:
                    errorDescription += "Пользователь не авторизован \n"
                case 12:
                    errorDescription += "Не удалось добавить таблицу \n"
                case 13:
                    errorDescription += "Пустое сообщение \n"
                case 14:
                    errorDescription += "Слишком большое сообщение \n"
                case 15:
                    errorDescription += "Ошибка запроса \n"
                case 16:
                    errorDescription += "Поле Ник должно быть более 1го и менее 255и символов \n"
                case 17:
                    errorDescription += "Недопустимые символы в поле Ник  \n"
                case 18:
                    errorDescription += "Нет доступа к этой комнате \n"
                default:
                    ""
                }
            }
            
        } else { // no errors
            return false
        }
        
        return true
    }
    
    func getDesc() -> String {
        return self.errorDescription
    }
}
