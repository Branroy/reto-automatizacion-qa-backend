
Feature: DELETE /usuarios/{_id} - Eliminación de usuarios

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * header Content-Type = 'application/json'

    # Cargar funciones reutilizables
    * def testData = call read('classpath:support/testData.feature')

    # Lista de usuarios creados por cada escenario
    * def createdUserIds = []


  @smoke @positive @DELETE001
  Scenario: DELETE-001 - Eliminar usuario existente y verificar eliminación

    # Generar correo único
    * def emailUnico = testData.uniqueEmail('qa.delete')

    # Construir usuario de prueba
    * def nuevoUsuario = testData.buildUser('QA User Delete Test', emailUnico)

    # Crear usuario de prueba
    Given path 'usuarios'
    And request nuevoUsuario
    When method POST

    # Registrar ID para limpieza automática
    * eval responseStatus == 201 && response._id && createdUserIds.push(response._id)

    Then status 201

    # Capturar ID generado
    * def idUsuario = response._id
    * match idUsuario == '#string'

    # Eliminar usuario
    Given path 'usuarios', idUsuario
    When method DELETE
    Then status 200

    # Validar respuesta de eliminación
    And match response.message == 'Registro excluído com sucesso'

    # Verificar que el usuario ya no existe
    Given path 'usuarios', idUsuario
    When method GET
    Then status 400

    # Validar ausencia del usuario
    And match response.message == 'Usuário não encontrado'

    * print 'Usuario eliminado correctamente:', idUsuario


  @negative @DELETE002
  Scenario: DELETE-002 - Intentar eliminar usuario inexistente

    # Generar ID aleatorio de 16 caracteres alfanuméricos
    * def idInexistente = 'ZZ' + karate.uuid().replaceAll('-', '').substring(0, 14)

    Given path 'usuarios', idInexistente
    When method DELETE
    Then status 200

    # Validar que no se eliminó ningún registro
    And match response.message == 'Nenhum registro excluído'

    * print 'Eliminacion de usuario inexistente validada'


  @negative @DELETE003
  Scenario: DELETE-003 - Intentar eliminar usuario con ID inválido

    # ID con longitud incorrecta
    * def idInvalido = '123'

    Given path 'usuarios', idInvalido
    When method DELETE
    Then status 200

    # Validar respuesta
    And match response.message == 'Nenhum registro excluído'

    * print 'Validacion de ID invalido ejecutada correctamente'
