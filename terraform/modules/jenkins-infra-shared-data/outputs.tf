output "admin_public_ips" {
  value = {
    dduportal       = ["109.88.234.158"],
    lemeurherve     = ["176.185.227.180", "2a01:e0a:b69:da30:5d59:cfbe:b675:e66d"],
    smerle33        = ["82.64.5.129"],
    mwaite          = ["162.142.59.220"],
  }
}

output "outbound_ips" {
  value = {
    "pkg.jenkins.io"        = ["52.202.51.185"],
    "trusted.ci.jenkins.io" = ["104.209.128.236"],
    "archives.jenkins.io"   = ["46.101.121.132", "2a03:b0c0:3:d0::9bc:d001"],
  }
}

output "external_service_ips" {
  value = {
    "ftp-osl.osuosl.org" = ["140.211.166.134", "2605:bc80:3010::134"]
  }
}
