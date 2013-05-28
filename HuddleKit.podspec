Pod::Spec.new do |s|
  s.name         = 'HuddleKit'
  s.version      = '1.0.0'
  s.summary      = 'An iOS library for accessing the Huddle API.'
  s.homepage     = 'http://github.com/Huddle/HuddleKit'
  s.license      = 'MIT'
  s.author       = { "Pete O'Grady" => 'pete.ogrady@huddle.com' }
  s.source       = { :git => 'http://github.com/Huddle/HuddleKit.git', :tag => '1.0.0' }
  s.platform     = :ios, '5.0'
  s.source_files = 'HuddleKit'
  s.frameworks = 'Security'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 1.2.1'
  s.dependency 'Reachability', '~> 3.1.0'
  s.dependency 'SVProgressHUD', '~> 0.9'
end
