require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  otSDKVersion = package["otSDKVersion"]
  s.name         = "react-native-onetrust-cmp"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-onetrust-cmp
                   DESC
  s.homepage     = "https://onetrust.com"
  # brief license entry:
  s.license      = "Apache-2.0"
  s.authors      = { "OneTrust LLC" => "support@onetrust.com" }
  s.platforms    = { :ios => "10.0" }
  s.source = { :http => "file://.."}
  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "OneTrust-CMP-XCFramework", "~> #{otSDKVersion}"
end

