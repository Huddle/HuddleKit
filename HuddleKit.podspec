Pod::Spec.new do |s|
  s.name         = 'HuddleKit'
  s.version      = '2.0'
  s.summary      = 'An iOS library for accessing the Huddle API.'
  s.homepage     = 'https://github.com/Huddle/HuddleKit'
  s.license      = 'MIT'
  s.author       = { "Pete O'Grady" => 'pete.ogrady@huddle.com' }
  s.source       = { :git => 'https://github.com/Huddle/HuddleKit.git', :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.source_files = 'HuddleKit'
  s.frameworks = 'Security'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 2.5'
end
