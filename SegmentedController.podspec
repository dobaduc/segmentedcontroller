Pod::Spec.new do |s|
  s.name                =  "SegmentedController"
  s.version             =  "0.2.0"
  s.summary             =  "Segmented controller component"
  s.description         =  "Simple yet highly customizable segmented controller component written in Swift"
  s.homepage            =  "https://github.com/dobaduc/segmentedcontroller"
  s.license             =  { :type => 'MIT' }
  s.authors             =  { "Duc Doba" => "---@gmail.com" }
  s.source              =  {
                             :git => "https://github.com/dobaduc/segmentedcontroller.git",
                             :tag => "#{s.version}"
                           }
  s.source_files        = ["SegmentedController/**/*.{swift,h,xib}"]
  s.requires_arc        = true
  s.ios.deployment_target = '10.0'
end
