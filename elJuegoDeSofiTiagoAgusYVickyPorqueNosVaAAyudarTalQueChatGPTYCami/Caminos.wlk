import Consumibles.*
import menu.*
import BarraAcad.*

 class Camino{
    var paresDeCaminos=[]
    var opcionesUsadas= []
    var opciones = []
    const limiteEstres = 100
    const academicoParaAprobar = 70
    var esperandoEleccion = false 
   

  method izquierda() = opciones.first()
  method derecha() = opciones.last()

  method elegir(unLado){
    esperandoEleccion = false //NUEVO
    opciones.forEach({unaOpcion => game.removeVisual(unaOpcion)})
    unLado.seleccionado()
  }


  method guardarUnoRandom(){
    var opcion1 = paresDeCaminos.anyOne()
    paresDeCaminos.remove(opcion1)
    opciones.add(opcion1)
    opcionesUsadas.add(opcion1)
  }

  method generarOpciones() {
    opciones.clear()
    self.guardarUnoRandom()
    self.guardarUnoRandom() // abrir la lista opciones y darles la posicon
    opciones.first().position(nota_rosa.posicionDelTexto())     // F -> nota rosa
    opciones.last().position(nota_amarilla.posicionDelTexto())  // G -> nota amarilla
  }

  //HACER FUNCION TERMINAR
  method reiniciar(){ 
     paresDeCaminos.addAll(opcionesUsadas) 
     opcionesUsadas.clear()
     opciones.clear()
     esperandoEleccion = false
  }

  method agregarOpciones(unasOpciones) { paresDeCaminos.addAll(unasOpciones) }
  method puedeElegir() = esperandoEleccion

  method perdioPorEstres() = barraAcademica.nivelEstres() >= limiteEstres
  method sinOpciones() = paresDeCaminos.size() < 2 // cada ronda gasta 2 opciones
  method aprobo() = barraAcademica.nivelAcademico() >= academicoParaAprobar

  // muestra la siguiente ronda de opciones o, si corresponde, termina el juego
  method presentarOpciones() {
    if (self.perdioPorEstres()) {
      self.terminar("¡Perdiste! Te estresaste demasiado")
    } else if (self.sinOpciones()) {
      if (self.aprobo()) {
        self.terminar("¡Ganaste! Te quedaste sin opciones pero aprobaste")
      } else {
        self.terminar("Perdiste: sin opciones y con poco nivel académico")
      }
    } else {
      if (not opcionesUsadas.isEmpty()) { regalos.sortear() } // en la 1ra ronda no se regala nada
      self.generarOpciones()
      opciones.forEach({unaOpcion => game.addVisual(unaOpcion)})
      esperandoEleccion = true
    }
  }

  method terminar(mensaje) {
    game.say(barraAcademica, mensaje)
    barraAcademica.terminar()
  }
}

const caminoFacil = new Camino () //Intentar De lograr modo historia y random

const caminoMedio = new Camino ()

const caminoDificil = new Camino()

//ESTO SON LAS FOTOS DE LAS ETIQUETAS//
class Nota{
  const color
  var property  position
  method image()="nota_" + color + ".gif"
  method posicionDelTexto() = position.right(1).up(4)
}
//-----------------------------------//


const nota_rosa = new Nota(color = "rosa", position = game.at(1,3))
const nota_amarilla = new Nota(color = "amarilla", position = game.at(12,3))


object modoDeJuego {
    var caminoActual = caminoFacil
    method cambiarA(unCamino){ caminoActual = unCamino
    unCamino.presentarOpciones() //NUEVO: arranca la partida
    game.removeVisual(menu)}

    method caminoActual() = caminoActual

    method resetear(){
        caminoActual.reiniciar()
    }

}

class Opcion{
  const nombre 
  const descripcion 
  const resultado

  const puntosAcademicos = 0
  const puntosEstres = 0
  const tiempoDeLectura = 2500 
  var property position = game.origin() 
  var mostrandoResultado = false 

  method seleccionado(){
     barraAcademica.modificarNivelAcademico(puntosAcademicos)
     barraAcademica.modificarNivelEstres(puntosEstres)
     mostrandoResultado = true // el texto que se dibuja es el resultado
     game.addVisual(self) 
     game.schedule(tiempoDeLectura, { self.seguir() }) 
     //modoDeJuego.caminoActual().presentarOpciones() 


  }

  method seguir() {
     game.removeVisual(self)
     mostrandoResultado = false
     modoDeJuego.caminoActual().presentarOpciones()
  }

  //method position(x,y) =game.at(x,y)
  method position(x,y) { position = game.at(x,y) } //CAMBIADO: ahora guarda la posicion
  method text(unTexto) = unTexto
  method image() = "textos/" + nombre + (if (mostrandoResultado) "_resultado" else "_opcion") + ".png"
  method descripcion() = descripcion
  method resultado() = resultado

}
