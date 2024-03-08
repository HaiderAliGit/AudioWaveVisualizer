//
//  CustomPlayerView.swift
//  audioDemo
//
//  Created by MacBook Pro on 07/03/2024.
//
import UIKit
import AVFoundation

class CustomPlayerView: UIViewController {
    
    var timer: Timer?
    var isPlaying = false
    var player: AVAudioPlayer?
    var waveforms: [UIView] = []
    
    
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var waveformContainerView: UIView!
    @IBOutlet weak var startTimeDuration: UILabel!
    @IBOutlet weak var totalSongDuration: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create waveform views programmatically
        createWaveformViews()
        
        // Load audio file
        if let audioPath = Bundle.main.path(forResource: "Beat110", ofType: "mp3") {
            let audioURL = URL(fileURLWithPath: audioPath)
            do {
                player = try AVAudioPlayer(contentsOf: audioURL)
                player?.prepareToPlay()
                player?.delegate = self
                
                // Set up timer for player indicator update
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePlayerIndicator), userInfo: nil, repeats: true)
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
        
        // Add tap gesture recognizer to waveformContainerView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(waveformContainerTapped(_:)))
        waveformContainerView.addGestureRecognizer(tapGesture)
        
    }
    
    func createWaveformViews() {
        let waveformWidth: CGFloat = 3.7
        let waveformSpacing: CGFloat = 5
        let waveformMaxHeight: CGFloat = 20
        let waveformMinHeight: CGFloat = 7
        
        let containerHeight = waveformContainerView.frame.height
        
        for index in 0..<39 {
            
            // Create left side waveform
            let leftWaveform = UIView()
            leftWaveform.backgroundColor = UIColor.gray
            let leftHeight = CGFloat.random(in: waveformMinHeight...waveformMaxHeight)
            let leftX = CGFloat(index) * (waveformWidth + waveformSpacing)
            let leftY = containerHeight / 2
            leftWaveform.frame = CGRect(x: leftX, y: leftY, width: waveformWidth, height: leftHeight)
            leftWaveform.layer.cornerRadius = waveformWidth / 2
            leftWaveform.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner] // Bottom corners only
            waveformContainerView.addSubview(leftWaveform)
            waveforms.append(leftWaveform)
            
            
            // Create right side waveform
            let rightWaveform = UIView()
            rightWaveform.backgroundColor = UIColor.darkGray
            let rightHeight = CGFloat.random(in: waveformMinHeight...waveformMaxHeight)
            let rightX = leftX
            let rightY = containerHeight / 2 - rightHeight
            rightWaveform.frame = CGRect(x: rightX, y: rightY, width: waveformWidth, height: rightHeight)
            rightWaveform.layer.cornerRadius = waveformWidth / 2
            rightWaveform.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top corners only
            waveformContainerView.addSubview(rightWaveform)
            waveforms.append(rightWaveform)
            
            // Add tap gesture recognizer to waveforms
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(waveformTapped(_:)))
            leftWaveform.addGestureRecognizer(tapGesture)
            leftWaveform.isUserInteractionEnabled = true
            let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(waveformTapped(_:)))
            rightWaveform.addGestureRecognizer(rightTapGesture)
            rightWaveform.isUserInteractionEnabled = true
        }
    }
    
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
        updatePlaystopButton()
    }
    
    @objc func updatePlayerIndicator() {
        guard let player = player else { return }
        let duration = player.duration
        let currentTime = player.currentTime
        
        // Update total song duration label
        totalSongDuration.text = formatTime(duration)
        
        // Update start time duration label
        startTimeDuration.text = formatTime(currentTime)
        
        let progress = Float(currentTime / duration)
        
        // Update waveform colors based on progress
        let numberOfWaveforms = waveforms.count
        let completedWaveforms = Int(progress * Float(numberOfWaveforms))
        for index in 0..<numberOfWaveforms {
            waveforms[index].backgroundColor = index < completedWaveforms ? .white : .gray
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    func updatePlaystopButton() {
        let imageName = isPlaying ? "pause_button" : "play_button"
        playPauseButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    
    @IBAction func waveformContainerTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: waveformContainerView)
        let percentage = Float(point.x / waveformContainerView.bounds.width)
        
        // Calculate the corresponding time in the song
        let songPosition = Double(percentage) * (player?.duration ?? 0.0)
        
        // Set the player's current time
        player?.currentTime = songPosition
    }
    
    @objc func waveformTapped(_ sender: UITapGestureRecognizer) {
        guard let waveformView = sender.view else { return }
        
        // Get the index of the tapped waveform
        if let index = waveforms.firstIndex(of: waveformView) {
            // Calculate the corresponding time in the song
            let songPosition = Double(index) / Double(waveforms.count) * (player?.duration ?? 0.0)
            
            // Set the player's current time
            player?.currentTime = songPosition
        }
    }
}

extension CustomPlayerView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        updatePlaystopButton()
    }
}
