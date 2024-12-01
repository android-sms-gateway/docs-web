data "docker_network" "proxy" {
  name = "proxy"
}

resource "docker_image" "app" {
  name         = "capcom6/${var.app-name}:${var.app-version}"
  keep_locally = true
}

resource "docker_service" "app" {
  name = var.app-name

  task_spec {
    container_spec {
      image = docker_image.app.name
    }

    networks_advanced {
      name = data.docker_network.proxy.id
    }

    resources {
      limits {
        memory_bytes = var.memory-limit
      }

      reservation {
        memory_bytes = 8 * 1024 * 1024
      }
    }
  }

  # Traefik support
  labels {
    label = "traefik.enable"
    value = true
  }
  labels {
    label = "traefik.docker.network"
    value = data.docker_network.proxy.name
  }

  labels {
    label = "traefik.http.routers.${var.app-name}.rule"
    value = "Host(`${var.app-host}`)"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}.entrypoints"
    value = "https"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}.tls"
    value = true
  }

  labels {
    label = "traefik.http.routers.${var.app-name}-root.rule"
    value = "Host(`sms-gate.app`)"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}-root.entrypoints"
    value = "https"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}-root.tls.certresolver"
    value = "le"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}-root.middlewares"
    value = "redirect-to-main-docs"
  }

  labels {
    label = "traefik.http.routers.${var.app-name}-capcom.rule"
    value = "Host(`sms.capcom.me`)"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}-capcom.entrypoints"
    value = "https"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}-capcom.tls.certresolver"
    value = "le"
  }
  labels {
    label = "traefik.http.routers.${var.app-name}-capcom.middlewares"
    value = "redirect-to-main-docs"
  }

  labels {
    label = "traefik.http.middlewares.redirect-to-main-docs.redirectregex.regex"
    value = "^https://(sms\\.capcom\\.me|sms-gate\\.app)(.*)"
  }
  labels {
    label = "traefik.http.middlewares.redirect-to-main-docs.redirectregex.replacement"
    value = "https://docs.sms-gate.app$${2}"
  }
  labels {
    label = "traefik.http.middlewares.redirect-to-main-docs.redirectregex.permanent"
    value = true
  }

  labels {
    label = "traefik.http.services.${var.app-name}.loadbalancer.server.port"
    value = 80
  }

  update_config {
    failure_action = "rollback"
  }
}
