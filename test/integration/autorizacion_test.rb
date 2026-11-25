require "test_helper"

# Tests de autorización de la Tarea 2: 401 (sin sesión), 403 (sin permiso) y respuestas permitidas.
class AutorizacionTest < ActionDispatch::IntegrationTest
  setup do
    @ana   = crear_usuario(nombre: "Ana")
    @beto  = crear_usuario(nombre: "Beto")
    @admin = crear_usuario(nombre: "Admin", rol: "admin")

    @area_ana  = crear_area(@ana)
    @tarea_ana = @area_ana.tareas.create!(titulo: "Tarea de Ana")
    @bloque_ana = @area_ana.bloques.create!(titulo: "Bloque de Ana", dia_semana: 1, hora_inicio: "08:00", hora_fin: "09:00")
  end

  # --- 401: no autenticado ---

  test "sin token cualquier recurso responde 401" do
    get "/api/v1/tareas"
    assert_response :unauthorized
  end

  # --- Restricción por propiedad: tareas ---

  test "el dueño puede ver su propia tarea (200)" do
    get "/api/v1/tareas/#{@tarea_ana.id}", headers: auth_headers(@ana)
    assert_response :ok
  end

  test "un usuario no puede ver la tarea de otro (403)" do
    get "/api/v1/tareas/#{@tarea_ana.id}", headers: auth_headers(@beto)
    assert_response :forbidden
  end

  test "un usuario no puede editar la tarea de otro (403) y no se modifica" do
    patch "/api/v1/tareas/#{@tarea_ana.id}",
          params: { tarea: { titulo: "Hackeada" } }, headers: auth_headers(@beto), as: :json
    assert_response :forbidden
    assert_equal "Tarea de Ana", @tarea_ana.reload.titulo
  end

  test "un usuario no puede eliminar el área de otro (403)" do
    delete "/api/v1/areas/#{@area_ana.id}", headers: auth_headers(@beto)
    assert_response :forbidden
    assert Area.exists?(@area_ana.id)
  end

  test "el index de un usuario solo trae lo suyo, aunque pida todos" do
    get "/api/v1/tareas?todos=true", headers: auth_headers(@beto)
    assert_response :ok
    assert_equal [], response.parsed_body
  end

  # --- Restricción por rol: admin ---

  test "el admin puede ver la tarea de otro usuario (200)" do
    get "/api/v1/tareas/#{@tarea_ana.id}", headers: auth_headers(@admin)
    assert_response :ok
  end

  test "el admin puede listar todas las tareas con todos=true" do
    get "/api/v1/tareas?todos=true", headers: auth_headers(@admin)
    assert_response :ok
    assert_equal 1, response.parsed_body.size
  end

  test "un usuario normal no puede listar usuarios (403)" do
    get "/api/v1/usuarios", headers: auth_headers(@ana)
    assert_response :forbidden
  end

  test "el admin puede listar usuarios (200) y no se expone password_digest" do
    get "/api/v1/usuarios", headers: auth_headers(@admin)
    assert_response :ok
    assert_equal 3, response.parsed_body.size
    assert_not response.body.include?("password_digest")
  end

  test "el admin puede cambiar el rol de otro usuario" do
    patch "/api/v1/usuarios/#{@ana.id}",
          params: { usuario: { rol: "admin" } }, headers: auth_headers(@admin), as: :json
    assert_response :ok
    assert_equal "admin", @ana.reload.rol
  end

  test "el admin no puede quitarse su propio rol (422)" do
    patch "/api/v1/usuarios/#{@admin.id}",
          params: { usuario: { rol: "usuario" } }, headers: auth_headers(@admin), as: :json
    assert_response :unprocessable_entity
    assert_equal "admin", @admin.reload.rol
  end

  test "un usuario normal no puede cambiar roles (403)" do
    patch "/api/v1/usuarios/#{@beto.id}",
          params: { usuario: { rol: "admin" } }, headers: auth_headers(@ana), as: :json
    assert_response :forbidden
    assert_equal "usuario", @beto.reload.rol
  end

  # --- Registro: el rol no se puede elegir ---

  test "registrarse con rol admin no da privilegios (el parámetro se ignora)" do
    post "/api/v1/auth/register",
         params: { nombre: "Intruso", email: "intruso@foco.cl", password: "clave12345", rol: "admin" }, as: :json
    assert_response :created
    assert_equal "usuario", User.find_by(email: "intruso@foco.cl").rol
  end

  # --- Corrección de la revisión de la Tarea 1 ---

  test "GET /bloques/:id responde 200 al dueño (antes daba 404)" do
    get "/api/v1/bloques/#{@bloque_ana.id}", headers: auth_headers(@ana)
    assert_response :ok
    assert_equal "Bloque de Ana", response.parsed_body["titulo"]
  end

  test "bloques#update con area_id ajeno responde 422" do
    area_beto = crear_area(@beto)
    patch "/api/v1/bloques/#{@bloque_ana.id}",
          params: { bloque: { area_id: area_beto.id } }, headers: auth_headers(@ana), as: :json
    assert_response :unprocessable_entity
  end
end
