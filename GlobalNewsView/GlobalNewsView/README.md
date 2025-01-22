# Document

# Support
- Native
- Banner
- LoadMore
- Refresh
- Select เปิดอ่าน WebView

# Unit Key
- ตอน initializer class GlobalNewsViewController จะมีให้ใส่ 
ตัวอย่าง
กรณี แสดง Ad
    let rootView = GlobalNewsViewController(
    showAd: true
    unitKeyBanner: "ca-app-pub-3940256099942544/2435281174",
    unitKeyNative: "ca-app-pub-3940256099942544/3986624511")
กรณี ไม่แสดง Ad
    let rootView = GlobalNewsViewController(showAd: false)


# ตั้งค่า UI ต่างๆ
## GlobalNewsUIModel
- ใช้กับพวก Header Tab กับ Content Body
var globalNewsViewBackground: UIColor! -> สี Background ทุก ViewContoller
var headerBackgroundColor: UIColor! -> สี Background Header
var buttonSelectColor: UIColor! -> สีปุ่มตอนกดสถานะ isSelect = true
var buttonNonSelectColor: UIColor! -> สีปุ่มตอนกดสถานะ isSelect = false
var buttonTitleColorNormal: UIColor!  -> สีปุ่มสี Title ตอน isSelect = true
var buttonTitleColorSelect: UIColor! -> สีปุ่มสี Title ตอน isSelect = false
var underlineColor: UIColor! -> สีเส้นต้แดงสถานะว่าแสดงหมวดไหนอยู่
var pageControlColorSelect: UIColor! -> สี PageControl หมวด Top สถานะ Select 
var pageControlColorNonSelect: UIColor! -> สี PageControl หมวด Top สถานะ Normal 

## NavView - CenterUIViewController
- NavView จะอยู่ใน CenterUIViewController

- กรณีไม่เรียกใช้ให้ระบุ init(needCustomNav: Bool = false)
ตัวอย่าง
class ViewController: CenterUIViewController {
    init(showAd: Bool, unitKeyBanner: String = "", unitKeyNative: String = "") {
        if showAd {
            AdmobViewModel.shared.adMobDataViewModel = AdMobDataViewModel(unitKeyBanner: unitKeyBanner, unitKeyNative: unitKeyNative)
        } else {
            AdmobViewModel.shared.adMobDataViewModel = AdMobDataViewModel(unitKeyBanner: "", unitKeyNative: "")
        }
        super.init()
    }
}

- กรณีเรียกใช้ให้ระบุ init(uiNavModel: CenterUIVCModel) 
class ViewController: CenterUIViewController {
    init(title: String, urlWebString: String, is_ck: Bool = false) {
        super.init(uiNavModel: CenterUIVCModel.init(
                        typeNav: .News,
                        backgroundColor: .blue,
                        fontColor: .white,
                        showDataWith: .init(imageLogo: .icNEWS,
                                            titleShow: title,
                                            imageButton: UIImage(systemName: "chevron.left")!)))
    }
}

## NavView - CenterUIVCModel
struct CenterUIVCModel {
    var typeNav: TypeNav = .none -> ถ้าเรียกใช้จำเป็นต้องระบุ Type ที่ไม่ใช่ none
    var backgroundColor: UIColor = .clear -> สี backgroundColor ของ Nav
    var fontColor: UIColor = .clear -> สี fontColor ของ ชื่อหน้า
    var pushToWhere: UIViewController? = nil -> สำหรับปุ่ม กรณีจะให้ Push ไปหน้าอื่นได้
    var showDataWith: CenterShowUI? = nil -> ข้อมูลที่ต้องการให้แสดง
}

struct CenterShowUI {
    var imageLogo: UIImage -> ภาพ Logo แสดงใน UIImageView
    var titleShow: String -> ชื่อที่ต้องการให้แสดง
    var imageButton: UIImage -> ภาพที่ต้องแสดงใน UIButton
}
