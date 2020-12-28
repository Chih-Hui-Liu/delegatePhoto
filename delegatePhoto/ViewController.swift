//
//  ViewController.swift
//  delegatePhoto
//
//  Created by Leo on 2020/12/15.
//

import UIKit
import CoreImage.CIFilterBuiltins
class ViewController: UIViewController {
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resizePhotoSegment: UISegmentedControl!
    @IBOutlet weak var brightUISlider: UISlider!
    @IBOutlet weak var contrastUISlider: UISlider!
    @IBOutlet weak var saturationUISlider: UISlider!
  
    let context = CIContext(options:nil)//其實在這個API內部用到了CIContext，而它就是在每次使用的使用去創建一個新的CIContext，比較影響性能因此建立一個CIcontext 重複利用不然看不太出來，或者直接手機跑就能比較名顯
    var choseControl:String = ""
    var newImage:UIImage?
    var count:CGFloat = 1 //用於鏡像
    var oneDegree = CGFloat.pi / 180//轉向使用
    var number:CGFloat = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func selectPhoto(_ sender: UIButton) {
    let controller = UIImagePickerController() //用於選擇照片使用delegate
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    @IBAction func turnRight(_ sender: UIButton) {
        imageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90 * number )//轉向使用
            number += 1//因為轉一邊因轉一次９０度因此３６０就歸０度
            if number == 4{
                number = 0
            }
       
    }
    @IBAction func mirrorChange(_ sender: UIButton) {
        count *= -1//用於鏡像每處發一次就轉向
        imageView.transform = CGAffineTransform(scaleX:count , y: 1)
    }
    @IBAction func resizePhoto(_ sender: UISegmentedControl) {
        //set default photo ratio 1:1
        let length: Int = 350 //調整比例
        var width: Int
        var height: Int
        switch sender.selectedSegmentIndex {
        case 0: //1:1
            width = length
            height = length
        case 1: //16:9
            width = length
            height = Int(Double(length) / 16 * 9)
        case 2: //4:3
            width = length
            height = Int(Double(length) / 4 * 3)
        default: //1:1
            width = length
            height = length
        }
        imageView.bounds.size = CGSize(width: width, height: height)
        //說明一下針對imageView 去做調整但不影響照片本質,畢竟手機的功能感覺會裁減到XD
    }
    @IBAction func reset(_ sender: UIButton) {
        number = 0
        count = 1
        resizePhotoSegment.selectedSegmentIndex = 0
        imageView.image = newImage
        imageView.transform = CGAffineTransform(scaleX:1 , y: 1)
        imageView.transform = CGAffineTransform(rotationAngle: oneDegree * number )
        imageView.bounds.size = CGSize(width: 350, height: 350)
        brightUISlider.value = 0
        contrastUISlider.value = 1
        saturationUISlider.value = 1
        imageView.image = newImage //另外存的照片遠始檔
        
    }
    @IBAction func saveButton(_ sender: UIButton) {
        if let image = imageView.image{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }//儲存使用
        
    }
    @IBAction func brightNess(_ sender: UISlider) {
        update(sliderValue: sender.value, number: 0)
    }
    @IBAction func contrast(_ sender: UISlider) {
        update(sliderValue: sender.value, number: 1)
    }
    @IBAction func saturation(_ sender: UISlider) {
        update(sliderValue: sender.value, number: 2)
    }
    func update(sliderValue: Float,number : Int) {//用來調整明亮度對比等
        let ciImage = CIImage(image:imageView.image! )
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey:kCIInputImageKey)
        switch number {
        case 0:
            filter?.setValue(sliderValue, forKey:kCIInputBrightnessKey)
        case 1:
            filter?.setValue(sliderValue, forKey:kCIInputContrastKey)
        default:
            filter?.setValue(sliderValue, forKey:kCIInputSaturationKey)
        }
        
        if let outputImage = filter?.outputImage,
           let cgImage = context.createCGImage(outputImage,from: outputImage.extent){//主要還是使用CIcontext功能除了外觀不會亂跑、模擬器可以比較看得出來
            let newImage = UIImage(cgImage: cgImage)
                imageView.image = newImage
        }
    }
    @IBAction func filterChange(_ sender: UIButton) {//濾鏡使用
        let ciImage = CIImage(image: imageView.image!)
        var string = ""//為了存取濾鏡名稱
        switch sender.tag {
        case 1:
            string = "CIColorMonochrome"
        case 2:
            string = "CIPhotoEffectFade"
        case 3:
            string = "CIPhotoEffectInstant"
        case 4:
            string = "CIPhotoEffectMono"
        case 5:
            string = "CIPhotoEffectNoir"
        default:
            imageView.image = newImage
        }
        let filter = CIFilter(name: string)
        filter?.setValue(ciImage, forKey:kCIInputImageKey)
        if let outputImage = filter?.outputImage,
           let cgImage = context.createCGImage(outputImage,from: outputImage.extent){
            let newImage = UIImage(cgImage: cgImage)
                imageView.image = newImage
        }
    }
//    對一張圖使用一個濾鏡效果，總結起來需要四步：
//    創建一個CIImage對象 .CImage 有很多初始化方法。譬如：CIImage(contentsOfURL:), CIImage(data:), CIImage(CGImage:), CIImage(bitmapData:bytesPerRow:size:format:colorSpace:),用的最多的是CIImage(contentsOfURL:)。
//    創建一個CIContext. CIContext 可能是基於CPU，也可能是基於GPU的。所以創建CIContext會消耗資源，影響性能，我們應該儘可能多的複用它。將處理過後的圖片數據，輸出為CIImage的時候會用到CIContext。
//    創建一個濾鏡. 創建好濾鏡後，我們需要為其設置參數。有的濾鏡要設置的參數比較多，有的濾鏡卻不需要設置參數。
//    獲取filter output. 濾鏡會輸出一個CIImage對象，用CIContext 可以將CIImage轉換為UIImage。
}

extension ViewController :UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        newImage = imageView.image //另外存一張新的用來重置使用
        imageView.contentMode = .scaleAspectFit
        dismiss(animated: true, completion: nil)
    }
    
}
