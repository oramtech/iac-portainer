locals {
  cloudflare_zone_id = "us-east1-b"
}

resource "random_id" "portainer_tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_argo_tunnel" "portainer" {
  account_id = var.cloudflare_account_id
  name       = "portainer-tunnel"
  secret     = random_id.portainer_tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "portainer" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_argo_tunnel.portainer.id

  config {    
    ingress_rule {
      hostname = "portainer.oram.tech"
      service  = "http://10.16.32.10:9000"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_access_application" "portainer" {
  account_id = var.cloudflare_account_id
  name             = "Portainer"
  domain           = "portainer.oram.tech"
  session_duration = "1h"
  type = "self_hosted"
}

resource "cloudflare_access_policy" "portainer" {
  account_id = var.cloudflare_account_id
  application_id = cloudflare_access_application.portainer.id
  name           = "Emails Policy"
  precedence     = "2"
  decision       = "allow"

  include {
    email = ["b@oram.co"]
  }
}

resource "cloudflare_record" "portainer" {
  zone_id = var.cloudflare_dns_zone_id
  name    = "portainer"
  value   = "${cloudflare_argo_tunnel.portainer.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}