#!/bin/sh
set -e

# Usamos la variable COMPOSE_PROFILES inyectada desde el host
ACTIVE_PROFILES=${COMPOSE_PROFILES:-none}
export ACTIVE_PROFILES

echo "Compose profiles: [$ACTIVE_PROFILES]"

# 2. Convertir a array compatible con sh (sin usar <<<)
profiles_list=$(echo "$ACTIVE_PROFILES" | tr ',' ' ')

ENABLE_BACKEND=false
ENABLE_DICTIONARY_RS=false
# ENABLE_LANDING_PAGE=false
ENABLE_PROCESSORS=false
ENABLE_S3_GATEWAY_RS=false
ENABLE_VUE=false
ENABLE_ZK=false
# Comprobar si la variable está vacía o es igual a "all"
if [[ -z "$ACTIVE_PROFILES" || "$ACTIVE_PROFILES" == "all" ]]; then
  echo "La variable está vacía o es 'all'."
  ENABLE_BACKEND=true
  ENABLE_DICTIONARY_RS=true
  ENABLE_PROCESSORS=true
  ENABLE_S3_GATEWAY_RS=true
  ENABLE_VUE=true
  ENABLE_ZK=true
else
  # Iterar sobre cada perfil en el array
  for profile in $profiles_list; do
    case "$profile" in
      "" | "all")
        echo "La variable está vacía o es 'all'."
        ENABLE_BACKEND=true
        ENABLE_PROCESSORS=true
        ENABLE_VUE=true
        ENABLE_ZK=true
      ;;
      "cache")
        echo "La variable contiene 'cache'."
        ENABLE_BACKEND=true
        ENABLE_DICTIONARY_RS=true
        ENABLE_VUE=true
      ;;
      "storage")
        echo "La variable contiene 'storage'."
        ENABLE_BACKEND=true
        ENABLE_S3_GATEWAY_RS=true
        ENABLE_VUE=true
      ;;
      "vue")
        echo "La variable contiene 'vue'."
        ENABLE_BACKEND=true
        ENABLE_VUE=true
      ;;
      "scheduler")
        echo "La variable contiene 'scheduler'."
        ENABLE_PROCESSORS=true
        ENABLE_ZK=true
      ;;
      "zk")
        echo "La variable contiene 'zk'."
        ENABLE_ZK=true
      ;;
      *)
        echo "La variable contiene un valor no reconocido: $profile."
      ;;
    esac
  done
fi


# Crear el directorio si no existe
mkdir -p /etc/nginx/api_upstreams_conf.d/
mkdir -p /etc/nginx/api_conf.d/
echo "carpetas /etc/nginx/api_upstreams_conf.d/ y /etc/nginx/api_conf.d/ creadas"

# rm -R /etc/nginx/api_upstreams_conf.d/*
# rm -R /etc/nginx/api_conf.d/*

# Comprobar si la variable está vacía o es igual a "all"
if [[ -z "$ACTIVE_PROFILES" || "$ACTIVE_PROFILES" == "all" ]]; then
  echo "copiar todos los archivos upstreams."
  cp /etc/nginx/templates/upstreams/*.conf /etc/nginx/api_upstreams_conf.d/
  cp /etc/nginx/templates/api_conf.d/*.conf /etc/nginx/api_conf.d/
else
  if [[ "$ENABLE_BACKEND" == "true" ]]; then
    cp /etc/nginx/templates/upstreams/adempiere_backend.conf /etc/nginx/api_upstreams_conf.d/
    cp /etc/nginx/templates/api_conf.d/adempiere_backend.conf /etc/nginx/api_conf.d/
  fi
  if [[ "$ENABLE_DICTIONARY_RS" == "true" ]]; then
    cp /etc/nginx/templates/upstreams/dictionary_rs.conf /etc/nginx/api_upstreams_conf.d/
    cp /etc/nginx/templates/api_conf.d/dictionary_rs.conf /etc/nginx/api_conf.d/
  fi
  if [[ "$ENABLE_PROCESSORS" == "true" ]]; then
    cp /etc/nginx/templates/upstreams/adempiere_backend.conf /etc/nginx/api_upstreams_conf.d/
    cp /etc/nginx/templates/api_conf.d/adempiere_backend.conf /etc/nginx/api_conf.d/
  fi
  if [[ "$ENABLE_S3_GATEWAY_RS" == "true" ]]; then
    cp /etc/nginx/templates/upstreams/adempiere_vue.conf /etc/nginx/api_upstreams_conf.d/
    cp /etc/nginx/templates/api_conf.d/adempiere_vue .conf /etc/nginx/api_conf.d/
  fi
  if [[ "$ENABLE_VUE" == "true" ]]; then
    cp /etc/nginx/templates/upstreams/adempiere_vue.conf /etc/nginx/api_upstreams_conf.d/
    cp /etc/nginx/templates/api_conf.d/adempiere_vue .conf /etc/nginx/api_conf.d/
  fi
  if [[ "$ENABLE_ZK" == "true" ]]; then
    cp /etc/nginx/templates/upstreams/adempiere_zk.conf /etc/nginx/api_upstreams_conf.d/
    cp /etc/nginx/templates/api_conf.d/adempiere_zk.conf /etc/nginx/api_conf.d/
  fi
fi



# Validar configuración
if ! nginx -t; then
  echo "Error: Invalid Nginx config"
  exit 1
fi

echo "Setup apply sucessfully"
