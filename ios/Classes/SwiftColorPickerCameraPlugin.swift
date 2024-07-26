import Flutter
import UIKit

public class SwiftColorPickerCameraPlugin: NSObject, FlutterPlugin, CameraScreenDelegate {
    
    var colorCode: String = ""

     private var pendingResult: FlutterResult?
     private var hostViewController: UIViewController?
    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "color_picker_camera", binaryMessenger: registrar.messenger())
    let instance = SwiftColorPickerCameraPlugin()
    instance.hostViewController = UIApplication.shared.delegate?.window??.rootViewController

    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if ("scan" == call.method) {

                 }
                 else if("startNewActivity"==call.method){
                
              
                    pendingResult = result
                    showMyCameraView()
                 }
                 else {
                    result("not implemented")
                }
  }
    private func showMyCameraView() {
      if #available(iOS 11.0, *) {
          let cameraViewController = CameraView()
          let navigationController = UINavigationController(rootViewController: cameraViewController)

          cameraViewController.delegate = self

          navigationController.modalPresentationStyle = .fullScreen

          hostViewController?.present(navigationController, animated: false)
        

              } else {
                  // Fallback on earlier versions
              }


          }

    func didReturnData(data: String) {

      colorCode="0xff"+data

      pendingResult?(colorCode)



              }
    
}


import Foundation
import UIKit

class AppColors {
    

    static let lightYellow = UIColor(red:229,green:166,blue:43,alpha:1)
    static let yellow      = UIColor(red:CGFloat(229.0/255.0),green:CGFloat(166.0/255.0),blue:CGFloat(43.0/255.0),alpha:CGFloat(1.0))
    static let black       = UIColor(red:20,green:20,blue:20,alpha:1)
}



import Foundation
import UIKit

class Cell_Bottom : UICollectionViewCell {
    
    var title   : UILabel!
    
