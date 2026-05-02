/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripcion: Esta aplicacion y su codigo fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribucion o uso no autorizado.
  Anio: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TermsConditionsDialog extends StatelessWidget {
  const TermsConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : AppColors.negroTexto;

    return AlertDialog(
      title: const Text('Términos y condiciones de uso'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Text(
            _termsConditionsText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              height: 1.35,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

const String _termsConditionsText = '''
TÉRMINOS Y CONDICIONES DE USO - RUTEX GO

1. ¿Quién hay detrás de RuteX Go?

RuteX Go es una aplicación desarrollada por TurisTech Team como proyecto de Trabajo de Fin de Grado (TFG). Si necesitas ponerte en contacto con nosotros, puedes hacerlo en cualquier momento a través de turistechteam@gmail.com.

2. Para qué sirve esta aplicación

RuteX Go nació con una idea clara: ayudarte a explorar mejor. La app te permite visualizar rutas turísticas, descubrir puntos de interés y guiarte durante tus desplazamientos. Para lograrlo, integramos servicios como Google Maps, que añaden funcionalidades de geolocalización y cartografía.

3. Usar la app implica aceptar estas condiciones

Si accedes a RuteX Go, asumes que has leído y aceptado estos Términos y Condiciones. No hay letra pequeña.

4. Cómo esperamos que uses la aplicación

La app es de uso personal y no comercial. Al usarla, te comprometes a respetar la legislación vigente, actuar de buena fe y no interferir con su funcionamiento.

5. Servicios de terceros

RuteX Go se apoya en servicios externos, principalmente Google Maps. Cada uno de ellos tiene sus propios términos y condiciones, que el usuario acepta de forma independiente. TurisTech Team no controla ni se responsabiliza de su disponibilidad o comportamiento.

6. Crear una cuenta

Algunas funcionalidades requieren registro. Para ello, solo necesitas un correo electrónico y una contraseña. Tú eres responsable de mantener esas credenciales en privado; si compartes tu acceso, lo haces bajo tu propia cuenta y riesgo.

7. Tus datos personales

7.1 Marco legal

El tratamiento de tus datos se rige por el Reglamento General de Protección de Datos (RGPD) y la Ley Orgánica de Protección de Datos y Garantía de los Derechos Digitales (LOPDGDD).

7.2 Responsable del tratamiento

El responsable somos nosotros: TurisTech Team. Contacto: turistechteam@gmail.com.

7.3 Qué datos recogemos

Solo los imprescindibles para que la app funcione:

- Tu dirección de correo electrónico.
- Tu contraseña, que se almacena cifrada y nunca en texto plano.

7.4 Para qué usamos esos datos

Únicamente para tres cosas: gestionar tu registro, autenticarte cada vez que entras y garantizar que el servicio funcione correctamente.

7.5 ¿Por qué podemos tratar tus datos?

Porque nos lo has permitido. La base legal para el tratamiento se apoya en tu consentimiento como usuario (art. 6.1.a RGPD) y en la necesidad de gestionar la relación de uso de la app (art. 6.1.b RGPD).

7.6 ¿Cuánto tiempo guardamos tus datos?

Los conservamos mientras tu cuenta esté activa. Si decides eliminarla, procedemos a suprimir tus datos. Eso sí, en algunos casos la ley nos obliga a mantenerlos bloqueados durante un período determinado antes de borrarlos definitivamente.

7.7 Tus derechos, claros y sin rodeos

Tienes derecho a acceder a tus datos, corregirlos, eliminarlos, limitar su uso y oponerte a su tratamiento. Para ejercer cualquiera de estos derechos, escríbenos a turistechteam@gmail.com.

Si crees que hemos vulnerado alguno de tus derechos, también puedes presentar una reclamación ante la Agencia Española de Protección de Datos (AEPD).

7.8 Seguridad

Aplicamos las medidas técnicas y organizativas necesarias para proteger tus datos frente a accesos no autorizados, pérdidas o alteraciones. No es solo una obligación legal; es una responsabilidad que tomamos en serio.

7.9 Datos y servicios externos

El uso de servicios como Google Maps puede implicar que terceros traten ciertos datos según sus propias políticas de privacidad. Al usar la app, reconoces y aceptas esa posibilidad.

8. Responsabilidad

La información que ofrece RuteX Go es orientativa. No garantizamos que sea siempre exacta ni que el servicio esté disponible sin interrupciones. Las decisiones que tomes durante su uso y el cumplimiento de las normas de circulación y seguridad son responsabilidad tuya.

9. Propiedad intelectual

RuteX Go, su código, diseño, estructura, bases de datos, gráficos y documentación es obra de sus tres creadores:

- Andrés Fernández Expósito.
- Joel Manuel García Villarino.
- Diego Vivas Paredes.

Todos los derechos están reservados conforme a la legislación española de propiedad intelectual.

9.1 Licencia de uso

Te concedemos una licencia personal, no exclusiva, intransferible y revocable para usar la app con fines estrictamente académicos o de evaluación. Nada más.

9.2 Lo que no puedes hacer

Sin autorización escrita de los titulares, está prohibido usar la app con fines comerciales, reproducirla o distribuirla, modificarla o crear obras derivadas, y cualquier intento de acceder al código fuente mediante ingeniería inversa o descompilación.

9.3 Sin garantías

La app se entrega tal como está. Los titulares no asumen responsabilidad por daños derivados de su uso.

9.4 Contexto académico

RuteX Go nació como Trabajo de Fin de Grado. Su uso queda limitado a fines educativos, de evaluación o demostración.

10. Cambios en estos términos

Podemos actualizar estos Términos en cualquier momento. Si lo hacemos, te lo haremos saber.

11. Legislación y jurisdicción

Estos Términos se rigen por la legislación española. Cualquier conflicto derivado del uso de la app se someterá a los Juzgados y Tribunales de Mérida (Badajoz), salvo que la normativa establezca un foro distinto en favor del usuario.

12. Contacto

¿Tienes dudas o quieres ejercer algún derecho? Por favor, no dudes en escribirnos: turistechteam@gmail.com.
''';
