//
//  ViewController.swift
//  See Food
//
//  Created by Александров Денис Александрович on 20.02.2020.
//  Copyright © 2020 Александров Денис Александрович. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model fail")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failt to process image")
            }
            
            if let firstResult = results.first {
                let identifire = firstResult.identifier
                
                if identifire.contains("hotdog") {
                    self.navigationItem.title = "HotDog!"
                } else {
                    self.navigationItem.title = "Not HotDog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            textLabel.isHidden = true
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert a CIImage")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

