//
//  ViewController.swift
//  ColorThiefSample
//
//  Created by Kazuki Ohara on 2017/02/12.
//  Copyright © 2019 Kazuki Ohara. All rights reserved.
//
//  License
//  -------
//  MIT License
//  https://github.com/yamoridon/ColorThiefSwift/blob/master/LICENSE

import UIKit
import ColorThiefSwift

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet var paletteLabels: [UILabel]!
    @IBOutlet var paletteViews: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
        imageView.image = image

        DispatchQueue.global(qos: .default).async {
            guard let colors = ColorThief.getPalette(from: image, colorCount: 10, quality: 1, ignoreWhite: true) else {
                return
            }
            let start = Date()
            guard let dominantColor = ColorThief.getColor(from: image) else {
                return
            }
            let elapsed = -start.timeIntervalSinceNow
            NSLog("time for getColorFromImage: \(Int(elapsed * 1000.0))ms")
            DispatchQueue.main.async { [weak self] in
                for i in 0 ..< 9 {
                    if i < colors.count {
                        let color = colors[i]
                        self?.paletteViews[i].backgroundColor = color.makePlatformNativeColor()
                        self?.paletteLabels[i].text = "getPalette[\(i)] R\(color.r) G\(color.g) B\(color.b)"
                    } else {
                        self?.paletteViews[i].backgroundColor = UIColor.white
                        self?.paletteLabels[i].text = "-"
                    }
                }
                self?.colorView.backgroundColor = dominantColor.makePlatformNativeColor()
                self?.colorLabel.text = "getColor R\(dominantColor.r) G\(dominantColor.g) B\(dominantColor.b)"
            }
        }
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
