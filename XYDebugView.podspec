Pod::Spec.new do |s|
s.name         = 'XYDebugView'
s.summary      = 'The tool of UIView to Debug its frame'
s.description      = <<-DESC
XYDebugView is debug tool to draw the all views frame in device screen and show it by 2d/3d style like reveal did.
                       DESC
s.version      = '0.2.0'
s.homepage     = "https://github.com/ZhipingYang/XYDebugView"
s.license      = 'MIT'
s.authors      = { 'ZhipingYang' => 'XcodeYang@gmail.com' }
s.platform     = :ios, '8.0'
s.ios.deployment_target = '8.0'
s.source       = { :git => 'https://github.com/ZhipingYang/XYDebugView.git', :tag => s.version.to_s }

s.requires_arc = true

s.source_files = 'XYDebugView/**/*'

s.frameworks = 'UIKit'

end
