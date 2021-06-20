//
//  FoundationExtensions.swift
//

import Foundation

// MARK: - Constants

let OneDayTimeInterval: TimeInterval = 86400

// MARK: - NSRange

extension NSRange {

    func toRange(_ string: String) -> Range<String.Index> {
        let start = string.index(string.startIndex, offsetBy: self.location)
        let end = string.index(start, offsetBy: self.length)
        return start..<end
    }

}

// MARK: - String

extension String {

    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }

        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }

        return String(self[substringStartIndex ..< substringEndIndex])
    }

    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    func strippingHTML() -> String {
        var result = self.replacingOccurrences(of: "<br />", with: "\n")

        result = result.replacingOccurrences(of: "<br/>", with: "\n")
        result = result.replacingOccurrences(of: "<br></br>", with: "\n")
        result = result.replacingOccurrences(of: "<br>", with: "\n")
        result = result.replacingOccurrences(of: "<p />", with: "\n")
        result = result.replacingOccurrences(of: "<p>", with: "\n")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        result = result.replacingOccurrences(of: "&#34;", with: "\"")
        result = result.replacingOccurrences(of: "&amp;#39;", with: "'")
        result = result.replacingOccurrences(of: "&amp;#34;", with: "\"")

        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        return result
    }

    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }

    var containsLetter: Bool {
        let regEx = ".*[a-zA-Z].*"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }

    var containsNumber: Bool {
        let regEx = ".*[0-9].*"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }

}

// MARK: - Dictionary

extension Dictionary {

    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
}

// MARK: - MutableCollection

extension MutableCollection {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: numericCast(arc4random_uniform(numericCast(diff))))
            swapAt(i, j)
        }
    }
}

// MARK: - TimeInterval

extension Int {

    var minutesSecondsString: String {
        let seconds = self % 60
        let minutes = (self / 60) % 60
        return NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
    }

}

// MARK: - Date

extension Date {

    // sunday = 1. saturday = 7
    var dayOfWeekIndex: Int {
        let calendar: Calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var week: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }

    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    var hours: Int {
        return Calendar.current.component(.hour, from: self)
    }

    var minutes: Int {
        return Calendar.current.component(.minute, from: self)
    }

    var seconds: Int {
        return Calendar.current.component(.second, from: self)
    }

    var dateAtBeginningOfDay: Date {
        let calendar: Calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }

