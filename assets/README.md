# Fotos de la app

Todas las fotos van en `assets/images/`. Mientras un archivo no exista, la app
muestra una foto de internet como respaldo (ver `lib/widgets/app_image.dart`),
así que la app nunca se ve vacía. Apenas pongas el archivo con el nombre exacto
de esta lista, esa foto tuya reemplaza a la de respaldo sin tocar código.

Recomendado: JPG, ~800 x 600 px, menos de 300 KB cada una.

## Marca

| Archivo | Dónde se ve |
|---|---|
| `logo 1.png` | Splash, Login, Registro y encabezado de la app |
| `splash_bg.jpg` | Fondo del Splash |
| `login_bg.jpg` | Fondo de Login, Registro y Recuperar contraseña |
| `bienvenida.jpg` | Foto grande de bienvenida, arriba del Inicio |

Si cambias el archivo del logo, actualiza `BusinessInfo.logo` en
`lib/models/business_info.dart` — es el único sitio donde está la ruta.

El círculo del perfil no usa foto: muestra las iniciales del nombre del
cliente, así siempre se ve bien aunque no haya subido una imagen.

## Productos

El nombre del archivo es el `id` del producto en `lib/models/product.dart`.

### Hamburguesas
- `mini_clasica.jpg`
- `mini_bbq_doble.jpg`
- `mini_pollo_crispy.jpg`
- `mini_ranchera.jpg`
- `mini_hawaiana.jpg`

### Perros
- `perro_sencillo.jpg`
- `perro_especial.jpg`
- `perro_ranchero.jpg`

### Perras
- `perra_mixta.jpg`
- `perra_suprema.jpg`

### Salchipapas
- `salchipapa_clasica.jpg`
- `salchipapa_especial.jpg`
- `picada_casa.jpg`

### Arepa Burguer
- `arepa_burguer_clasica.jpg`
- `arepa_burguer_pollo.jpg`
- `arepa_burguer_mixta.jpg`

### Arepa rellena
- `arepa_rellena_carne.jpg`
- `arepa_rellena_pollo.jpg`
- `arepa_rellena_mixta.jpg`

### Chuzo
- `chuzo_carne.jpg`
- `chuzo_mixto.jpg`

## Agregar un producto nuevo

1. Copia la foto a `assets/images/` con un nombre en minúsculas y guiones bajos.
2. Agrega el `Product` en `lib/models/product.dart` con ese `imageAsset`,
   su `category` (debe ser una de `kCategorias`) y su `price`.
3. Listo: aparece solo en el Menú, en su categoría del Inicio y, si le pones
   `destacado: true`, también en el carrusel "Destacadas".
