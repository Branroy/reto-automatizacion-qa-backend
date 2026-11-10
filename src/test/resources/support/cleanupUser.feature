
Feature: Limpieza de usuarios temporales

  Scenario: Eliminar un usuario generado durante las pruebas

    Given url baseUrl
    And path 'usuarios', idUsuario
    When method DELETE
    Then status 200

    # Aceptar eliminación correcta o registro ya eliminado
    * assert response.message == 'Registro excluído com sucesso' || response.message == 'Nenhum registro excluído'