    var dateAtEndOfDay: Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: self)!
        let tomorrowMidnight = calendar.startOfDay(for: tomorrow)
        return calendar.date(byAdding: .second, value: -1, to: tomorrowMidnight)!
    }

    var dateAtBeginningOfHour: Date? {
        var components: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = self.hours
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)
    }

    var dateWithZeroSeconds: Date {
        let time: TimeInterval = floor(self.timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: time)
    }

    func isBetweenDates(_ startDate: Date, endDate: Date, inclusive: Bool = false) -> Bool {
        if inclusive == true {
            var result = self.isBetweenDates(startDate, endDate: endDate)
            if (!result)
            {
                if ((self == startDate) || (self == endDate))
                {
                    result = true
                }
            }
            return result
        } else {
            if (self.isEarlierThan(startDate)) {
                return false
            }
            if (self.isLaterThan(endDate)) {
                return false
            }
            return true
        }
    }

    func isEarlierThan(_ date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }

    func isLaterThan(_ date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }

    var isToday: Bool
    {
        let today = Date()
        return self.year == today.year && self.month == today.month && self.day == today.day
    }

    func roundToMinutes(interval: Int) -> Date {
        let time: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
        let minutes: Int = time.minute!
        let remain = minutes % interval
        return self.addingTimeInterval(TimeInterval(60 * (interval - remain))).dateWithZeroSeconds
    }

    func addingDayIndexFromToday(dayIndex: Int) -> Date? {
        let calendar = Calendar.current
        let dateComponents: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        var tomorrowComponents: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.addingTimeInterval(OneDayTimeInterval))

        tomorrowComponents.hour = dateComponents.hour
        tomorrowComponents.minute = dateComponents.minute
        tomorrowComponents.second = dateComponents.second

        let tomorrow = calendar.date(from: tomorrowComponents)

        return calendar.date(byAdding: .day, value: dayIndex, to: tomorrow!)
    }

    var timeHasPassed: Bool {
        let calendar = Calendar.current
        var dateComponents: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        let todayComponents: DateComponents = calendar.dateComponents([.year, .month, .day], from: Date())

        dateComponents.day = todayComponents.day
        dateComponents.month = todayComponents.month
        dateComponents.year = todayComponents.year

        let timeOnly = calendar.date(from: dateComponents)

        if (timeOnly!.timeIntervalSince(Date()) < 0.0) {
            return true
        } else {
            return false
        }
    }

    // Returns date formatted as countdown:
    //
    // >= 1 day == time in day(s) rounded up
    // >= 1 hour == time in hour(s) rounded up
    // >= 5 minutes == time in minutes rounded up
    // < 5 minutes == time in minutes, seconds rounded up

    func countdownTimeStringUntilDate(targetDate: Date, noRounding : Bool = false) -> String {
        let nextReminderSecondsLeft:Int = Int(self.timeIntervalSince(targetDate))
        var days : Int = nextReminderSecondsLeft / Int(86400)
        var hours : Int = nextReminderSecondsLeft % Int(86400) / 3600
        var minutes : Int = (nextReminderSecondsLeft % 3600) / 60
        let seconds : Int = (nextReminderSecondsLeft % 3600) % 60
        var countdownString: String = ""

        if (noRounding) {
            hours = nextReminderSecondsLeft / 3600
            if (hours > 0) {
                countdownString = String(format: NSLocalizedString("%d:%02d:%02d", comment:"hours:minutes:seconds left in reminder"),hours,minutes,seconds)
            } else if (minutes > 0) {
                countdownString = String(format: NSLocalizedString("%d:%02d", comment:"minutes:seconds left in reminder"),minutes,seconds)
            } else {
                countdownString = String(format: NSLocalizedString("%d:%02d", comment:"minutes:seconds left in reminder"),0,seconds)
            }
        } else {
            if days >= 1 {
                if hours > 0 || minutes > 0 || seconds > 0 {
                    days += 1
                }
                if days == 1 {
                    countdownString = String(format: NSLocalizedString("%d Day", comment: "number of days left in reminder (singular)"), days)
                } else {
                    countdownString = String(format: NSLocalizedString("%d Days", comment: "number of days left in reminder (plural)"), days)
                }
            } else if hours >= 1 {
                if minutes > 0 || seconds > 0 {
                    hours += 1
                }
                if hours == 1 {
                    countdownString = String(format: NSLocalizedString("%d Hour", comment: "number of hours left in reminder (singular)"), hours)
                } else {
                    countdownString = String(format: NSLocalizedString("%d Hours", comment: "number of hours left in reminder (plural)"), hours)
                }
            } else if minutes >= 5 {
                if seconds > 0 {
                    minutes += 1
                }
                if minutes == 1 {
                    countdownString = String(format: NSLocalizedString("%d Min", comment: "number of minutes left in reminder (singular)"), minutes)
                } else {
                    countdownString = String(format: NSLocalizedString("%d Mins", comment: "number of minutes left in reminder (plural)"), minutes)
                }
            } else {
                countdownString = String(format: NSLocalizedString("%d:%02d", comment: "number of minutes and seconds left in reminder"), minutes, seconds)
            }
        }
        return countdownString
    }

    func numberOfDaysUntilDate(date: Date) -> Int {
        let calendar: Calendar = Calendar.current
        let components: DateComponents = calendar.dateComponents([.day], from: self, to: date)
        return components.day!
    }

    func addingYears(numberOfYears: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: numberOfYears, to: self)
    }

    func addingMonths(numberOfMonths: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
    }

    func addingDays(numberOfDays: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: numberOfDays, to: self)
    }

    func addingHours(numberOfHours: Int) -> Date? {
         return Calendar.current.date(byAdding: .hour, value: numberOfHours, to: self)
    }

    func addingMinutes(numberOfMinutes: Int) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: numberOfMinutes, to: self)
    }

    func addingSeconds(numberOfSeconds: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: numberOfSeconds, to: self)
    }

    static func dateFromISOString(_ isoString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let result = formatter.date(from: isoString)
        return result
    }

    var isoString: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }

}

// MARK: - File Handling

func openTextFileNamed(name: String, fileExtension: String) -> String? {
    var result: String?
    if let filePath = Bundle.main.path(forResource: name, ofType: fileExtension) {
        do {
            let contents = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            result = contents
        } catch {
            print(error)
        }
    }
    return result
}
