
function fn() {

    var config = {};

    // Configuración del ambiente
    config.baseUrl = karate.properties['baseUrl']
        || 'https://serverest.dev';

    // Protección de datos sensibles en logs y reportes
    karate.configure('logging', {
        report: 'debug',
        console: 'info',
        pretty: true,
        mask: {
            jsonPaths: [
                '$..password'
            ]
        }
    });

    // Limpieza automática al finalizar cada escenario
    karate.configure('afterScenario', function() {

        // Evitar recursividad al ejecutar el Feature de limpieza
        if (karate.get('skipCleanupHook', false)) {
            return;
        }

        // Recuperar exclusivamente los IDs creados por el escenario
        var ids = karate.get('createdUserIds', []);

        if (!ids || ids.length === 0) {
            return;
        }

        karate.log('Iniciando limpieza de usuarios temporales:', ids.length);

        for (var i = 0; i < ids.length; i++) {

            karate.call(
                'classpath:support/cleanupUser.feature',
                {
                    idUsuario: ids[i],
                    skipCleanupHook: true
                }
            );

            karate.log('Usuario temporal eliminado:', ids[i]);
        }
    });

    return config;
}
