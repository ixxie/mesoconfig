{ pkgs, ... }: { 

    services = {

        # Enable the X11 windowing system.

        xserver = {
        
            enable = true;
            xkbOptions = "eurosign:e";
            layout = "us";

            # Enable the Gnome Desktop Environment.

            displayManager.gdm.enable = true;
            desktopManager = {

                gnome3 = {
                            enable = true;
                };
                
            };

        };

    };

}