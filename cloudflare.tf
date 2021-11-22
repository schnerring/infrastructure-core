resource "cloudflare_zone" "schnerring_net" {
  zone = "schnerring.net"
}

# Email SPF

resource "cloudflare_record" "spf" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "schnerring.net"
  type    = "TXT"
  value   = "v=spf1 include:mailgun.org include:_spf.protonmail.ch mx ~all"
  ttl     = 86400
}

# ProtonMail

resource "cloudflare_record" "protonmail_verification" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "schnerring.net"
  type    = "TXT"
  value   = "protonmail-verification=15dc53d4ac7f44c8c021a551bf61ed21410beab5"
  ttl     = 86400
}

resource "cloudflare_record" "protonmail_mx_1" {
  zone_id  = cloudflare_zone.schnerring_net.id
  name     = "schnerring.net"
  type     = "MX"
  value    = "mail.protonmail.ch"
  ttl      = 86400
  priority = 10
}

resource "cloudflare_record" "protonmail_mx_2" {
  zone_id  = cloudflare_zone.schnerring_net.id
  name     = "schnerring.net"
  type     = "MX"
  value    = "mailsec.protonmail.ch"
  ttl      = 86400
  priority = 20
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

# Mailgun

resource "cloudflare_record" "mailgun_dkim" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "email._domainkey"
  type    = "TXT"
  value   = "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7ayPkPghq2agA/MInpj6zrOzfNzRlC+vUHVzKn7oKBu8EMBZnfv+xeA4gtqAZD5iymZL8p+wcovfDIrxIR2hIMQCsfuVP1vml96jJTXSf721SzfgD68ET97wCun6yi7GDtI5itkgk58nqlxAohF7u6fztBDHTGLaFZ0QXG8hlmN6qrgbxd3QWMcOgpQEeocU6zzQZsb0VNFJxWZR58n4DBEkY3OWd3Jui5BRioBRC3NQ4gtQparskkjIuTx/+kmksOzfGe4+BcG/NjJRNKcKYpLOMq83G5DSIyf3ql46kQPA3eqRUrST7FEpiF5kAJovGTAs/ryH+DmuLVa5dIX4iQIDAQAB"
  ttl     = 86400
}

# GitHub Pages

resource "cloudflare_record" "gh_pages_apex" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "schnerring.net"
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
  priority = 2

  actions {
    forwarding_url {
      url         = "https://schnerring.net/"
      status_code = 301
    }
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
  name    = "schnerring.net"
  type    = "TXT"
  value   = "MS=ms51347144"
  ttl     = 86400
}

# Sea Bats

resource "cloudflare_zone" "sensingskies_org" {
  zone = "sensingskies.org"
}

# GitHub Pages

resource "cloudflare_record" "sensingskies_gh_pages_apex" {
  zone_id = cloudflare_zone.sensingskies_org.id
  name    = "sensingskies.org"
  type    = "CNAME"
  value   = "schnerring.github.io"
  proxied = true
}

resource "cloudflare_record" "sensingskies_gh_pages_www" {
  zone_id = cloudflare_zone.sensingskies_org.id
  name    = "www"
  type    = "CNAME"
  value   = "schnerring.github.io"
  proxied = true
}

resource "cloudflare_page_rule" "sensingskies_gh_pages_rule_forward_www_to_apex" {
  zone_id  = cloudflare_zone.sensingskies_org.id
  target   = "https://www.sensingskies.org/"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://sensingskies.org/"
      status_code = 301
    }
  }
}

# Cloudflare Pages

resource "cloudflare_record" "hugo_theme_gruvbox" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "hugo-theme-gruvbox"
  type    = "CNAME"
  value   = "hugo-theme-gruvbox.pages.dev"
  proxied = true
}

# VPN

resource "cloudflare_record" "vpn1" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "vpn1"
  type    = "A"
  value   = "193.32.127.220" # Mullvad ch6-wireguard public exit IP
  proxied = false
}

resource "cloudflare_record" "vpn2" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "vpn2"
  type    = "A"
  value   = "193.32.127.225" # Mullvad ch7-wireguard public exit IP
  proxied = false
}
