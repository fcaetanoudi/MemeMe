//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Fagner Caetano on 21/03/21.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var memedImage = UIImage()
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var imagePickedView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40),
        NSAttributedString.Key.strokeWidth : NSNumber(value: -3.0 as Float)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        imagePicker.delegate = self
        setTextFields(topTextField, "TOP")
        setTextFields(bottomTextField, "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subcribeToKeyBoardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyBoardNotifications()
    }
    
    
    
    func save(_ memedImage: UIImage) {
        if imagePickedView.image != nil && topTextField.text != nil && bottomTextField.text != nil
        {
            let top = self.topTextField.text!
            let bottom = self.bottomTextField.text!
            let image = self.imagePickedView.image!
            
            let meme = Meme(topText: top, bottomText: bottom, originalImage: image, memedImage: memedImage)
        }
    }
    
    func toolBarVisible(_ visible: Bool){
        navBar.isHidden = !visible
        toolBar.isHidden = !visible
    }
    
    
    func generateMemedImage() -> UIImage {
        
        self.toolBarVisible(false)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.toolBarVisible(true)
        
        return memedImage
        
    }
    
    @IBAction func shareMemedImage(_ sender: Any) {
        let memeToShare = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memeToShare], applicationActivities: nil)
        activityController.completionWithItemsHandler = { _, success, _, _ in
            if success {
                self.save(memeToShare)
            }
        }
        activityController.popoverPresentationController?.sourceView = self.view
        present(activityController, animated: true, completion: nil)
    }
    
}

extension MemeEditorViewController: UIImagePickerControllerDelegate {
    
    
    @IBAction func openFromGallery(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func openFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickedView.image = image
        }
        self.dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
}

extension MemeEditorViewController: UITextFieldDelegate {
    
    func setTextFields(_ textFiled: UITextField, _ text: String) {
        textFiled.delegate = self
        textFiled.text = text
        textFiled.defaultTextAttributes = memeTextAttributes
        textFiled.textAlignment = .center
        textFiled.backgroundColor = .clear
        textFiled.borderStyle = .none
        textFiled.autocapitalizationType = .allCharacters
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if topTextField.text == "" {
            topTextField.text = "TOP"
        }; if bottomTextField.text == ""{
            bottomTextField.text = "BOTTOM"
        }
        return true
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        } else {
            return
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subcribeToKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyBoardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
