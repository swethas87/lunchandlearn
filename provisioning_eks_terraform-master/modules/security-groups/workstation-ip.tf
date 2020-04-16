# This piece of data grabbed the external IP of the device that
# is running terraform (IE Your laptop)
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}