Pod::Spec.new do |spec|
  spec.name         = "SZLaunchAdPage"
  spec.version      = "1.0.0"
  spec.summary      = "简单易用的iOS启动页广告"

  spec.homepage     = "https://github.com/sunzhongliangde/SZLaunchAdPage"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "sunzhongliang" => "sunzhong_liang@163.com" }
  spec.social_media_url   = "https://sunzhongliangde.github.io"

  spec.platform     = :ios, "8.0"
  spec.source       = { :git => "https://github.com/sunzhongliangde/SZLaunchAdPage.git", :tag => "#{spec.version}" }

  spec.source_files  = "LaunchAdPage/*.{h,m}"
  spec.requires_arc  = true
  spec.dependency "SDWebImage"
  # spec.dependency "JSONKit", "~> 1.4"

end
