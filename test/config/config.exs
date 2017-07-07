# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

# config :nerves, :firmware,
#   rootfs_additions: "config/rootfs_additions",
#   fwup_conf: "config/fwup.conf"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"

network_interface = System.get_env("NERVES_NETWORK_INTERFACE") || "usb0"
key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"
test_server = System.get_env("NERVES_TEST_SERVER")
websocket_protocol = System.get_env("WEBSOCKET_PROTOCOL") || "ws"

config :bootloader,
  app: :nerves_system_test,
  init: [:nerves_runtime, :nerves_network]

config :nerves_network, :default,
  eth0: [
    ipv4_address_method: :dhcp
  ],
  usb0: [
    ipv4_address_method: :linklocal
  ]
if ssid = System.get_env("NERVES_NETWORK_SSID") do
  config :nerves_network, :default,
    wlan0: [
      ssid: ssid,
      psk: System.get_env("NERVES_NETWORK_PSK"),
      key_mgmt: String.to_atom(key_mgmt)
    ]
end

config :nerves_system_test, NervesTestServer.Socket,
  url: "#{websocket_protocol}://#{test_server}/socket/websocket"

config :nerves_system_test,
  system: Mix.Project.config[:app],
  network_interface: network_interface,
  tests: [
    {:test, :priv_dir, "test"},
    {:nerves_system_test, :priv_dir, "test"}
  ]

config :nerves_runtime, :kv,
  nerves_fw_application_part0_devpath: "/dev/mmcblk0p3",
  nerves_fw_application_part0_fstype: "ext4",
  nerves_fw_application_part0_target: "/root",
  nerves_fw_architecture: "arm",
  nerves_fw_author: "The Nerves Team",
  nerves_fw_description: Mix.Project.config[:description],
  nerves_fw_platform: "rpi0",
  nerves_fw_product: Mix.Project.config[:app],
  nerves_fw_vcs_identifier: System.get_env("NERVES_FW_VCS_IDENTIFIER"),
  nerves_fw_version: Mix.Project.config[:version]
