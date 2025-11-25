# RuteX Go 🏛️📱

### *Aplicación móvil gamificada para turismo cultural en Extremadura*

<p align="center">
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg"/></a>
  <a href="https://github.com/TurisTechTeam-Dev/rutex-go-project/issues"><img src="https://img.shields.io/github/issues/TurisTechTeam-Dev/rutex-go-project.svg"/></a>
  <a href="https://developer.android.com"><img src="https://img.shields.io/badge/Platform-Android-green.svg"/></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Backend-Firebase-orange.svg"/></a>
</p>

## 👥 Equipo de Desarrollo - TurisTech Team

| Desarrollador | GitHub | Especialización |
|---------------|--------|-----------------|
| **Andrés Fernández Expósito** | [@AndresFE0209](https://github.com/AndresFE0209) | Backend & Coordinación |
| **Joel Manuel García Villarino** | [@Joeljole1987](https://github.com/Joeljole1987) | Backend & Diseño UX/UI |
| **Diego Vivas Paredes** | [@DiegoVP963](https://github.com/DiegoVP963) | Frontend & Diseño UX/UI |
| **María Mercedes Martínez Fragoso** | [@MercedesOrg01](https://github.com/MercedesOrg01) | Tutora del Proyecto |

**Centro Educativo:** IES Albarregas (Mérida, Badajoz)  
**Ciclo Formativo:** 2º FP Desarrollo de Aplicaciones Multiplataforma  
**Curso Académico:** 2025/26  
**Organización GitHub:** [@TurisTechTeam-Dev](https://github.com/TurisTechTeam-Dev)

---

## 🌟 Resumen
**RuteX Go** es una app móvil gamificada creada por **TurisTech Team** para potenciar el turismo cultural en Extremadura mediante rutas geolocalizadas, contenido histórico multimedia y dinámicas de gamificación (trivias, rangos, logros y rankings).  
Su objetivo es transformar la visita al patrimonio histórico en una experiencia educativa, interactiva y sostenible.

---

## 📑 Índice
- [🚀 Estado del proyecto](#-estado-del-proyecto)  
- [✨ Características principales](#-características-principales)  
- [🧩 Tecnologías](#-tecnologías)  
- [📁 Estructura del repositorio](#-estructura-del-repositorio)  
- [🛠️ Instalación y ejecución](#️-instalación-y-ejecución)  
- [🏗️ Arquitectura y decisiones técnicas](#️-arquitectura-y-decisiones-técnicas)  
- [📌 Requisitos no funcionales](#-requisitos-no-funcionales)  
- [📚 Documentación académica](#-documentación-académica)  
- [🤝 Cómo contribuir](#-cómo-contribuir)  
- [📝 Licencia y autores](#-licencia-y-autores)  
- [📞 Contacto](#-contacto)

---

## 🚀 Estado del proyecto
| Fase | Estado |
|------|--------|
| **Sprint 1** – Análisis y Diseño | 🟡 En progreso |
| **Entregable E1** | Prototipo funcional centrado en Mérida (auth, rutas, trivial básico, puntos/rangos) |

🔮 **Roadmap próximo:** mapas interactivos, gamificación avanzada, integración con comercios locales, pruebas y despliegue.

---

## ✨ Características principales
- 🗺️ Rutas culturales geolocalizadas con marcadores.  
- 🎯 Misiones y trivias asociadas a cada punto de interés.  
- 🏅 Sistema de puntos, rangos e insignias.  
- 🏆 Rankings locales y globales.  
- 👤 Autenticación y gestión de usuarios.  
- 🖼️ Contenido multimedia (texto, imágenes, audio).  
- 🔔 Futuro: recompensas comerciales, notificaciones push y posibles mejoras con RA.

---

## 🎯 Objetivos del Proyecto

- ✅ **Innovación Turística:** Ofrecer una experiencia turística gamificada única en Extremadura
- ✅ **Valorización Patrimonial:** Potenciar la apreciación del patrimonio cultural extremeño
- ✅ **Educación Interactiva:** Integrar dinámicas educativas para turistas de todas las edades
- ✅ **Impacto Económico:** Impulsar el comercio local mediante sistema de recompensas
- ✅ **Sostenibilidad:** Promover turismo responsable alineado con los ODS 2030
- ✅ **Formación Académica:** Aplicar conocimientos DAM en proyecto real con impacto social

---

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Android Nativo** - Kotlin/Java con Jetpack Compose
- **Flutter/Dart** - Desarrollo multiplataforma (Fase 2)

### Backend
- **Firebase Suite Completa** - Authentication, Firestore, Storage, Functions
- **Google Maps API** - Geolocalización y mapas interactivos
- **Firebase Analytics** - Métricas y comportamiento de usuarios
- **Firebase Cloud Messaging** - Notificaciones push inteligentes

### Herramientas de Desarrollo
- **Android Studio** - IDE principal para desarrollo nativo
- **Visual Studio Code** - Editor para Flutter y documentación
- **Git + GitHub** - Control de versiones y colaboración en equipo
- **GitHub Actions** - CI/CD automatizado y despliegue
- **Firebase Console** - Gestión del backend y analíticas

---

## 📁 Estructura del repositorio
--------------------------
rutex-go-project/  
├─ docs/                  — Documentación académica y técnica (memoria, análisis, diseño)  
├─ mobile-app/            — Código fuente de la aplicación  
│  ├─ android-native/     — Implementación Android (Kotlin)  
│  └─ flutter/            — Implementación Flutter (fase 2)  
├─ backend/               — Funciones y configuraciones de Firebase  
├─ assets/                — Recursos multimedia (imágenes, audio)  
├─ tests/                 — Pruebas unitarias e integración  
├─ scripts/               — Automatización y utilidades  
└─ README.md              — Este archivo

---

I## 🛠️ Instalación y ejecución

### 📌 Requisitos
- Android Studio 2020.3+  
- Android SDK API 24+  
- Proyecto Firebase configurado  
- Google Maps API Key  

### 📥 Clonado
```bash
git clone https://github.com/TurisTechTeam-Dev/rutex-go-project.git
cd rutex-go-project
git checkout -b feature/<nombre-funcionalidad>
```

### ⚠️ Notas importantes
- No subir claves ni archivos sensibles (**google-services.json**).  
- Instrucciones de compilación específicas en:  
  `mobile-app/android-native/README.md` (Sprint 2).

---

## 📅 Cronograma de Desarrollo (Metodología Ágil)

| Sprint | Fechas | Objetivos Principales | Estado | Responsable |
|--------|--------|-----------------------|--------|-------------|
| **Sprint 1** | 17/10 - 15/12 | Definición, Análisis y Diseño | 🔄 En progreso | Todos |
| **Sprint 2** | 01/11 - 15/11 | Fundamentos Técnicos y Firebase | ⏳ Pendiente | Diego |
| **Sprint 3** | 16/11 - 30/11 | Geolocalización y Sistema de Rutas | ⏳ Pendiente | Joel |
| **Sprint 4** | 01/12 - 15/12 | Gamificación Core y Trivias | ⏳ Pendiente | Andrés |
| **Sprint 5** | 16/12 - 30/12 | Rankings y Características Sociales | ⏳ Pendiente | Diego |
| **Sprint 6** | 01/01 - 15/01 | Integración, Pruebas y Optimización | ⏳ Pendiente | Joel |
| **Sprint 7** | 16/01 - 31/01 | Finalización, Documentación y Deploy | ⏳ Pendiente | Todos |

### Entregables por Evaluación
- **1ª Evaluación (15/12):** Propuesta, análisis de requisitos, mockups y arquitectura
- **2ª Evaluación (**/03):** MVP funcional con características principales implementadas
- **3ª Evaluación (**/06):** Aplicación completa, documentación final y presentación

## 📱 Capturas de Pantalla

*[Pendiente - Se añadirán mockups en Sprint 1 y capturas reales en Sprint 6]*
2]

---

## 🏗️ Arquitectura y decisiones técnicas

### 📌 ADRs principales
- **ADR-001:** Firebase como BaaS (rápido, escalable y flexible).  
- **ADR-002:** Kotlin como base; Flutter para futuro multiplataforma.  
- **ADR-003:** Firestore como base de datos por flexibilidad del modelo NoSQL.

### 📚 Colecciones Firestore

/users  
/cities  
/routes  
/monuments  
/missions  
/rankings


### 🔗 Integraciones
- Google Maps: mapas, distancias y marcadores.  
- Firebase Storage: contenido multimedia.  
- Firebase Messaging: notificaciones.

---

## 📚 Documentación académica
La documentación completa está en: `docs/memoria.md`.

---

## 🤝 Proceso de Contribución

Este proyecto es desarrollado como **Trabajo Final de Grado** por estudiantes de **DAM** en **IES Albarregas**.

### Flujo de Trabajo para el Equipo:
1. **Asignación de tareas** por sprint en reuniones de planificación
2. **Crear rama específica:** `git checkout -b feature/nueva-funcionalidad`
3. **Desarrollo en rama aislada** con commits descriptivos
4. **Pull Request** para revisión del código entre compañeros
5. **Merge a develop** tras aprobación de al menos 1 compañero
6. **Deploy a main** solo para versiones estables
7. Incluye documentación y pruebas.

---

## 📄 Licencia y Derechos

Este proyecto está licenciado bajo la **Licencia MIT** - ver [LICENSE](LICENSE) para detalles completos.

**Copyright (c) 2025 TurisTechTeam-Dev**  
Andrés Fernández Expósito, Joel Manuel García Villarino, Diego Vivas Paredes

---

## 📞 Contacto y Soporte

**TurisTech Team - Desarrollo de Software Turístico**

- 🐙 **Organización GitHub:** [@TurisTechTeam-Dev](https://github.com/TurisTechTeam-Dev)
- 📂 **Repositorio Principal:** [rutex-go-project](https://github.com/TurisTechTeam-Dev/rutex-go-project)
- 🎫 **Issues y Soporte:** [GitHub Issues](https://github.com/TurisTechTeam-Dev/rutex-go-project/issues)
- 📧 **Email del Equipo:** *[turistechteam@gmail.com]*
- 🏫 **Centro Académico:** IES Albarregas, Mérida (Badajoz)

### Contacto Individual:
- **Andrés Fernández:** [@AndresFE0209](https://github.com/AndresFE0209) - *Backend & Coordinación*
- **Joel García:** [@Joeljole1987](https://github.com/Joeljole1987) - *Backend & Diseño UX/UI*  
- **Diego Vivas:** [@DiegoVP963](https://github.com/DiegoVP963) - *Frontend & Diseño UX/UI*

---

**⭐ Si te gusta nuestro proyecto, no olvides darle una estrella en GitHub**

*Desarrollado con ❤️ por TurisTech Team para impulsar el turismo cultural en Extremadura*

---

**IES Albarregas** | **Desarrollo de Aplicaciones Multiplataforma** | **Curso 2025/26**


