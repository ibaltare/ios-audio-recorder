//
//  ViewController.swift
//  Sound Recorder App
//
//  Created by Nicolas on 30/04/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    //MARK: -Declarations
    var recordingSession:AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 1200, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue ]
    let sounds = ["a", "b", "c", "d"]
    @IBOutlet var buttonA: UIButton!
    @IBOutlet var buttonB: UIButton!
    @IBOutlet var buttonC: UIButton!
    @IBOutlet var buttonD: UIButton!
    
    func getDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
    }
    
    //MARK: -LifeCycle Hook
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...3 {
            let path = getDirectory().appendingPathComponent("\(i).m4a").path
            if FileManager.default.fileExists(atPath: path) {
                let button = self.view.viewWithTag(i) as? UIButton
                button?.setTitle("Play", for: .normal)
            }
        }
        
        let longPressRecognizerA = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonA.addGestureRecognizer(longPressRecognizerA)
        let longPressRecognizerB = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonB.addGestureRecognizer(longPressRecognizerB)
        let longPressRecognizerC = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonC.addGestureRecognizer(longPressRecognizerC)
        let longPressRecognizerD = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonD.addGestureRecognizer(longPressRecognizerD)
        
        recordingSession = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission { accepted in
            if accepted {
                print("permission granted")
            }
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        let button = sender.view as? UIButton
        let tag = sender.view!.tag
        
        if sender.state == .began {
            button?.setTitle("Recording...", for: .normal)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
                try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                let fileName = getDirectory().appendingPathComponent("\(String(describing: tag)).m4a")
                print("\(String(describing: tag)).m4a")
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.record()
            }catch {
                print("failed to record...")
            }
        }else if sender.state == .ended {
            button?.setTitle("Play", for: .normal)
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    //MARK: - UI functions
    @IBAction func buttonPressed(_ sender: UIButton) {
        let tag  = sender.tag
        let path = getDirectory().appendingPathComponent("\(tag).m4a").path
        if FileManager.default.fileExists(atPath: path) {
            let filePath = getDirectory().appendingPathComponent("\(tag).m4a")
            print(filePath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: filePath)
                audioPlayer.play()
            } catch {
                print("failed to play")
            }
        } else {
            let url = Bundle.main.url(forResource: sounds[sender.tag], withExtension: "mp3")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url!)
                audioPlayer.play()
            } catch {
                print("failed to play")
            }
        }
        
    }
}

