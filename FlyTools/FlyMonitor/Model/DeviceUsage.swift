//
//  DeviceUsage.swift
//  FlyTools
//
//  Created by FlyKite on 2022/11/1.
//

import Foundation

struct DeviceUsage {
    let cpuUsage: Double
    let memoryUsage: UInt64
    
    var formattedCPUUsage: String {
        String(format: "%.0lf%%", round(cpuUsage * 100))
    }
    
    var formattedMemoryUsage: String {
        let usageMB = Double(memoryUsage) / 1024 / 1024
        return String(format: "%.1lfM", usageMB)
    }
    
    static func getCurrentUsage() -> DeviceUsage? {
        do {
            let cpuUsage = try getApplicationUsageOfCPU()
            let memoryUsage = try getApplicationUsageOfMemory()
            return DeviceUsage(cpuUsage: cpuUsage, memoryUsage: memoryUsage)
        } catch {
            print(error)
            return nil
        }
    }
    
    private static func getApplicationUsageOfCPU() throws -> Double {
        var threads = thread_act_array_t(bitPattern: 32)
        var count = mach_msg_type_number_t(MemoryLayout<thread_act_array_t>.size) / 4
        let result = task_threads(mach_task_self_, &threads, &count)
        if result == KERN_SUCCESS, let threads = threads {
            var usage: Double = 0
            for index in 0 ..< Int(count) {
                var threadInfo = thread_basic_info()
                var threadInfoOutCount = THREAD_INFO_MAX
                let result = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threads[index], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoOutCount)
                    }
                }
                if result == KERN_SUCCESS {
                    usage += Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE)
                }
            }
            return usage
        } else {
            let message = String(cString: mach_error_string(result), encoding: .ascii) ?? "unknown error"
            throw NSError(domain: "Fail to get cpu usage: \(message)", code: -9999)
        }
    }
    
    private static func getApplicationUsageOfMemory() throws -> UInt64 {
        var info = task_vm_info_data_t()
        var size = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &size)
            }
        }
        
        if result == KERN_SUCCESS {
            return info.phys_footprint
        } else {
            let message = String(cString: mach_error_string(result), encoding: .ascii) ?? "unknown error"
            throw NSError(domain: "Fail to get memory usage: \(message)", code: -9999)
        }
    }
}
