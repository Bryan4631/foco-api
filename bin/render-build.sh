#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails db:migrate
# Tarea 2: los seeds son idempotentes (find_or_initialize_by) y crean el usuario admin de prueba.
# Se ejecutan en el paso de build/deploy porque en producción no hay shell interactiva.
bundle exec rails db:seed