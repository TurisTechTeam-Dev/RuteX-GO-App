# Propuesta de Proyecto: RuteX Go

## Información General

**Título del Proyecto:** RuteX Go - Aplicación Móvil Gamificada para Turismo Cultural en Extremadura

**Equipo de Desarrollo:** TurisTech Team  
**Organización GitHub:** [@TurisTechTeam-Dev](https://github.com/TurisTechTeam-Dev)  
**Repositorio:** [github.com/TurisTechTeam-Dev/rutex-go-project](https://github.com/TurisTechTeam-Dev/rutex-go-project)

**Propietarios y Desarrolladores:**
- Andrés Fernández Expósito - [@AndresFE0209](https://github.com/AndresFE0209) - Backend/Base de Datos & Coordinación
- Joel Manuel García Villarino - [@Joeljole1987](https://github.com/Joeljole1987) - frontend/Backend & Diseño UX/UI
- Diego Vivas Paredes - [@DiegoVP963](https://github.com/DiegoVP963) - Frontend & Diseño UX/UI

**Contexto Académico:**
- **Ciclo Formativo:** 2º FP Desarrollo de Aplicaciones Multiplataforma
- **Centro Educativo:** IES Albarregas (Mérida, Badajoz)
- **Curso Académico:** 2025/26
- **Fecha de Inicio:** 17 de octubre de 2025
- **Fecha de Entrega:** *******

---

## 1. Introducción

El turismo cultural en ciudades extremeñas como Mérida sigue un modelo tradicional basado en visitas guiadas o recorridos sin contexto, lo cual resulta poco atractivo para turistas jóvenes y visitantes independientes. Muchas personas no saben qué monumentos visitar ni cuánto tiempo dedicar a cada uno, por lo que la experiencia puede ser confusa y poco interactiva.

RuteX Go nace como una alternativa moderna, gamificada y educativa que permite recorrer la ciudad mediante rutas interactuando con trivias, puntos, rangos y contenido histórico de forma accesible y divertida.

El nombre del proyecto sintetiza su identidad:
- **Ruta** → núcleo del proyecto: recorrer el patrimonio.
- **EX (Extremadura)** → referencia territorial directa.
- **Go** → movimiento, acción y gamificación.

---

## 2. Resumen Ejecutivo

El turista independiente es el perfil mayoritario en ciudades históricas como Mérida. Este suele carecer de orientación clara sobre qué visitar y en qué orden. RuteX Go resuelve este problema ofreciendo rutas organizadas con duración estimada, navegación GPS y misiones tipo trivial que enseñan historia local.

El objetivo del MVP para la primera evaluación es un prototipo funcional centrado en Mérida que incluya:
- Gestión de usuarios (login, registro, recuperación).
- Selección de ciudad.
- Rutas disponibles con navegación punto a punto.
- Misiones/quiz de 3 preguntas por monumento.
- Sistema de puntuación y rangos (de "esclavo" a "emperador").

---

## 3. Justificación del Proyecto

RuteX Go permitirá mejorar la experiencia turística, fomentar el comercio local y promover un turismo sostenible sin necesidad de folletos físicos. Además, introduce gamificación, lo que ofrece una ventaja competitiva real respecto a otras aplicaciones turísticas regionales.

### 3.1 Análisis de Competencia

| Aplicación | Pros | Contras |
|-----------|------|---------|
| **Visit Mérida** | Uso de beacons, QR, NFC; geolocalización | Sin gamificación; interfaz mejorable |
| **Muévete Extremadura** | Información turística + comercial; audioguías | Sin retos; depende de internet |
| **Cáceres Turismo Oficial** | Mucho contenido multimedia; tarjeta turística | Pesada; sin misiones ni recompensas |
| **Extremadura Rural** | Muchas rutas rurales y naturales; sostenibilidad | Sin geolocalización interactiva; sin gamificación |
| **RuteX Go** | Gamificación completa, Firestore, Maps API, rutas educativas | Aún sin beacons/NFC; requiere creación de contenido propio |

---

## 4. Contribución a Objetivos de Desarrollo Sostenible (ODS)

RuteX Go contribuye especialmente a:

- **ODS 8 — Trabajo decente y crecimiento económico:** Promueve el comercio local mediante turismo a pie.  
- **ODS 11 — Ciudades y comunidades sostenibles:** Difunde el patrimonio histórico de forma accesible.  
- **ODS 12 — Consumo responsable:** Elimina folletos físicos.  
- **ODS 13 — Acción por el clima:** Turismo sin vehículos, sin emisiones.  
- **ODS 17 — Alianzas:** Proyecto colaborativo entre estudiantes, centros educativos y futuro apoyo institucional.

---

## 5. Historias de Usuario (HU)

### HU-011 — Autenticación completa  
El usuario puede iniciar sesión y recuperar su contraseña mediante email.

### HU-012 — Registro de usuario  
El usuario puede registrarse mediante Firebase Authentication.

### HU-013 — Selección de ciudad  
El usuario selecciona una ciudad y accede a las rutas disponibles.

### HU-014 — Navegación GPS  
El usuario ve su ubicación en el mapa y avanza punto a punto durante la ruta.

### HU-015 — Misiones/Quiz  
Al llegar a un monumento, el usuario completa un quiz de 3 preguntas y gana puntos para subir de rango.

---

## 6. Backlog – Metodología MoSCoW

### MUST
- Login / registro
- Rutas operativas
- Misiones / trivias
- Sistema de puntos y ranking

### SHOULD
- Logros visuales
- Mapas interactivos mejorados

### COULD
- Recompensas en comercios locales
- Realidad aumentada

---

## 7. Arquitectura

### 7.1 Diagramas (C1 y C2)
Arquitectura basada en:
- Aplicación móvil Flutter + Kotlin (cuando se requiera funcionalidad nativa).
- Firebase como backend (Auth, Firestore, Storage, Messaging).
- Google Maps API para mapas y GPS.
- Firebase Console como panel de administración, métricas y logs.

### 7.2 ADR — Decisiones de Arquitectura

**ADR-001 — Firebase como BaaS**  
Integración rápida, escalabilidad y reducción de complejidad backend.

**ADR-002 — Flutter/Kotlin como stack móvil**  
Flutter para desarrollo multiplataforma ágil; Kotlin para integración nativa en Android.

**ADR-003 — Firestore como base de datos NoSQL**  
Estructura flexible para guardar rutas, monumentos, misiones y perfiles de usuario.

---

## 8. Integraciones y Dependencias

- **Firebase Auth:** sesiones, login y registro.
- **Firestore:** rutas, ciudades, monumentos, trivias, puntuaciones, rankings.
- **Firebase Storage:** imágenes asociadas a monumentos o contenido multimedia.
- **Firebase Messaging:** notificaciones push (futuro).
- **Google Maps API:** renderizado del mapa, ubicación GPS, marcadores.

---

## 9. Requisitos No Funcionales (NFR)

- **NFR-001:** Tiempo de respuesta general < 2–3s.
- **NFR-002:** Seguridad mediante Firebase Authentication.
- **NFR-003:** Todas las comunicaciones deben ser HTTPS.
- **NFR-004:** Interfaz intuitiva y coherente.
- **NFR-005:** Actualización GPS cada 2–3s.
- **NFR-006:** Registro de eventos mediante Firebase Analytics.
- **NFR-007:** Pruebas unitarias, integración y rendimiento.
- **NFR-008:** Accesibilidad básica (contrastes, tipografía).
- **NFR-009:** Bajo consumo de batería.
- **NFR-010:** Cacheo ligero y tolerancia a fallos.

---

## 10. Diseño y Prototipo Figma

### Paleta de colores
- Verde: `#007A3D`
- Verde claro: `#4CAF70`
- Blanco: `#FFFFFF`
- Gris neutro: `#7A8587`
- Negro claro: `#2F3333`
- Negro: `#0B0B0B`

### Tipografía — Montserrat
- H1: 28 / Bold  
- H2: 22 / SemiBold  
- Body: 16 / Regular  
- Inputs: 14 / Regular  

### Estilo Visual
- Minimalista y limpio  
- Botones redondeados  
- Enfoque en usabilidad y claridad  
- Estética de “aplicación turística gamificada”

---

## 11. Anexos

### 11.1 Plan de pruebas
Pruebas piloto realizadas en Mérida con rutas reales.

### 11.2 KPIs iniciales
Pendiente de definición.

### 11.3 Enlaces del proyecto
- **Trello:** [Tablero del Proyecto](https://trello.com/b/4BG86pOo/pidam2a-turistech-team-rutex-go)  
- **GitHub (App):** [Repositorio RuteX Go](https://github.com/TurisTechTeam-Dev/RuteX-Go-App)  
- **Figma (Prototipo):** [Diseño en Figma](https://www.figma.com/design/e0CsJ3JseYF9CZ494aazFS/RuteX-Go?node-id=0-1&t=srIv5Qz8igajXF2e-1)  
- **Documentación Técnica:** *(pendiente)*  


### 11.4 Changelog de E1
Por el momento, sin cambios registrados.

---

**TurisTech Team – Proyecto RuteX Go – 2024/2025**  

## Conclusiones y Consideraciones Futuras

### Viabilidad del Proyecto
RuteX Go representa un proyecto técnicamente viable y educativamente valioso que aprovecha tecnologías maduras (Android, Firebase) para crear una solución innovadora en el sector turístico. La combinación de gamificación, contenido cultural y tecnología móvil posiciona el proyecto como una contribución significativa tanto al portfolio académico del equipo como al panorama de aplicaciones turísticas en Extremadura.

### Escalabilidad y Sostenibilidad
El proyecto está diseñado con arquitectura escalable que permite:
- **Expansión geográfica** a otras ciudades extremeñas y regiones españolas
- **Evolución tecnológica** hacia multiplataforma (iOS, web) en futuras iteraciones
- **Modelo de negocio** sostenible mediante partnerships con instituciones turísticas
- **Comunidad de usuarios** autosostenible mediante gamificación y contenido generado

### Oportunidades de Continuidad
Post-académicamente, RuteX Go ofrece múltiples caminos de desarrollo:
- **Comercialización** con instituciones turísticas regionales
- **Incubación empresarial** como startup de tecnología turística
- **Colaboración académica** con universidades e instituciones culturales
- **Contribución open source** a la comunidad de desarrollo turístico

---

**Documento de Propuesta de Proyecto - RuteX Go**  
*Versión 5.0 - 03 de diciembre de 2025*  
*TurisTech Team - Andrés Fernández Expósito, Joel Manuel García Villarino, Diego Vivas Paredes*  
*IES Albarregas - Desarrollo de Aplicaciones Multiplataforma*  
*Organización: [@TurisTechTeam-Dev](https://github.com/TurisTechTeam-Dev)*
