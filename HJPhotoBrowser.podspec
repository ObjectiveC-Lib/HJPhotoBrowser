Pod::Spec.new do |s|
  s.name            = 'HJPhotoBrowser'
  s.version         = '1.0.0'

  s.ios.deployment_target = '8.0'

  s.summary         = 'Photo Browser for photo display'
  s.homepage        = 'https://github.com/ObjectiveC-Lib/HJPhotoBrowser'
  s.source          = { :git => 'https://github.com/ObjectiveC-Lib/HJPhotoBrowser.git', :tag => s.version }
  s.license         = { :type => 'MIT', :file => 'LICENSE' }
  s.author          = { 'navy' => 'lzxy169@gmail.com' }

  s.requires_arc    = true
  s.framework       = 'MessageUI', 'QuartzCore', 'SystemConfiguration', 'MobileCoreServices', 'Security'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'HJPhotoBrowser/**/*.{h,m}'
  end

  s.dependency 'YYCategories'
  s.dependency 'SDWebImage'
  s.dependency 'SDWebImage/GIF'
  s.dependency 'SDWebImage/WebP'
  s.dependency 'DACircularProgress'
  s.dependency 'pop'

end
