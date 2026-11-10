
Feature: PUT /usuarios/{_id} - Actualización de usuarios

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * header Content-Type = 'application/json'

    # Cargar funciones reutilizables
    * def testData = call read('classpath:support/testData.feature')

    # Lista de usuarios creados por cada escenario
    * def createdUserIds = []


  @smoke @positive @PUT001
  Scenario: PUT-001 - PUT /usuarios/{_id} - Actualizar usuario existente y verificar persistencia

    # Generar datos únicos
    * def emailInicial = testData.uniqueEmail('qa.put.before')
    * def emailActualizado = testData.uniqueEmail('qa.put.after')

    # Definir contraseñas inicial y actualizada
    * def passwordInicial = 'QaInitial123!'
    * def passwordActualizada = 'QaUpdated456!'

    # Construir usuario inicial
    * def usuarioInicial = testData.buildUser('QA PUT Automation User', emailInicial, passwordInicial)

    Given path 'usuarios'
    And request usuarioInicial
    When method POST

    # Registrar ID para limpieza automática
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    # Capturar ID generado
    * def idUsuario = response._id
    * match idUsuario == '#string'

    # Construir usuario actualizado
    * def usuarioActualizado = testData.buildUser('QA PUT User Updated', emailActualizado, passwordActualizada)

    # Ejecutar PUT
    Given path 'usuarios', idUsuario
    And request usuarioActualizado
    When method PUT
    Then status 200

    # Validar respuesta de actualización
    And match response.message == 'Registro alterado com sucesso'

    # Consultar usuario actualizado
    Given path 'usuarios', idUsuario
    When method GET
    Then status 200

    # Validar persistencia del identificador y atributos
    And match response._id == idUsuario
    And match response.nome == 'QA PUT User Updated'
    And match response.email == emailActualizado
    And match response.password == passwordActualizada
    And match response.administrador == 'false'

    # Validar estructura utilizando esquema centralizado
    * def usuarioSchema = read('classpath:schemas/usuario.schema.json')
    And match response contains usuarioSchema

    * print 'Usuario actualizado correctamente:', idUsuario
    * print 'Nuevo nombre:', response.nome
    * print 'Nuevo email:', response.email
    * print 'Contraseña actualizada y validada correctamente'


  @negative @PUT002
  Scenario: PUT-002 - PUT /usuarios/{_id} - Rechazar actualización con correo duplicado

    # Crear propietario del correo
    * def emailPropietario = testData.uniqueEmail('qa.owner')
    * def usuarioPropietario = testData.buildUser('QA PUT Automation User', emailPropietario)

    Given path 'usuarios'
    And request usuarioPropietario
    When method POST

    # Registrar primer usuario para limpieza
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    # Crear usuario que intentaremos actualizar
    * def emailObjetivo = testData.uniqueEmail('qa.target')
    * def usuarioObjetivo = testData.buildUser('QA PUT Automation User', emailObjetivo)

    Given path 'usuarios'
    And request usuarioObjetivo
    When method POST

    # Registrar segundo usuario para limpieza
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    * def idObjetivo = response._id

    # Construir actualización utilizando el correo del otro usuario
    * def actualizacionDuplicada = testData.buildUser('QA Target User Updated', emailPropietario)

    Given path 'usuarios', idObjetivo
    And request actualizacionDuplicada
    When method PUT
    Then status 400

    # Validar regla de negocio
    And match response.message == 'Este email já está sendo usado'

    * print 'Correo duplicado rechazado correctamente'


  @negative @PUT003
  Scenario: PUT-003 - PUT /usuarios/{_id} - Rechazar actualización con body vacío

    # Crear usuario de prueba
    * def emailUsuario = testData.uniqueEmail('qa.empty')
    * def usuarioInicial = testData.buildUser('QA PUT Automation User', emailUsuario)

    Given path 'usuarios'
    And request usuarioInicial
    When method POST

    # Registrar ID para limpieza
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    * def idUsuario = response._id

    # Ejecutar actualización con body vacío
    * def payloadVacio = {}

    Given path 'usuarios', idUsuario
    And request payloadVacio
    When method PUT
    Then status 400

    # Validar los cuatro campos obligatorios
    And match response.nome == 'nome é obrigatório'
    And match response.email == 'email é obrigatório'
    And match response.password == 'password é obrigatório'
    And match response.administrador == 'administrador é obrigatório'

    * print 'Validacion de body vacio ejecutada correctamente'


  @negative @PUT004
  Scenario: PUT-004 - PUT /usuarios/{_id} - Rechazar campo _id dentro del body

    # Crear usuario de prueba
    * def emailUsuario = testData.uniqueEmail('qa.id')
    * def usuarioInicial = testData.buildUser('QA PUT Automation User', emailUsuario)

    Given path 'usuarios'
    And request usuarioInicial
    When method POST

    # Registrar ID para limpieza
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    * def idUsuario = response._id

    # Preparar body incluyendo ID no permitido
    * def usuarioConId = testData.buildUser('QA PUT User Updated', emailUsuario)
    * set usuarioConId._id = idUsuario

    Given path 'usuarios', idUsuario
    And request usuarioConId
    When method PUT
    Then status 400

    # Validar restricción
    And match response._id == '_id não é permitido'

    * print 'Restriccion del campo _id validada correctamente'


  @negative @PUT_FIELDS
  Scenario Outline: <id> - PUT /usuarios/{_id} - Rechazar actualización: <caso>

    # Crear usuario independiente para cada prueba
    * def emailInicial = testData.uniqueEmail('qa.put.field')
    * def usuarioInicial = testData.buildUser('QA PUT Automation User', emailInicial)

    Given path 'usuarios'
    And request usuarioInicial
    When method POST

    # Registrar ID para limpieza
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    * def idUsuario = response._id

    # Construir actualización utilizando función centralizada
    * def payloadActualizacion = testData.buildUpdatePayload('<tipo>', emailInicial)

    # Ejecutar actualización
    Given path 'usuarios', idUsuario
    And request payloadActualizacion
    When method PUT
    Then status 400

    # Obtener campo y mensaje esperado
    * def campoError = '<campoRespuesta>'
    * def mensajeEsperado = "<mensajeEsperado>"

    # Validar mensaje de error
    * match response[campoError] == mensajeEsperado

    * print 'Validacion negativa completada:', '<id>'


    Examples:
      | id      | caso                        | tipo                | campoRespuesta | mensajeEsperado |
      | PUT-005 | Email vacío                 | EMAIL_VACIO         | email          | email não pode ficar em branco |
      | PUT-006 | Email con formato inválido  | EMAIL_INVALIDO      | email          | email deve ser um email válido |
      | PUT-007 | Email ausente               | EMAIL_AUSENTE       | email          | email é obrigatório |
      | PUT-008 | Administrador vacío         | ADMINISTRADOR_VACIO | administrador  | administrador deve ser 'true' ou 'false' |
