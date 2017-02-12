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
    @IBOutlet var labels: [UILabel]!

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
            let start = NSDate()
            guard let colors = ColorThief.getPaletteFromImage(image, colorCount: 10, quality: 1, ignoreWhite: true) else {
                return
            }
            let elapsed = -start.timeIntervalSinceNow
            NSLog("\(elapsed * 1000.0)ms")
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                for i in 0 ..< min(10, colors.count) {
                    let color = colors[i]
                    self?.labels[i].backgroundColor = color.toUIColor()
                    self?.labels[i].text = "#\(i + 1) r:\(color.r), green:\(color.b), blue:\(color.b)"
                }
            }
        }
    }
}
