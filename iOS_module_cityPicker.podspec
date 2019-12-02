Pod::Spec.new do |s|
  s.name         = "iOS_module_cityPicker"
  s.version      = "1.0.0"
  s.summary      = "幻熊分类"
  s.homepage     = "https://github.com/halobear/iOS_module_cityPicker.git"
  s.license      = "MIT"
  s.author       = { "FuYe" => "834225691@qq.com" }
  s.platform     = :ios, "8.0"
  s.swift_versions = ["4.2", "5.0"]
  s.source       = { :git => "https://github.com/halobear/iOS_module_cityPicker.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.source_files = "HBCityPicker/*.{h,m}"
  s.resources =  "HBCityPicker/HaloShop.db"
  s.dependency "ActionSheetPicker-3.0", '~> 2.2.0'
  s.dependency "FMDB"
end
