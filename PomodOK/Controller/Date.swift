//
//  Date.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 04.11.2022.
//  Copyright © 2022 Ярослав Шерстюк. All rights reserved.
//  https://stackoverflow.com/a/33397770/10563031

import Foundation

extension Date {

  static func today() -> Date {
      
      //let date = Date()
      let calendar = Calendar(identifier: .gregorian)
      let startOfDate = calendar.startOfDay(for: Date())
      
      return startOfDate // 2022-11-04 00:00:00 +0200
  }

  func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.next,
               weekday,
               considerToday: considerToday)
  }

  func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.previous,
               weekday,
               considerToday: considerToday)
  }

  func get(_ direction: SearchDirection,
           _ weekDay: Weekday,
           considerToday consider: Bool = false) -> Date {

    let dayName = weekDay.rawValue

    let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

    assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

    let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

    let calendar = Calendar(identifier: .gregorian)

    if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
      return self
    }

    var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
    nextDateComponent.weekday = searchWeekdayIndex

    let date = calendar.nextDate(after: self,
                                 matching: nextDateComponent,
                                 matchingPolicy: .nextTime,
                                 direction: direction.calendarSearchDirection)

    return date!
  }

}

// MARK: Helper methods
extension Date {
  func getWeekDaysInEnglish() -> [String] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar.weekdaySymbols
  }

  enum Weekday: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
  }

  enum SearchDirection {
    case next
    case previous

    var calendarSearchDirection: Calendar.SearchDirection {
      switch self {
      case .next:
        return .forward
      case .previous:
          return .backward
      }
    }
  }
}



//
//Date.today()                                  // Oct 15, 2019 at 9:21 AM
//Date.today().next(.monday)                    // Oct 21, 2019 at 9:21 AM
//Date.today().next(.sunday)                    //  Oct 20, 2019 at 9:21 AM
//
//
//Date.today().previous(.sunday)                // Oct 13, 2019 at 9:21 AM
//Date.today().previous(.monday)                // Oct 14, 2019 at 9:21 AM
//
//Date.today().previous(.thursday)              // Oct 10, 2019 at 9:21 AM
//Date.today().next(.thursday)                  // Oct 17, 2019 at 9:21 AM
//Date.today().previous(.thursday,
//                      considerToday: true)    // Oct 10, 2019 at 9:21 AM
//
//
//Date.today().next(.monday)
//            .next(.sunday)
//            .next(.thursday)
