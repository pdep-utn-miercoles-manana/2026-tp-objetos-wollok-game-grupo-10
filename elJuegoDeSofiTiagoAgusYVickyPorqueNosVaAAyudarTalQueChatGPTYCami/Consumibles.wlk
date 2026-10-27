import BarraAcad.*
class Consumible{
  var property position=game.at(0, 0)
  const nombreArchivo
  const puntosAcademicos 
  const puntosEstres 
  
  method image() = "Consumibles/" + nombreArchivo + ".gif"
  method imagenInventario() = "Consumibles/" + nombreArchivo + "_mariokart.gif"
  
  method consumido() {
     barraAcademica.modificarNivelAcademico(puntosAcademicos)
     barraAcademica.modificarNivelEstres(puntosEstres)
  }

  method seleccionado() {
    if (inventario.hayLugar()){
          game.removeVisual(self)
          inventario.guardar(self)
  }
   else { 
      game.say(espacio1, "inventario lleno")
   }
  }
 }

const chocolate = new Consumible( nombreArchivo= "choco" , puntosAcademicos =10, puntosEstres=0)
const bestia = new Consumible(nombreArchivo= "energetica", puntosAcademicos=15, puntosEstres=5) 

object inventario {
  const property items = []

  method guardar(unItem) {
    if (items.size() < 2) {
      items.add(unItem)
    } else {
      game.say(espacio1, "Inventario lleno")
    }
  }

   method hayLugar() = items.size() < 2

  method consumir() {
    if (items.isEmpty()) {
      game.say(espacio1, "Inventario vacío") //lifo
    } else {
      const item = items.last()
      items.remove(item)
      item.consumido()
    }
  }
}

class EspacioInventario{
   var property position = game.at(0,0)
   const numero

   method image() =
    if (numero < inventario.items().size())
      inventario.items().get(numero).imagenInventario() // get me da lo de una posicion
    else
      "Consumibles/cuadrito_azul.png"
}

const espacio1 = new EspacioInventario(position = game.at(0, 0), numero = 0)
const espacio2 = new EspacioInventario(position = game.at(1, 0), numero = 1)