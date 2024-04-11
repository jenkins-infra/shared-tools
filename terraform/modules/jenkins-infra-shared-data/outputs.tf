output "admin_public_ips" {
  value = {
    dduportal           = ["89.84.210.161"],
    lemeurherve         = ["176.185.227.180"],
    lemeurherve_tmp_tel = ["176.145.123.59", "37.170.86.165"],
    smerle33            = ["82.64.5.129"],
    mwaite              = ["162.142.59.220"],
  }
}

output "outbound_ips" {
  value = {
    "pkg.jenkins.io"        = ["52.202.51.185"],
    "trusted.ci.jenkins.io" = ["104.209.128.236"],
    "archives.jenkins.io"   = ["46.101.121.132", "2a03:b0c0:3:d0::9bc:d001"],
    "privatek8s.jenkins.io" = [
      "20.22.6.81",   # Outbound IPv4 of the cluster LB
      "20.65.63.127", # Outbound IPv4 of the NAT gateway "privatek8s-outbound"
    ],
    "publick8s.jenkins.io" = [
      "20.22.30.74",  # Outbound IPv4 of the cluster LB
      "20.22.30.9",   # Outbound IPv4 of the cluster LB
      "20.85.71.108", # Outbound IPv4 of the cluster LB
      "20.7.192.189", # Outbound IP of the NAT gateway "publick8s-outbound"
    ],
    "trusted.sponsorship.ci.jenkins.io" = ["172.177.128.34"],
  }
}

output "external_service_ips" {
  value = {
    "ftp-osl.osuosl.org" = ["140.211.166.134", "2605:bc80:3010::134"]
    "gpg_keyserver" = [
      "162.213.33.8", "162.213.33.9", # keyserver.ubuntu.com
    ]
  }
}
