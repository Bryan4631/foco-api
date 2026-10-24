user = User.find_or_initialize_by(email: "demo@foco.cl")
user.nombre = "Usuario Demo"
user.password = "demo12345"
user.save!

utem     = user.areas.find_or_create_by!(nombre: "UTEM")     { |a| a.tipo = "estudio";         a.color = "#2563eb" }
cumbrio  = user.areas.find_or_create_by!(nombre: "Cumbrio")  { |a| a.tipo = "emprendimiento"; a.color = "#ff6b4a" }
trabajo  = user.areas.find_or_create_by!(nombre: "Trabajo")  { |a| a.tipo = "trabajo";         a.color = "#7c3aed" }
personal = user.areas.find_or_create_by!(nombre: "Personal") { |a| a.tipo = "personal";        a.color = "#16a34a" }

utem.tareas.find_or_create_by!(titulo: "Entregar Tarea 1 de Computación Web") do |t|
  t.fecha_limite = Date.new(2026, 10, 28); t.prioridad = "alta"; t.estimado_minutos = 600
end
utem.tareas.find_or_create_by!(titulo: "Estudiar para la prueba de Cloud") do |t|
  t.fecha_limite = Date.new(2026, 11, 3); t.prioridad = "media"; t.estimado_minutos = 240
end
cumbrio.tareas.find_or_create_by!(titulo: "Publicar cambios de servicios en cumbrio.cl") do |t|
  t.fecha_limite = Date.new(2026, 10, 30); t.prioridad = "alta"; t.estimado_minutos = 120
end
trabajo.tareas.find_or_create_by!(titulo: "Preparar informe semanal") do |t|
  t.fecha_limite = Date.new(2026, 10, 30); t.prioridad = "media"; t.estimado_minutos = 90
end
personal.tareas.find_or_create_by!(titulo: "Salir a correr") do |t|
  t.prioridad = "baja"; t.estimado_minutos = 45
end

utem.bloques.find_or_create_by!(titulo: "Clase de Computación Web", dia_semana: 1) do |b|
  b.hora_inicio = "08:30"; b.hora_fin = "10:00"
end
trabajo.bloques.find_or_create_by!(titulo: "Turno de trabajo", dia_semana: 2) do |b|
  b.hora_inicio = "09:00"; b.hora_fin = "13:00"
end
cumbrio.bloques.find_or_create_by!(titulo: "Trabajo en Cumbrio", dia_semana: 3) do |b|
  b.hora_inicio = "18:00"; b.hora_fin = "20:00"
end
personal.bloques.find_or_create_by!(titulo: "Gimnasio", dia_semana: 4) do |b|
  b.hora_inicio = "19:00"; b.hora_fin = "20:00"
end
