
@ignore
Feature: Funciones reutilizables para datos de prueba

  Scenario: Exponer funciones de generación de datos

    # Cargar datos centralizados desde JSON
    * def userData = read('classpath:data/usuarios.json')

    # Generar correos electrónicos únicos
    * def uniqueEmail =
      """
      function(prefix) {
        var prefijo = prefix || 'qa';
        return prefijo + '.' + karate.uuid().replaceAll('-', '') + '@test.com';
      }
      """

    # Construir usuarios para pruebas POST, PUT, GET y DELETE
    * def buildUser =
      """
      function(nombre, email, password, administrador) {

        if (!email) {
          throw new Error('El correo electrónico es obligatorio para construir un usuario');
        }

        return {
          nome: nombre || userData.defaultUser.name,
          email: email,
          password: password || userData.defaultUser.password,
          administrador: administrador == null
            ? userData.defaultUser.administrator
            : String(administrador)
        };
      }
      """

    # Construir payloads para pruebas de actualización
    * def buildUpdatePayload =
      """
      function(tipo, email) {

        var usuario = {
          nome: userData.updatedUser.name,
          email: email,
          password: userData.updatedUser.password,
          administrador: userData.defaultUser.administrator
        };

        if (tipo === 'EMAIL_VACIO') {
          usuario.email = userData.invalidData.emptyEmail;
        }

        if (tipo === 'EMAIL_INVALIDO') {
          usuario.email = userData.invalidData.invalidEmail;
        }

        if (tipo === 'EMAIL_AUSENTE') {
          delete usuario.email;
        }

        if (tipo === 'ADMINISTRADOR_VACIO') {
          usuario.administrador = userData.invalidData.emptyAdministrator;
        }

        return usuario;
      }
      """
