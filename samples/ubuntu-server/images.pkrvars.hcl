images = {
  "2204-lts" = {
    core = {
      name        = "u2204s"
      description = "Ubuntu Server 22.04 LTS"

      iso_url_local  = "ubuntu-22.04.3-live-server-amd64.iso"
      iso_url_remote = "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
      iso_checksum   = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }

  "2004-lts" = {
    core = {
      name        = "u2004s"
      description = "Ubuntu Server 20.04 LTS"

      iso_url_local  = "ubuntu-20.04.4-live-server-amd64.iso"
      iso_url_remote = "https://old-releases.ubuntu.com/releases/20.04/ubuntu-20.04.4-live-server-amd64.iso"
      iso_checksum   = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }
}
