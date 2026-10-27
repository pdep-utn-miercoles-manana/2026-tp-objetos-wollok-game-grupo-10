import Consumibles.*
import menu.*
import BarraAcad.*

 class Camino{
    var paresDeCaminos=[]
    var opcionesUsadas= []
    var opciones = []
    //NUEVO: reglas para ganar/perder (se pueden cambiar por dificultad: new Camino(limiteEstres = 80))
    const limiteEstres = 100
    const academicoParaAprobar = 70
    var esperandoEleccion = false //NUEVO: true mientras hay opciones en pantalla para elegir con F/G
   

  method izquierda() = opciones.first()
  method derecha() = opciones.last()

  method elegir(unLado){
    esperandoEleccion = false //NUEVO
    opciones.forEach({unaOpcion => game.removeVisual(unaOpcion)})
    unLado.seleccionado()
  }


  method guardarUnoRandom(){
    //var opcion1 =  paresDeCaminos.get(0.randomUpTo(paresDeCaminos.size())) //si no funca, usar randomize
    var opcion1 = paresDeCaminos.anyOne() //CAMBIADO: randomUpTo da decimales y get(decimal) falla al azar
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
  method reiniciar(){ //CAMBIADO (antes: reinciar)
     //paresDeCaminos = opcionesUsadas //No me gusta nada 
     //opcionesUsadas = []
     paresDeCaminos.addAll(opcionesUsadas) //NUEVO: vuelven las usadas + las que quedaban sin usar
     opcionesUsadas.clear()
     opciones.clear()
     esperandoEleccion = false
  }

  //NUEVO ---------------------------------------------------------------
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
  const descripcion
  const resultado

  const puntosAcademicos = 0
  const puntosEstres = 0
  const tiempoDeLectura = 2500 //NUEVO: ms que se ve el resultado antes de seguir
  var property position = game.origin() //NUEVO
  var mostrandoResultado = false //NUEVO

  method seleccionado(){
     barraAcademica.modificarNivelAcademico(puntosAcademicos)
     barraAcademica.modificarNivelEstres(puntosEstres)
     //game.tick(20, game.removeVisual(self), self.text(resultado)) //CAMBIADO: tick no se usa asi, ahora es schedule
     mostrandoResultado = true //NUEVO: ahora el texto que se dibuja es el resultado
     game.addVisual(self) //NUEVO: elegir() lo habia sacado, lo mostramos con el resultado
     game.schedule(tiempoDeLectura, { self.seguir() }) //NUEVO
     //modoDeJuego.caminoActual().presentarOpciones() //CAMBIADO: ahora se llama en seguir()


  }

  //NUEVO: pasado el tiempo de lectura saca el resultado y sigue con la proxima ronda
  method seguir() {
     game.removeVisual(self)
     mostrandoResultado = false
     modoDeJuego.caminoActual().presentarOpciones()
  }

  //method position(x,y) =game.at(x,y)
  method position(x,y) { position = game.at(x,y) } //CAMBIADO: ahora guarda la posicion
  method text(unTexto) = unTexto
  method text() = if (mostrandoResultado) resultado else descripcion //NUEVO: lo que se dibuja

}

const opcion1 = new Opcion(puntosAcademicos=50, descripcion="hola que tal",resultado="no me saludaron")
const opcion2 = new Opcion(puntosAcademicos=90, descripcion="hola ",resultado="me saludaron")