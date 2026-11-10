
Feature: GET /usuarios - Consulta y listado de usuarios

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


  @smoke @positive @GET001
  Scenario: GET-001 - GET /usuarios - Listar todos los usuarios

    # Generar correo único
    * def emailPrueba = testData.uniqueEmail('qa.get.list')

    # Construir usuario de prueba
    * def usuarioPrueba = testData.buildUser('QA GET List User', emailPrueba)

    # Crear usuario propio para la prueba
    Given path 'usuarios'
    And request usuarioPrueba
    When method POST
    Then status 201

    # Capturar y registrar ID para limpieza
    * def idUsuario = response._id
    * match idUsuario == '#string'
    * eval createdUserIds.push(idUsuario)

    # Consultar listado completo
    Given path 'usuarios'
    When method GET
    Then status 200

    # Validar estructura principal
    And match response.quantidade == '#number'
    And match response.usuarios == '#[]'

    # Validar consistencia de cantidades
    And match response.quantidade == response.usuarios.length

    # Comprobar que nuestro usuario aparece en el listado
    And match response.usuarios[*]._id contains idUsuario

    # Validar esquema centralizado de cada usuario
    And match each response.usuarios contains usuarioSchema

    # Mostrar información sin exponer contraseñas
    * print 'Cantidad reportada:', response.quantidade
    * print 'Cantidad recibida:', response.usuarios.length
    * print 'Usuario de prueba encontrado:', idUsuario


  @positive @GET002
  Scenario: GET-002 - GET /usuarios - Buscar usuario por ID existente

    # Generar correo único
    * def emailPrueba = testData.uniqueEmail('qa.get.filter')

    # Construir usuario de prueba
    * def usuarioPrueba = testData.buildUser('QA GET Filter User', emailPrueba)

    # Crear usuario independiente
    Given path 'usuarios'
    And request usuarioPrueba
    When method POST
    Then status 201

    # Capturar y registrar ID para limpieza
    * def idUsuario = response._id
    * match idUsuario == '#string'
    * eval createdUserIds.push(idUsuario)

    # Buscar mediante filtro
    Given path 'usuarios'
    And param _id = idUsuario
    When method GET
    Then status 200

    # Validar resultado
    And match response.quantidade == 1
    And match response.usuarios == '#[1]'
    And match response.usuarios[0]._id == idUsuario
    And match response.usuarios[0].email == emailPrueba

    # Validar esquema centralizado
    And match response.usuarios[0] contains usuarioSchema

    * print 'Usuario propio encontrado correctamente:', idUsuario


  @negative @GET003
  Scenario: GET-003 - GET /usuarios - Buscar usuario por ID inexistente

    # Generar ID aleatorio de 16 caracteres
    * def idInexistente = 'ZZ' + karate.uuid().replaceAll('-', '').substring(0, 14)

    # Consultar mediante el filtro
    Given path 'usuarios'
    And param _id = idInexistente
    When method GET
    Then status 200

    # Validar ausencia de resultados
    And match response.quantidade == 0
    And match response.usuarios == []

    * print 'ID inexistente generado:', idInexistente
    * print 'Busqueda sin resultados validada correctamente'
