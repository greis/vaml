Pod::Spec.new do |s|
  s.name         = "vaml"
  s.version      = "0.0.1"

  s.author = "Gabriel Reis"
  s.summary = "Layout iOS views with Haml"
  s.homepage = "https://github.com/greis/vaml-ios"
  s.license = "See LICENSE"

  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/greis/vaml.git", :tag => s.version.to_s }
  s.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.requires_arc = true
  s.dependency 'ConstraintFormatter', '~> 1.0'
end
