Pod::Spec.new do |s|
s.name                  = 'XYDebugView'
s.version               = '2.0.0'
s.summary               = 'A lightweight 2D / 3D UIKit hierarchy debugger.'
s.description           = <<-DESC
  XYDebugView helps inspect UIKit view hierarchies with 2D outlines, 3D exploded layers,
  focus controls, and an index tree browser, all from a lightweight CocoaPods package.
DESC
s.homepage              = 'https://github.com/ZhipingYang/XYDebugView'
s.license               = { :type => 'MIT', :file => 'LICENSE' }
s.authors               = { 'ZhipingYang' => 'XcodeYang@gmail.com' }
s.source                = { :git => 'https://github.com/ZhipingYang/XYDebugView.git', :tag => s.version.to_s }
s.platform              = :ios, '8.0'
s.ios.deployment_target = '8.0'
s.requires_arc          = true

s.source_files = 'XYDebugView/**/*.{h,m}'
s.public_header_files = [
  'XYDebugView/XYDebugViewManager.h',
  'XYDebugView/XYdebugConst.h'
]
s.frameworks = 'UIKit'
end
