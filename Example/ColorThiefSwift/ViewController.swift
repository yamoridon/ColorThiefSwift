//
//  ViewController.swift
//  ColorThiefSample
//
//  Created by Kazuki Ohara on 2017/02/12.
//  Copyright © 2017 Kazuki Ohara. All rights reserved.
//
//  License
//  -------
//  MIT License
//  https://github.com/orchely/ColorThiefSwift/blob/master/LICENSE

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

    @IBAction func buttonTapped(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imageView.image = image

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            guard let colors = ColorThief.getPaletteFromImage(image, colorCount: 10, quality: 1, ignoreWhite: true) else {
                return
            }
            let start = NSDate()
            guard let dominantColor = ColorThief.getColorFromImage(image) else {
                return
            }
            let elapsed = -start.timeIntervalSinceNow
            NSLog("time for getColorFromImage: \(Int(elapsed * 1000.0))ms")
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                for i in 0 ..< 9 {
                    if i < colors.count {
                        let color = colors[i]
                        self?.paletteViews[i].backgroundColor = color.toUIColor()
                        self?.paletteLabels[i].text = "getPalette[\(i)] R\(color.r) G\(color.g) B\(color.b)"
                    } else {
                        self?.paletteViews[i].backgroundColor = UIColor.whiteColor()
                        self?.paletteLabels[i].text = "-"
                    }
                }
                self?.colorView.backgroundColor = dominantColor.toUIColor()
                self?.colorLabel.text = "getColor R\(dominantColor.r) G\(dominantColor.g) B\(dominantColor.b)"

            }
        }
    }
}
