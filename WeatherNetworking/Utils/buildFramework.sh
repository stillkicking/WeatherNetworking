echo '...delete the iPhone archive'
rm -r '../../archives/WeatherNetworkingiOS.xcarchive'

#echo '...build the iPhone documentation'
#xcodebuild docbuild \
#-scheme WeatherNetworkingKit \
#-destination 'generic/platform=iOS' \
#-quiet

echo '...build the iPhone framework'
xcodebuild archive \
-project ../../WeatherNetworking.xcodeproj \
-scheme WeatherNetworkingKit \
-destination "generic/platform=iOS" \
-archivePath "../../archives/WeatherNetworkingiOS" \
-quiet \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo '...delete iPhone Simulator archive'
rm -r '../../archives/WeatherNetworkingSimulator.xcarchive'

#echo '...build the iPhone Simulator documentation'
#xcodebuild docbuild \
#-scheme WeatherNetworkingKit \
#-destination 'generic/platform=iOS Simulator' \
#-quiet

echo '...build the iPhone Simulator framework'
xcodebuild archive \
-project ../../WeatherNetworking.xcodeproj \
-scheme WeatherNetworkingKit \
-destination "generic/platform=iOS Simulator" \
-archivePath "../../archives/WeatherNetworkingSimulator" \
-quiet \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo '...delete & rebuild xcframework'
rm -r '../../xcframeworks/WeatherNetworkingKit.xcframework'
xcodebuild -create-xcframework \
-archive "../../archives/WeatherNetworkingSimulator.xcarchive" -framework WeatherNetworkingKit.framework \
-archive "../../archives/WeatherNetworkingiOS.xcarchive" -framework WeatherNetworkingKit.framework \
-output "../../xcframeworks/WeatherNetworkingKit.xcframework"
