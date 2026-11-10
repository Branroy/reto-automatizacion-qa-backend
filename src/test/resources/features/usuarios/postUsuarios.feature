
Feature: POST /usuarios - Registro de usuarios

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * header Content-Type = 'application/json'

    # Cargar funciones reutilizables
    * def testData = call read('classpath:support/testData.feature')

    # Lista de usuarios creados por cada escenario
    * def createdUserIds = []

    # Helper específico para construir payloads de validación negativa
    * def buildPayload =
      """
      function(campoOmitido, email) {

        if (campoOmitido === 'todos') {
          return {};
        }

        var usuario = testData.buildUser(
          'QA Automation User',
          email,
          'QaTest123!',
          'false'
        );

        if (campoOmitido !== 'ninguno') {
          delete usuario[campoOmitido];
        }

        return usuario;
      }
      """


  @smoke @positive @POST001
  Scenario: POST-001 - POST /usuarios - Registrar usuario válido

    # Generar correo único
    * def emailUnico = testData.uniqueEmail('qa.post')

    # Construir usuario
    * def nuevoUsuario = testData.buildUser('QA Automation User', emailUnico)

    # Registrar usuario
    Given path 'usuarios'
    And request nuevoUsuario
    When method POST

    # Registrar ID para limpieza automática
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    # Validar respuesta
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'

    * print 'Usuario registrado correctamente'
    * print 'ID generado:', response._id


  @negative @POST002
  Scenario: POST-002 - POST /usuarios - Rechazar correo duplicado

    # Generar correo único
    * def emailUnico = testData.uniqueEmail('qa.duplicate')

    # Construir usuario
    * def nuevoUsuario = testData.buildUser('QA Duplicate User', emailUnico)

    # Registrar primer usuario
    Given path 'usuarios'
    And request nuevoUsuario
    When method POST

    # Registrar primer ID para limpieza
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    # Intentar registrar nuevamente el mismo correo
    Given path 'usuarios'
    And request nuevoUsuario
    When method POST

    # Protección por si el sistema acepta inesperadamente el duplicado
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 400

    # Validar mensaje de negocio
    And match response.message == 'Este email já está sendo usado'

    * print 'Correo duplicado rechazado correctamente'


  @negative @POST_FIELDS
  Scenario Outline: <id> - POST /usuarios - Rechazar registro: <caso>

    # Generar correo único por ejecución
    * def emailUnico = testData.uniqueEmail('qa.post.negative')

    # Seleccionar correo generado o valor de prueba
    * def emailFinal = '<email>' == 'GENERAR' ? emailUnico : '<email>'

    # Construir payload según el caso
    * def usuario = buildPayload('<campoOmitido>', emailFinal)

    Given path 'usuarios'
    And request usuario
    When method POST

    # Protección por si un caso negativo genera un usuario inesperadamente
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 400

    # Convertir respuesta esperada a objeto JSON
    * def erroresEsperados = karate.fromString('<erroresEsperados>')

    # Validar todos los errores esperados
    And match response contains erroresEsperados

    * print 'Validacion negativa completada:', '<id>'


    Examples:
      | id       | caso                             | campoOmitido  | email           | erroresEsperados |
      | POST-003 | Nombre ausente                  | nome          | GENERAR         | {"nome":"nome é obrigatório"} |
      | POST-004 | Body vacío                      | todos         | GENERAR         | {"nome":"nome é obrigatório","email":"email é obrigatório","password":"password é obrigatório","administrador":"administrador é obrigatório"} |
      | POST-005 | Email ausente                   | email         | GENERAR         | {"email":"email é obrigatório"} |
      | POST-006 | Password ausente                | password      | GENERAR         | {"password":"password é obrigatório"} |
      | POST-007 | Nombre ausente y email inválido | nome          | correo-invalido | {"nome":"nome é obrigatório","email":"email deve ser um email válido"} |
      | POST-008 | Administrador ausente           | administrador | GENERAR         | {"administrador":"administrador é obrigatório"} |
      | POST-009 | Email inválido                  | ninguno       | correo-invalido | {"email":"email deve ser um email válido"} |
