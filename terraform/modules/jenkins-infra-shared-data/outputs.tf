output "admin_public_ips" {
  value = {
    dduportal   = ["109.88.234.158"],
    lemeurherve = ["176.185.227.180"],
    smerle33    = ["82.64.5.129"],
    mwaite      = ["162.142.59.220"],
  }
}

output "outbound_ips" {
  value = {
    "pkg.jenkins.io"              = ["52.202.51.185"],
    "trusted.ci.jenkins.io"       = ["104.209.128.236"],
  }
}

output "external_service_ips" {
  value = {
    "ftp-osl.osuosl.org" = ["140.211.166.134", "2605:bc80:3010::134"]
  }
}
