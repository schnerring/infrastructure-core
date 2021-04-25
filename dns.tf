resource "cloudflare_zone" "schnerring_net_zone" {
  zone = "schnerring.net"
}

# GitHub Pages

resource "cloudflare_record" "gh_pages_cname_apex" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "@"
  type    = "CNAME"
  value   = "schnerring.github.io"
}

resource "cloudflare_record" "gh_pages_cname_www" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "www"
  type    = "CNAME"
  value   = "schnerring.github.io"
}
