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

const chocolate = new Consumible(nombreArchivo = "choco", puntosAcademicos = 15, puntosEstres = -20)
const bestia = new Consumible(nombreArchivo = "energetica", puntosAcademicos = 25, puntosEstres = 10)

// De aca sale el consumible que se ofrece como UNA de las dos opciones de una ronda.
object sorteoDeConsumibles {
  const consumibles = [chocolate, bestia]

  method unoAlAzar() = consumibles.anyOne()
}

object inventario {
  const items = []

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

  method imagenDelEspacio(numero) =
    if (numero < items.size())
      items.get(numero).imagenInventario()
    else
      "Consumibles/cuadrito_azul.png"
}

class EspacioInventario {
  const property position
  const numeroPosicionInventario

  method image() = inventario.imagenDelEspacio(numeroPosicionInventario)
}

const espacio1 = new EspacioInventario(position = game.at(26, 11), numeroPosicionInventario = 0)
const espacio2 = new EspacioInventario(position = game.at(29, 11), numeroPosicionInventario = 1)
