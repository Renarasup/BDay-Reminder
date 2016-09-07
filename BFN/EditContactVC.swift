//
//  EditContactVC.swift
//  BFN
//
//  Created by Lai, Allen on 7/24/16.
//  Copyright © 2016 Lai, Allen. All rights reserved.
//

import UIKit
import CoreData
import Photos


class EditContactVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var birthyearTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    private var profileImage: UIImage!      // needed so when its nil, it shows the defaultProfileImage
    
    var friend: Friend!

    
    // Core Data
    var managedObjectContext: NSManagedObjectContext!
    var entry: NSManagedObject! {
        didSet {
            let firstName = entry.valueForKey("firstName") as! String
            let lastName = entry.valueForKey("lastName") as! String
            let month = entry.valueForKey("month") as! Int
            let day = entry.valueForKey("day") as! Int
            let birthday = Date(month: month, day: day)
            if let year = entry.valueForKey("year") {
                birthday.year = year as? Int
            }
            
            let friend = Friend(firstName: firstName, lastName: lastName, birthdate: birthday)
            if let profilePicture = entry.valueForKey("profilePicture") {
                friend.profilePicture = profilePicture as? UIImage
            }
            
            
            if let notes = entry.valueForKey("notes") {
                friend.notes = notes as? String
            }
            self.friend = friend
            
        }
    }
    
    var bithdatePicker = PMEDatePicker()
    var birthYearPicker = PMEDatePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // make profileImage rounded
        self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2
        self.profilePictureImageView.clipsToBounds = true
        
        var back = UIImage(named: "BackButton")
        back = back?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backIndicatorImage = back
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = back
        
        notesTextView.delegate = self
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.blackColor().CGColor
        notesTextView.layer.cornerRadius = 5
        firstNameTextField.useUnderline()
        lastNameTextField.useUnderline()
        birthdateTextField.useUnderline()
        birthyearTextField.useUnderline()
        
        // set all the delegate TextFields
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        birthdateTextField.delegate = self
        birthyearTextField.delegate = self
        
        // set the formate for datepickers
        bithdatePicker.dateFormatTemplate = "MMMd"
        birthYearPicker.dateFormatTemplate = "yyyy"
        
        // done and cancel button in toolbar setup
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewBirthdayVC.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewBirthdayVC.cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        
        birthdateTextField.inputView = bithdatePicker
        birthdateTextField.inputAccessoryView = toolBar
        birthyearTextField.inputView = birthYearPicker
        birthyearTextField.inputAccessoryView = toolBar
        
        // sets the default picker to current the birthday
        if let birthYear = friend.birthdate?.year {
            let stringDate = String(friend.birthdate!.day!) + "-" + String(friend.birthdate!.month!) + "-" + String(birthYear)
            let dateformatter = NSDateFormatter()
            dateformatter.dateFormat = "dd-M-yyyy"
            let date = dateformatter.dateFromString(stringDate)
            bithdatePicker.setDate(date, animated: false)
            birthYearPicker.setDate(date, animated: false)
        } else {
            let stringDate = String(friend.birthdate!.day!) + "-" + String(friend.birthdate!.month!)
            let dateformatter = NSDateFormatter()
            dateformatter.dateFormat = "dd-M"
            let date = dateformatter.dateFromString(stringDate)
            bithdatePicker.setDate(date, animated: false)
        }

        
        firstNameTextField.becomeFirstResponder()
        
        // Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext

 
 
        if let image = friend.profilePicture {
            profilePictureImageView.image = image
        }
        if let firstName = friend.firstName {
            firstNameTextField.text = firstName
        }
        if let lastName = friend.lastName {
            lastNameTextField.text = lastName
        }
        if let month = friend.birthdate?.month, let day = friend.birthdate?.day {
            let dateString = String(month) + "/" + String(day)
            birthdateTextField.text = dateString
        }
        if let year = friend.birthdate?.year {
            birthyearTextField.text = String(year)
        }
        if let notes = friend.notes {
            notesTextView.text = notes
        }
        
        
    }
    func donePicker() {
        // update the cell's button title and record button
        
        let dateFormatter = NSDateFormatter()
        if birthdateTextField.isFirstResponder() {
            dateFormatter.dateFormat = "MMM d"
            let dateString = dateFormatter.stringFromDate(bithdatePicker.date)
            birthdateTextField.text = dateString
            
            birthyearTextField.becomeFirstResponder()
        } else if birthyearTextField.isFirstResponder() {
            dateFormatter.dateFormat = "yyyy"
            let dateString = dateFormatter.stringFromDate(birthYearPicker.date)
            birthyearTextField.text = dateString
            
            notesTextView.becomeFirstResponder()
        }
        
    }
    func cancelPicker() {
        if birthdateTextField.isFirstResponder() {
            birthdateTextField.text = ""
        } else if birthyearTextField.isFirstResponder() {
            birthyearTextField.text = ""
        }
        self.view.endEditing(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        self.view.endEditing(true)
    }
    // UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            friend.firstName = firstNameTextField.text
            lastNameTextField.becomeFirstResponder()
            return true
        }
        if textField == lastNameTextField {
            friend.lastName = lastNameTextField.text
            birthdateTextField.becomeFirstResponder()
            return true
        }
        if textField == birthdateTextField {
            //  TODO:: store the birthdate
            //friend.birthdateTextField = birthdateTextField.text
            birthyearTextField.becomeFirstResponder()
            return true
        }
        if textField == birthyearTextField {
            //  TODO:: store the birthdate
            //friend.birthdateTextField = birthdateTextField.text
            notesTextView.becomeFirstResponder()
            return true
        }
        if textField == notesTextView {
            self.view.endEditing(true)
            return true
        }
        
        
        return true
    }
    
    func alert(msg: String) {
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        
        if firstNameTextField.text == "" || birthdateTextField.text == "" {
            alert("FIRST NAME and BIRTHDAY must be filled in")
            return
        }
        
        friend.firstName = firstNameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        friend.lastName = lastNameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        friend.birthdate = Date(month: bithdatePicker.date.month(), day: bithdatePicker.date.day(), year: birthYearPicker.date.year())
        friend.profilePicture = profilePictureImageView.image
        friend.notes = notesTextView.text
        
        entry.setValue(self.friend.firstName, forKey: "firstName")
        entry.setValue(self.friend.lastName, forKey: "lastName")
        entry.setValue(self.friend.birthdate?.day, forKey: "day")
        entry.setValue(self.friend.birthdate?.month, forKey: "month")
        entry.setValue(self.friend.birthdate?.year, forKey: "year")
        entry.setValue(self.friend.profilePicture, forKey: "profilePicture")
        entry.setValue(self.friend.notes, forKey: "notes")
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("could not save \(error)")
        }
        self.view.endEditing(true)
        self.navigationController?.popToRootViewControllerAnimated(true)
    
    }
    
    
    
    func presentCamera()
    {
        // CHALLENGE: present normla image picker controller
        //              update the postImage + postImageView
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func pickProfileImage(sender: UITapGestureRecognizer) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.pickProfileImage(sender)
                })
            })
            return
        }
        
        if authorization == .Authorized {
            let controller = ImagePickerSheetController()
            
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "ActionTitle"),
                secondaryTitle: NSLocalizedString("Use this one", comment: "Action Title"),
                handler: { (_) -> () in
                    
                    self.presentCamera()
                    
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.profileImage = images[0]
                        self.profilePictureImageView.image = self.profileImage
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { (_) -> () in
                self.profileImage = nil
                self.profilePictureImageView.image = UIImage(named: "defaultProfileImage")
                }, secondaryHandler: nil))
            
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}



extension EditContactVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        self.profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profilePictureImageView.image! = self.profileImage
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}






