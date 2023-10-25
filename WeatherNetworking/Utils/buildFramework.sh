while getopts ":hv:" option; do
    case $option in
    v)
    VERSION_FOLDER=v$OPTARG
    VERSION_SUFFIX=_$OPTARG
    ;;
    h)
    echo "Generates iPhone and Simulator archives and a zipped xcframework for WeatherNetworking"
    echo
    echo "Syntax: buildFramewprk -v|h"
    echo "options:"
    echo "h     Print this Help."
    echo "v     The suffix to be added to all output files (.archive and .xcframework)"
    echo
    exit 1
    ;;
   esac
done

if [ -z "$VERSION_FOLDER" ]
then
    echo "You must specify a version (use -v)"
    exit 1
fi

BUILD_FOLDER="../../build/$VERSION_FOLDER"
echo '...delete any existing build files'
rm -r "$BUILD_FOLDER"

echo '...build the iPhone documentation'
xcodebuild docbuild \
-project ../../WeatherNetworking.xcodeproj \
-scheme WeatherNetworkingKit \
-destination 'generic/platform=iOS' \
-quiet

echo '...build the iPhone framework'
xcodebuild archive \
-project ../../WeatherNetworking.xcodeproj \
-scheme WeatherNetworkingKit \
-destination "generic/platform=iOS" \
-archivePath "$BUILD_FOLDER/WeatherNetworkingiOS$VERSION_SUFFIX" \
-quiet \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo '...build the iPhone Simulator documentation'
xcodebuild docbuild \
-project ../../WeatherNetworking.xcodeproj \
-scheme WeatherNetworkingKit \
-destination 'generic/platform=iOS Simulator' \
-quiet

echo '...build the iPhone Simulator framework'
xcodebuild archive \
-project ../../WeatherNetworking.xcodeproj \
-scheme WeatherNetworkingKit \
-destination "generic/platform=iOS Simulator" \
-archivePath "$BUILD_FOLDER/WeatherNetworkingSimulator$VERSION_SUFFIX" \
-quiet \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo '...rebuild xcframework'
xcodebuild -create-xcframework \
-archive "$BUILD_FOLDER/WeatherNetworkingSimulator$VERSION_SUFFIX.xcarchive" -framework WeatherNetworkingKit.framework \
-archive "$BUILD_FOLDER/WeatherNetworkingiOS$VERSION_SUFFIX.xcarchive" -framework WeatherNetworkingKit.framework \
-output "$BUILD_FOLDER/WeatherNetworkingKit.xcframework" \

echo '...zip up the xcframework'
ditto -c -k --sequesterRsrc --keepParent "$BUILD_FOLDER/WeatherNetworkingKit.xcframework" "$BUILD_FOLDER/WeatherNetworkingKit$VERSION_SUFFIX.xcframework.zip"

echo '...clean up'
rm -r "$BUILD_FOLDER/WeatherNetworkingKit.xcframework"

echo '...generate zip checksum:'
swift package compute-checksum "$BUILD_FOLDER/WeatherNetworkingKit$VERSION_SUFFIX.xcframework.zip"

