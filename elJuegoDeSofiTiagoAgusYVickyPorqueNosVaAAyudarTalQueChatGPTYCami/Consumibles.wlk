import wollok.game.*
import BarraAcad.*

class Consumible {
  var property position = game.at(0, 0)
  const nombreArchivo
  const puntosAcademicos
  const puntosEstres

  method image() = "textos/consumible_" + nombreArchivo + ".png" // la nota que se ve como opcion (F / G)
  method imagenInventario() = "Consumibles/" + nombreArchivo + "_mariokart.gif"

  method consumido() {
    barraAcademica.aplicar(puntosAcademicos, puntosEstres)
  }

  // si lo elegis en una ronda, va al inventario y pasa la proxima ronda
  method seleccionado(unModo) {
    inventario.guardar(self)
    unModo.presentarRonda()
  }
}

const chocolate = new Consumible(nombreArchivo = "choco", puntosAcademicos = 10, puntosEstres = 0)
const bestia = new Consumible(nombreArchivo = "energetica", puntosAcademicos = 15, puntosEstres = -20) // la energetica te baja el estres

// De aca sale el consumible que se ofrece como UNA de las dos opciones de una ronda.
object kiosco { // mejor nombre, mas especifico
  method consumibles() = [chocolate, bestia]

  method consumibleAlAzar() = self.consumibles().anyOne()
}

object inventario {
  var property items = []

  method guardar(unItem) {
    if (self.hayLugar()) {
      items.add(unItem)
    } else {
      game.say(espacio1, "Inventario lleno")
    }
  }

  method hayLugar() = items.size() < 2

  method vaciar() { items.clear() }

  method consumir() {
    if (items.isEmpty()) {
      game.say(espacio1, "Inventario vacío")
    } else {
      const item = items.last() // el ultimo que entro es el primero que sale
      items.remove(item)
      item.consumido()
    }
  }
}

class EspacioInventario {
  var property position = game.at(0, 0)
  const numeroPosicionInventario

  method image() =
    if (numeroPosicionInventario < inventario.items().size())
      inventario.items().get(numeroPosicionInventario).imagenInventario()
    else
      "Consumibles/cuadrito_azul.png"
}

const espacio1 = new EspacioInventario(position = game.at(26, 11), numeroPosicionInventario = 0)
const espacio2 = new EspacioInventario(position = game.at(29, 11), numeroPosicionInventario = 1)
