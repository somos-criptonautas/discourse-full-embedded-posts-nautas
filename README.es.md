# Full embedded posts

[ENGLISH](README.md) | **ESPAÑOL**

Componente de tema de Discourse para los temas creados por la función de
[Embedding](https://meta.discourse.org/t/embedding-discourse-comments-via-javascript/31963)
desde un blog Ghost:

- el artículo completo se muestra al cargar, en lugar de un extracto más un botón "Mostrar más"
- las tarjetas de marcador de Ghost se muestran como tarjetas estilo onebox
- las tarjetas de aviso (callout) de Ghost se muestran con la paleta de avisos del foro, conservando el emoji de Ghost

## Instalación

Admin → Personalizar → Temas → Componentes → Instalar → Desde un repositorio git, con la URL de este repo.

## Ajuste requerido del sitio

El estilo de las tarjetas necesita que las clases de Ghost sobrevivan a la importación. En `allowed embed classnames`,
**añade** al valor existente (por defecto es `emoji`, no lo reemplaces):

```
kg-card kg-bookmark-card kg-bookmark-container kg-bookmark-content kg-bookmark-title kg-bookmark-description kg-bookmark-metadata kg-bookmark-icon kg-bookmark-author kg-bookmark-publisher kg-bookmark-thumbnail kg-callout-card kg-callout-emoji kg-callout-text kg-callout-card-grey kg-callout-card-white kg-callout-card-blue kg-callout-card-green kg-callout-card-yellow kg-callout-card-red kg-callout-card-pink kg-callout-card-purple kg-callout-card-accent
```

Sin esto, Discourse elimina todas las clases `kg-*` al extraer el contenido y las tarjetas llegan
como montones de divs sin estilo.

## Notas

El truncado y la eliminación de clases ocurren en la importación: el extracto se convierte en el post y el artículo
completo se guarda en `topic_embeds.embed_content_cache`. El componente lo obtiene por el mismo
endpoint `/posts/:id/expand-embed` que usa el botón, con caché en el servidor, así que tu blog no se
vuelve a rastrear. Si esa petición falla, el botón se deja en su lugar.

Tanto el ajuste anterior como `embed truncate` solo afectan a las importaciones **futuras**. Los temas ya
importados conservan en la base de datos su copia truncada y sin clases hasta que se reimporten con
`TopicEmbed.import` desde la consola de rails.

Las tarjetas no se convierten en oneboxes, a propósito: el onebox se ejecuta en el servidor al procesar (cook)
solo los enlaces `a.onebox`, por lo que convertir una tarjeta en onebox exigiría reescribir el HTML antes del cook,
es decir, un plugin y no un tema.

## Licencia

GPL-3.0. Consulta [LICENSE](LICENSE).

Texto de este README bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
