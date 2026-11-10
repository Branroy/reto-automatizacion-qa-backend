
Feature: GET /usuarios/{_id} - Consulta de usuario por identificador

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * header Content-Type = 'application/json'

    # Cargar funciones reutilizables
    * def testData = call read('classpath:support/testData.feature')

    # Cargar esquema centralizado de usuarios
    * def usuarioSchema = read('classpath:schemas/usuario.schema.json')

    # Lista de usuarios creados por cada escenario
    * def createdUserIds = []


  @positive @GET004
  Scenario: GET-004 - GET /usuarios/{_id} - Consultar usuario existente

    # Generar correo único
    * def emailPrueba = testData.uniqueEmail('qa.get.id')

    # Construir usuario de prueba
    * def usuarioPrueba = testData.buildUser('QA GET ID User', emailPrueba)

    # Crear usuario independiente
    Given path 'usuarios'
    And request usuarioPrueba
    When method POST
    Then status 201

    # Capturar y registrar ID para limpieza
    * def idUsuario = response._id
    * match idUsuario == '#string'
    * eval createdUserIds.push(idUsuario)

    # Consultar usuario por ID
    Given path 'usuarios', idUsuario
    When method GET
    Then status 200

    # Validar identificador
    And match response._id == idUsuario

    # Validar información del usuario
    And match response.nome == 'QA GET ID User'
    And match response.email == emailPrueba

    # Validar esquema centralizado
    And match response contains usuarioSchema

    * print 'Usuario encontrado correctamente:', idUsuario


  @negative @GET005
  Scenario: GET-005 - GET /usuarios/{_id} - Consultar usuario inexistente

    # Generar ID aleatorio válido de 16 caracteres
    * def idInexistente = 'ZZ' + karate.uuid().replaceAll('-', '').substring(0, 14)

    # Consultar usuario inexistente
    Given path 'usuarios', idInexistente
    When method GET
    Then status 400

    # Validar mensaje de error
    And match response.message == 'Usuário não encontrado'

    * print 'Usuario inexistente validado correctamente:', idInexistente


  @negative @GET006
  Scenario: GET-006 - GET /usuarios/{_id} - Consultar usuario con ID de longitud inválida

    # Generar ID con longitud incorrecta
    * def idInvalido = '123'

    Given path 'usuarios', idInvalido
    When method GET
    Then status 400

    # Validar mensaje de formato inválido
    And match response.id == 'id deve ter exatamente 16 caracteres alfanuméricos'

    * print 'Validacion de longitud del ID ejecutada correctamente'
