//
//  Session.swift
//  RWDevCon
//
//  Created by Mic Pringle on 07/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation

struct Session: Decodable {
  
  static var formatter: NSDateFormatter {
    get {
      let formatter = NSDateFormatter()
      formatter.timeZone = NSTimeZone(name: "US/Eastern")!
      formatter.locale = NSLocale(localeIdentifier: "en_US")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      return formatter
    }
  }
  
  static var timeFormatter: NSDateFormatter {
    get {
      let formatter = NSDateFormatter()
      formatter.timeZone = NSTimeZone(name: "US/Eastern")!
      formatter.locale = NSLocale(localeIdentifier: "en_US")
      formatter.dateFormat = "h:mm a"
      return formatter
    }
  }
  
  let date: NSDate?
  let description: String?
  let duration: Int?
  let id: String?
  var isFavorite: Bool?
  let number: String?
  var presenters: [Person]?
  let room: String?
  var time: String? {
    get {
      guard let date = date else { return nil }
      return Session.timeFormatter.stringFromDate(date)
    }
  }
  let title: String?
  let track: String?
  
  init?(json: JSON) {
    self.date = Decoder.decodeDate("date", dateFormatter: Session.formatter)(json)
    self.description = "description" <~~ json
    self.duration = "duration" <~~ json
    self.id = "id" <~~ json
    self.isFavorite = "isFavorite" <~~ json
    self.number = "number" <~~ json
    self.presenters = "presenters" <~~ json
    self.room = "room" <~~ json
    self.title = "title" <~~ json
    self.track = "track" <~~ json
  }
  
}