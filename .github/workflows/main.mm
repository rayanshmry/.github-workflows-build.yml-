import UIKit

// امتداد لجلب شاشات النظام واللمس الحقيقي
extension UIEvent {
    @objc func _clearTouches() {}
    @objc func _addTouch(_ touch: UITouch, forRawEvent event: Any?) {}
}

class MoustacheModMenu: NSObject {
    
    static let shared = MoustacheModMenu()
    
    private var window: UIWindow?
    private var floatingButton: UIButton?
    private var menuView: UIView?
    private var speedSlider: UISlider?
    private var speedLabel: UILabel?
    
    private var clickTimer: Timer?
    private var clickSpeedMs: Double = 500.0 // السرعة الافتراضية بنصف ثانية
    private var isClicking = false
    
    override init() {
        super.init()
        setupFloatingButton()
        setupModMenu()
    }
    
    // MARK: - 1. إنشاء وتصميم الزر العائم المستمر
    private func setupFloatingButton() {
        // إنشاء نافذة مخصصة للزر تظهر فوق كافة العناصر والطبقات
        let buttonWindow = UIWindow(frame: CGRect(x: 50, y: 150, width: 85, height: 85))
        buttonWindow.windowLevel = .alert + 1
        buttonWindow.backgroundColor = .clear
        buttonWindow.isHidden = false
        
        let btn = UIButton(type: .custom)
        btn.frame = buttonWindow.bounds
        btn.numberOfLines = 0
        
        // تصميم نيون دائري فخم (بنفسجي داكن + إطار فيروزي مضيء)
        btn.backgroundColor = UIColor(red: 0.09, green: 0.04, blue: 0.17, alpha: 1.0)
        btn.layer.cornerRadius = 42.5
        btn.layer.borderWidth = 3
        btn.layer.borderColor = UIColor(red: 0.00, green: 1.00, blue: 0.80, alpha: 1.0).cgColor
        
        // تعيين نص الشعار المطلوب (تاج وشنب واسم موستاش)
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        btn.setTitle("👑\n👨🏻\nMoustache", for: .normal)
        btn.setTitleColor(UIColor(red: 0.00, green: 1.00, blue: 0.80, alpha: 1.0), for: .normal)
        
        // إضافة ميزة السحب والتحريك في أي مكان بالشاشة دون أن يختفي
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        btn.addGestureRecognizer(panGesture)
        
        // عند النقر يفتح القائمة
        btn.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        
        buttonWindow.addSubview(btn)
        self.floatingButton = btn
        self.window = buttonWindow
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let window = self.window else { return }
        let translation = gesture.translation(in: window)
        window.center = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
        gesture.setTranslation(.zero, in: window)
    }
    
