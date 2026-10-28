"""
Genera las imagenes de texto de las cartitas (assets/textos/*.png).

Wollok Game dibuja text() siempre a 12px, asi que el texto de las opciones
se muestra como imagen. Este script lee todos los `new Opcion(...)` de los
.wlk del proyecto y por cada uno con `nombre` genera:

    assets/textos/<nombre>_opcion.png      (descripcion)
    assets/textos/<nombre>_resultado.png   (resultado)

Como usarlo (cada vez que agreguen o cambien una opcion):
    pip install pillow
    python herramientas/generarTextos.py

Fuente: Gochi Hand (SIL Open Font License, ver OFL.txt).
"""

import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERRAMIENTAS = Path(__file__).resolve().parent
PROYECTO = HERRAMIENTAS.parent
SALIDA = PROYECTO / "assets" / "textos"
FUENTE = HERRAMIENTAS / "GochiHand-Regular.ttf"

# Tamaño de la imagen: 11 x 6 celdas de 40px. Se ubica con Nota.posicionDelTexto()
ANCHO, ALTO = 440, 240
ANCHO_MAX_TEXTO = 360  # margen para no tocar los bordes de la nota
ALTO_MAX_TEXTO = 210
TAMANIO_LETRA = 54  # si un texto no entra, se achica solo
TAMANIO_MINIMO = 24
INTERLINEADO = 10
COLOR_TINTA = (34, 34, 34, 255)
INCLINACION = 2  # grados, para que parezca escrito a mano (0 = derecho)


def buscar_opciones():
    """Devuelve [(nombre, descripcion, resultado)] de todos los new Opcion(...)."""
    opciones = []
    for archivo in sorted(PROYECTO.glob("*.wlk")):
        codigo = archivo.read_text(encoding="utf-8")
        for argumentos in argumentos_de_new_opcion(codigo):
            valores = dict(re.findall(r'(\w+)\s*=\s*"((?:[^"\\]|\\.)*)"', argumentos))
            if "nombre" not in valores:
                print(f"  (salteo un Opcion sin nombre en {archivo.name})")
                continue
            opciones.append((valores["nombre"], valores["descripcion"], valores["resultado"]))
    return opciones


def argumentos_de_new_opcion(codigo):
    """Texto entre los parentesis de cada `new Opcion(`, respetando strings y comentarios."""
    for inicio in re.finditer(r"new\s+Opcion\s*\(", codigo):
        if codigo.rfind("//", codigo.rfind("\n", 0, inicio.start()) + 1, inicio.start()) != -1:
            continue  # linea comentada
        i, nivel, en_string = inicio.end(), 1, False
        while i < len(codigo) and nivel > 0:
            c = codigo[i]
            if en_string:
                if c == "\\":
                    i += 1
                elif c == '"':
                    en_string = False
            elif c == '"':
                en_string = True
            elif c == "(":
                nivel += 1
            elif c == ")":
                nivel -= 1
            i += 1
        yield codigo[inicio.end():i - 1]


def partir_en_renglones(texto, fuente):
    renglones, actual = [], ""
    for palabra in texto.split():
        prueba = f"{actual} {palabra}".strip()
        if actual and fuente.getlength(prueba) > ANCHO_MAX_TEXTO:
            renglones.append(actual)
            actual = palabra
        else:
            actual = prueba
    renglones.append(actual)
    return "\n".join(renglones)


def generar_imagen(texto, destino):
    tamanio = TAMANIO_LETRA
    while True:
        fuente = ImageFont.truetype(str(FUENTE), tamanio)
        renglones = partir_en_renglones(texto, fuente)
        lienzo = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
        _, arriba, _, abajo = lienzo.multiline_textbbox(
            (0, 0), renglones, font=fuente, spacing=INTERLINEADO, align="center")
        ancho = max(fuente.getlength(renglon) for renglon in renglones.split("\n"))
        entra = ancho <= ANCHO_MAX_TEXTO and (abajo - arriba) <= ALTO_MAX_TEXTO
        if entra or tamanio <= TAMANIO_MINIMO:
            break
        tamanio -= 2

    imagen = Image.new("RGBA", (ANCHO, ALTO), (0, 0, 0, 0))
    ImageDraw.Draw(imagen).multiline_text(
        (ANCHO / 2, ALTO / 2), renglones, font=fuente, fill=COLOR_TINTA,
        anchor="mm", align="center", spacing=INTERLINEADO)
    if INCLINACION:
        imagen = imagen.rotate(INCLINACION, resample=Image.BICUBIC, center=(ANCHO / 2, ALTO / 2))
    imagen.save(destino)
    return tamanio


def main():
    SALIDA.mkdir(parents=True, exist_ok=True)
    opciones = buscar_opciones()
    generados = set()
    for nombre, descripcion, resultado in opciones:
        if nombre in generados:
            continue  # la misma opcion se crea una vez por dificultad
        generados.add(nombre)
        for sufijo, texto in (("opcion", descripcion), ("resultado", resultado)):
            destino = SALIDA / f"{nombre}_{sufijo}.png"
            tamanio = generar_imagen(texto, destino)
            print(f"  {destino.relative_to(PROYECTO)}  ({tamanio}px)  {texto}")
    print(f"Listo: {len(generados) * 2} imagenes en {SALIDA.relative_to(PROYECTO)}")


if __name__ == "__main__":
    main()
