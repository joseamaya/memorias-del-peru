# ADR-0017 — Cabezas de la Microsoft Rocketbox Avatar Library

- Estado: Aceptado
- Fecha: 2026-11-12
- Matiza: [ADR-0016](0016-personajes-realistas-makehuman.md) (la cabeza y el pelo de MakeHuman se sustituyen; cuerpo, ropa, esqueleto y animaciones siguen igual)

## Contexto

Tras corregir la postura y la cara (ADR-0016), los personajes seguían viéndose poco realistas de cerca. La cara de MakeHuman tiene poco detalle: una malla de juego de unos 3000 triángulos para todo el cuerpo y una textura de piel genérica. Los agentes no pueden esculpir caras a mano. El responsable del proyecto preguntó por la manera de tener personajes hechos por artistas y aprobó probar Rocketbox.

La prueba (2026-11-12) montó la cabeza de dos avatares sobre el cuerpo de MakeHuman con la ropa andina. La cara pasó de muñeco a persona. El responsable aprobó integrarlo.

## Opciones consideradas

1. **Avatares de Rocketbox completos.** Rechazada: la ropa moderna (vaqueros, camisas, zapatillas) está modelada como parte del cuerpo y no hay cuerpo desnudo debajo que vestir.
2. **Generación por IA a partir de imágenes.** Rechazada por ahora: las licencias varían y la topología necesita limpieza para animarse.
3. **Artista 3D o escaneos comprados.** Sigue siendo el camino hacia el fotorrealismo, fuera del alcance de los agentes.
4. **Solo la cabeza de Rocketbox sobre el cuerpo de MakeHuman.** Aceptada.

## Decisión

- **Fuente:** Microsoft Rocketbox Avatar Library, https://github.com/microsoft/Microsoft-Rocketbox.
  - Licencia MIT («Copyright (c) 2020 Microsoft»): permite uso comercial y modificación, con la condición de incluir el aviso de copyright. El aviso está en `assets/models/LICENSE.md`.
  - El repositorio está archivado (solo lectura) desde el 2 de octubre de 2026.
- **Avatares usados:** solo se descargan el FBX y las texturas de cabeza y de pelo; no se versionan.
  - **Hombres:** `Male_Adult_09`, `Male_Adult_10`, `Business_Male_02` y `Business_Male_06`.
  - **Mujeres:** `Medical_Female_01`, `Female_Adult_11`, `Sports_Female_02` y `Business_Female_01`.
  - **Criterio de elección:** sin casco, gorra ni maquillaje moderno, y sin barba, porque el vello facial era escaso.
- **Injerto en `pch_people.py`:**
  1. Del FBX se toman las caras de los materiales de cabeza y de pelo; el cuerpo y la ropa modernos se descartan.
  2. La cabeza se escala por la anchura de la cara a la altura de los ojos y se coloca sobre los ojos de MakeHuman.
  3. Se quitan la cabeza, los ojos, las cejas, las pestañas y el pelo de MakeHuman, junto con la piel del cuerpo que la nueva cabeza tapa.
  4. El borde del cuello se pega a la superficie del cuerpo. La cabeza sigue al hueso `Head`, y el cuello toma los pesos del cuerpo.
  5. La textura de la cara se lleva al mismo moreno que el cuerpo, con su mapa de normales. El pelo usa recorte por alfa.
  6. La cinta y el paño de la cabeza se construyen sobre la forma de la cabeza nueva.
- **Más variedad:** los tres vecinos dejan de ser clones del mismo modelo. Se añaden `pch_npc_villager_b` y `pch_npc_villager_c`, con otras caras y otros colores. Los cuatro hombres que comparten escena (mensajero, curaca, principales y agricultor) tienen caras distintas. Los dos principales comparten modelo, como antes.

## Consecuencias

- Caras, ojos y pelo con calidad de artista y texturas de 2K reducidas a 1K. Los personajes resultan más ligeros (6900–8600 triángulos), porque la cabeza de Rocketbox sustituye a la de MakeHuman y a sus ojos, cejas, pestañas y pelo.
- Los 10 `.glb` de personaje suman 11 MB. La medición está en [docs/08](../08_entorno_y_rendimiento.md).
- **Regenerar los personajes** exige también los avatares de Rocketbox (`--rocketbox`, ver la cabecera de `pch_people.py`).
- **Interpretación declarada (PCH-018):**
  - Los rostros son de personas actuales con la piel teñida, no retratos andinos.
  - Los peinados son los de los avatares (corto, coleta, moño o melena), no las trenzas.
- La unión del cuello puede notarse de muy cerca en los hombres, cuyo trozo de cabeza acaba a media altura del cuello. En las mujeres queda bajo la ropa.
- Sin rasgos de expresión ni boca animada: los avatares traen formas faciales, pero no se usan en esta fase.
