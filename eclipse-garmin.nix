{ pkgs ? import <nixpkgs> { } }:

with pkgs.eclipses; eclipseWithPlugins {
  eclipse = eclipse-platform;
  # jvmArgs = [ "-Xmx2048m" ];
  plugins = [
    plugins.jdt
    # (plugins.buildEclipsePlugin {
    #   name = "connect-iq";
    #   srcFeature = pkgs.fetchurl {
    #     url = "https://developer.garmin.com/downloads/connect-iq/eclipse/features/connectiq.feature.ide_3.2.5.jar";
    #     sha256 = "06465j8gllxx0d0mvd1cvnsq23dscn9m83pzs2k96bixk3rbgfds";
    #   };
    # })
    # (plugins.buildEclipseUpdateSite {
    #   name = "connect-iq";
    #   src = pkgs.fetchurl {
    #     url = "https://developer.garmin.com/downloads/connect-iq/eclipse/site.xml";
    #     sha256 = "06465j8gllxx0d0mvd1cvnsq23dscn9m83pzs2k96bixk3rbgfds";
    #   };
    # })
  ];
}

# Warning: Installing unsigned software for which the authenticity or validity cannot be established. Continue with the installation?
#   /home/ch1bo/.eclipse/org.eclipse.platform_4.16.0/plugins/IQ_AppSettingsEditor_3.2.5.jar
#   /home/ch1bo/.eclipse/org.eclipse.platform_4.16.0/plugins/IQ_IDE_3.2.5.jar
#   /home/ch1bo/.eclipse/org.eclipse.platform_4.16.0/plugins/IQ_PackageWizard_3.2.5.jar
#   /home/ch1bo/.eclipse/org.eclipse.platform_4.16.0/plugins/IQ_SdkManager_3.2.5.jar
#   /home/ch1bo/.eclipse/org.eclipse.platform_4.16.0/features/connectiq.feature.ide_3.2.5
#   /home/ch1bo/.eclipse/org.eclipse.platform_4.16.0/features/connectiq.feature.sdk_3.2.5
#   /home/ch1bo/.eclipse/org.eclipse.platform_4.16.0/plugins/org.eclipse.wst.sse.core_1.2.400.v202004081818.jar
