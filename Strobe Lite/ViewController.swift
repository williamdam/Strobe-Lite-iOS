//
//  ViewController.swift
//  Strobe Lite
//
//  Created by william dam on 1/27/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var frequencySlider: UISlider!
    var strobeTimer : Timer?
    var frequency = 0
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var onLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The default starting value of frequency slider and var
        frequencySlider.value = 7
        frequency = Int(frequencySlider.value)
        
        // Set style for onOffSwitch
        onOffSwitch.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        onOffSwitch.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        onOffSwitch.layer.cornerRadius = 16.0
        
        // Set visibility of onOffLabels
        onOffLabels()
        
    }

    // Highlights ON label when switch on, OFF label when switch off
    func onOffLabels() {
        if onOffSwitch.isOn {
            offLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
            onLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            offLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            onLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        }
    }
    
    // Returns time period of one toggle (on and off)
    func getToggleRate(_ frequency: Int) -> Float {
        
        // 1 second / number of toggles.  1 cycle = 2 toggles
        return 1.0/(2 * Float(frequency))
    }
    
    // Turns off led flashlight
    @objc func killTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .on {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    // Turns on or off led flashlight
    @objc func toggleTorch() {
        
        guard let device = AVCaptureDevice.default(for: .video) else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .on {
                    device.torchMode = .off
                } else {
                    device.torchMode = .on
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
        
    }

    // Changes frequency and restarts strobe if on
    @IBAction func frequencySliderMoved(_ sender: UISlider) {
        
        // Save value to var
        self.frequency = Int(sender.value)
        
        if onOffSwitch.isOn {
            strobeTimer?.invalidate()
            strobeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(getToggleRate(frequency)), target: self, selector: #selector(toggleTorch), userInfo: nil, repeats: true)
        }
        
    }
    
    // Turns on and off strobe light
    @IBAction func onOffSwitch(_ sender: UISwitch) {
        
        onOffLabels()
        
        if sender.isOn {
            strobeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(getToggleRate(frequency)), target: self, selector: #selector(toggleTorch), userInfo: nil, repeats: true)
        } else {
            strobeTimer?.invalidate()
            killTorch()
        }
        
    }
    
}