    var _height : CGFloat!
    var _width  : CGFloat!
    
    
    static var identifier = "Bottom_Cell"
    static func nib() -> UINib {
        return UINib(nibName: "Cell_Bottom", bundle: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addTitle()
        self.contentView.layer.backgroundColor = UIColor.gray.cgColor.copy(alpha: 0.3)
        self.contentView.layer.cornerRadius = 7

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        title.frame = CGRect(x: 5,
                             y: contentView.frame.height*0.5-11,
                             width: contentView.frame.width-10,
                             height: 22 )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {

        self.contentView.layer.backgroundColor = UIColor.gray.cgColor.copy(alpha: 0.3)
        self.contentView.layer.cornerRadius = 7
    }
    
    
    
    func addTitle(){

        layoutIfNeeded()
        self.contentView.layoutIfNeeded()
        _width  = self.contentView.frame.width
        _height = self.contentView.frame.height

        self.title = {
            let l          = UILabel(frame: CGRect(x: 10 , y: 10, width:50,height:22) )
            l.adjustsFontSizeToFitWidth = true
            l.font         = UIFont(name: "Comic Sans MS", size: 28 )
            l.textColor    = UIColor.black
            l.text         = "Text -001"
            l.textAlignment = .center
            return l
        }()
        self.contentView.addSubview(self.title)
        self.contentView.bringSubviewToFront(self.title)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}



import UIKit
import AVFoundation
import Vision



protocol CameraScreenDelegate: class {
    func didReturnData(data: String)
}
@available(iOS 10.0, *)
@available(iOS 11.0, *)
class CameraView: UIViewController, UINavigationControllerDelegate {
        weak var delegate: CameraScreenDelegate?

    
    @IBOutlet var previewLayer : UIView!
    @IBOutlet var slider       : UISlider!
    @IBOutlet var cvSlider     : UICollectionView!
    var cvDiamonds             : UICollectionView!
    
    var captureSession         : AVCaptureSession!
    var stillImageOutput       : AVCapturePhotoOutput!
    var videoPreviewLayer      : AVCaptureVideoPreviewLayer!
    var input                  : AVCaptureDeviceInput!
    
    var backInput              : AVCaptureInput!
    var frontInput             : AVCaptureInput!
    var backCamera             : AVCaptureDevice!
    var frontCamera            : AVCaptureDevice!
    var AVPreviewLayer         : AVCaptureVideoPreviewLayer! = AVCaptureVideoPreviewLayer()
    var videoOutput            : AVCaptureVideoDataOutput!
    let photoOutput            = AVCapturePhotoOutput()
    
    let pickerController       = UIImagePickerController()
    
    var _viewColor       : UIView!
    var _viewTopBar      : UIView!
    
    var  _imageView      : UIImageView!
    var     _view        : UIView!
    var _labelColorCode  : UILabel!
    var _labelTitle      : UILabel!
    var _imageTarget     : UIImageView? = nil
    
    var _picImageTarget   : UIImageView? = nil
    var _picView         : UIImageView!
    
    var _btnScreenshot   : UIButton!
    var _btnInfo         : UIButton!
    var _btnFinalizeSS   : UIButton!
    var _labelGrade      : UILabel!
    var _bottomView      : UIView!
    var showTitle        = false
    
    var _labelBackTitle : UILabel!
    var _btnBackTopBar  : UIButton!
    var _btnBackCamera  : UIButton!

    var _hexColor : String!
    
    var _red   : CGFloat!
    var _green : CGFloat!
    var _blue  : CGFloat!
    
    var bottomTitles = ["D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var sliderImages = ["d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    
    var bottomCellColors = ["#FDFEF6","#FBFCE8","#FCFFE0","#FDFCCC","#FEFBB4","#FBFC9F","#FFF699","#FFF699","#FCF770","#FCF75E","#FCF75E","#FCF75E","#FCF75E","#FCF75E","#FCF75E"]
    var cvBottom : UICollectionView!
    
    var showingPic = false
    
    //TO CREATE IMAGE OVER --
    private var detectionOverlay : CALayer! = nil
    private var requests                    = [VNRequest]()
    private var bufferSize : CGSize         = .zero
    //    private var _rootLayer  : CALayer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appComesForeground), name: UIApplication.willEnterForegroundNotification  , object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(appGoesInBackground), name: UIApplication.didEnterBackgroundNotification, object: nil )
        
        self.view.addGestureRecognizer( UIPinchGestureRecognizer(target: self, action: #selector( pinchToZoom(_:) )) )
        
    }
    
    @objc func appComesForeground(){

//        self.navigationController?.popViewController(animated: true)
//        if(carouselGrades != nil && carouselDiamonds != nil ){
//            print("CAROUSELS ARE NOT NILL")
//            self.carouselGrades  .reloadData()
//            self.carouselDiamonds.reloadData()
//        }
        
        if ( showingPic == true ){

            self.navigationController?.popViewController(animated: true)
//            self.carouselDiamonds.removeFromSuperview()
//            self.carouselGrades.removeFromSuperview()
//            self.carouselDiamonds.delegate   = nil
//            self.carouselGrades.delegate     = nil
//            self.carouselDiamonds.dataSource = nil
//            self.carouselGrades.dataSource   = nil
//
//            self.carouselDiamonds = nil
//            self.carouselGrades   = nil
//            addCarousels()
//            self._btnScreenshot.isHidden = true
//            self._btnFinalizeSS.isHidden = false
//            self._btnInfo.isHidden       = true
        }
        
    }
    
    @objc func appGoesInBackground(){

        
        if(showingPic == true){
//            self.carouselDiamonds.removeFromSuperview()
//            self.carouselGrades.removeFromSuperview()
//            print("SHOWING PIC IS TRUE __ APP BACKGROUND")
//            self.carouselDiamonds.delegate = nil
//            self.carouselDiamonds = nil
//            self.carouselGrades   = nil
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        self.AVPreviewLayer.frame = self.previewLayer.bounds

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        addTopBar()
        addBottomButtons()
        addCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.setUpCamera()

        let tab = self.navigationController?.navigationBar
        tab?.barTintColor  = UIColor.white
        tab?.tintColor     = UIColor.black
        tab?.isHidden      = true

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        DispatchQueue.global(qos: .userInitiated).async {
            self.undoCamera()
        }
        let tab = self.navigationController?.navigationBar
        tab?.barTintColor = UIColor.black
        tab?.tintColor    = UIColor.white
    }
    
    
    func hideView (_ views: [UIView] , _ bool  : Bool ) {
        for view in views {
            view.isHidden = bool
        }
    }
    
    func addTopBar () {
        
        let width         = self.view.frame.width
        let height        = self.view.frame.height
        
        bufferSize.width  = width
        bufferSize.height = height
        
        self.AVPreviewLayer.layoutIfNeeded()
        self._picView.layoutIfNeeded()
        let plHeight = self.AVPreviewLayer.frame.height
        let plWidth  = self.AVPreviewLayer.frame.width
        
        let pvWidth  = self._picView.frame.width
        let pvHeight = self._picView.frame.height
        

        let dif = 0
        let topGap = height*0.03
        
        self._viewTopBar = {
            let v                   = UIView(frame: CGRect(x: 0 , y: topGap , width: width, height: height*0.25 ) )
            v.layer.cornerRadius  = 0
            v.layer.shadowOpacity = 0
            v.layer.backgroundColor = UIColor.darkGray.cgColor
            return v
        }()
        
        if(_imageTarget != nil ){
            _imageTarget?.removeFromSuperview()
        }
        
        self._viewColor  = {
            let v        = UIView(frame: CGRect(x: width*0.05, y: height*0.125+topGap-30, width: 60, height: 60))
            v.layer.cornerRadius    = v.frame.height/2
            v.layer.backgroundColor = UIColor.darkGray.cgColor
            return v
        }()
        
        self._labelColorCode = {
            let l          = UILabel(frame: CGRect(x: width*0.05+100 , y: height*0.125+topGap, width: width*0.50+30-11, height: 22 ) )
            l.adjustsFontSizeToFitWidth = true
            l.font         = UIFont(name: "Comic Sans MS", size: 18 )
            l.textColor    = AppColors.yellow
            return l
        }()
        
        self._btnInfo =  {
            let btn                      = UIButton(frame: CGRect(x: width-70, y: height*0.125+topGap,width: 40,height: 40) )
            if #available(iOS 13.0, *) {
                btn.setImage(UIImage(systemName: "info")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btn.tintColor                = UIColor.white
            btn.layer.backgroundColor    = AppColors.yellow.cgColor
            btn.layer.cornerRadius       = btn.frame.height/2
            btn.addTarget(self , action: #selector(showInfo), for: .touchUpInside)
            return btn
        }()
        
        self._btnFinalizeSS =  {
            let btn                      = UIButton(frame: CGRect(x: width-70, y: height*0.125+topGap, width: 40, height: 40))
//            let _resizedImage = UIImage(named: "imageSave")?.customResizeImage(CGSize(width:20,height:20 )).withRenderingMode(.alwaysTemplate)
//            btn.setImage(_resizedImage, for: .normal)
            btn.tintColor                = UIColor.white
            btn.layer.backgroundColor    = AppColors.yellow.cgColor
            btn.layer.cornerRadius       = btn.frame.height/2
            btn.addTarget(self , action: #selector(finalizeScreenshot), for: .touchUpInside)
            return btn
        }()
        
        self._labelTitle = {
            let l          = UILabel(frame: CGRect(x: width*0.05+120 , y: height*0.05-11, width: width*0.50, height: 22 ) )
            l.adjustsFontSizeToFitWidth = true
            l.font         = UIFont(name: "Comic Sans MS", size: 18 )
            l.textColor    = UIColor.black
            return l
        }()
        self.view.layoutIfNeeded()
        
        if(_picImageTarget == nil ){
               self._picImageTarget = {

                let _y          = (Int(height)/2)+dif-15
                let iv          = UIImageView(frame: CGRect(x: Int(pvWidth/2)-10, y:Int(pvHeight/2)-10  , width:200, height: 200 ) )
                iv.image?.withRenderingMode(.alwaysTemplate)
                  if #available(iOS 13.0, *) {

                 iv.image  = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
             
                iv.tintColor    = UIColor.white
                iv.tintColor    = UIColor.black
                return iv
            }()
            self._picView.addSubview(_picImageTarget!)
            self._picView.bringSubviewToFront(_picImageTarget!)
        }
        
        self._imageTarget = {
            _          = (Int(height)/2)+dif-15
            let iv          = UIImageView(frame: CGRect(x: Int(plWidth/2)-25, y:Int(plHeight/2)-10  , width: 40, height: 40 ) )
           iv.image?.withRenderingMode(.alwaysTemplate)
                  if #available(iOS 13.0, *) {

                 iv.image  = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
             
            iv.tintColor    = UIColor.black
            return iv
        }()
        
        self._btnBackCamera  = {
            let btn                      = UIButton(frame: CGRect(x: width*0.05  , y: height*0.02+topGap,width: 60,height: 60) )
            btn.imageView?.contentMode = .scaleAspectFill
            if #available(iOS 13.0, *) {
                _ = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
//            let resized = image.customResizeImage(CGSize(width: 30, height: 30 ) )
//            btn.setImage(resized, for: .normal )
            btn.tintColor                = UIColor.black
            btn.addTarget(self , action: #selector(closeController), for: .touchUpInside)
            return btn
        }()
        
        self._btnBackTopBar =   {
            let btn                      = UIButton(frame: CGRect(x: width*0.10  , y: height*0.02+topGap,width: 30,height: 40) )
            btn.imageView?.contentMode = .scaleAspectFill
            if #available(iOS 13.0, *) {
                btn.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btn.tintColor                = UIColor.black
            btn.addTarget(self , action: #selector(closeController), for: .touchUpInside)
            return btn
        }()
        
        self._labelBackTitle = {
            let l          = UILabel(frame: CGRect(x: 0 , y: 0, width: 0, height: 0 ) )
      
            return l
        }()
        
        //PREVIEW LAYER
        self.AVPreviewLayer.addSublayer(_imageTarget!.layer)
        
        self._picView.isHidden = true
        self.AVPreviewLayer.isHidden = false
        self.AVPreviewLayer.backgroundColor = UIColor.gray.cgColor
        
        self.view.addSubview(self._viewTopBar)
        self.view.bringSubviewToFront(self._viewTopBar)
        self.view.addSubview(_labelColorCode)
        self.view.bringSubviewToFront(_labelColorCode)
        self._viewTopBar.addSubview(self._viewColor)
        self._viewTopBar.bringSubviewToFront(self._viewColor)
//        self.view.addSubview(_btnInfo)
//        self.view.bringSubviewToFront(_btnInfo)
        _btnInfo.isHidden = true
        self.view.addSubview(_btnFinalizeSS)
        self.view.bringSubviewToFront(_btnFinalizeSS)
        _btnFinalizeSS.isHidden = true
        
        self.view.addSubview(self._labelTitle)
        self.view.bringSubviewToFront(self._labelTitle)
        
        // self.view.addSubview(self._btnBackTopBar)
        // self.view.bringSubviewToFront(self._btnBackTopBar)
        
        // self.view.addSubview(self._labelBackTitle)
        // self.view.bringSubviewToFront(self._labelBackTitle)
    
        // self.view.addSubview(self._btnBackCamera)
        // self.view.bringSubviewToFront(self._btnBackCamera)
        
        hideView([self._viewColor,self._viewTopBar,self._labelTitle,self._labelColorCode,_labelBackTitle,_btnBackTopBar] , false )
        
    }
    
    func addCollectionView () {
        let _width = self.view.frame.width
        let _height = self.view.frame.height
        
        self._labelGrade = {
            let l           = UILabel(frame: CGRect(x: _width*0.25 , y: _height*0.85-11, width: _width*0.50, height: 22 ) )
            l.adjustsFontSizeToFitWidth = true
            l.font          = UIFont(name: "Comic Sans MS", size: 18 )
            l.textColor     = AppColors.yellow
            l.textAlignment = .center
            return l
        }()
        
        self._bottomView = {
            let v = UIView(frame: CGRect(x:0,y:_height*0.82,width:_width,height:_height*0.18))
            v.layer.backgroundColor = UIColor.white.cgColor
            return v
        }()
        
//        self.cvDiamonds = {
//            let _flowLayout = UICollectionViewFlowLayout()
//            _flowLayout.scrollDirection     = .horizontal
//            _flowLayout.estimatedItemSize   = .zero
//            let cv = UICollectionView(frame: CGRect(x: 0  , y: self.view.frame.height*0.30 , width: self.view.frame.width , height: self.view.frame.height*0.12) , collectionViewLayout: _flowLayout )
//            return cv
//        }()
//
//        self.cvBottom = {
//            let _flowLayout = UICollectionViewFlowLayout()
//            _flowLayout.scrollDirection     = .horizontal
//            _flowLayout.estimatedItemSize   = .zero
//            let cv = UICollectionView(frame: CGRect(x: 0  , y: self.view.frame.height*0.88 , width: self.view.frame.width , height: self.view.frame.height*0.12) , collectionViewLayout: _flowLayout )
//            return cv
//        }()
        
//        //Carousels --
//
//        self.carouselDiamonds = {
//            let c  = iCarousel(frame: CGRect(x:0,y: _height*0.30 ,width: self.view.frame.width,height:80 ) )
//            c.type = .cylinder
//            return c
//        }()
//
//        self.carouselGrades = {
//            let c  = iCarousel(frame: CGRect(x:0,y:self.view.frame.height*0.86,width:self.view.frame.width,height: self.view.frame.height*0.12) )
//            c.type = .coverFlow
//            return c
//        }()
//
//        self.carouselDiamonds.dataSource = self
//        self.carouselGrades.dataSource   = self
//
//        self.carouselDiamonds.delegate   = self
//        self.carouselGrades.delegate     = self

//        self.carouselDiamonds.isScrollEnabled = false
//
        
        
//
//        self._bottomView.addSubview(carouselGrades)
//        self._bottomView.bringSubviewToFront(carouselGrades)
//
//        carouselGrades.frame = CGRect(x: 0, y: self._bottomView.frame.height*0.3, width: self._bottomView.frame.width , height: self._bottomView.frame.height*0.60 )
////        self.view.addSubview(carouselGrades  )
//        self.view.addSubview(carouselDiamonds)
////        self.view.bringSubviewToFront(carouselGrades  )
//        self.view.bringSubviewToFront(carouselDiamonds)
//
//        carouselDiamonds.isHidden = true
//        carouselGrades  .isHidden = true
//        setUpCarousels()
        //---
        
//        addCarousels()
        
//        self.cvBottom.delegate   = self
//        self.cvBottom.dataSource = self
//        self.cvBottom.layer.backgroundColor = UIColor.white.cgColor.copy(alpha: 0.2)
//        self.cvBottom.isHidden   = false
//        self.cvBottom.register(Cell_Bottom.self, forCellWithReuseIdentifier: Cell_Bottom.identifier)
        
        self.view.addSubview(_bottomView)
//        self.view.addSubview(cvBottom)
//        self.view.bringSubviewToFront(cvBottom)
        self.view.addSubview(_labelGrade)
        self.view.bringSubviewToFront(_labelGrade)
//        self.view.addSubview(cvDiamonds)
//        self.view.bringSubviewToFront(cvDiamonds)
        
//        cvBottom.isHidden       = true
        _labelGrade.isHidden    = true
        _bottomView.isHidden    = true
        
        //COLLECTION VIEW SLIDER
//        cvSlider.delegate     = self
//        cvSlider.dataSource   = self
//        cvSlider.layer.backgroundColor   = UIColor.gray.cgColor.copy(alpha: 0)
//        cvSlider.showsHorizontalScrollIndicator = false
//        cvSlider.isUserInteractionEnabled       = false
//        cvBottom.isUserInteractionEnabled       = false
//        cvDiamonds.layer.backgroundColor = UIColor.white.cgColor
//        cvDiamonds.isHidden = true
        
//        print("----- SLIDER CELL IDENTIFIER --- \(SliderCell.identifier)")
//        cvSlider.register(SliderCell.self, forCellWithReuseIdentifier: SliderCell.identifier )
//        cvDiamonds.register(SliderCell.self, forCellWithReuseIdentifier: SliderCell.identifier )
        
        //SLIDER
//        slider.minimumValue = 1
//        slider.maximumValue = Float(bottomTitles.count)
//        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0)
//        slider.minimumTrackTintColor = UIColor.white.withAlphaComponent(0)
//        let _resizedImage = UIImage(named: "frame")!.customResizeImage(CGSize(width: _width/2, height: _height*0.12))
//
//        slider.setThumbImage(_resizedImage , for: .normal )
//        slider.setThumbImage(_resizedImage , for: .highlighted )
//
//        let _rect = CGRect(x: 0 , y: 0, width: _width/2, height: _height*0.12)
//        slider.thumbRect(forBounds: _rect , trackRect: _rect, value: slider.value )
//
//
//        cvSlider.isHidden   = true
//        slider  .isHidden   = true
//
//        self.view.bringSubviewToFront( slider )
//        self.view.bringSubviewToFront( cvSlider )
        
    }
    
    func addCarousels () {
        let _width  = self.view.frame.width
        let _height = self.view.frame.height
    }
    
    @IBAction func sliderTip(_ sender : UISlider){
        
        slider.value = roundf(slider.value)

        let ip = IndexPath(item: Int(round(sender.value)), section: 0 )
        cvSlider.scrollToItem(at: ip , at: .centeredHorizontally , animated: true )
        cvBottom.scrollToItem(at: ip , at: .centeredHorizontally , animated: true )
    }
    
    
    func addBottomButtons(){
        
        let width   = self.view.frame.width
        let height  = self.view.frame.height
        self._btnScreenshot = {
        let marginBottom: CGFloat = 30  // Adjust this value to set the desired margin
        let btn = UIButton(frame: CGRect(x: (width * 0.50) - 35, y: (height * 0.90) - 30 - marginBottom, width: 80, height: 80))
            btn.addTarget(self, action: #selector(btnCapturePhoto), for: .touchUpInside)
            btn.backgroundColor = .white
            btn.layer.cornerRadius = 40  // Half of the width/height to make it circular
            btn.layer.masksToBounds = true  // To ensure the corners are clipped   
            return btn
        }()
        self.view.addSubview(self._btnScreenshot)
        self.view.bringSubviewToFront(self._btnScreenshot)
    }

    
    @objc func closeController(){

        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showInfo(){
        
        let _message = """
        1-Clean The Diamond and camera lens.
        
        2.)Use a neutral, dull ,white background and daylight equivalent-light in a darkened room.

        3.)Place the diamond face-down on the grading surface.

        4.) Point the color detection outline towards the entire pavilion avoiding dark and bright areas.

        Beware: Brightness, fire, and scintillation can affect a diamonds color. This color detection app is only approximate for colorless to light yellow diamonds. Diamonds should be graded in person by a Graduate Gemologist.
        
        """
        showAlertWith(title: "Camera Instructions", message: _message )
    }
    
    @objc func btnCapturePhoto () {

        
        
        self.delegate?.didReturnData(data:  self._hexColor!)

        self.dismiss(animated: false, completion: nil)

        
        hideView([self._viewColor,self._viewTopBar,self._labelTitle,self._labelColorCode,_labelBackTitle,_btnBackTopBar] , false )
        hideView([self._btnBackCamera], true )
        showingPic                   = true
//        self._picView.isHidden       = false
        self._labelTitle.isHidden    = true
//        self._classifyTitle(_red*255,_green*255,_blue*255)
//        //        self.cvBottom.isHidden       = false
        self._bottomView.isHidden    = false
        self.captureSession.stopRunning()
        self._btnInfo.isHidden       = true
        self._btnFinalizeSS.isHidden = false
//
//        //        self.undoCamera()
//
        self._labelGrade.isHidden        = false
        self._labelGrade.text = "Colorless"
//        self.carouselDiamonds.isHidden   = false
////        self.carouselGrades  .isHidden   = false
////        self.view.bringSubviewToFront( self.carouselGrades )
////        self.view.insertSubview(_btnScreenshot, belowSubview: _bottomView )
////        self.view.insertSubview(_btnInfo      , belowSubview: _btnFinalizeSS )
//
//        self._btnScreenshot.isHidden   = true
//
//
//        //        cvSlider.isHidden   = false
//        //        slider  .isHidden   = false
//        //ANIMATE INFO BUTTON - ADD CAPTURE BUTTON
//        //        UIView.animate(withDuration: 0.25){
//        //            self._btnInfo.transform = self._btnInfo.transform.translatedBy(x: 1, y: 0)
//        //        }
//        //
//
    }
    
    
    @objc func finalizeScreenshot(){
        
       
        showingPic                     = false

        takeScreenshot()
        
        hideView([self._viewColor,self._viewTopBar,self._labelTitle,self._labelColorCode,_labelBackTitle,_btnBackTopBar] , true)
        hideView([self._btnBackCamera], false )
        self.captureSession.startRunning()
        self._picView.isHidden         = true
//        self.cvBottom.isHidden         = true
        self._bottomView.isHidden      = false
        self._btnScreenshot.isHidden   = false
//        self._btnInfo.isHidden         = false
        self._btnFinalizeSS.isHidden   = false
        self._labelGrade.isHidden      = true
        self._picView.isHidden         = true
        self._labelTitle.isHidden      = true
//        cvSlider.isHidden              = true
//        slider  .isHidden              = true
//        self.carouselDiamonds.isHidden = true
//        self.carouselGrades.isHidden   = true
        
    }
    @objc func takeScreenshot(){
        //
        //        self._picView.isHidden    = false
        //        self._labelTitle.isHidden = false
        //        self._classifyTitle(_red*255, _green*255, _blue*255 )
        //DOING IN OTHER FUNC
        
        //        let settings         = AVCapturePhotoSettings()
        ////        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        //
        //        let previewFormat = [
        //                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
        //                kCVPixelBufferWidthKey as String: 160,
        //                kCVPixelBufferHeightKey as String: 160
        //            ]
        //        settings.previewPhotoFormat =  previewFormat
        self._picView.isHidden       = false

        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)) , nil)
        UIGraphicsEndImageContext()
        
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert )
        ac.addAction(UIAlertAction(title: "OKAY", style: .default))
        present(ac, animated: true)
    }
    func setColorGrade(_ val : String){
        switch (val){
        case "D","E","F":
            _labelGrade.text = "Colorless"

            break;
        case "G","H","I","J":
            _labelGrade.text = "Near Colorless"

            break;
        case "K","L","M":
            _labelGrade.text = "Faint"

            break;
        case "N","O","P","Q","R":
            _labelGrade.text = "Very Light"

            break;
        case "S","T","U","V","W","X","Y","Z":
            _labelGrade.text = "Light"

            break;
        default:

            break;
        }
    }
    
}

//Mark:- Setting Up Camera .
@available(iOS 11.0, *)
extension CameraView : AVCaptureVideoDataOutputSampleBufferDelegate , AVCapturePhotoCaptureDelegate {
    
    
    @objc func pinchToZoom(_ sender: UIPinchGestureRecognizer) {


        guard let device = self.backCamera else { return }

            if sender.state == .changed {

//                let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
                let maxZoomFactor = CGFloat(7.0)
                let pinchVelocityDividerFactor: CGFloat = 10.0

                do {

                    try device.lockForConfiguration()
                    defer { device.unlockForConfiguration() }

                    let desiredZoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchVelocityDividerFactor )
                    device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))

                } catch {
                    print(error)
                }
            }
        }
   

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage    : CIImage       = CIImage(cvPixelBuffer: imageBuffer)
        //        let im = UIImage(ciImage: ciimage)
        let im = UIImage(ciImage: ciimage)
        //        let r = UIGraphicsImageRenderer(size:
        //            CGSize(width: im.size.height, height: im.size.width))
        //        let outim = r.image { _ in
        //            let con = UIGraphicsGetCurrentContext()!
        //            con.translateBy(x: 0, y: im.size.width)
        //            con.rotate(by: -.pi/2)
        //            im.draw(at: .zero)
        //         }
        //        self._captureOutputForVN(didOutput: sampleBuffer) // ---> CAPTURE OUTPUT FOR VISION ..
        DispatchQueue.main.async {
            if(self._picView != nil ){
                self._picView.image = im
            }
            let color = self._exportColor(ciimage)
            self._viewColor.layer.backgroundColor  = color?.cgColor
            self._red   = color!.redValue
            self._green = color!.greenValue
            self._blue  = color!.greenValue
            //            guard let _color = color! else {return}
            self._labelColorCode.text = "RGB : \(Int(color!.redValue*255)),\(Int(color!.greenValue*255)),\(Int(color!.blueValue*255))"
            
         

            self._hexColor = String(format:"%02X", Int(color!.redValue*255)) + String(format:"%02X", Int(color!.greenValue*255)) + String(format:"%02X", Int(color!.blueValue*255))
            
        }
    }
    func _exportColor(_ image : CIImage) -> UIColor?{
        
        let inputImage = image.cropped(to: CGRect(x: image.extent.size.width/2-5, y: image.extent.size.height/2-5 , width: 10, height: 10))
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil  }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    func _classifyTitle(_ red:CGFloat, _ green: CGFloat ,_ blue: CGFloat ){
        
    
        //VERSION - 02
        if (red >= 155 && red<=200 && green>=155 && green<=205 && blue>=150 && blue<=200 ){//NEAR COLORLESS
            self._labelTitle.text = "Near ColorLess"
        }else if (red >= 190 && red<=200 && green>=190 && green<=210 && blue>=195 && blue<=210){//COLORLESS
            self._labelTitle.text = "ColorLess"
        }else if (red >= 100 && red<=200 && green>=90 && green<=175 && blue>=70 && blue<=200){//LIGHT
            self._labelTitle.text = "Light"
        }else if (red >= 190 && red<=210 && green>=190 && green<=210 && blue>=170 && blue<=200) {//FAINT
            self._labelTitle.text = "Faint"
        }else if (red >= 220 && green>=220 && blue>=80 && blue<=135) {//FANCY
            self._labelTitle.text = "Fancy"
        }else if ( red >= 235 && green>=234  && blue>=136 ) {//VERY LIGHT YELLOW
            self._labelTitle.text = "Very Light Yellow"
        }else {
            self._labelTitle.text = "Unknown"
        }
        
    }
    func setupOutput(){
        
        self.videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        let videoQueue   = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("could not add video output")
        }
        
        if self.captureSession.canAddOutput(self.photoOutput) {
            self.captureSession.addOutput(self.photoOutput)
            self.photoOutput.isHighResolutionCaptureEnabled = true
        }
        
    }
    func setUpCamera(){
        
        //PIC VIEW
        self._picView = {
            let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height) )
            iv.backgroundColor = UIColor.gray
            iv.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
            return iv
        }()
        //--PIC VIEW
        
        self.captureSession = AVCaptureSession()
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = .vga640x480
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            self.backCamera = device
        } else {fatalError("no back camera")}
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("could not create input device from back camera")
        }
        self.backInput = bInput
        if !captureSession.canAddInput(backInput) {
            fatalError("could not add back camera input to capture session")
        }
        captureSession.addInput(backInput)
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            self.AVPreviewLayer                 = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.AVPreviewLayer.videoGravity    = .resizeAspectFill
            self.AVPreviewLayer.contentsGravity = .resizeAspectFill
            self.AVPreviewLayer.frame           = self.view.bounds
            self.view.layer.addSublayer(self.AVPreviewLayer)
            
            self._picView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(self._picView)
            self.AVPreviewLayer.isHidden = false
            
        }
        setupOutput()
        self.captureSession.commitConfiguration()
        self.captureSession.startRunning()
    }
    func undoCamera(){
        if (captureSession != nil ){
            self.captureSession.stopRunning()
            self.captureSession.beginConfiguration()
            if(videoOutput != nil ){ self.captureSession.removeOutput(self.videoOutput) }
            self.videoOutput = nil
            if ( photoOutput != nil ){ self.captureSession.removeOutput(self.photoOutput) }
            self.captureSession.removeInput(backInput)
            self.backInput = nil
            self.captureSession.commitConfiguration()
            self.captureSession = nil
        }
    }
}