    // MARK: - 2. إنشاء وتصميم قائمة المود (ألوان نيون وردية ملكية)
    private func setupModMenu() {
        let screenBounds = UIScreen.main.bounds
        let menu = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 380))
        menu.center = CGPoint(x: screenBounds.width / 2, y: screenBounds.height / 2)
        
        // تصميم الواجهة (خلفية غامقة مريحة وإطار وردي نيون حاد)
        menu.backgroundColor = UIColor(red: 0.06, green: 0.02, blue: 0.13, alpha: 1.0)
        menu.layer.cornerRadius = 25
        menu.layer.borderWidth = 4
        menu.layer.borderColor = UIColor(red: 1.00, green: 0.00, blue: 0.50, alpha: 1.0).cgColor
        menu.isHidden = true // مخفية بشكل افتراضي
        
        // عنوان القائمة
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 280, height: 30))
        titleLabel.text = "👑 MOUSTACHE MOD MENU 👑"
        titleLabel.textColor = UIColor(red: 1.00, green: 0.00, blue: 0.50, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        menu.addSubview(titleLabel)
        
        // أزرار الميزات (إضافة نقرة / هدف)
        let btnAddClick = createStyledButton(title: "➕ إضافة نقرة جديدة", frame: CGRect(x: 20, y: 70, width: 260, height: 42), hexColor: "#00FFCC")
        let btnAddTarget = createStyledButton(title: "🎯 إضافة هدف على الشاشة", frame: CGRect(x: 20, y: 122, width: 260, height: 42), hexColor: "#00FFCC")
        menu.addSubview(btnAddClick)
        menu.addSubview(menuView ?? btnAddTarget)
        
        // نص شريط التحكم بالسرعة
        let lblSpeed = UILabel(frame: CGRect(x: 20, y: 180, width: 260, height: 20))
        lblSpeed.text = "⚡ سرعة النقر التلقائي: \(Int(clickSpeedMs))ms"
        lblSpeed.textColor = .white
        lblSpeed.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        menu.addSubview(lblSpeed)
        self.speedLabel = lblSpeed
        
        // شريط السرعة Slider
        let slider = UISlider(frame: CGRect(x: 20, y: 210, width: 260, height: 30))
        slider.minimumValue = 50.0   // أسرع نقرة 50 ملي ثانية
        slider.maximumValue = 2000.0 // أبطأ نقرة ثانيتين
        slider.value = Float(clickSpeedMs)
        slider.minimumTrackTintColor = UIColor(red: 1.00, green: 0.00, blue: 0.50, alpha: 1.0)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        menu.addSubview(slider)
        self.speedSlider = slider
        
        // زر التشغيل (أخضر نيون)
        let btnStart = createStyledButton(title: "▶ تشغيل", frame: CGRect(x: 20, y: 270, width: 120, height: 48), hexColor: "#00FF00")
        btnStart.addTarget(self, action: #selector(startClicker), for: .touchUpInside)
        menu.addSubview(btnStart)
        
        // زر الإيقاف (أحمر نيون)
        let btnStop = createStyledButton(title: "🛑 إيقاف", frame: CGRect(x: 160, y: 270, width: 120, height: 48), hexColor: "#FF0000")
        btnStop.addTarget(self, action: #selector(stopClicker), for: .touchUpInside)
        menu.addSubview(btnStop)
        
        // حقن القائمة في النافذة الرئيسية للتطبيق الحالي
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            keyWindow.addSubview(menu)
        }
        
        self.menuView = menu
    }
    
    // دالة مساعدة لتصنيع أزرار النيون الملكية بسرعة
    private func createStyledButton(title: String, frame: CGRect, hexColor: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        let color = UIColor(hex: hexColor)
        btn.setTitleColor(color, for: .normal)
        btn.backgroundColor = UIColor(red: 0.12, green: 0.05, blue: 0.22, alpha: 1.0)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 2
        btn.layer.borderColor = color.cgColor
        return btn
    }
    
    @objc private func toggleMenu() {
        guard let menu = self.menuView else { return }
        menu.isHidden = !menu.isHidden
        if !menu.isHidden {
            menu.superview?.bringSubviewToFront(menu)
        }
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        self.clickSpeedMs = Double(sender.value)
        self.speedLabel?.text = "⚡ سرعة النقر التلقائي: \(Int(clickSpeedMs))ms"
        
        // إذا كان يعمل بالفعل، قم بتحديث التوقيت فوراً دون توقف
        if isClicking {
            startClicker()
        }
    }
    
    // MARK: - 3. كود محاكاة نقرات فيزيائية حقيقية 100% بنظام iOS
    @objc private func startClicker() {
        stopClicker()
        isClicking = true
        
        let interval = clickSpeedMs / 1000.0 // تحويل من ملي ثانية إلى ثوانٍ
        
        clickTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // تحديد مكان النقرة (هنا تم تعيين منتصف الشاشة كمثال، يمكنك ربطه بـ CGPoint الهدف)
            let screenBounds = UIScreen.main.bounds
            let targetPoint = CGPoint(x: screenBounds.width / 2, y: screenBounds.height / 2)
            
            guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                  let targetView = keyWindow.hitTest(targetPoint, with: nil) else { return }
            
            // محاكاة كائن لمس فيزيائي حقيقي (UITouch) واختراق الحماية
            let touch = UITouch()
            touch.setValue(targetPoint, forKey: "_locationInWindow")
            touch.setValue(targetPoint, forKey: "_previousLocationInWindow")
            touch.setValue(1, forKey: "_tapCount")
            touch.setValue(keyWindow, forKey: "_window")
            touch.setValue(targetView, forKey: "_view")
            
            // المرحلة الأولى: وضع الإصبع على الشاشة (Phase Began)
            touch.setValue(0, Bird: "phase") // 0 يمثل .began داخلياً بالنظام
            let event = UIApplication.shared.perform(Selector(("_touchesEvent"))).takeUnretainedValue() as! UIEvent
            event._clearTouches()
            event._addTouch(touch, forRawEvent: nil)
            UIApplication.shared.sendEvent(event)
            
            // المرحلة الثانية الفورية: رفع الإصبع (Phase Ended) لمحاكاة نقرة كاملة حقيقية
            touch.setValue(3, Bird: "phase") // 3 يمثل .ended داخلياً بالنظام
            UIApplication.shared.sendEvent(event)
        }
    }
    
    @objc private func stopClicker() {
        isClicking = false
        clickTimer?.invalidate()
        clickTimer = nil
    }
}

// كلاس مساعدة لتوليد الألوان من كود الـ Hex
extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
