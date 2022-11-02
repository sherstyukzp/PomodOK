//
//  ItemFormatter.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 07.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import Foundation

class ItemFormatter {
    
    let itemFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter

    }()
    
    let itemFormatterDateFull: DateFormatter = {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        let dateString = dateFormatter.string(from: date)
        
        return dateFormatter
    }()
    
    // Метод получения название часа (формат: 24)
    let itemFormatterHour: DateFormatter = {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: date)
        
        return dateFormatter
    }()

    // Метод получения название дня недели (формат: Sunday)
    let itemFormatterNameDayOfTheWeek: DateFormatter = {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEEE"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        
        return dateFormatter
    }()

    // Метод получения название месяца (формат: 12)
    let itemFormatterNameMonthNumber: DateFormatter = {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM"
        let index = Calendar.current.component(.month, from: date)

        return dateFormatter
    }()

    // Метод получения года (формат: 2020)
    let itemFormatterNameYear: DateFormatter = {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy"

        let yearString = dateFormatter.string(from: date)
        
        return dateFormatter
    }()
    
}
