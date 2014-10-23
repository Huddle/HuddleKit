Pod::Spec.new do |s|
  s.name         = 'HuddleKit'
  s.version      = '1.0.4'
  s.summary      = 'An iOS library for accessing the Huddle API.'
  s.homepage     = 'http://github.com/Huddle/HuddleKit'
  s.license      = 'MIT'
  s.author       = { "Pete O'Grady" => 'pete.ogrady@huddle.com' }
  s.source       = { :git => 'http://github.com/Huddle/HuddleKit.git', :tag => '1.0.4' }
  s.platform     = :ios, '5.0'
  s.source_files = 'HuddleKit'
  s.frameworks = 'Security'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 1.3.3'
  s.dependency 'Reachability', '~> 3.1.0'
  s.dependency 'SVProgressHUD', '~> 1.0'
  s.prefix_header_contents = <<-EOS
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Security/Security.h>
EOS
end
