//
//  FlyToolsWindow.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/27.
//

import UIKit

class FlyBallViewController: UIViewController {
    
    private let flyBall: FlyBall = FlyBall()
    
    private let flyBallEdgeMargin: CGFloat = 2
    
    private var usageTimer: Timer?
    private let usageQueue: DispatchQueue = DispatchQueue(label: "com.FlyKite.FlyTools.FBVC")
    
    override func loadView() {
        view = ContentView()
    }
    
    private class ContentView: UIView {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = super.hitTest(point, with: event)
            return view != self ? view : nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        startUsageTimer()
        getApplicationUsageOfCPU()
    }
    
    private func startUsageTimer() {
        usageTimer?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.usageQueue.async {
                self.updateFlyBallUsage()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        usageTimer = timer
    }
    
    @objc private func updateFlyBallUsage() {
        var usages: [String] = []
        switch getApplicationUsageOfCPU() {
        case let .success(usage):
            usages.append(String(format: "%.0lf%%", round(usage * 100)))
        case let .failure(error):
            print(error)
        }
        switch getApplicationUsageOfMemory() {
        case let .success(usage):
            let usageMB = Double(usage) / 1024 / 1024
            usages.append(String(format: "%.1lfM", usageMB))
        case let .failure(error):
            print(error)
        }
        DispatchQueue.main.async {
            self.flyBall.textForBallState = usages.joined(separator: "\n")
        }
    }
    
    private func getApplicationUsageOfCPU() -> Result<Double, Error> {
        var threads = thread_act_array_t(bitPattern: 32)
        var count = mach_msg_type_number_t(MemoryLayout<thread_act_array_t>.size) / 4
        let result = task_threads(mach_task_self_, &threads, &count)
        if result == KERN_SUCCESS, let threads = threads {
            var usage: Double = 0
            for index in 0 ..< Int(count) {
                var threadInfo = thread_basic_info()
                var threadInfoOutCount = THREAD_INFO_MAX
                let result2 = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threads[index], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoOutCount)
                    }
                }
                usage += Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE)
            }
            return .success(usage)
        } else {
            let message = String(cString: mach_error_string(result), encoding: .ascii) ?? "unknown error"
            return .failure(NSError(domain: "Fail to get cpu usage: \(message)", code: -9999))
        }
    }
    
    private func getApplicationUsageOfMemory() -> Result<UInt64, Error> {
        var info = task_vm_info_data_t()
        var size = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &size)
            }
        }
        
        if result == KERN_SUCCESS {
            return .success(info.phys_footprint)
        } else {
            let message = String(cString: mach_error_string(result), encoding: .ascii) ?? "unknown error"
            return .failure(NSError(domain: "Fail to get memory usage: \(message)", code: -9999))
        }
    }
    
    private func toggleFlyBall() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0) {
            switch self.flyBall.state {
            case .ball: self.flyBall.state = .expanded
            case .expanded: self.flyBall.state = .ball
            }
            let size = self.flyBall.state.size
            let x = self.flyBall.center.x > self.view.bounds.width / 2
                ? self.view.bounds.width - max(self.view.safeAreaInsets.right, self.flyBallEdgeMargin) - size.width
                : max(self.view.safeAreaInsets.left, self.flyBallEdgeMargin)
            let maxY = self.view.bounds.height - size.height - max(self.view.safeAreaInsets.bottom, self.flyBallEdgeMargin)
            let y = min(self.flyBall.frame.origin.y, maxY)
            self.flyBall.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            self.view.layoutIfNeeded()
        }
    }
    
    private var panOffset: CGPoint = .zero
    @objc private func onFlyBallPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            panOffset = pan.location(in: flyBall)
        } else if pan.state == .changed {
            let location = pan.location(in: view)
            let width = flyBall.frame.width
            let height = flyBall.frame.height
            
            let minX = max(view.safeAreaInsets.left, flyBallEdgeMargin)
            let maxX = view.bounds.width - width - max(view.safeAreaInsets.right, flyBallEdgeMargin)
            let x = min(max(location.x - panOffset.x, minX), maxX)
            
            let minY = max(view.safeAreaInsets.top, flyBallEdgeMargin)
            let maxY = view.bounds.height - height - max(view.safeAreaInsets.bottom, flyBallEdgeMargin)
            let y = min(max(location.y - panOffset.y, minY), maxY)
            
            flyBall.frame = CGRect(x: x, y: y, width: width, height: height)
        } else if pan.state == .ended || pan.state == .cancelled {
            let x = flyBall.center.x > view.bounds.width / 2
                ? view.bounds.width - max(view.safeAreaInsets.right, flyBallEdgeMargin) - flyBall.frame.width
                : max(view.safeAreaInsets.left, flyBallEdgeMargin)
            let targetFrame = CGRect(x: x, y: flyBall.frame.origin.y, width: flyBall.frame.width, height: flyBall.frame.height)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.flyBall.frame = targetFrame
            }
        }
    }
}

extension FlyBallViewController: FlyBallDelegate {
    func flyBall(_ flyBall: FlyBall, actionButtonClick actionType: ActionType) {
        switch actionType {
        case .fileBrowser:
            let controller = FileBrowserViewController()
            let nav = UINavigationController(rootViewController: controller)
            present(nav, animated: true)
        case .toggleFlyBall:
            toggleFlyBall()
        default:
            break
        }
    }
}

extension FlyBallViewController {
    private func setupViews() {
        flyBall.frame = CGRect(origin: CGPoint(x: flyBallEdgeMargin, y: 150), size: flyBall.state.size)
        flyBall.delegate = self
        flyBall.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onFlyBallPan)))
        
        view.addSubview(flyBall)
    }
}
