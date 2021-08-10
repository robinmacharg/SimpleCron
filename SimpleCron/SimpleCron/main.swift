//
//  main.swift
//  SimpleCron
//
//  Created by Robin Macharg on 09/08/2021.
//

import Foundation

var crontab: [CronEntry] = []

/**
 * Represents a crontab time specification: minutes or hours.  A wildcard ('*') can also be represented
 */
enum CronTime {
    enum TimeType {
        case minute
        case hour
    }
    case number(Int)
    case wildcard
}

extension CronTime {
    
    enum CronTimeErrors: Error {
        case invalidNumber(_ string: String)
    }
    
    // Validate and initialize a CronTime from a string
    init(type: TimeType, value: String) throws {
        switch value {
        case "*":
            self = .wildcard
        
        case _ where Int(value) != nil:
            guard let intValue = Int(value),
                  type == .minute
                    ? (0..<60).contains(intValue)
                    : (0..<24).contains(intValue) else
            {
                throw CronTimeErrors.invalidNumber(value)
            }
            self = .number(intValue)
        
        default:
            throw CronTimeErrors.invalidNumber(value)
        }
    }
}

/**
 * Represents a single line of a simplified Crontab file
 */
struct CronEntry {
    
    enum CronEntryErrors: Error {
        case invalidCronEntry
    }
    
    let minutes: CronTime
    let hour: CronTime
    let command: String
}

/**
 * Parse a line of a text crontab into a structure
 */
func parseLine(_ line: String) throws -> CronEntry {
    let components = line.components(separatedBy: .whitespaces)
    
    if components.count >= 3 {
        if let minutes = try? CronTime.init(type: .minute, value: components[0]),
           let hour = try? CronTime.init(type: .hour, value: components[1])
            {
            let command = components[2...].joined(separator: " ")
            return CronEntry(minutes: minutes, hour: hour, command: command)
        }
    }

    // Fallthrough
    throw CronEntry.CronEntryErrors.invalidCronEntry
}

// Read stdin and populate a crontab structure
while let line = readLine() {
    // Exit is there's a parsing failure
    guard let cronEntry = try? parseLine(line) else {
        exit(1)
    }
    
    crontab.append(cronEntry)
}

print(crontab)
