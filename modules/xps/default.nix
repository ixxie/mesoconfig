{ config, pkgs, ... }:

{
  # autogenerated hardware config
  imports = [ ./hardware-config.nix ];
  
	# Use the gummiboot efi boot loader.
	boot.loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
  };

  # enable the swap device
  swapDevices = [ { label="swap"; } ];

  # firmware support
  nixpkgs.config.allowUnfree = true; 

  hardware =
  {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  # fix various kinks
  services.xserver =
  {
    # Make right click
    desktopManager.gnome3.extraGSettingsOverrides =
    ''
      [org.gnome.desktop.peripherals.touchpad]
      click-method = 'default'
    '';
  };
  boot.blacklistedKernelModules = [
    "psmouse" # for psmouse error
    "mei_wdt" # for udev wait for device
  ];
}