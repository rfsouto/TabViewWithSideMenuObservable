# Uso: ruby add_uitests.rb <Test1.swift> [<Test2.swift> ...]  (ficheros ya presentes en <proyecto>UITests/)
require 'xcodeproj'
name = 'TabViewWithSideMenuWithViewModel'
proj = Xcodeproj::Project.open("#{name}.xcodeproj")
app = proj.targets.find { |t| t.name == name }
ui_name = "#{name}UITests"
ui = proj.targets.find { |t| t.name == ui_name }
group = proj.main_group[ui_name] || proj.main_group.new_group(ui_name, ui_name)
unless ui
  ui = proj.new_target(:ui_test_bundle, ui_name, :ios, '17.2')
  ui.add_dependency(app)
  ui.build_configurations.each do |c|
    c.build_settings['TEST_TARGET_NAME'] = name
    c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.rfsouto.#{ui_name}"
    c.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    c.build_settings['SWIFT_VERSION'] = '5.0'
    c.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.2'
  end
end
ARGV.each do |f|
  next if group.files.any? { |r| r.path == f }
  ref = group.new_file(f)
  ui.add_file_references([ref])
end
proj.save
scheme_path = Xcodeproj::XCScheme.shared_data_dir(proj.path)
s = Xcodeproj::XCScheme.new
s.add_build_target(app)
s.add_test_target(ui)
s.set_launch_target(app)
s.save_as(proj.path, name, true)
