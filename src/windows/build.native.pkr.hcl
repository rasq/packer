locals {
  native_iso_sources = {
    virtualbox = "virtualbox-iso.core"
    vmware     = "vmware-iso.core"
    hyperv     = "hyperv-iso.core"
  }

  native_import_sources = {
    virtualbox = "virtualbox-ovf.core"
    vmware     = "vmware-vmx.core"
    hyperv     = "hyperv-vmcx.core"
  }

  native_iso          = contains(keys(local.image_options.native), "source_iso_checksum")
  downloads_directory = "${coalesce(var.userprofile_directory, var.home_directory)}/Downloads"

  source_options_native = {
    iso_urls = local.native_iso ? [
      "${local.downloads_directory}/${local.image_options.native.source_iso_url_local}",
      local.image_options.native.source_iso_url_remote
    ] : []
    iso_checksum = local.native_iso ? local.image_options.native.source_iso_checksum : ""
    cd_content = merge({
      "autounattend.xml"             = templatefile("${path.root}/boot/autounattend.xml", { boot = local.image_options.native })
      "autounattend-first-logon.ps1" = templatefile("${path.root}/boot/autounattend-first-logon.ps1", { boot = local.image_options.native })
      }, {
      for setup_script in compact([lookup(local.image_options.native, "boot_setup_script", "")]) : setup_script => file("${path.cwd}/${setup_script}")
    })

    import_directory = local.native_build ? "${path.cwd}/../${lookup(local.image_options.native, "source_image_type", "")}/artifacts/${lookup(local.image_options.native, "source_image_name", "")}/${local.image_provider}-native" : ""

    boot_command = local.native_iso ? [
      "<enter><wait><enter><wait><enter>"
    ] : []
    shutdown_command = "shutdown /s /t 10"
  }
}

build {
  name = "native-restore"

  sources = ["null.core"]

  provisioner "shell-local" {
    inline = [
      "chef install",
      "chef export ${local.artifacts_directory}/chef --force"
    ]
  }
}

locals {
  chef_destination         = "C:/Windows/Temp/chef/"
  chef_max_retries         = 10
  chef_start_retry_timeout = "30m"
}

build {
  name = "native-image"

  sources = local.native_build ? (local.native_iso ? compact([lookup(local.native_iso_sources, local.image_provider, "")]) : compact([lookup(local.native_import_sources, local.image_provider, "")])) : ["null.core"]

  provisioner "powershell" {
    script = "${path.root}/chef/initialize.ps1"

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "file" {
    source      = "${local.artifacts_directory}/chef/"
    destination = local.chef_destination
  }

  provisioner "powershell" {
    script              = "${path.root}/chef/provision.ps1"
    max_retries         = local.chef_max_retries
    pause_before        = "1m"
    start_retry_timeout = local.chef_start_retry_timeout

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "powershell" {
    script = "${path.root}/chef/cleanup.ps1"

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  post-processor "manifest" {
    output = "${local.artifacts_directory}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "${local.artifacts_directory}/checksum.{{ .ChecksumType }}"
  }
}
