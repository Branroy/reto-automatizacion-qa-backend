
# Reto de Automatización QA Backend

## 1. Descripción

Proyecto de automatización de pruebas funcionales para la API REST de ServeRest, utilizando Karate DSL.

El objetivo es validar las operaciones CRUD del recurso `/usuarios`, incluyendo escenarios positivos, negativos, validaciones de negocio y manejo de datos de prueba.

## 2. Tecnologías utilizadas

| Tecnología | Versión |
|---|---|
| Java | 21 |
| Maven | 3.9.16 |
| Karate DSL | 2.1.4 |
| JUnit Jupiter | 5.10.1 |
| Maven Surefire | 3.5.2 |

## 3. Arquitectura del proyecto

```text
reto-automatizacion-qa-backend/
│
├── pom.xml
├── README.md
│
└── src/
    └── test/
        ├── java/
        │   └── runners/
        │       └── TestRunner.java
        │
        └── resources/
            ├── karate-config.js
            │
            ├── data/
            │   └── usuarios.json
            │
            ├── schemas/
            │   └── usuario.schema.json
            │
            ├── support/
            │   ├── testData.feature
            │   └── cleanupUser.feature
            │
            └── features/
                └── usuarios/
                    ├── getUsuarios.feature
                    ├── getUsuarioId.feature
                    ├── postUsuarios.feature
                    ├── putUsuarios.feature
                    └── deleteUsuarios.feature
```

## 4. Cobertura de pruebas

| Método | Escenarios | Cobertura |
|---|---:|---|
| GET /usuarios | 3 | Listado y búsqueda mediante filtros |
| GET /usuarios/{_id} | 3 | Consulta por identificador |
| POST /usuarios | 9 | Registro y validaciones negativas |
| PUT /usuarios/{_id} | 8 | Actualización y validaciones |
| DELETE /usuarios/{_id} | 3 | Eliminación y manejo de identificadores |
| **Total** | **26** | |

### Principales validaciones

- Registro de usuarios con información válida.
- Rechazo de correos electrónicos duplicados.
- Validación de campos obligatorios.
- Validación de formatos de correo electrónico.
- Actualización y persistencia de información.
- Restricción de campos no permitidos.
- Consulta de usuarios existentes e inexistentes.
- Eliminación de usuarios y validación de su ausencia.

## 5. Manejo de datos de prueba

Los datos estáticos se centralizan en:

`src/test/resources/data/usuarios.json`

Las funciones reutilizables se encuentran en:

`src/test/resources/support/testData.feature`

Funciones disponibles:

- `uniqueEmail()`: genera correos electrónicos únicos.
- `buildUser()`: construye usuarios de prueba.
- `buildUpdatePayload()`: construye datos para escenarios de actualización.

El esquema de respuesta de usuario se centraliza en:

`src/test/resources/schemas/usuario.schema.json`

## 6. Limpieza automática

El proyecto implementa un mecanismo de limpieza mediante el hook `afterScenario` configurado en `karate-config.js`.

Los escenarios registran los identificadores de los usuarios creados durante su ejecución.

Al finalizar cada escenario, se invoca `cleanupUser.feature` para eliminar los registros temporales.

Esto permite mantener los escenarios independientes y reducir la acumulación de datos de prueba.

## 7. Ejecución del proyecto

### Requisitos previos

- Java JDK 21.
- Maven 3.9.16 o compatible.
- Acceso a internet para consumir la API de ServeRest.

### Ejecutar todas las pruebas

Desde la raíz del proyecto:

```bash
mvn clean test
```

### Configurar la URL del ambiente

```bash
mvn clean test -DbaseUrl=https://serverest.dev
```

## 8. Reportes de ejecución

Los reportes se generan en:

`target/karate-reports/`

Formatos disponibles:

| Formato | Ubicación |
|---|---|
| HTML | karate-summary.html |
| HTML por Feature | feature-html/ |
| JUnit XML | junit-xml/ |
| Cucumber JSON | cucumber-json/ |
| Karate JSONL | karate-json/ |

El reporte HTML permite consultar el resultado general, las métricas de ejecución, los Features, los escenarios y los pasos ejecutados.

## 9. Resultado de la última ejecución

| Indicador | Resultado |
|---|---:|
| Features ejecutados | 5 |
| Escenarios ejecutados | 26 |
| Escenarios aprobados | 26 |
| Escenarios fallidos | 0 |
| Porcentaje de aprobación | 100% |
| Estado de Maven | BUILD SUCCESS |

## 10. Comando de ejecución principal

```bash
mvn clean test
```
