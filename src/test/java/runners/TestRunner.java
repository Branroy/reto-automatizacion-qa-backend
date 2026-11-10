
package runners;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class TestRunner {

    @Test
    void testUsuarios() {

        SuiteResult result = Runner
                .path("src/test/resources/features/usuarios")

                // Reporte HTML interactivo
                .outputHtmlReport(true)

                // Reporte JUnit XML para CI/CD
                .outputJunitXml(true)

                // Reporte Cucumber JSON para dashboards
                .outputCucumberJson(true)

                // Eventos estructurados JSON Lines
                .outputJsonLines(true)

                // Mantener ejecución secuencial
                .parallel(1);

        assertTrue(
                result.isPassed(),
                "Falló la ejecución de las pruebas de usuarios"
        );
    }
}
