#
#  Be sure to run `pod spec lint MDWamp.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "MDWamp"
  s.version      = "2.2.5"
  s.summary      = "A client side objective-C implementation of the WebSocket subprotocol WAMP"
  s.description  = <<-DESC
MDWamp is a client side objective-C implementation of the WebSocket subprotocol [WAMP][wamp_link] (v2).  

With this library and with a server [implementation of WAMP protocol][wamp_impl] you can bring Real-time notification not only for a web app (as WebSocket was created for) but also on your mobile App, just like an inner-app Apple Push Notifcation Service, avoiding the hassle of long polling request to the server for getting new things.
                   DESC
  s.homepage     = "https://github.com/mogui/MDWamp"
  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  s.author             = { "Niko Usai" => "mogui83@gmail.com" }
  s.social_media_url   = "http://twitter.com/mogui247"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/mogui/MDWamp.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.{h,m,c}",
  s.ios.frameworks = "MobileCoreServices", "CFNetwork", "Security"
  s.osx.frameworks = "CFNetwork", "Security"
  s.library = "icucore"
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'MPMessagePack'
  s.dependency 'SocketRocket', '>= 0.5.1'
  

end
