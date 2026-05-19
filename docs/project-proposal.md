# Propuesta de Proyecto: RuteX Go

## Información General

| Propiedad | Detalles |
| :--- | :--- |
| **Título** | RuteX Go: Aplicación Móvil Gamificada para Turismo Cultural |
| **Proyecto** | [TurisTechTeam-Dev/rutex-go-project](https://github.com/TurisTechTeam-Dev/rutex-go-project) |
| **Estado** | Versión 1.0 |
| **Ciclo** | 2º FP Desarrollo de Aplicaciones Multiplataforma |
| **Centro** | IES Albarregas (Mérida, Badajoz) |
| **Curso** | 2025/26 |

### Equipo de Desarrollo

* **Andrés Fernández Expósito** ([@AndresFE0209](https://github.com/AndresFE0209))  
  *Rol: Responsable de Backend, Base de Datos y Coordinación*
* **Joel Manuel García Villarino** ([@Joeljole1987](https://github.com/Joeljole1987))  
  *Rol: Desarrollo Frontend y Diseño de Experiencia de Usuario*
* **Diego Vivas Paredes** ([@DiegoVP963](https://github.com/DiegoVP963))  
  *Rol: Desarrollo Frontend y Especialista en Interfaz de Usuario*

---

## 1. Introducción

El turismo cultural en ciudades con una carga histórica significativa, como Mérida, suele basarse en modelos tradicionales de visitas guiadas o recorridos sin contexto narrativo. Este enfoque resulta limitado para captar el interés de un perfil de turista joven y nativo digital, quien demanda experiencias interactivas, personalizadas y dinámicas.

RuteX Go surge como una solución tecnológica de turismo inteligente, diseñada para transformar el recorrido patrimonial en una aventura gamificada. A través de rutas geolocalizadas, desafíos históricos y un sistema de progresión de niveles, la aplicación permite al usuario interactuar con el entorno de una manera educativa y eficiente.

Los pilares fundamentales del proyecto son:

- **Ruta**: Optimización de recorridos patrimoniales mediante geolocalización precisa.
- **Extremadura (EX)**: Revalorización del patrimonio cultural y artístico de la región.
- **Go (Acción)**: Impulso al dinamismo y a la gamificación como herramientas clave para descubrir el legado histórico.

---

## 2. Resumen Ejecutivo

RuteX Go aborda la brecha existente en el mercado del turismo independiente, donde los visitantes de ciudades históricas como Mérida a menudo enfrentan dificultades para organizar sus recorridos y contextualizar el patrimonio que observan. Nuestra solución centraliza la planificación y la experiencia cultural, ofreciendo rutas optimizadas, navegación GPS en tiempo real y misiones interactivas.

La propuesta se materializa en la Versión 1.0 de la aplicación completa, centrada en una experiencia de usuario robusta y totalmente funcional. Este lanzamiento incluye:

- **Gestión integral de usuarios:** Sistema de autenticación seguro y personalizado mediante Firebase.
- **Navegación inteligente:** Rutas punto a punto con estimación de duración y soporte de geolocalización.
- **Gamificación aplicada:** Sistema de trivias (3 preguntas por hito) para validar el aprendizaje del usuario durante la visita.
- **Reconocimiento y progresión:** Sistema de puntuación que otorga rangos dinámicos, desde "esclavo" hasta "emperador", incentivando la recurrencia.

RuteX Go no solo mejora la experiencia turística, sino que establece una base tecnológica escalable, diseñada para fomentar el flujo de visitantes hacia comercios locales y promover un modelo de turismo sostenible y responsable.

---

## 3. Justificación del Proyecto

RuteX Go tiene como objetivo principal modernizar la experiencia turística, eliminando la dependencia de soportes físicos y fomentando un modelo de turismo sostenible. La aplicación no solo actúa como guía, sino como un motor de dinamización económica y cultural, ofreciendo ventajas competitivas claras frente a las soluciones actuales.

### 3.1 Análisis de Competencia

| Aplicación | Fortalezas | Debilidades |
| :--- | :--- | :--- |
| **Visit Mérida** | Uso de beacons, QR, NFC; geolocalización | Ausencia de gamificación; interfaz obsoleta |
| **Muévete Extremadura** | Información turística y comercial | Sin retos interactivos; dependencia total de red |
| **Cáceres Turismo** | Contenido multimedia abundante | Aplicación pesada; sin misión ni recompensa |
| **RuteX Go** | Gamificación total, integración Firestore/Maps | Fase de despliegue inicial |

La diferenciación de RuteX Go radica en la integración de la gamificación como eje central del recorrido, transformando una visita pasiva en una experiencia activa y gratificante.

---

## 4. Arquitectura del Sistema

La selección del *stack* tecnológico responde a necesidades de escalabilidad, rendimiento y mantenibilidad:

- **Frontend:** Flutter (Dart), permitiendo una compilación nativa eficiente para iOS y Android con una única base de código.
- **Backend:** Firebase (Firestore, Authentication, Storage). Arquitectura *serverless* que garantiza alta disponibilidad y reducción de costes operativos.
- **Integración:** Google Maps API para la gestión geoespacial y cálculo de rutas en tiempo real.

---

## 5. Roadmap de Expansión y Estrategia de Crecimiento

Tras la consolidación y despliegue de la Versión 1.0, el proyecto se orienta hacia la monetización sostenible, la mejora de la experiencia inmersiva y la internacionalización. Este plan estratégico define las fases de escalabilidad proyectadas para RuteX Go:

### 5.1 Ecosistema de Comercios Locales (Monetización)
* **Sistema de Fidelización:** Integración de un monedero digital (*wallet*) que permita a los usuarios canjear los puntos obtenidos por misiones en descuentos directos en establecimientos adheridos.
* **Publicidad Geo-cercada:** Implementación de notificaciones *push* de proximidad para promocionar comercios locales de restauración y artesanía de forma no intrusiva.
* **Analítica B2B:** Desarrollo de un *dashboard* para negocios locales que permita medir el flujo de visitantes y el impacto real de las campañas de fidelización.

### 5.2 Tecnologías Inmersivas
* **Realidad Aumentada (RA):** Desarrollo de una capa visual sobre la cámara del dispositivo que superponga recreaciones históricas en 3D sobre monumentos y ruinas actuales.
* **Visitas Virtuales (VR):** Integración de módulos de realidad virtual para experiencias inmersivas desde dispositivos móviles, fomentando el interés turístico previo al viaje.

### 5.3 Internacionalización y Accesibilidad
* **Soporte Multilenguaje:** Implementación de un motor de localización dinámica (*localization engine*) para ofrecer la interfaz y los contenidos culturales en inglés, francés, alemán y portugués, ampliando el espectro de usuarios potenciales.
* **Accesibilidad:** Adaptación de la interfaz bajo estándares WCAG para garantizar la usabilidad a personas con diversidad funcional.

### 5.4 Funcionalidades Sociales Avanzadas
* **Rutas Colaborativas:** Sistema descentralizado para que los usuarios puedan crear, valorar y compartir sus propias rutas patrimoniales.
* **Leaderboards Globales:** Rankings competitivos a nivel regional para incentivar la exploración profunda de todo el legado histórico de Extremadura.

---

## 6. Modelo de Sostenibilidad y Viabilidad

La viabilidad del proyecto no depende únicamente del desarrollo técnico, sino de su capacidad para mantenerse operativo, evolucionar y generar valor a largo plazo. Proponemos un modelo de sostenibilidad híbrido que garantiza el retorno tanto social como económico:

* **Sostenibilidad Institucional (Pilar Público):** La aplicación actúa como una herramienta de promoción turística de alto valor para la ciudad. Esto permite establecer convenios con entidades locales (Ayuntamientos, Oficinas de Turismo) para la gestión centralizada y oficial de los puntos de interés, asegurando que el contenido sea preciso y actualizado.
* **Modelo de Negocio Escalable:** El proyecto contempla la integración futura de una plataforma B2B. Este módulo permitirá que los comercios locales (restauración, artesanía, servicios) gestionen su visibilidad y ofrezcan cupones de fidelización personalizados, transformando la aplicación en un activo económico directo para el tejido comercial de la región.
* **Optimización de Costes Operativos:** Gracias a la arquitectura *serverless* (Backend bajo demanda) de Firebase, el coste de infraestructura es dinámico y ajustado al uso real. Esto elimina la necesidad de mantener servidores físicos o instancias de alta carga, permitiendo que la aplicación sea financieramente sostenible incluso en fases de baja adopción o durante las etapas iniciales de lanzamiento.

---

## 7. Estrategia de Implementación y Adopción (Go-to-Market)

Para garantizar la transición efectiva de un prototipo funcional a un producto disponible en el mercado (Play Store), se ha definido una estrategia de despliegue gradual:

* **Fase de Lanzamiento (MVP+):** Implementación de puntos de activación física (códigos QR en monumentos y oficinas de turismo) para reducir la fricción de entrada, permitiendo al usuario descargar la aplicación y comenzar la experiencia de forma inmediata.
* **Fidelización y Retención:** Aplicación de mecánicas de gamificación (rango, trivias, desbloqueos) como motor principal de retención. Se utilizarán métricas de usuario para monitorizar el *churn rate* (tasa de abandono) y ajustar la dificultad o incentivos de las rutas según el comportamiento real.
* **Validación y Crecimiento:** Uso de analítica de datos anonimizada para testear el flujo de conversión. Este enfoque basado en datos (*data-driven*) permitirá iterar el producto rápidamente, optimizando la experiencia de usuario antes de escalar a mercados geográficos más amplios.

---

## 8. Excelencia Operativa y Escalabilidad

El tribunal académico y los posibles inversores evaluarán la capacidad del sistema para gestionar carga. La arquitectura propuesta está diseñada para la resiliencia y el crecimiento:

* **Arquitectura *Cloud-Native*:** El uso de servicios gestionados en la nube (Firebase/Firestore) garantiza una escalabilidad horizontal automática. La infraestructura crece dinámicamente con la demanda de usuarios sin requerir intervención manual ni gestión de servidores complejos.
* **Ciclo de Vida del Desarrollo (DevOps):** Implementación de flujos de trabajo de integración y despliegue continuo (CI/CD). Esto permite realizar actualizaciones rápidas, correcciones de errores (*hotfixes*) y despliegue de nuevas funcionalidades sin interrupciones en el servicio.
* **Monitorización y Diagnóstico:** Configuración de herramientas de observabilidad para detectar errores de ejecución y cuellos de botella en tiempo real, garantizando una alta disponibilidad y una experiencia de usuario estable y profesional bajo cualquier carga de trabajo.

---

## 9. Cumplimiento Normativo y Seguridad (Compliance)

La publicación en *stores* oficiales exige estándares de seguridad y transparencia que hemos integrado desde la concepción del producto:

* **Protección de Datos (RGPD/GDPR):** Implementación de políticas de privacidad transparentes, asegurando que el tratamiento de datos personales esté alineado con la normativa europea. La aplicación solicita los permisos mínimos estrictamente necesarios (geolocalización) para su correcto funcionamiento.
* **Seguridad de Capas:** Aplicación del principio de *Least Privilege* (menor privilegio) en las reglas de acceso al Backend, garantizando que cada usuario solo acceda a la información necesaria y protegiendo la integridad de la base de datos contra accesos no autorizados.
* **Estándares de Publicación:** Cumplimiento estricto de las guías de diseño y seguridad de Google Play Store, asegurando que el proyecto supere los procesos de revisión y certificación necesarios para un lanzamiento comercial seguro y fiable.

---

**Documento de Propuesta de Proyecto - RuteX Go**  
*Versión 1.0*  
*TurisTech Team - Andrés Fernández Expósito, Joel Manuel García Villarino, Diego Vivas Paredes*  
*IES Albarregas - Desarrollo de Aplicaciones Multiplataforma*  
*Organización: [@TurisTechTeam-Dev](https://github.com/TurisTechTeam-Dev)*
