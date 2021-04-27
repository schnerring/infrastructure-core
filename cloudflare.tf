resource "cloudflare_zone" "schnerring_net" {
  zone = "schnerring.net"
}

# ProtonMail

resource "cloudflare_record" "protonmail_verification" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "@"
  type    = "TXT"
  value   = "protonmail-verification=15dc53d4ac7f44c8c021a551bf61ed21410beab5"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_mx_1" {
  zone_id  = cloudflare_zone.schnerring_net.id
  name     = "@"
  type     = "MX"
  value    = "mail.protonmail.ch"
  ttl      = 86400
  priority = 10
}

resource "cloudflare_record" "protonmail_mx_2" {
  zone_id  = cloudflare_zone.schnerring_net.id
  name     = "@"
  type     = "MX"
  value    = "mailsec.protonmail.ch"
  ttl      = 86400
  priority = 20
}

resource "cloudflare_record" "protonmail_spf" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "@"
  type    = "TXT"
  value   = "v=spf1 include:_spf.protonmail.ch mx ~all"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dkim_1" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "protonmail._domainkey"
  type    = "CNAME"
  value   = "protonmail.domainkey.dj4kj3y2wss6natk5aychy474cv3uutffovaawtyl2qdey7roqmvq.domains.proton.ch"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dkim_2" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "protonmail2._domainkey"
  type    = "CNAME"
  value   = "protonmail2.domainkey.dj4kj3y2wss6natk5aychy474cv3uutffovaawtyl2qdey7roqmvq.domains.proton.ch"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dkim_3" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "protonmail3._domainkey"
  type    = "CNAME"
  value   = "protonmail3.domainkey.dj4kj3y2wss6natk5aychy474cv3uutffovaawtyl2qdey7roqmvq.domains.proton.ch"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_dmarc" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "_dmarc"
  type    = "TXT"
  value   = "v=DMARC1; p=none; rua=mailto:dmarc@schnerring.net"
  ttl     = 86400
}

# GitHub Pages

resource "cloudflare_record" "gh_pages_apex" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "@"
  type    = "CNAME"
  value   = "schnerring.github.io"
  proxied = true
}

resource "cloudflare_record" "gh_pages_www" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "www"
  type    = "CNAME"
  value   = "schnerring.github.io"
  proxied = true
}

resource "cloudflare_page_rule" "gh_pages_rule_forward_www_to_apex" {
  zone_id  = cloudflare_zone.schnerring_net.id
  target   = "https://www.schnerring.net/"
  priority = 3

  actions {
    forwarding_url {
      url         = "https://schnerring.net/"
      status_code = 301
    }
  }
}

resource "cloudflare_page_rule" "gh_pages_rule_always_use_https" {
  zone_id  = cloudflare_zone.schnerring_net.id
  target   = "http://schnerring.net/*"
  priority = 2

  actions {
    always_use_https = true
  }
}

resource "cloudflare_page_rule" "gh_pages_rule_cache_everything" {
  zone_id  = cloudflare_zone.schnerring_net.id
  target   = "https://schnerring.net/*"
  priority = 1

  actions {
    cache_level = "cache_everything"
  }
}

# Azure Active Directory domain verification

resource "cloudflare_record" "azure_verification" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "@"
  type    = "TXT"
  value   = "MS=ms51347144"
}