//MARK:- FOR VISION LIBRARY --
@available(iOS 11.0, *)
extension CameraView {
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil

        guard let modelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") else {

            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        if #available(iOS 12.0, *) {
                            self.drawVisionRequestResults(results)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        return error
    }
    
    @available(iOS 12.0, *)
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()

        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        if #available(iOS 12.0, *) {
            for observation in results where observation is VNRecognizedObjectObservation {
                if #available(iOS 12.0, *) {
                    guard let objectObservation = observation as? VNRecognizedObjectObservation else {

                        continue
                    }
                    let topLabelObservation = objectObservation.labels[0]
                    let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
                    let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
                    
                    let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                                    identifier: topLabelObservation.identifier,
                                                                    confidence: topLabelObservation.confidence)
                    shapeLayer.addSublayer(textLayer)
                    detectionOverlay.addSublayer(shapeLayer)
                } else {
                    // Fallback on earlier versions
                }
                // Select only the label with the highest confidence.
//                let topLabelObservation = objectObservation.labels[0]
//                let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
//
//                let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
//
//                let textLayer = self.createTextSubLayerInBounds(objectBounds,
//                                                                identifier: topLabelObservation.identifier,
//                                                                confidence: topLabelObservation.confidence)
//                shapeLayer.addSublayer(textLayer)
//                detectionOverlay.addSublayer(shapeLayer)
            }
        } else {
            // Fallback on earlier versions
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
    
    func _captureOutputForVN( didOutput sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    
    func setupLayers() {
        

        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        
        //        detectionOverlay.backgroundColor = UIColor.gray.cgColor
        
        detectionOverlay.position = CGPoint(x: AVPreviewLayer.bounds.midX, y: AVPreviewLayer.bounds.midY)
        self.AVPreviewLayer.addSublayer(detectionOverlay)
        //        addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = self.AVPreviewLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        

        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
        
    }
    
}

//MARK:- COLLECTION VIEW DELEGATES
@available(iOS 11.0, *)
extension CameraView : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == cvBottom ){
            return bottomTitles.count
        }else if (collectionView == cvSlider ){
            return sliderImages.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if ( collectionView == cvBottom ){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell_Bottom.identifier, for: indexPath) as! Cell_Bottom
            cell.title.text = bottomTitles[indexPath.row]
            cell.contentView.layer.backgroundColor = UIColor(named: "#FCF75E")?.cgColor
//            if ( indexPath.row < bottomCellColors.count ) {
//                cell.contentView.layer.backgroundColor = UIColor().hexStringToUIColor(hex: bottomCellColors[indexPath.row]).cgColor
//            }else {
//                cell.contentView.layer.backgroundColor = UIColor().hexStringToUIColor(hex: "#FCF75E").cgColor
//            }
            return cell
        }else if ( collectionView == cvSlider) {

            let sliderCell = collectionView.dequeueReusableCell(withReuseIdentifier: SliderCell.identifier , for: indexPath) as! SliderCell
            let _imageName = sliderImages[indexPath.row]

            sliderCell._setImage( UIImage(named: _imageName )! )
            return sliderCell

        }else if ( collectionView == cvDiamonds ) {

            let sliderCell = collectionView.dequeueReusableCell(withReuseIdentifier: SliderCell.identifier , for: indexPath) as! SliderCell
            let _imageName = sliderImages[indexPath.row]

            //            sliderCell.contentView.backgroundColor = UIColor.yellow
            //            sliderCell.contentView.layer.backgroundColor = UIColor.yellow.cgColor
            sliderCell._setImage( UIImage(named: _imageName )! )
            return sliderCell

        }else {
            return UICollectionViewCell()
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let _width  = collectionView.frame.width
        let _height = collectionView.frame.height
        if(collectionView == cvBottom){
            return  CGSize(width: _width/3 , height: _height*0.9 )
        }else if ( collectionView == cvSlider ){
            return  CGSize(width: _width/8 , height: _height )
        }else if ( collectionView == cvDiamonds ){
            return  CGSize(width: _width/6 , height: _height )
        }else {
            return  CGSize(width: _width/3 , height: _height*0.9 )
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (collectionView == cvSlider ){
            return 15
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if( collectionView == cvBottom ){
            setColorGrade(bottomTitles[indexPath.row])
        }else if ( collectionView == cvSlider ){

        }else {
            
        }
        
     
    }
     


////MARK:- Carousel Delegates
//extension CameraView : iCarouselDataSource ,iCarouselDelegate{
//
//    func setUpCarousels () {
//        _labelGrade.text = "Colorless"
//        carouselGrades.contentOffset   = CGSize(width: 10, height: 10)
//        carouselDiamonds.contentOffset = CGSize(width: 10, height: 10)
//    }
//
//
//
//    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
//        switch (option){
//        case .spacing :
//            if (carousel == carouselDiamonds){
//                print("SPACING VALUE OF DIAMONDS\(value)")
//                return 1.1
//            }else if (carousel == carouselGrades ){
//                return 1.1
//            }else {
//                return value
//            }
//        case .visibleItems :
//            if (carousel == carouselGrades){
//                return 7
//            }else if ( carousel == carouselDiamonds ){
//                return 7
//            }else {
//                return value
//            }
//        case .angle :
//            if (carousel == carouselDiamonds ){
//                print("ANGLE VALUE OF DIAMONDS \(value)")
//            }
//            if (carousel == carouselGrades){
//                return value
//            }
//            return value
//
//        default:
//            return value
//        }
//    }
////
//    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
//
//        if (carousel == carouselDiamonds ) {
//
//        }else if ( carousel == carouselGrades ) {
//            let index = carousel.currentItemIndex
//            carouselDiamonds.scrollToItem(at: index , duration: 0.25 )
//            print(" -- Item Index Change \(index) -- ")
//            setColorGrade(bottomTitles[index])
//        }else {
//
//        }
//
//    }
//
//    func numberOfItems(in carousel: iCarousel) -> Int {
//
//        if (carousel == carouselDiamonds ) {
//            return sliderImages.count
//        }else if ( carousel == carouselGrades ) {
//            return bottomTitles.count
//        }else {
//            return 4
//        }
//
//    }
//
//    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
//
//        if (carousel == carouselDiamonds ) {
//
//            let cWidth       = carousel.frame.width
//            let cHeight      = carousel.frame.height
//            let view         = UIView(frame: CGRect(x: 0 , y: 0 , width: cWidth/4 , height: cHeight ) )
//            let _imageView   = UIImageView(frame: CGRect(x: 0, y: 0 , width: cWidth/4 , height: cHeight ))
//            view.addSubview(_imageView)
//            let _imageName   = sliderImages[index]
//            _imageView.image = UIImage(named: _imageName)
//            return view
//        }else if ( carousel == carouselGrades ) {
//            let cWidth  = carousel.frame.width
//            let cHeight = carousel.frame.height
//            let view    = UIView( frame: CGRect(x: 0 , y: 0 , width: cWidth/8 , height: cHeight ) )
//            let _title  = UILabel( frame: CGRect(x: 0 , y: cHeight/2-11 , width: cWidth/8 , height: 22 ) )
//            _title.textAlignment = .center
//            _title.font          = UIFont(name:"System",size:25)
//            _title.text          = bottomTitles[index]
//            _title.textColor     = UIColor.black
//            view.layer.borderWidth     = 1
//            view.layer.borderColor     = UIColor.black.cgColor
//            view.layer.backgroundColor = UIColor.white.cgColor
//            view.addSubview(_title)
//            return view
//        }else {
//            let view = UIView(frame: CGRect(x: 0 , y: 0 , width: 200 , height: 200 ) )
//            return view
//        }
//
//    }
//
//
//}

//MARK:- Slider Collection View Cell

class SliderCell : UICollectionViewCell {
    
    static var identifier : String = "Slider_Cell"
    var _image : UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addImage()
    }
    
    func _setImage( _ img : UIImage ){
        self._image.image = img
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _image.frame = CGRect(x: 0,
                              y: 0,
                              width: contentView.frame.width,
                              height: contentView.frame.height )
    }
    
    private func addImage(){
        _image = {
            let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 10 , height: 10 ))
            return image
        }()
        self.contentView.addSubview( _image )
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SliderCell2 : UICollectionViewCell {
    
    static var identifier : String = "Slider_Cell2"
    
    @IBOutlet var _image : UIImageView!
    
    func _setImage( _ img : UIImage ){
        self._image.image = img
    }
    
}

@IBDesignable
class CustomSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat     = 20
    @IBInspectable var trachWidth : CGFloat     = 20
    @IBInspectable var thumbWidth : Float       = 52
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: trackHeight))
    }
    
    
    lazy var startingOffset: Float = 0 - (thumbWidth / 2)
    lazy var endingOffset  : Float = thumbWidth
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let xTranslation =  startingOffset + (minimumValue + endingOffset) / maximumValue * value
        return super.thumbRect(forBounds: bounds, trackRect: rect.applying(CGAffineTransform(translationX: CGFloat(xTranslation), y: 0)), value: value)
    }
}

    }
