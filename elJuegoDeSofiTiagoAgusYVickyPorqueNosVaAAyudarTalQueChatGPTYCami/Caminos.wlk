import Consumibles.*
import menu.*
import BarraAcad.*

 class Camino{
    var paresDeCaminos=[]
    var opcionesUsadas= []
    var opciones = []
   

  method izquierda() = opciones.first()
  method derecha() = opciones.last()

  method elegir(unLado){
    opciones.forEach({unaOpcion => game.removeVisual(unaOpcion)})
    unLado.seleccionado()
  }


  method guardarUnoRandom(){
    var opcion1 =  paresDeCaminos.get(0.randomUpTo(paresDeCaminos.size())) //si no funca, usar randomize
    paresDeCaminos.remove(opcion1)
    opciones.add(opcion1)
    opcionesUsadas.add(opcion1)
  }

  method generarOpciones() {
    opciones.clear()
    self.guardarUnoRandom()
    self.guardarUnoRandom() // abrir la lista opciones y darles la posicon
    opciones.last().position(10, 5)
    opciones.first().position(5, 5)
  }
  //HACER FUNCION TERMINAR
}

const caminoFacil = new Camino () //Intentar De lograr modo historia y random

const caminoMedio = new Camino ()

const caminoDificil = new Camino()

//ESTO SON LAS FOTOS DE LAS ETIQUETAS//
class Nota{
  const color
  var property  position
  method image()="nota_" + color + ".gif"
}
//-----------------------------------//


const nota_rosa = new Nota(color = "rosa", position = game.at(1,3))
const nota_amarilla = new Nota(color = "amarilla", position = game.at(12,3))


object modoDeJuego {
    var caminoActual = caminoFacil
    method cambiarA(unCamino){ caminoActual = unCamino
    game.removeVisual(menu)}

    method caminoActual() = caminoActual

}

class Opcion{
  const descripcion
  const resultado

  const puntosAcademicos = 0
  const puntosEstres = 0

  method seleccionado(){
     barraAcademica.modificarNivelAcademico(puntosAcademicos)
     barraAcademica.modificarNivelEstres(puntosEstres)
     game.tick(20, game.removeVisual(self), self.text(resultado)) 

  }

  method position(x,y) =game.at(x,y)
  method text(unTexto) = unTexto

}

const opcion1 = new Opcion(puntosAcademicos=50, descripcion="hola que tal",resultado="no me saludaron")
const opcion1 = new Opcion(puntosAcademicos=90, descripcion="hola ",resultado="me saludaron")