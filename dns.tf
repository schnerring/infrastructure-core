resource "cloudflare_zone" "schnerring_net_zone" {
  zone = "schnerring.net"
}

# ProtonMail

resource "cloudflare_record" "protonmail_verification" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "@"
  type    = "TXT"
  value   = "protonmail-verification=15dc53d4ac7f44c8c021a551bf61ed21410beab5"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_mx_1" {
  zone_id  = cloudflare_zone.schnerring_net_zone.id
  name     = "@"
  type     = "MX"
  value    = "mail.protonmail.ch"
  ttl      = 86400
  priority = 10
}

resource "cloudflare_record" "protonmail_mx_2" {
  zone_id  = cloudflare_zone.schnerring_net_zone.id
  name     = "@"
  type     = "MX"
  value    = "mailsec.protonmail.ch"
  ttl      = 86400
  priority = 20
}

resource "cloudflare_record" "protonmail_spf" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "@"
  type    = "TXT"
  value   = "v=spf1 include:_spf.protonmail.ch mx ~all"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dkim_1" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "protonmail._domainkey"
  type    = "CNAME"
  value   = "protonmail.domainkey.dj4kj3y2wss6natk5aychy474cv3uutffovaawtyl2qdey7roqmvq.domains.proton.ch"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dkim_2" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "protonmail2._domainkey"
  type    = "CNAME"
  value   = "protonmail2.domainkey.dj4kj3y2wss6natk5aychy474cv3uutffovaawtyl2qdey7roqmvq.domains.proton.ch"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dkim_3" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "protonmail3._domainkey"
  type    = "CNAME"
  value   = "protonmail3.domainkey.dj4kj3y2wss6natk5aychy474cv3uutffovaawtyl2qdey7roqmvq.domains.proton.ch"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dmarc" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "_dmarc"
  type    = "TXT"
  value   = "v=DMARC1; p=none; rua=mailto:dmarc@schnerring.net"
  ttl     = 86400
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