//
//  AppExtensions.swift
//  JAG_App
//
//  Created by Saqib  on 08/03/2021.
//  Copyright © 2021 Saqib. All rights reserved.
//

import Foundation
import UIKit


class AppExtension{
    
}

extension UIViewController{
    
    
}

extension UIImage {
    
   func customResizeImage(_ size : CGSize)->UIImage{
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect( origin: .zero , size: size ) )
        let resizedImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
    var averageColor : UIColor? {
        guard let _Image = CIImage(image: self) else { return nil }
        let inputImage = _Image.cropped(to: CGRect(x: _Image.extent.size.width/2-5, y: _Image.extent.size.height/2-5, width: 10, height: 10))
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
//        let extentVector = CIVector(x: inputImage.extent.size.width/2-5, y: inputImage.extent.size.height/2-5, z: 10 , w: 10)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}


extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public convenience init?(hex: String) {
            let r, g, b, a: CGFloat

            if hex.hasPrefix("#") {
                let start = hex.index(hex.startIndex, offsetBy: 1)
                let hexColor = String(hex[start...])

                if hexColor.count == 8 {
                    let scanner = Scanner(string: hexColor)
                    var hexNumber: UInt64 = 0

                    if scanner.scanHexInt64(&hexNumber) {
                        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                        a = CGFloat(hexNumber & 0x000000ff) / 255

                        self.init(red: r, green: g, blue: b, alpha: a)
                        return
                    }
                }
            }

            return nil
        }
    
//    public convenience init?(hex2: String){
//            return hexStringToUIColor(hex: hex2)
//        }
}


extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            guard let currentAttributedPlaceholderColor = attributedPlaceholder?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as? UIColor else { return UIColor.clear }
            return currentAttributedPlaceholderColor
        }
        set {
            guard let currentAttributedString = attributedPlaceholder else { return }
            let attributes = [NSAttributedString.Key.foregroundColor : newValue]
            
            attributedPlaceholder = NSAttributedString(string: currentAttributedString.string, attributes: attributes)
        }
    }
}
