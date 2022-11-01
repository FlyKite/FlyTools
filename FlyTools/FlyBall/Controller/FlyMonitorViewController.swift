//
//  FlyMonitorViewController.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/27.
//

import UIKit

class FlyMonitorViewController: UIViewController {
    
    private let monitor: FlyMonitor = FlyMonitor()
    
    private let monitorEdgeMargin: CGFloat = 2
    
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
    }
    
    private func startUsageTimer() {
        updateMonitorUsage()
        usageTimer?.invalidate()
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMonitorUsage), userInfo: nil, repeats: true)
        usageTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func stopUsageTimer() {
        usageTimer?.invalidate()
        usageTimer = nil
    }
    
    @objc private func updateMonitorUsage() {
        usageQueue.async {
            let usage = DeviceUsage.getCurrentUsage()
            DispatchQueue.main.async {
                self.monitor.deviceUsage = usage
            }
        }
    }
    
    private func toggleMonitor() {
        view.layoutIfNeeded()
        let state = monitor.state.next
        let size = state.size
        let x = monitor.center.x > view.bounds.width / 2 ? maximumMonitorX() : minimumMonitorX()
        let y = minimumMonitorY()
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.monitor.state = state
            self.monitor.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            self.view.layoutIfNeeded()
        }
    }
    
    private var panOffset: CGPoint = .zero
    @objc private func handleMonitorPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            panOffset = pan.location(in: monitor)
        } else if pan.state == .changed {
            let location = pan.location(in: view)
            let x = min(max(location.x - panOffset.x, minimumMonitorX()), maximumMonitorX())
            let y = min(max(location.y - panOffset.y, minimumMonitorY()), maximumMonitorY())
            monitor.frame = CGRect(origin: CGPoint(x: x, y: y), size: monitor.frame.size)
        } else if pan.state == .ended || pan.state == .cancelled {
            let x = monitor.center.x > view.bounds.width / 2 ? maximumMonitorX() : minimumMonitorX()
            let y = monitor.frame.origin.y
            let targetFrame = CGRect(origin: CGPoint(x: x, y: y), size: monitor.frame.size)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.monitor.frame = targetFrame
            }
        }
    }
    
    private func minimumMonitorX() -> CGFloat {
        return max(view.safeAreaInsets.left, monitorEdgeMargin)
    }
    
    private func maximumMonitorX() -> CGFloat {
        return view.bounds.width - monitor.frame.width - max(view.safeAreaInsets.right, monitorEdgeMargin)
    }
    
    private func minimumMonitorY() -> CGFloat {
        return max(view.safeAreaInsets.top, monitorEdgeMargin)
    }
    
    private func maximumMonitorY() -> CGFloat {
        return view.bounds.height - monitor.frame.height - max(view.safeAreaInsets.bottom, monitorEdgeMargin)
    }
}

extension FlyMonitorViewController: FlyMonitorDelegate {
    func flyMonitor(_ monitor: FlyMonitor, actionButtonClick actionType: ActionType) {
        switch actionType {
        case .fileBrowser:
            let controller = FileBrowserViewController()
            let nav = UINavigationController(rootViewController: controller)
            present(nav, animated: true)
        case .toggleMonitor:
            toggleMonitor()
        default:
            break
        }
    }
}

extension FlyMonitorViewController {
    private func setupViews() {
        monitor.frame = CGRect(origin: CGPoint(x: monitorEdgeMargin, y: 150), size: monitor.state.size)
        monitor.delegate = self
        monitor.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMonitorPan)))
        
        view.addSubview(monitor)
    }
}
